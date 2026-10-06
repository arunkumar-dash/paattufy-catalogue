import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/entities/entities.dart';
import '../features/library/data/library_providers.dart';
import '../features/playback/data/playback_controller.dart';

/// "Open with" / share-target (AP §6, §8.14): tapping an audio file in a file
/// manager, or sharing one to Paattufy, plays it here.
class IntentsService {
  IntentsService(this._container);
  final ProviderContainer _container;

  static const _method = MethodChannel('paattufy/intents');
  static const _events = EventChannel('paattufy/intents_events');

  /// Called after a song was found and started, so the UI can open Now Playing.
  void Function()? onPlaying;
  void Function(String message)? onProblem;

  Future<void> start() async {
    final initial = await _method.invokeMapMethod<Object?, Object?>('initial');
    if (initial != null) await handle(initial);
    _events.receiveBroadcastStream().listen((e) => handle((e as Map).cast<Object?, Object?>()));
  }

  Future<void> handle(Map<Object?, Object?> intent) async {
    final uri = intent['uri'] as String?;
    if (uri == null) return;
    var song = await _find(uri);
    if (song == null) {
      // A file that MediaStore knows but the library hasn't picked up yet.
      await _container.read(scanControllerProvider.notifier).run(full: false);
      song = await _find(uri);
    }
    if (song == null) {
      onProblem?.call('Couldn\'t find that file in your library. Try rescanning.');
      return;
    }
    await _container.read(playbackControllerProvider.notifier).playSong(song);
    onPlaying?.call();
  }

  Future<Song?> _find(String uri) async {
    final repo = _container.read(libraryRepositoryProvider);
    final direct = await repo.songByContentUri(uri);
    if (direct != null) return direct;
    String? media;
    try {
      media = await _method.invokeMethod<String>('resolve', {'uri': uri});
    } on PlatformException {
      media = null;
    }
    return media == null ? null : repo.songByContentUri(media);
  }
}
