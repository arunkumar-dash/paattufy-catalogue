import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants.dart';
import '../core/settings/app_settings.dart';
import '../core/theming/app_theme.dart';
import '../features/download_hub/data/download_providers.dart';
import '../features/library/data/library_providers.dart';
import '../features/playback/data/playback_controller.dart';
import 'router.dart';

final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

class PaattufyApp extends ConsumerStatefulWidget {
  const PaattufyApp({super.key});

  @override
  ConsumerState<PaattufyApp> createState() => _PaattufyAppState();
}

class _PaattufyAppState extends ConsumerState<PaattufyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = ref.read(playbackControllerProvider.notifier);
    switch (state) {
      // Position / play state are flushed immediately when leaving the
      // foreground (AP §3.5), on top of the 1 s throttle.
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        controller.flushState();
      // Incremental scan on resume (TP §5.1).
      case AppLifecycleState.resumed:
        if (ref.read(settingsProvider).onboardingComplete) {
          ref.read(scanControllerProvider.notifier).run(full: false);
        }
      case AppLifecycleState.hidden:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final seed = Color(ref.watch(settingsProvider.select((s) => s.themeSeedColor)));
    final mode = ref.watch(settingsProvider.select((s) => s.themeMode));
    final router = ref.watch(routerProvider);

    // "Added N songs" toast when a download finishes (AP §5.8).
    ref.listen(downloadsProvider, (prev, next) {
      final before = {for (final d in prev?.value ?? const []) d.id: d.status};
      for (final d in next.value ?? const []) {
        if (d.status == 'done' && before[d.id] != null && before[d.id] != 'done') {
          scaffoldMessengerKey.currentState
            ?..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text('Added ${d.itemsAdded} ${d.itemsAdded == 1 ? 'song' : 'songs'} from "${d.title}"')));
        }
      }
    });

    return MaterialApp.router(
      title: appName,
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: scaffoldMessengerKey,
      theme: buildTheme(seed, Brightness.light),
      darkTheme: buildTheme(seed, Brightness.dark),
      themeMode: mode,
      routerConfig: router,
    );
  }
}
