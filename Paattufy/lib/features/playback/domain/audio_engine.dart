import '../../../core/entities/entities.dart';

/// 0 = off, 1 = repeat queue, 2 = repeat one (AP §3.5, §11.12).
enum RepeatMode { off, all, one }

extension RepeatModeCycle on RepeatMode {
  /// off → repeat-queue → repeat-one → off.
  RepeatMode get next => RepeatMode.values[(index + 1) % RepeatMode.values.length];
}

enum EngineState { idle, loading, buffering, ready, completed }

/// One loaded item: a queue row id paired with its song.
class EngineTrack {
  const EngineTrack(this.queueItemId, this.song);
  final int queueItemId;
  final Song song;
}

/// Platform-independent audio engine. The production implementation wraps
/// just_audio; tests use an in-memory fake, so all queue/skip/persistence
/// logic in `PlaybackController` is unit-testable.
abstract class AudioEngine {
  // Transport
  Future<void> play();
  Future<void> pause();

  /// Stops playback and releases the audio focus / foreground service, but
  /// keeps the loaded tracks and position (used for route changes, AP §3.6).
  Future<void> stop();
  Future<void> seek(Duration position, {int? index});
  Future<void> seekToNext();
  Future<void> seekToPrevious();

  // Queue
  Future<void> setTracks(
    List<EngineTrack> tracks, {
    required int index,
    Duration position = Duration.zero,
  });
  Future<void> insertTracks(int index, List<EngineTrack> tracks);
  Future<void> removeTrackAt(int index);
  Future<void> moveTrack(int from, int to);
  List<int> get loadedQueueItemIds;

  // Modes
  Future<void> setSpeed(double speed);
  Future<void> setPitch(double pitch);
  Future<void> setRepeatMode(RepeatMode mode);
  Future<void> setSkipSilence(bool enabled);

  /// 0..1 player volume (used for the soft fade between songs).
  Future<void> setVolume(double volume);
  Future<void> setVolumeNormalisation(bool enabled);

  /// Per-track loudness correction (dB) applied while normalisation is on.
  Future<void> setTrackGainDb(double gainDb);

  // Observation
  int? get currentIndex;
  Duration get position;
  Duration? get duration;
  bool get playing;
  int? get audioSessionId;
  Stream<int?> get currentIndexStream;
  Stream<bool> get playingStream;
  Stream<Duration> get positionStream;
  Stream<Duration?> get durationStream;
  Stream<EngineState> get stateStream;

  Future<void> dispose();
}
