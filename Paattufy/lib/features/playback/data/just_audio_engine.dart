import 'dart:async';

import 'package:just_audio/just_audio.dart';

import '../domain/audio_engine.dart';

/// [AudioEngine] backed by a single just_audio [AudioPlayer] (AP §2: one
/// player instance). Uses `AudioSource.uri` on the MediaStore content URI, so
/// audio is passed through untouched — bit-perfect, never re-encoded.
class JustAudioEngine implements AudioEngine {
  JustAudioEngine()
      : _loudness = AndroidLoudnessEnhancer() {
    _player = AudioPlayer(
      audioPipeline: AudioPipeline(androidAudioEffects: [_loudness]),
    );
    _loudness.setEnabled(false);
  }

  late final AudioPlayer _player;
  final AndroidLoudnessEnhancer _loudness;
  List<int> _ids = [];

  AudioPlayer get player => _player;

  AudioSource _source(EngineTrack t) => AudioSource.uri(
        Uri.parse(t.song.contentUri),
        tag: t.queueItemId,
      );

  @override
  List<int> get loadedQueueItemIds => List.unmodifiable(_ids);

  @override
  Future<void> setTracks(
    List<EngineTrack> tracks, {
    required int index,
    Duration position = Duration.zero,
  }) async {
    _ids = tracks.map((t) => t.queueItemId).toList();
    if (tracks.isEmpty) {
      await _player.stop();
      await _player.setAudioSources(const []);
      return;
    }
    await _player.setAudioSources(
      tracks.map(_source).toList(),
      initialIndex: index,
      initialPosition: position,
    );
  }

  @override
  Future<void> insertTracks(int index, List<EngineTrack> tracks) async {
    _ids.insertAll(index, tracks.map((t) => t.queueItemId));
    await _player.insertAudioSources(index, tracks.map(_source).toList());
  }

  @override
  Future<void> removeTrackAt(int index) async {
    _ids.removeAt(index);
    await _player.removeAudioSourceAt(index);
  }

  @override
  Future<void> moveTrack(int from, int to) async {
    final id = _ids.removeAt(from);
    _ids.insert(to, id);
    await _player.moveAudioSource(from, to);
  }

  /// just_audio's `play()` only completes when playback pauses, stops or
  /// finishes — awaiting it would block every caller for the length of the
  /// song. Kick it off and return; state changes arrive via [playingStream].
  @override
  Future<void> play() async {
    unawaited(_player.play().catchError((Object _) {}));
  }
  @override
  Future<void> pause() => _player.pause();
  @override
  Future<void> stop() => _player.stop();
  @override
  Future<void> seek(Duration position, {int? index}) =>
      _player.seek(position, index: index);
  @override
  Future<void> seekToNext() => _player.seekToNext();
  @override
  Future<void> seekToPrevious() => _player.seekToPrevious();

  @override
  Future<void> setSpeed(double speed) => _player.setSpeed(speed);
  @override
  Future<void> setPitch(double pitch) => _player.setPitch(pitch);
  @override
  Future<void> setRepeatMode(RepeatMode mode) => _player.setLoopMode(
        switch (mode) {
          RepeatMode.off => LoopMode.off,
          RepeatMode.all => LoopMode.all,
          RepeatMode.one => LoopMode.one,
        },
      );
  @override
  Future<void> setSkipSilence(bool enabled) =>
      _player.setSkipSilenceEnabled(enabled);

  @override
  Future<void> setVolume(double volume) => _player.setVolume(volume.clamp(0.0, 1.0));

  @override
  Future<void> setVolumeNormalisation(bool enabled) =>
      _loudness.setEnabled(enabled);

  @override
  Future<void> setTrackGainDb(double gainDb) =>
      _loudness.setTargetGain(gainDb.clamp(-10.0, 10.0));

  @override
  int? get currentIndex => _player.currentIndex;
  @override
  Duration get position => _player.position;
  @override
  Duration? get duration => _player.duration;
  @override
  bool get playing => _player.playing;
  @override
  int? get audioSessionId => _player.androidAudioSessionId;

  @override
  Stream<int?> get currentIndexStream => _player.currentIndexStream;
  @override
  Stream<bool> get playingStream => _player.playingStream;
  @override
  Stream<Duration> get positionStream => _player.positionStream;
  @override
  Stream<Duration?> get durationStream => _player.durationStream;
  @override
  Stream<EngineState> get stateStream => _player.processingStateStream.map(
        (s) => switch (s) {
          ProcessingState.idle => EngineState.idle,
          ProcessingState.loading => EngineState.loading,
          ProcessingState.buffering => EngineState.buffering,
          ProcessingState.ready => EngineState.ready,
          ProcessingState.completed => EngineState.completed,
        },
      );

  @override
  Future<void> dispose() => _player.dispose();
}
