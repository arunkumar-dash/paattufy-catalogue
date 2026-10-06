import 'package:audio_service/audio_service.dart';

/// Commands the media session (notification, lock screen, headset buttons,
/// Bluetooth, Android Auto, tile) can issue. Implemented by the playback
/// controller via [MediaSessionBridge].
abstract class MediaSessionCommands {
  Future<void> onPlay();
  Future<void> onPause();
  Future<void> onStop();
  Future<void> onSkipNext();
  Future<void> onSkipPrevious();
  Future<void> onSeek(Duration position);

  /// Session custom actions: `toggleShuffle`, `cycleRepeat` (home widget).
  Future<void> onCustom(String name);

  /// Android Auto / media browser tree (AP §6).
  Future<List<MediaItem>> onBrowse(String parentMediaId);
  Future<void> onPlayFromMediaId(String mediaId);
}

/// audio_service handler: owns the platform MediaSession, the MediaStyle
/// notification and the foreground service (TP §5.4, §6). It holds no playback
/// logic of its own — every action is forwarded to [commands].
class PaattufyAudioHandler extends BaseAudioHandler with SeekHandler {
  MediaSessionCommands? commands;

  @override
  Future<void> play() async => commands?.onPlay();
  @override
  Future<void> pause() async => commands?.onPause();
  @override
  Future<void> stop() async {
    await commands?.onStop();
    await super.stop();
  }

  @override
  Future<void> skipToNext() async => commands?.onSkipNext();
  @override
  Future<void> skipToPrevious() async => commands?.onSkipPrevious();
  @override
  Future<void> seek(Duration position) async => commands?.onSeek(position);

  @override
  Future<dynamic> customAction(String name, [Map<String, dynamic>? extras]) async {
    await commands?.onCustom(name);
  }

  @override
  Future<List<MediaItem>> getChildren(String parentMediaId, [Map<String, dynamic>? options]) async =>
      await commands?.onBrowse(parentMediaId) ?? const [];

  @override
  Future<void> playFromMediaId(String mediaId, [Map<String, dynamic>? extras]) async =>
      commands?.onPlayFromMediaId(mediaId);

  /// Pushes the current media item (or clears it).
  void publishItem(MediaItem? item) => mediaItem.add(item);

  void publishState({
    required bool playing,
    required bool loading,
    required bool hasQueue,
    required Duration position,
    required double speed,
    int? queueIndex,
  }) {
    playbackState.add(
      PlaybackState(
        controls: [
          MediaControl.skipToPrevious,
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices: const [0, 1, 2],
        processingState: !hasQueue
            ? AudioProcessingState.idle
            : loading
                ? AudioProcessingState.loading
                : AudioProcessingState.ready,
        playing: playing,
        updatePosition: position,
        speed: speed,
        queueIndex: queueIndex,
      ),
    );
  }
}
