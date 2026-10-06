import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:paattufy/app/app.dart';
import 'package:paattufy/core/database/app_database.dart';
import 'package:paattufy/core/providers/core_providers.dart';
import 'package:paattufy/core/providers/http_providers.dart';
import 'package:paattufy/core/settings/app_settings.dart';
import 'package:paattufy/features/library/data/artwork_cache.dart';
import 'package:paattufy/features/library/data/media_store_scanner.dart';
import 'package:paattufy/features/playback/data/playback_controller.dart';
import 'package:paattufy/features/playback/data/playback_extras.dart';
import 'package:paattufy/features/playback/data/output_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fake_audio_engine.dart';
import 'fake_http.dart';
import 'test_db.dart';

class NoArtwork extends ArtworkCache {
  NoArtwork() : super(MediaStoreScanner());
  @override
  Future<Uint8List?> bytes(String contentUri, {int size = 256}) async => null;
}

class StubOutputPlatform implements OutputPlatform {
  @override
  Future<String> currentRoute() async => 'speaker';
  @override
  Stream<String> get routeChanges => const Stream.empty();
  @override
  Future<List<OutputDevice>> listOutputs() async =>
      const [OutputDevice(id: 1, kind: 'speaker', name: 'Phone speaker', active: true)];
  @override
  Future<bool> openSwitcher() async => true;
  @override
  Future<bool> openEqualizer(int id) async => true;
}

class Harness {
  Harness(this.db, this.songs, this.engine, this.container, this.http);
  final AppDatabase db;
  final List<Song> songs;
  final FakeAudioEngine engine;
  final ProviderContainer container;
  final FakeHttpAdapter http;

  PlaybackController get controller => container.read(playbackControllerProvider.notifier);
}

/// Boots the real app widget tree over the fixture library with a fake audio
/// engine, in-memory database and fake HTTP. Native channels are never hit.
Future<Harness> bootApp(
  WidgetTester tester, {
  Map<String, Object> prefs = const {'onboarding_complete': true, 'suggestion_mode': 'metadata'},
  FakeHandler? httpHandler,
  Size size = const Size(900, 1600),
  List<Override> extra = const [],
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final sp = await SharedPreferences.getInstance();
  late AppDatabase db;
  late List<Song> songs;
  await tester.runAsync(() async {
    (db, songs) = await seededDb();
  });
  final engine = FakeAudioEngine();
  final http = FakeHttpAdapter(httpHandler ?? (o) => const FakeResponse('{}', status: 404));
  final container = ProviderContainer(overrides: [
    databaseProvider.overrideWithValue(db),
    audioEngineProvider.overrideWithValue(engine),
    sharedPreferencesProvider.overrideWithValue(sp),
    artworkCacheProvider.overrideWithValue(NoArtwork()),
    dioProvider.overrideWithValue(fakeDio(http)),
    outputPlatformProvider.overrideWithValue(StubOutputPlatform()),
    ...extra,
  ]);
  tester.view.physicalSize = size * 2;
  tester.view.devicePixelRatio = 2;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
  await tester.runAsync(() => container.read(playbackControllerProvider.notifier).init());
  await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const PaattufyApp()));
  await settle(tester);
  return Harness(db, songs, engine, container, http);
}

/// Drift streams emit on real async time, so give them a moment between pumps.
Future<void> settle(WidgetTester tester, {int rounds = 6}) async {
  for (var i = 0; i < rounds; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 25)));
    await tester.pump(const Duration(milliseconds: 60));
  }
}

Finder inNav(String label) => find.descendant(of: find.byType(NavigationBar), matching: find.text(label));

extension TesterX on WidgetTester {
  Future<void> tapAndSettle(Finder f) async {
    await tap(f.first);
    await settle(this);
  }
}

/// Tears the app down *inside* the test body: drift's stream-cleanup timers
/// must be flushed before flutter_test's pending-timer check runs.
Future<void> shutdown(WidgetTester tester, Harness h) async {
  await tester.pumpWidget(const SizedBox());
  h.container.dispose();
  // The in-memory database is left to process exit: closing it under
  // `runAsync` can wait forever on drift's stream bookkeeping. Pumping flushes
  // the zero-duration timers drift schedules when listeners cancel.
  await tester.pump(const Duration(seconds: 1));
  await tester.pump(const Duration(seconds: 1));
}

/// `testWidgets` + boot + guaranteed shutdown.
void appTest(
  String description,
  Future<void> Function(WidgetTester tester, Harness h) body, {
  Map<String, Object> prefs = const {'onboarding_complete': true, 'suggestion_mode': 'metadata'},
  FakeHandler? httpHandler,
  List<Override> extra = const [],
  Size size = const Size(900, 1600),
}) {
  testWidgets(description, (tester) async {
    final h = await bootApp(tester, prefs: prefs, httpHandler: httpHandler, extra: extra, size: size);
    try {
      await body(tester, h);
    } finally {
      await shutdown(tester, h);
    }
  });
}
