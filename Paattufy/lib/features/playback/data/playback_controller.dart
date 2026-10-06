import 'dart:async';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/constants.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/settings/app_settings.dart';
import '../../library/data/library_providers.dart';
import '../../queue/data/queue_repository.dart';
import '../../queue/domain/queue_models.dart';
import '../domain/audio_engine.dart';
import '../domain/queue_sync_plan.dart';
import 'play_stats_repository.dart';

/// Hook invoked after queue changes so the suggestion engine can top the
/// queue up to 10 upcoming songs (AP §3.4). Wired in Phase 5.
typedef QueueTopUp = Future<void> Function();

class PlaybackUiState {
  const PlaybackUiState({
    this.current,
    this.currentItemId,
    this.playing = false,
    this.loading = false,
    this.duration = Duration.zero,
    this.speed = 1.0,
    this.preservePitch = false,
    this.repeat = RepeatMode.off,
    this.shuffle = false,
    this.route = 'speaker',
    this.stoppedByRouteChange = false,
    this.ready = false,
  });

  final Song? current;
  final int? currentItemId;
  final bool playing;
  final bool loading;
  final Duration duration;
  final double speed;
  final bool preservePitch;
  final RepeatMode repeat;
  final bool shuffle;
  final String route;

  /// True after an output-device change stopped playback: the UI shows a
  /// "Resume" affordance that just calls play() (AP §3.6).
  final bool stoppedByRouteChange;

  /// Startup restore finished (queue re-read, engine primed).
  final bool ready;

  PlaybackUiState copyWith({
    Object? current = _unset,
    Object? currentItemId = _unset,
    bool? playing,
    bool? loading,
    Duration? duration,
    double? speed,
    bool? preservePitch,
    RepeatMode? repeat,
    bool? shuffle,
    String? route,
    bool? stoppedByRouteChange,
    bool? ready,
  }) {
    return PlaybackUiState(
      current: identical(current, _unset) ? this.current : current as Song?,
      currentItemId:
          identical(currentItemId, _unset) ? this.currentItemId : currentItemId as int?,
      playing: playing ?? this.playing,
      loading: loading ?? this.loading,
      duration: duration ?? this.duration,
      speed: speed ?? this.speed,
      preservePitch: preservePitch ?? this.preservePitch,
      repeat: repeat ?? this.repeat,
      shuffle: shuffle ?? this.shuffle,
      route: route ?? this.route,
      stoppedByRouteChange: stoppedByRouteChange ?? this.stoppedByRouteChange,
      ready: ready ?? this.ready,
    );
  }

  static const _unset = Object();
}

final audioEngineProvider = Provider<AudioEngine>(
  (ref) => throw UnimplementedError('audioEngineProvider must be overridden'),
);

final queueRepositoryProvider =
    Provider<QueueRepository>((ref) => QueueRepository(ref.watch(databaseProvider)));

final playStatsRepositoryProvider =
    Provider<PlayStatsRepository>((ref) => PlayStatsRepository(ref.watch(databaseProvider)));

final queueTopUpProvider = Provider<QueueTopUp?>((ref) => null);

final randomProvider = Provider<Random>((ref) => Random());

/// Owns the playback session (TP §5.4): the DB queue is the source of truth,
/// the engine is kept in step with minimal edits, and pointer/position are
/// persisted so everything survives process death.
class PlaybackController extends Notifier<PlaybackUiState> {
  late final AudioEngine _engine = ref.read(audioEngineProvider);
  late final QueueRepository _queue = ref.read(queueRepositoryProvider);
  late final PlayStatsRepository _stats = ref.read(playStatsRepositoryProvider);
  late final AppDatabase _db = ref.read(databaseProvider);
  late final Random _random = ref.read(randomProvider);

  final List<StreamSubscription<Object?>> _subs = [];
  Future<void> _lock = Future.value();
  int _syncDepth = 0;
  bool get _syncing => _syncDepth > 0;
  bool _engineLoaded = false;
  DateTime _lastPositionWrite = DateTime.fromMillisecondsSinceEpoch(0);
  Duration _maxPosition = Duration.zero;
  Song? _trackedSong;

  @override
  PlaybackUiState build() {
    ref.onDispose(() {
      for (final s in _subs) {
        s.cancel();
      }
    });
    return const PlaybackUiState();
  }

  AppSettings get _settings => ref.read(settingsProvider);

  Future<T> _serial<T>(Future<T> Function() body) {
    final completer = Completer<T>();
    _lock = _lock.then((_) async {
      try {
        completer.complete(await body());
      } catch (e, st) {
        completer.completeError(e, st);
      }
    });
    return completer.future;
  }

  // --- startup ------------------------------------------------------------

  /// Restores queue, pointer, position and modes before the first frame
  /// (AP §2 "Resume exactly where you left off").
  Future<void> init() => _serial(() async {
        final row = await (_db.select(_db.playbackStates)..where((t) => t.id.equals(1))).getSingle();
        final repeat = RepeatMode.values[row.repeatMode.clamp(0, 2)];
        state = state.copyWith(
          speed: row.speed,
          preservePitch: row.preservePitch,
          repeat: repeat,
          shuffle: row.shuffleEnabled,
          route: row.outputRoute,
        );
        await _applyModes();

        final snap = await _queue.snapshot();
        if (_settings.resumeOnLaunch && snap.current != null) {
          await _loadEngine(snap, position: Duration(milliseconds: row.positionMs));
          state = state.copyWith(
            current: snap.current!.song,
            currentItemId: snap.currentItemId,
            duration: Duration(milliseconds: snap.current!.song.durationMs),
          );
        }
        _subscribe();
        state = state.copyWith(ready: true);
      });

  void _subscribe() {
    _subs
      ..add(_engine.currentIndexStream.listen(_onIndexChanged))
      ..add(_engine.playingStream.listen(_onPlayingChanged))
      ..add(_engine.positionStream.listen(_onPosition))
      ..add(_engine.durationStream.listen((d) {
        if (d != null) state = state.copyWith(duration: d);
      }))
      ..add(_engine.stateStream.listen((s) {
        state = state.copyWith(loading: s == EngineState.loading || s == EngineState.buffering);
        if (s == EngineState.completed) {
          unawaited(_serial(() => _finishTracking(skipped: false)));
        }
      }));
  }

  Future<void> _applyModes() async {
    await _engine.setSpeed(state.speed);
    await _engine.setPitch(state.preservePitch ? 1.0 : state.speed);
    await _engine.setRepeatMode(state.repeat);
    await _engine.setSkipSilence(_settings.skipSilence);
    await _engine.setVolumeNormalisation(_settings.volumeNormalisation);
  }

  Future<void> _loadEngine(QueueSnapshot snap, {Duration position = Duration.zero}) async {
    _syncDepth++;
    try {
      final idx = snap.currentIndex < 0 ? 0 : snap.currentIndex;
      await _engine.setTracks(
        [for (final e in snap.entries) EngineTrack(e.id, e.song)],
        index: idx,
        position: position,
      );
      _engineLoaded = snap.entries.isNotEmpty;
    } finally {
      _syncDepth--;
    }
  }

  // --- engine events --------------------------------------------------------

  Future<void> _onIndexChanged(int? index) async {
    if (_syncing || index == null) return;
    final ids = _engine.loadedQueueItemIds;
    if (index < 0 || index >= ids.length) return;
    final itemId = ids[index];
    if (itemId == state.currentItemId) return;
    await _serial(() async {
      // Re-check under the lock: a verb that just ran may already have moved
      // the pointer to this item (seek(index:) echoes back as an event).
      if (itemId == state.currentItemId) return;
      await _finishTracking(skipped: false);
      await _queue.setPointer(itemId);
      final snap = await _queue.snapshot();
      _beginTracking(itemId, snap.current?.song);
      state = state.copyWith(
        current: snap.current?.song,
        currentItemId: itemId,
        duration: Duration(milliseconds: snap.current?.song.durationMs ?? 0),
        stoppedByRouteChange: false,
      );
      await _persistPosition(Duration.zero, force: true);
      await _afterQueueChange(snap);
    });
  }

  void _onPlayingChanged(bool playing) {
    state = state.copyWith(playing: playing);
    unawaited(_persistPlaying(playing));
  }

  double _lastVolume = 1.0;

  /// Soft fade (Settings → Playback): fades out the last seconds of a song and
  /// fades in the first ones. True overlapping crossfade isn't available in
  /// the single-player stack, so this is the honest approximation.
  void _applyFade(Duration p) {
    final enabled = _settings.crossfade;
    var v = 1.0;
    if (enabled) {
      final total = state.duration;
      final fadeOut = const Duration(seconds: 3);
      final fadeIn = const Duration(seconds: 2);
      if (total > fadeOut * 2 && total - p < fadeOut) {
        v = ((total - p).inMilliseconds / fadeOut.inMilliseconds).clamp(0.0, 1.0);
      } else if (p < fadeIn) {
        v = (0.25 + 0.75 * p.inMilliseconds / fadeIn.inMilliseconds).clamp(0.0, 1.0);
      }
    }
    if ((v - _lastVolume).abs() >= 0.05 || (v == 1.0 && _lastVolume != 1.0)) {
      _lastVolume = v;
      unawaited(_engine.setVolume(v));
    }
  }

  void _onPosition(Duration p) {
    _applyFade(p);
    if (p > _maxPosition) _maxPosition = p;
    final now = DateTime.now();
    if (now.difference(_lastPositionWrite) >= const Duration(seconds: 1) && state.playing) {
      _lastPositionWrite = now;
      unawaited(_persistPosition(p));
    }
  }

  // --- stats ------------------------------------------------------------------

  void _beginTracking(int? itemId, Song? song) {
    _trackedSong = song;
    _maxPosition = Duration.zero;
    if (song != null) {
      unawaited(_stats.recordPlayStarted(song.id, DateTime.now()));
    }
  }

  /// Called when leaving a track: counts a play if it was listened to for
  /// ≥ 30 s or ≥ 50 %, otherwise (when user-initiated) counts a skip.
  Future<void> _finishTracking({required bool skipped}) async {
    final song = _trackedSong;
    if (song == null) return;
    final total = Duration(milliseconds: song.durationMs);
    final threshold = total.inMilliseconds == 0
        ? const Duration(seconds: 30)
        : Duration(
            milliseconds: min(const Duration(seconds: 30).inMilliseconds, total.inMilliseconds ~/ 2));
    if (_maxPosition >= threshold) {
      await _stats.recordPlayCompleted(song.id);
    } else if (skipped) {
      await _stats.recordSkip(song.id);
    }
    _trackedSong = null;
  }

  // --- persistence --------------------------------------------------------------

  Future<void> _persistPosition(Duration p, {bool force = false}) =>
      (_db.update(_db.playbackStates)..where((t) => t.id.equals(1))).write(
        PlaybackStatesCompanion(
          positionMs: Value(p.inMilliseconds),
          updatedAt: Value(DateTime.now()),
        ),
      );

  Future<void> _persistPlaying(bool playing) =>
      (_db.update(_db.playbackStates)..where((t) => t.id.equals(1))).write(
        PlaybackStatesCompanion(isPlaying: Value(playing), updatedAt: Value(DateTime.now())),
      );

  Future<void> _persistModes() =>
      (_db.update(_db.playbackStates)..where((t) => t.id.equals(1))).write(
        PlaybackStatesCompanion(
          speed: Value(state.speed),
          preservePitch: Value(state.preservePitch),
          repeatMode: Value(state.repeat.index),
          shuffleEnabled: Value(state.shuffle),
          outputRoute: Value(state.route),
          updatedAt: Value(DateTime.now()),
        ),
      );

  /// Immediate flush on pause / stop / app-background (AP §3.5).
  Future<void> flushState() async {
    await _persistPosition(_engine.position, force: true);
    await _persistPlaying(_engine.playing);
    await _persistModes();
  }

  // --- queue verbs (AP §3.4) ----------------------------------------------------

  /// Play a single song: clears the queue.
  Future<void> playSong(Song song) =>
      _replaceAndPlay(() => _queue.playSingle(song, description: 'Song'));

  /// Play a list (group / album / folder). [shuffle] randomises the order.
  Future<void> playSongs(
    List<Song> songs, {
    int startIndex = 0,
    bool shuffle = false,
    String description = '',
  }) {
    if (songs.isEmpty) return Future.value();
    var list = songs;
    var start = startIndex;
    if (shuffle) {
      list = [...songs]..shuffle(_random);
      start = 0;
    }
    return _replaceAndPlay(
      () => _queue.replaceWith(list, startIndex: start, description: description),
      shuffleFlag: shuffle ? true : null,
    );
  }

  /// Play a new song while something plays: front of the queue, now.
  Future<void> playNow(Song song) => _serial(() async {
        await _finishTracking(skipped: true);
        final snap = await _queue.playNow(song);
        await _syncEngineLocked(snap, seekToCurrent: true);
        _publishCurrent(snap);
        await _engine.play();
        await _afterQueueChange(snap);
      });

  Future<void> playNext(List<Song> songs) => _serial(() async {
        final snap = await _queue.playNext(songs);
        await _afterMutation(snap);
      });

  Future<void> addToQueue(List<Song> songs) => _serial(() async {
        final snap = await _queue.addToQueue(songs);
        await _afterMutation(snap);
      });

  Future<void> removeFromQueue(int itemId) => _serial(() async {
        final before = await _queue.snapshot();
        final wasCurrent = before.currentItemId == itemId;
        final snap = await _queue.remove(itemId);
        if (wasCurrent) await _finishTracking(skipped: true);
        await _syncEngineLocked(snap, seekToCurrent: wasCurrent);
        if (wasCurrent) _publishCurrent(snap);
        await _afterQueueChange(snap);
      });

  /// [toIndex] is the index in the final list (after removal of the item).
  Future<void> reorder(int itemId, int toIndex) => _serial(() async {
        final snap = await _queue.move(itemId, toIndex);
        await _afterMutation(snap);
      });

  Future<void> clearQueue() => _serial(() async {
        await _queue.clear();
        await _engine.stop();
        await _engine.setTracks(const [], index: 0);
        _engineLoaded = false;
        _trackedSong = null;
        state = state.copyWith(current: null, currentItemId: null, playing: false, duration: Duration.zero);
      });

  /// Jump to an item (tap a row in the queue).
  Future<void> playItem(int itemId) => _serial(() async {
        final snap = await _queue.snapshot();
        final idx = snap.entries.indexWhere((e) => e.id == itemId);
        if (idx < 0) return;
        await _finishTracking(skipped: true);
        await _queue.setPointer(itemId);
        final fresh = await _queue.snapshot();
        await _syncEngineLocked(fresh, seekToCurrent: true);
        _publishCurrent(fresh);
        await _engine.play();
        await _afterQueueChange(fresh);
      });

  Future<void> keepSuggested(int itemId) => _queue.keepSuggested(itemId);

  /// "Not interested": removes it and penalises it as a skip.
  Future<void> dismissSuggested(int itemId) async {
    final snap = await _queue.snapshot();
    final entry = snap.entries.where((e) => e.id == itemId).firstOrNull;
    if (entry != null) await _stats.recordSkip(entry.song.id);
    await removeFromQueue(itemId);
  }

  Future<void> _replaceAndPlay(
    Future<QueueSnapshot> Function() mutate, {
    bool? shuffleFlag,
  }) =>
      _serial(() async {
        await _finishTracking(skipped: true);
        final snap = await mutate();
        if (shuffleFlag != null && shuffleFlag != state.shuffle) {
          state = state.copyWith(shuffle: shuffleFlag);
          await _persistModes();
        }
        await _loadEngine(snap);
        _publishCurrent(snap);
        state = state.copyWith(stoppedByRouteChange: false);
        await _engine.play();
        await _afterQueueChange(snap);
      });

  void _publishCurrent(QueueSnapshot snap) {
    state = state.copyWith(
      current: snap.current?.song,
      currentItemId: snap.currentItemId,
      duration: Duration(milliseconds: snap.current?.song.durationMs ?? 0),
    );
    _beginTracking(snap.currentItemId, snap.current?.song);
  }

  /// Manual queue edits drop the suggestions after the pointer; the top-up
  /// then recomputes them from the changed queue ("dropped/recomputed when the
  /// user changes the queue meaningfully", AP §3.4).
  Future<void> _afterMutation(QueueSnapshot snap) async {
    if (ref.read(queueTopUpProvider) != null) {
      await _queue.dropUpcomingSuggested();
      snap = await _queue.snapshot();
    }
    await _syncEngineLocked(snap);
    await _afterQueueChange(snap);
  }

  /// Applies the minimal edit script so the loaded queue matches the DB.
  Future<void> _syncEngineLocked(QueueSnapshot snap, {bool seekToCurrent = false}) async {
    _syncDepth++;
    try {
      if (!_engineLoaded) {
        if (snap.entries.isEmpty) return;
        await _loadEngine(snap);
        return;
      }
      final byId = {for (final e in snap.entries) e.id: e.song};
      final ops = planQueueSync(_engine.loadedQueueItemIds, snap.entries.map((e) => e.id).toList());
      for (final op in ops) {
        switch (op) {
          case RemoveOp(:final index):
            await _engine.removeTrackAt(index);
          case InsertOp(:final index, :final id):
            await _engine.insertTracks(index, [EngineTrack(id, byId[id]!)]);
          case MoveOp(:final from, :final to):
            await _engine.moveTrack(from, to);
        }
      }
      if (seekToCurrent && snap.currentIndex >= 0) {
        await _engine.seek(Duration.zero, index: snap.currentIndex);
      }
    } finally {
      _syncDepth--;
    }
  }

  /// Shuffle toggling / top-up after any queue change.
  Future<void> _afterQueueChange(QueueSnapshot snap) async {
    final topUp = ref.read(queueTopUpProvider);
    if (topUp != null && snap.upcomingCount < queueTopUpTarget) {
      await topUp();
      await _syncEngineLocked(await _queue.snapshot());
    }
  }

  /// Called by the suggestion engine after it appended to the DB queue.
  Future<void> resyncEngine() => _serial(() async {
        await _syncEngineLocked(await _queue.snapshot());
      });

  // --- transport -------------------------------------------------------------------

  Future<void> play() => _serial(() async {
        if (!_engineLoaded) {
          final snap = await _queue.snapshot();
          if (snap.entries.isEmpty) return;
          final row = await (_db.select(_db.playbackStates)..where((t) => t.id.equals(1))).getSingle();
          await _loadEngine(snap, position: Duration(milliseconds: row.positionMs));
          _publishCurrent(snap);
        }
        state = state.copyWith(stoppedByRouteChange: false);
        if (_trackedSong == null && state.current != null) {
          _beginTracking(state.currentItemId, state.current);
        }
        await _engine.play();
      });

  Future<void> pause() async {
    await _engine.pause();
    await flushState();
  }

  Future<void> togglePlayPause() => state.playing ? pause() : play();

  Future<void> seek(Duration position) => _engine.seek(position);

  Future<void> skipNext() => _serial(() async {
        final snap = await _queue.snapshot();
        final idx = snap.currentIndex;
        if (idx < 0) return;
        if (idx + 1 < snap.entries.length) {
          await _finishTracking(skipped: true);
          await _queue.setPointer(snap.entries[idx + 1].id);
          final fresh = await _queue.snapshot();
          await _engine.seek(Duration.zero, index: idx + 1);
          _publishCurrent(fresh);
          await _afterQueueChange(fresh);
        } else if (state.repeat == RepeatMode.all && snap.entries.isNotEmpty) {
          await _finishTracking(skipped: true);
          await _queue.setPointer(snap.entries.first.id);
          await _engine.seek(Duration.zero, index: 0);
          _publishCurrent(await _queue.snapshot());
        } else {
          await _engine.seek(_engine.duration ?? Duration.zero);
        }
      });

  /// If more than the skip-back window into the song, restart it; otherwise
  /// go to the previous item — never more than one back (AP §3.4, §11.11).
  Future<void> skipPrevious() => _serial(() async {
        final snap = await _queue.snapshot();
        final idx = snap.currentIndex;
        if (idx < 0) return;
        final window = Duration(milliseconds: _settings.skipBackWindowMs);
        if (_engine.position > window || idx == 0) {
          await _engine.seek(Duration.zero);
          return;
        }
        await _finishTracking(skipped: false);
        await _queue.setPointer(snap.entries[idx - 1].id);
        await _engine.seek(Duration.zero, index: idx - 1);
        _publishCurrent(await _queue.snapshot());
      });

  // --- modes -------------------------------------------------------------------------

  Future<void> setSpeed(double speed) async {
    state = state.copyWith(speed: speed);
    await _engine.setSpeed(speed);
    await _engine.setPitch(state.preservePitch ? 1.0 : speed);
    await _persistModes();
  }

  /// Preserve-pitch off (default): pitch drifts with speed (cheapest); on:
  /// pitch is held at 1.0 (TP §5.4).
  Future<void> setPreservePitch(bool preserve) async {
    state = state.copyWith(preservePitch: preserve);
    await _engine.setPitch(preserve ? 1.0 : state.speed);
    await _persistModes();
  }

  Future<void> cycleRepeat() async {
    final next = state.repeat.next;
    state = state.copyWith(repeat: next);
    await _engine.setRepeatMode(next);
    await _persistModes();
  }

  Future<void> toggleShuffle() => _serial(() async {
        final enable = !state.shuffle;
        state = state.copyWith(shuffle: enable);
        await _persistModes();
        if (enable) {
          final snap = await _queue.shuffleUpcoming(_random);
          await _syncEngineLocked(snap);
        }
      });

  /// Re-reads the queue/pointer from the database into the engine — used after
  /// a backup restore replaced them underneath the running session.
  Future<void> reloadFromDatabase() => _serial(() async {
        await _engine.stop();
        _engineLoaded = false;
        final snap = await _queue.snapshot();
        if (snap.entries.isEmpty) {
          state = state.copyWith(current: null, currentItemId: null, playing: false, duration: Duration.zero);
          return;
        }
        await _loadEngine(snap);
        _publishCurrent(snap);
      });

  Future<void> applyAudioSettings() async {
    await _engine.setSkipSilence(_settings.skipSilence);
    await _engine.setVolumeNormalisation(_settings.volumeNormalisation);
  }

  // --- output route (AP §3.6) -----------------------------------------------------------

  /// Every route change **stops** playback (never pause) and preserves queue
  /// and position, so one tap on play resumes exactly there.
  Future<void> handleRouteChange(String newRoute) => _serial(() async {
        final wasPlaying = _engine.playing;
        await _persistPosition(_engine.position, force: true);
        state = state.copyWith(route: newRoute, playing: false, stoppedByRouteChange: wasPlaying || state.stoppedByRouteChange);
        await _persistModes();
        await _engine.stop();
        // `stop()` releases the engine's resources; the next play() reloads
        // at the saved position.
        _engineLoaded = false;
        await _persistPlaying(false);
      });
}

final playbackControllerProvider =
    NotifierProvider<PlaybackController, PlaybackUiState>(PlaybackController.new);

/// Live position for the seek bar.
final positionProvider = StreamProvider<Duration>(
  (ref) => ref.watch(audioEngineProvider).positionStream,
);

final queueSnapshotProvider = StreamProvider<QueueSnapshot>(
  (ref) => ref.watch(queueRepositoryProvider).watch(),
);

final isFavouriteProvider = StreamProvider.family<bool, String>(
  (ref, songId) => ref.watch(playStatsRepositoryProvider).watchFavourite(songId),
);

/// Re-exported for convenience in UI code.
final songsLookupProvider = Provider<Future<List<Song>> Function(Iterable<String>)>(
  (ref) => ref.watch(libraryRepositoryProvider).songsByIds,
);
