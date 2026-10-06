import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';

import '../../../core/settings/app_settings.dart';
import '../../library/data/artwork_cache.dart';
import '../../playback/data/playback_controller.dart';
import '../../queue/domain/queue_models.dart';

/// Pushes Now-Playing state to the three home-screen widgets (AP §6, TP §6):
/// `home_widget` writes shared state that the Kotlin AppWidgetProviders render.
/// Updates are debounced and progress is refreshed at a low rate, so widgets
/// cost next to nothing; artwork is handed over as a cached file path.
class WidgetUpdater {
  WidgetUpdater(this._container, {this.progressInterval = const Duration(seconds: 15)});
  final ProviderContainer _container;
  final Duration progressInterval;

  static const providers = [
    'com.paattufy.music.PlayerWidgetSmall',
    'com.paattufy.music.PlayerWidgetMedium',
    'com.paattufy.music.PlayerWidgetLarge',
  ];

  Timer? _debounce;
  Timer? _progress;
  String? _artFor;
  String? _artPath;

  void start() {
    _container.listen(playbackControllerProvider, (prev, next) {
      _schedule();
      final playingChanged = prev?.playing != next.playing;
      if (playingChanged) {
        _progress?.cancel();
        if (next.playing) _progress = Timer.periodic(progressInterval, (_) => _schedule());
      }
    }, fireImmediately: true);
    _container.listen(settingsProvider.select((s) => s.themeSeedColor), (_, _) => _schedule());
    _container.listen(queueSnapshotProvider, (_, _) => _schedule());
  }

  void _schedule() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), push);
  }

  Future<void> push() async {
    try {
      final s = _container.read(playbackControllerProvider);
      final song = s.current;
      final engine = _container.read(audioEngineProvider);
      final pos = engine.position.inMilliseconds;
      final total = s.duration.inMilliseconds;

      if (song != null && _artFor != song.id) {
        _artFor = song.id;
        final f = await _container.read(artworkCacheProvider).file(song.contentUri, size: 384);
        _artPath = f?.path;
      }
      final QueueSnapshot? snap = _container.read(queueSnapshotProvider).value;
      final upcoming = snap?.upcoming ?? const [];

      Future<void> save(String k, Object? v) => HomeWidget.saveWidgetData<dynamic>(k, v);
      await save('title', song?.title);
      await save('artist', song?.artist);
      await save('artPath', song == null ? null : _artPath);
      await save('playing', s.playing);
      await save('progress', total <= 0 ? 0.0 : (pos / total).clamp(0.0, 1.0));
      await save('shuffle', s.shuffle);
      await save('repeat', s.repeat.index);
      await save('accent', _container.read(settingsProvider).themeSeedColor);
      for (var i = 0; i < 3; i++) {
        await save('queue${i + 1}', i < upcoming.length ? upcoming[i].song.title : null);
      }
      for (final p in providers) {
        await HomeWidget.updateWidget(qualifiedAndroidName: p);
      }
    } catch (_) {
      // Widgets are best-effort; never disturb playback.
    }
  }

  void dispose() {
    _debounce?.cancel();
    _progress?.cancel();
  }
}
