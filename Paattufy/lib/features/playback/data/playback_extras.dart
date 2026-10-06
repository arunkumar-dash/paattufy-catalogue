
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/audio_engine.dart';
import 'output_service.dart';
import 'playback_controller.dart';
import 'sleep_timer.dart';

/// Sleep timer wired to playback: fires → pause; end-of-track mode also fires
/// when the queue runs out.
final sleepTimerProvider = Provider<SleepTimer>((ref) {
  final timer = SleepTimer(onFire: () => ref.read(playbackControllerProvider.notifier).pause());
  ref.listen<int?>(playbackControllerProvider.select((s) => s.currentItemId), (prev, next) => timer.onTrackBoundary(next));
  final sub = ref.read(audioEngineProvider).stateStream.listen((s) {
    if (s == EngineState.completed) timer.onTrackBoundary(null);
  });
  ref.onDispose(() {
    sub.cancel();
    timer.dispose();
  });
  return timer;
});

final sleepTimerStateProvider = StreamProvider<SleepTimerState>((ref) async* {
  final timer = ref.watch(sleepTimerProvider);
  yield timer.state;
  yield* timer.changes;
});

final outputPlatformProvider = Provider<OutputPlatform>((ref) => NativeOutputPlatform());

/// Every output route change stops playback (AP §3.6). Started once at boot.
final outputWatcherProvider = Provider<OutputWatcher>((ref) {
  final watcher = OutputWatcher(
    ref.watch(outputPlatformProvider),
    onChange: (route) => ref.read(playbackControllerProvider.notifier).handleRouteChange(route),
  );
  ref.onDispose(watcher.dispose);
  return watcher;
});

final outputDevicesProvider = FutureProvider.autoDispose<List<OutputDevice>>(
  (ref) => ref.watch(outputPlatformProvider).listOutputs(),
);
