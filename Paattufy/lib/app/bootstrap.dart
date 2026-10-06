import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:flutter/material.dart' show SnackBar, Text;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:shared_preferences/shared_preferences.dart';

import '../core/settings/app_settings.dart';
import '../features/download_hub/data/download_providers.dart';
import '../features/playback/data/audio_handler.dart';
import '../features/playback/data/just_audio_engine.dart';
import '../features/playback/data/media_session_bridge.dart';
import '../features/playback/data/playback_controller.dart';
import '../features/playback/data/playback_extras.dart';
import '../features/suggestions/data/analysis_scheduler.dart';
import '../features/suggestions/data/suggestion_providers.dart';
import '../features/widgets_integration/data/widget_updater.dart';
import 'app.dart' show scaffoldMessengerKey;
import 'intents_service.dart';
import 'router.dart';
import 'routes.dart';

/// Everything that must exist before the first frame: prefs, the audio engine
/// and media session, and the restored playback session (TP §5.4 splash gate).
class AppBootstrap {
  AppBootstrap(this.container, this.bridge, this.intents);
  final ProviderContainer container;
  final MediaSessionBridge bridge;
  final IntentsService intents;

  static Future<AppBootstrap> start() async {
    final prefs = await SharedPreferences.getInstance();

    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    final handler = await AudioService.init<PaattufyAudioHandler>(
      builder: PaattufyAudioHandler.new,
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.paattufy.music.playback',
        androidNotificationChannelName: 'Playback',
        androidNotificationIcon: 'drawable/ic_stat_music',
        // Foreground service drops when playback stops, so no battery is
        // wasted (AP §6).
        androidStopForegroundOnPause: true,
        androidNotificationOngoing: false,
      ),
    );

    final engine = JustAudioEngine();
    final container = ProviderContainer(overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      audioEngineProvider.overrideWithValue(engine),
      suggestionTopUpOverride, // queue top-up to 10 (AP §3.4)
      ...extraOverrides,
    ]);

    await container.read(playbackControllerProvider.notifier).init();
    final bridge = MediaSessionBridge(container, handler)..start();

    // Background services: each failure is isolated so the app always starts.
    await _guard(() => container.read(outputWatcherProvider).start()); // stop on every route change
    await _guard(() async {
      container.read(downloadManagerProvider); // created early so it can recover paused transfers
    });
    await _guard(AnalysisScheduler.register);
    await _guard(() async => WidgetUpdater(container).start());

    final intents = IntentsService(container)
      ..onPlaying = (() => container.read(routerProvider).push(Routes.nowPlaying))
      ..onProblem = ((m) => scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(content: Text(m))));
    await _guard(intents.start);
    await _guard(() async {
      // Tapping a home-screen widget opens Now Playing.
      HomeWidget.widgetClicked.listen((_) => container.read(routerProvider).push(Routes.nowPlaying));
      if (await HomeWidget.initiallyLaunchedFromHomeWidget() != null) {
        container.read(routerProvider).push(Routes.nowPlaying);
      }
    });
    return AppBootstrap(container, bridge, intents);
  }

  static Future<void> _guard(Future<void> Function() step) async {
    try {
      await step();
    } catch (e, st) {
      debugPrint('bootstrap step failed: $e\n$st');
    }
  }

  /// Hooks added by tests or later phases.
  static final List<Override> extraOverrides = [];
}
