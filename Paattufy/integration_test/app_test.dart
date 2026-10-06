// End-to-end walk-through on a device/emulator (TP §8, AP §9.4):
// onboarding → scan → sort → build a smart group → play group → play-next →
// suggestion top-up → reorder → resume after "restart" → lyrics pick (mocked
// provider) → catalogue parse (mocked HTTP).
//
// Prerequisites (see scripts/test_all.sh): an emulator with the fixture audio
// in /sdcard/Music/<artist>/ and permissions pre-granted; data cleared.
import 'dart:convert';

import 'package:flutter/material.dart' hide RepeatMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:paattufy/app/app.dart';
import 'package:paattufy/app/bootstrap.dart';
import 'package:paattufy/core/providers/http_providers.dart';
import 'package:paattufy/core/settings/app_settings.dart';
import 'package:paattufy/features/groups/domain/rules.dart';
import 'package:paattufy/features/library/data/library_providers.dart';
import 'package:paattufy/features/library/data/library_repository.dart';
import 'package:paattufy/features/playback/data/just_audio_engine.dart';
import 'package:paattufy/features/lyrics/data/lyrics_providers.dart';
import 'package:paattufy/features/playback/data/playback_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../test/support/fake_http.dart';

const catalogueJson = {
  'schemaVersion': 1,
  'sites': [
    {
      'id': 'masstamilan',
      'title': 'Masstamilan',
      'link': 'https://www.masstamilan.dev/',
      'mode': 'listing',
      'listing': {'listPageUrl': 'https://www.masstamilan.dev/', 'cardLinkHrefPattern': r'^/[a-z0-9-]+-songs(-[0-9]+)?$'},
    },
    {'id': 'songspk', 'title': 'SongsPK', 'link': 'https://songspk.com.se/', 'mode': 'browse'},
  ],
};

Future<void> pumpFor(WidgetTester tester, {double seconds = 1.0}) async {
  final end = DateTime.now().add(Duration(milliseconds: (seconds * 1000).round()));
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> tapText(WidgetTester tester, String text, {double wait = 1.0}) async {
  await tester.tap(find.text(text).first);
  await pumpFor(tester, seconds: wait);
}

Future<void> waitUntil(WidgetTester tester, bool Function() cond, {int seconds = 30, String what = 'condition'}) async {
  for (var i = 0; i < seconds * 10; i++) {
    if (cond()) return;
    await tester.pump(const Duration(milliseconds: 100));
  }
  fail('timed out waiting for $what');
}

Future<void> waitForText(WidgetTester tester, String text, {int seconds = 30}) async {
  for (var i = 0; i < seconds * 10; i++) {
    if (find.text(text).evaluate().isNotEmpty) return;
    await tester.pump(const Duration(milliseconds: 100));
  }
  fail('"$text" never appeared');
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Paattufy end-to-end', (tester) async {
    final http = FakeHttpAdapter((o) {
      final url = o.uri.toString();
      if (url.contains('paattufy-catalogue') && url.endsWith('download-catalogue.json')) {
        return FakeResponse(jsonEncode(catalogueJson), headers: {'etag': ['"t1"']});
      }
      if (o.uri.host == 'lrclib.net' && o.uri.path == '/api/search') {
        return FakeResponse.json([
          {'trackName': 'Song 1', 'artistName': 'Ilaiyaraaja', 'albumName': 'Ilaiyaraaja', 'duration': 20.0, 'syncedLyrics': '[00:01.00]integration line', 'plainLyrics': 'integration line'},
        ]);
      }
      return const FakeResponse('{}', status: 404);
    });
    AppBootstrap.extraOverrides.add(dioProvider.overrideWithValue(fakeDio(http)));

    final boot = await AppBootstrap.start();
    var container = boot.container;
    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const PaattufyApp()));
    await pumpFor(tester, seconds: 2);

    // --- onboarding → scan -------------------------------------------------------
    await tapText(tester, 'Get started');
    await tapText(tester, 'Continue');
    await tapText(tester, 'Save & scan my library', wait: 2);
    await waitForText(tester, '12 songs found');
    await tapText(tester, 'Finish', wait: 2);
    expect(find.text('Songs'), findsWidgets);
    expect(find.text('12 songs'), findsOneWidget);

    // --- sort ------------------------------------------------------------------------
    await tester.tap(find.byIcon(Icons.sort));
    await pumpFor(tester);
    await tester.tap(find.byType(Switch));
    await pumpFor(tester);
    expect(container.read(songsSortProvider).ascending, isFalse);
    await tester.tapAt(const Offset(10, 10));
    await pumpFor(tester);
    final firstSong = await container.read(libraryRepositoryProvider).watchSongs(sort: SongSort.title, ascending: false).first;
    expect(find.text(firstSong.first.title), findsOneWidget);

    // --- build a smart group ------------------------------------------------------------
    await tester.tap(find.descendant(of: find.byType(NavigationBar), matching: find.text('Groups')));
    await pumpFor(tester);
    await tapText(tester, 'New group');
    await tapText(tester, 'Build a rule');
    await tester.enterText(find.widgetWithText(TextField, 'Group name'), 'Raja');
    // The emulator's untagged WAVs carry no artist; MediaStore names the album after the folder.
    await tester.tap(find.byType(DropdownButton<RuleField>).first);
    await pumpFor(tester);
    await tester.tap(find.text('Album').last);
    await pumpFor(tester);
    await tester.enterText(find.widgetWithText(TextField, 'Album'), 'Ilaiyaraaja');
    await pumpFor(tester, seconds: 2);
    expect(find.text('Matches 3 songs'), findsOneWidget);
    await tapText(tester, 'Save', wait: 2);

    // --- play the group -----------------------------------------------------------------------
    await tapText(tester, 'Play', wait: 2);
    final ctl = container.read(playbackControllerProvider.notifier);
    await waitUntil(tester, () => container.read(playbackControllerProvider).playing, what: 'playback to start');
    expect(container.read(playbackControllerProvider).playing, isTrue);
    expect(container.read(playbackControllerProvider).current!.artist, anyOf('Unknown artist', 'Ilaiyaraaja'));

    // --- suggestion top-up: queue is filled to 10 upcoming ----------------------------------------
    var snap = await container.read(queueRepositoryProvider).snapshot();
    for (var i = 0; i < 100 && snap.upcomingCount < 10; i++) {
      await pumpFor(tester, seconds: 0.2);
      snap = await container.read(queueRepositoryProvider).snapshot();
    }
    expect(snap.upcomingCount, 10 < 11 ? 10 : snap.upcomingCount, reason: 'topped up to 10 upcoming');
    expect(snap.upcoming.where((e) => e.isSuggested), isNotEmpty);

    // --- play next + reorder --------------------------------------------------------------------------
    final library = container.read(libraryRepositoryProvider);
    final all = await library.allVisibleSongs();
    final target = all.firstWhere((s) => !snap.entries.any((e) => e.song.id == s.id), orElse: () => all.last);
    await ctl.playNext([target]);
    snap = await container.read(queueRepositoryProvider).snapshot();
    expect(snap.upcoming.first.song.id, target.id);
    await ctl.reorder(snap.upcoming.last.id, snap.currentIndex + 1);
    snap = await container.read(queueRepositoryProvider).snapshot();
    expect(container.read(audioEngineProvider).loadedQueueItemIds, snap.entries.map((e) => e.id).toList(), reason: 'engine mirrors the DB queue');

    // --- resume after restart ---------------------------------------------------------------------------
    await ctl.skipNext();
    await pumpFor(tester, seconds: 3);
    await ctl.pause();
    await ctl.flushState();
    final before = container.read(playbackControllerProvider).current!.id;
    final beforeQueue = (await container.read(queueRepositoryProvider).snapshot()).entries.map((e) => e.id).toList();
    await tester.pumpWidget(const SizedBox());
    container.dispose();
    // The audio_service session is per process, so "restart" = a fresh container + engine over the same database.
    container = ProviderContainer(overrides: [
      sharedPreferencesProvider.overrideWithValue(await SharedPreferences.getInstance()),
      audioEngineProvider.overrideWithValue(JustAudioEngine()),
      dioProvider.overrideWithValue(fakeDio(http)),
    ]);
    await container.read(playbackControllerProvider.notifier).init();
    final restored = container.read(playbackControllerProvider);
    expect(restored.current?.id, before, reason: 'same song after restart');
    expect(restored.playing, isFalse, reason: 'restore never auto-plays');
    expect((await container.read(queueRepositoryProvider).snapshot()).entries.map((e) => e.id).toList(), beforeQueue);
    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const PaattufyApp()));
    await pumpFor(tester, seconds: 2);

    // --- lyrics pick (mocked provider) ----------------------------------------------------------------------
    final song = container.read(playbackControllerProvider).current!;
    final lyrics = container.read(lyricsRepositoryProvider);
    final candidates = await lyrics.search(defaultLyricsQuery(song));
    expect(candidates, isNotEmpty, reason: 'LRCLIB-shaped response parsed by the declarative provider');
    expect(candidates.first.hasSynced, isTrue,
        reason: 'candidates=${[for (final c in candidates) '${c.providerId}:${c.title}:${c.hasSynced}']}; '
            'fake saw ${[for (final r in http.requests) r.uri.toString()]}');
    await lyrics.pick(song, candidates.first);
    final resolved = await lyrics.resolveLocal(song);
    expect(resolved!.synced, contains('integration line'));

    // --- catalogue parse (mocked HTTP) -------------------------------------------------------------------------
    await tester.tap(find.descendant(of: find.byType(NavigationBar), matching: find.text('Download')));
    await pumpFor(tester, seconds: 3);
    expect(find.text('Masstamilan'), findsOneWidget);
    expect(find.text('SongsPK'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    container.dispose();
  });
}
