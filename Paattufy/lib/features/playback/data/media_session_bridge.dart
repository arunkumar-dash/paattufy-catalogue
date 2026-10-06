import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../groups/data/group_providers.dart';
import '../../library/data/artwork_cache.dart';
import '../../library/data/library_providers.dart';
import 'audio_handler.dart';
import 'playback_controller.dart';

/// Mirrors the controller's state into the audio_service media session and
/// routes session commands back to the controller.
class MediaSessionBridge implements MediaSessionCommands {
  MediaSessionBridge(this._container, this._handler);

  final ProviderContainer _container;
  final PaattufyAudioHandler _handler;
  ProviderSubscription<PlaybackUiState>? _sub;
  int? _lastItemId;

  PlaybackController get _ctl => _container.read(playbackControllerProvider.notifier);

  void start() {
    _handler.commands = this;
    _sub = _container.listen<PlaybackUiState>(
      playbackControllerProvider,
      (prev, next) => _push(next),
      fireImmediately: true,
    );
  }

  Future<void> _push(PlaybackUiState s) async {
    if (s.currentItemId != _lastItemId) {
      _lastItemId = s.currentItemId;
      final song = s.current;
      if (song == null) {
        _handler.publishItem(null);
      } else {
        _handler.publishItem(MediaItem(
          id: song.id,
          title: song.title,
          artist: song.artist,
          album: song.album,
          duration: Duration(milliseconds: song.durationMs),
        ));
        unawaited(_attachArt(song.id, song.contentUri, song.title, song.artist, song.album,
            song.durationMs, s.currentItemId));
      }
    }
    _handler.publishState(
      playing: s.playing,
      loading: s.loading,
      hasQueue: s.current != null,
      position: _container.read(audioEngineProvider).position,
      speed: s.speed,
    );
  }

  /// Artwork loads lazily to a cached file, then the item is re-published
  /// with `artUri` (AP §2 "lazy artwork", §8.13).
  Future<void> _attachArt(String id, String contentUri, String title, String artist,
      String album, int durationMs, int? itemId) async {
    final file = await _container.read(artworkCacheProvider).file(contentUri);
    if (file == null || _lastItemId != itemId) return;
    _handler.publishItem(MediaItem(
      id: id,
      title: title,
      artist: artist,
      album: album,
      duration: Duration(milliseconds: durationMs),
      artUri: Uri.file(file.path),
    ));
  }

  void dispose() {
    _sub?.close();
    _handler.commands = null;
  }

  @override
  Future<void> onPlay() => _ctl.play();
  @override
  Future<void> onPause() => _ctl.pause();
  @override
  Future<void> onStop() => _ctl.pause();
  @override
  Future<void> onSkipNext() => _ctl.skipNext();
  @override
  Future<void> onSkipPrevious() => _ctl.skipPrevious();
  @override
  Future<void> onSeek(Duration position) => _ctl.seek(position);

  @override
  Future<void> onCustom(String name) async {
    switch (name) {
      case 'toggleShuffle':
        await _ctl.toggleShuffle();
      case 'cycleRepeat':
        await _ctl.cycleRepeat();
    }
  }

  // --- Android Auto browse tree: Queue · Groups · Library -------------------

  static const _root = AudioService.browsableRootId;

  MediaItem _folder(String id, String title) => MediaItem(id: id, title: title, playable: false);

  MediaItem _song(dynamic s) => MediaItem(
        id: 'song:${s.id}',
        title: s.title as String,
        artist: s.artist as String,
        album: s.album as String,
        duration: Duration(milliseconds: s.durationMs as int),
        playable: true,
      );

  @override
  Future<List<MediaItem>> onBrowse(String parentMediaId) async {
    if (parentMediaId == _root) {
      return [_folder('queue', 'Queue'), _folder('groups', 'Groups'), _folder('library', 'All songs')];
    }
    if (parentMediaId == 'queue') {
      final snap = await _container.read(queueRepositoryProvider).snapshot();
      return [for (final e in snap.entries) _song(e.song)];
    }
    if (parentMediaId == 'groups') {
      final groups = await _container.read(groupRepositoryProvider).watchSummaries().first;
      return [for (final g in groups) _folder('group:${g.group.id}', '${g.group.name} (${g.songCount})')];
    }
    if (parentMediaId.startsWith('group:')) {
      final id = int.tryParse(parentMediaId.substring(6));
      if (id == null) return const [];
      final songs = await _container.read(groupRepositoryProvider).songsIn(id);
      return [for (final s in songs.take(200)) _song(s)];
    }
    if (parentMediaId == 'library') {
      final songs = await _container.read(libraryRepositoryProvider).allVisibleSongs();
      return [for (final s in songs.take(300)) _song(s)];
    }
    return const [];
  }

  @override
  Future<void> onPlayFromMediaId(String mediaId) async {
    if (!mediaId.startsWith('song:')) return;
    final song = await _container.read(libraryRepositoryProvider).songById(mediaId.substring(5));
    if (song != null) await _ctl.playSong(song);
  }
}
