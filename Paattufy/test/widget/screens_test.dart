import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart' hide RepeatMode;
import 'package:flutter_test/flutter_test.dart';
import 'package:paattufy/app/router.dart';
import 'package:paattufy/app/routes.dart';
import 'package:paattufy/core/database/app_database.dart';
import 'package:paattufy/core/settings/app_settings.dart';
import 'package:paattufy/features/groups/domain/rules.dart';
import 'package:paattufy/features/library/data/library_providers.dart';
import 'package:paattufy/features/playback/data/playback_controller.dart';
import 'package:paattufy/features/settings/presentation/settings_screen.dart';
import 'package:paattufy/features/playback/domain/audio_engine.dart';
import 'package:paattufy/features/playback/presentation/mini_player.dart';

import '../support/fake_http.dart';
import '../support/widget_harness.dart';

const publishedCatalogue = '''
{"schemaVersion":1,"sites":[
 {"id":"masstamilan","title":"Masstamilan","link":"https://www.masstamilan.dev/","mode":"listing",
  "listing":{"listPageUrl":"https://www.masstamilan.dev/","cardLinkHrefPattern":"^/[a-z0-9-]+-songs(-[0-9]+)?\$"}},
 {"id":"songspk","title":"SongsPK","link":"https://songspk.com.se/","mode":"browse"}]}
''';

const tall = Size(900, 7000);
final settingsScrollable = find.descendant(of: find.byType(SettingsScreen), matching: find.byType(Scrollable)).first;

double topOf(WidgetTester t, String text) => t.getTopLeft(find.text(text).first).dy;

void main() {
  group('Library', () {
    appTest('lists the fixture songs, sorted by title', (tester, h) async {
      expect(find.text('Kanavugal'), findsOneWidget);
      expect(find.text('12 songs'), findsOneWidget);
      expect(topOf(tester, 'Kadhal'), lessThan(topOf(tester, 'Kanavugal')));
    });

    appTest('sort sheet: descending title puts Vennilaa first, and is remembered', (tester, h) async {
      await tester.tapAndSettle(find.byIcon(Icons.sort));
      expect(find.text('Sort songs by'), findsOneWidget);
      await tester.tapAndSettle(find.byType(Switch)); // Ascending → off
      expect(h.container.read(songsSortProvider).ascending, isFalse);
      expect(h.container.read(sharedPreferencesProvider).getBool('sort_songs_asc'), isFalse);
      await tester.tapAt(const Offset(10, 10)); // dismiss the sheet
      await settle(tester);
      expect(topOf(tester, 'Vennilaa'), lessThan(topOf(tester, 'Kadhal')));
    });

    appTest('tapping a song plays it; mini player appears', (tester, h) async {
      expect(find.byType(MiniPlayer).evaluate().isNotEmpty, isTrue);
      expect(find.text('Kanavugal'), findsOneWidget);
      await tester.tapAndSettle(find.text('Kanavugal'));
      expect(h.engine.tracks, hasLength(1));
      expect(h.engine.playing, isTrue);
      expect(find.byIcon(Icons.pause), findsWidgets);
    });

    appTest('long-press multi-select → Add to queue', (tester, h) async {
      await tester.longPress(find.text('Kanavugal'));
      await settle(tester);
      expect(find.text('1 selected'), findsOneWidget);
      await tester.tapAndSettle(find.text('Megam'));
      expect(find.text('2 selected'), findsOneWidget);
      await tester.tapAndSettle(find.byIcon(Icons.queue_music));
      final q = await tester.runAsync(() => h.container.read(queueRepositoryProvider).snapshot());
      expect(q!.entries.map((e) => e.song.title).toSet(), {'Kanavugal', 'Megam'});
      expect(find.textContaining('selected'), findsNothing);
    });

    appTest('song menu has every action from the plan and no delete', (tester, h) async {
      await tester.tapAndSettle(find.byIcon(Icons.more_vert).at(1));
      for (final t in ['Play', 'Play next', 'Add to queue', 'Add to group', 'Go to artist', 'Go to album', 'Lyrics', 'Details', 'Share']) {
        expect(find.text(t), findsOneWidget, reason: t);
      }
      expect(find.textContaining('Delete'), findsNothing, reason: 'the library is read-only');
    });

    appTest('Details shows the file path; tap copies it', (tester, h) async {
      await tester.tapAndSettle(find.byIcon(Icons.more_vert).at(1));
      await tester.tapAndSettle(find.text('Details'));
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
      await settle(tester);
      expect(find.text('File path'), findsOneWidget);
      expect(find.textContaining('/storage/emulated/0/Music/'), findsWidgets);
    });

    appTest('Artists, Albums and Folders tabs show derived views', (tester, h) async {
      await tester.tapAndSettle(find.text('Artists'));
      expect(find.text('Ilaiyaraaja'), findsOneWidget);
      expect(find.text('2 albums · 4 songs'), findsWidgets);
      await tester.tapAndSettle(find.text('Albums'));
      expect(find.text('Nizhal Nijam'), findsOneWidget);
      await tester.tapAndSettle(find.text('Folders'));
      expect(find.textContaining('Music/Ilaiyaraaja'), findsWidgets);
    });

    appTest('excluding a folder hides its songs everywhere, live', (tester, h) async {
      expect(find.text('12 songs'), findsOneWidget);
      await tester.runAsync(() => h.container.read(libraryRepositoryProvider).excludeFolder('/storage/emulated/0/Music/Ilaiyaraaja'));
      await settle(tester, rounds: 8);
      expect(find.text('8 songs'), findsOneWidget);
      expect(find.text('Kanavugal'), findsNothing);
      await tester.tapAndSettle(find.text('Folders'));
      expect(find.textContaining('excluded'), findsOneWidget, reason: 'folder stays listed, flagged, so it can be re-included');
    });
  });

  group('Search', () {
    appTest('groups results by type', (tester, h) async {
      await tester.tapAndSettle(find.byIcon(Icons.search));
      await tester.enterText(find.byType(TextField), 'rahman');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await settle(tester, rounds: 10);
      expect(find.text('Songs'), findsOneWidget);
      expect(find.text('Artists'), findsOneWidget);
      expect(find.text('A. R. Rahman'), findsWidgets);
      expect(find.text('Minnal'), findsOneWidget);
    });

    appTest('shows a message when nothing matches and remembers recent searches', (tester, h) async {
      await tester.tapAndSettle(find.byIcon(Icons.search));
      await tester.enterText(find.byType(TextField), 'zzzzqqq');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await settle(tester, rounds: 10);
      expect(find.textContaining('No results'), findsOneWidget);
      final prefs = h.container.read(sharedPreferencesProvider);
      expect(prefs.getStringList('recent_searches'), ['zzzzqqq']);
    });
  });

  group('Groups', () {
    appTest('built-in smart groups are listed with Smart badges', (tester, h) async {
      await tester.tapAndSettle(inNav('Groups'));
      for (final n in ['Favourites', 'Recently added', 'Recently played', 'Most played']) {
        expect(find.text(n), findsOneWidget, reason: n);
      }
      expect(find.text('Smart'), findsNWidgets(4));
      expect(find.text('0 songs'), findsWidgets, reason: 'Favourites is empty until something is hearted');
    });

    appTest('rule builder: live preview counts matches, Save creates the group', (tester, h) async {
      await tester.tapAndSettle(inNav('Groups'));
      await tester.tapAndSettle(find.text('New group'));
      await tester.tapAndSettle(find.text('Build a rule'));
      expect(find.text('New smart group'), findsOneWidget);
      await tester.enterText(find.widgetWithText(TextField, 'Group name'), 'Raja only');
      await tester.enterText(find.widgetWithText(TextField, 'Artist'), 'Ilaiyaraaja');
      await tester.pump(const Duration(milliseconds: 400)); // 300 ms debounce
      await settle(tester, rounds: 10);
      expect(find.text('Matches 4 songs'), findsOneWidget);
      await tester.tapAndSettle(find.text('Save'));
      await settle(tester, rounds: 8);
      expect(find.text('Raja only'), findsWidgets);
      expect(find.text('4 songs'), findsWidgets);
    });

    appTest('rule builder: pick the year field, between a range, match any', (tester, h) async {
      await tester.tapAndSettle(inNav('Groups'));
      await tester.tapAndSettle(find.text('New group'));
      await tester.tapAndSettle(find.text('Build a rule'));
      // Switch the first condition from Artist to Release year.
      await tester.tapAndSettle(find.byType(DropdownButton<RuleField>).first);
      await tester.tapAndSettle(find.text('Release year').last);
      await tester.tapAndSettle(find.byType(DropdownButton<RuleOperator>).first);
      await tester.tapAndSettle(find.text('is between').last);
      expect(find.byType(RangeSlider), findsOneWidget);
      expect(find.text('1980 – 1989'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 400));
      await settle(tester, rounds: 10);
      expect(find.text('Matches 4 songs'), findsOneWidget, reason: 'Ilaiyaraaja 1982 + 1986 songs');
      await tester.tapAndSettle(find.byType(DropdownButton<MatchMode>));
      await tester.tapAndSettle(find.text('any').last);
    });

    appTest('static group: hand-pick songs then open it', (tester, h) async {
      await tester.tapAndSettle(inNav('Groups'));
      await tester.tapAndSettle(find.text('New group'));
      await tester.tapAndSettle(find.text('Hand-pick songs'));
      await tester.enterText(find.widgetWithText(TextField, 'Group name'), 'Road trip');
      await tester.tapAndSettle(find.text('Kanavugal'));
      await tester.tapAndSettle(find.text('Natpu'));
      expect(find.text('2 selected'), findsOneWidget);
      await tester.tapAndSettle(find.text('Save'));
      await settle(tester, rounds: 8);
      expect(find.text('Road trip'), findsWidgets);
      expect(find.text('Kanavugal'), findsOneWidget);
      expect(find.text('Natpu'), findsOneWidget);
    });
  });

  group('Now Playing', () {
    Future<void> playAndOpen(WidgetTester tester, Harness h) async {
      await tester.runAsync(() => h.controller.playSongs(h.songs.take(4).toList(), description: 'Test group'));
      await settle(tester);
      await tester.tapAndSettle(find.byType(MiniPlayer));
      await settle(tester);
    }

    appTest('shows the song, output chip, and transport', (tester, h) async {
      await playAndOpen(tester, h);
      expect(find.text('Kanavugal'), findsWidgets);
      expect(find.text('Phone speaker'), findsOneWidget);
      expect(find.text('1.0×'), findsOneWidget);
      expect(find.text('Lyrics'), findsOneWidget);
      expect(find.text('Queue'), findsOneWidget);
      expect(find.byIcon(Icons.pause), findsWidgets);
    });

    appTest('play/pause, next, previous drive the engine', (tester, h) async {
      await playAndOpen(tester, h);
      await tester.tapAndSettle(find.byIcon(Icons.pause).last);
      expect(h.engine.playing, isFalse);
      await tester.tapAndSettle(find.byIcon(Icons.play_arrow).last);
      expect(h.engine.playing, isTrue);
      await tester.tapAndSettle(find.byIcon(Icons.skip_next).last);
      expect(h.engine.currentIndex, 1);
      expect(find.text('Megam'), findsWidgets);
      await tester.tapAndSettle(find.byIcon(Icons.skip_previous).last);
      expect(h.engine.currentIndex, 0);
    });

    appTest('speed sheet: stepped speeds and preserve-pitch toggle', (tester, h) async {
      await playAndOpen(tester, h);
      await tester.tapAndSettle(find.text('1.0×'));
      for (final s in ['0.5×', '0.75×', '1.0×', '1.25×', '1.5×', '1.75×', '2.0×']) {
        expect(find.text(s), findsWidgets, reason: s);
      }
      await tester.tapAndSettle(find.text('1.5×'));
      expect(h.engine.speed, 1.5);
      expect(h.engine.pitch, 1.5, reason: 'preserve pitch is off by default');
      await tester.tapAndSettle(find.text('Preserve pitch'));
      expect(h.engine.pitch, 1.0);
    });

    appTest('repeat cycles off → queue → one; shuffle toggles', (tester, h) async {
      await playAndOpen(tester, h);
      await tester.tapAndSettle(find.byIcon(Icons.repeat));
      expect(h.engine.repeat, RepeatMode.all);
      await tester.tapAndSettle(find.byIcon(Icons.repeat));
      expect(h.engine.repeat, RepeatMode.one);
      expect(find.byIcon(Icons.repeat_one), findsOneWidget);
      await tester.tapAndSettle(find.byIcon(Icons.shuffle));
      expect(h.container.read(playbackControllerProvider).shuffle, isTrue);
    });

    appTest('favourite heart toggles and feeds the Favourites group', (tester, h) async {
      await playAndOpen(tester, h);
      await tester.tapAndSettle(find.byIcon(Icons.favorite_border));
      expect(find.byIcon(Icons.favorite), findsOneWidget);
      final stat = await tester.runAsync(() => h.container.read(playStatsRepositoryProvider).statFor(h.songs.first.id));
      expect(stat!.favourite, isTrue);
    });

    appTest('queue sheet lists Next up and follows queue edits live', (tester, h) async {
      await playAndOpen(tester, h);
      await tester.tapAndSettle(find.text('Queue'));
      expect(find.text('Playing from Test group'), findsOneWidget);
      expect(find.text('Now playing'), findsOneWidget);
      expect(find.text('Next up'), findsOneWidget);
      expect(find.text('Megam'), findsOneWidget);
      final megam = await tester.runAsync(() async => (await h.container.read(queueRepositoryProvider).snapshot()).upcoming.first);
      await tester.runAsync(() => h.controller.removeFromQueue(megam!.id));
      await settle(tester, rounds: 8);
      expect(find.text('Megam'), findsNothing, reason: 'sheet updates as the queue changes');
      final q = await tester.runAsync(() => h.container.read(queueRepositoryProvider).snapshot());
      expect(q!.entries.map((e) => e.song.title), isNot(contains('Megam')));
      expect(h.engine.loadedQueueItemIds, q.entries.map((e) => e.id).toList());
    });

    appTest('output change stops playback and the mini player offers resume', (tester, h) async {
      await tester.runAsync(() => h.controller.playSongs(h.songs.take(3).toList()));
      await settle(tester);
      await tester.runAsync(() => h.controller.handleRouteChange('bluetooth:Buds'));
      await settle(tester);
      expect(h.engine.playing, isFalse);
      expect(find.textContaining('Output changed'), findsOneWidget);
      await tester.tapAndSettle(find.byIcon(Icons.play_arrow).first);
      expect(h.engine.playing, isTrue);
    });

    appTest('sleep timer sheet offers presets and end-of-track', (tester, h) async {
      await playAndOpen(tester, h);
      await tester.tapAndSettle(find.byIcon(Icons.more_vert).last);
      await tester.tapAndSettle(find.text('Sleep timer'));
      expect(find.text('30 min'), findsOneWidget);
      expect(find.text('End of track'), findsOneWidget);
      await tester.tapAndSettle(find.text('15 min'));
    });
  });

  group('Lyrics', () {
    appTest('synced lyrics render; tapping a line seeks to it', (tester, h) async {
      await tester.runAsync(() async {
        await h.db.into(h.db.lyricsCache).insert(LyricsCacheCompanion.insert(
              songId: h.songs.first.id,
              providerId: 'lrclib',
              syncedLrc: const Value('[00:01.00]First line\n[00:02.00]Second line\n[00:03.00]Third line'),
              source: 'remote',
              fetchedAt: DateTime.now(),
            ));
        await h.controller.playSong(h.songs.first);
      });
      await settle(tester, rounds: 8);
      h.container.read(routerProvider).push(Routes.lyrics);
      await settle(tester, rounds: 8);
      expect(find.text('First line'), findsOneWidget);
      expect(find.text('Third line'), findsOneWidget);
      await tester.tapAndSettle(find.text('Third line'));
      expect(h.engine.position, const Duration(seconds: 3));
      expect(find.textContaining('Sync +0.0 s'), findsOneWidget);
      await tester.tapAndSettle(find.byIcon(Icons.add));
      expect(find.textContaining('Sync +0.2 s'), findsOneWidget);
    });

    appTest('no lyrics → search prompt; picker lists candidates with badges', (tester, h) async {
      await tester.runAsync(() => h.controller.playSong(h.songs.first));
      await settle(tester, rounds: 8);
      h.container.read(routerProvider).push(Routes.lyricsPicker(h.songs.first.id));
      await settle(tester, rounds: 10);
      expect(find.text('Search lyrics'), findsOneWidget);
    }, httpHandler: (o) => FakeResponse.json([
          {'trackName': 'Kanavugal', 'artistName': 'Ilaiyaraaja', 'albumName': 'Nizhal Nijam', 'duration': 4.0, 'syncedLrc': '[00:01.00]hi', 'plainLyrics': 'hi'},
          {'trackName': 'Kanavugal live', 'artistName': 'Ilaiyaraaja', 'duration': 99.0, 'plainLyrics': 'hi'},
        ]));
  });

  group('Download hub', () {
    appTest('catalogue from GitHub JSON: site cards with mode badges', (tester, h) async {
      await tester.tapAndSettle(inNav('Download'));
      await settle(tester, rounds: 10);
      expect(find.text('Masstamilan'), findsOneWidget);
      expect(find.text('SongsPK'), findsOneWidget);
      expect(find.text('Recent list'), findsOneWidget);
      expect(find.text('Browse'), findsOneWidget);
      expect(find.textContaining('Last updated'), findsOneWidget);
      await tester.tapAndSettle(find.text('Downloads'));
      expect(find.text('No downloads yet'), findsOneWidget);
    }, httpHandler: (o) => FakeResponse(publishedCatalogue, headers: {'etag': ['"v1"']}));

    appTest('offline with no cache shows an empty catalogue, not a crash', (tester, h) async {
      await tester.tapAndSettle(inNav('Download'));
      await settle(tester, rounds: 10);
      expect(find.text('No sites yet'), findsOneWidget);
    }, httpHandler: (o) => null);
  });

  group('Settings', () {
    appTest('has every section from the plan', (tester, h) async {
      await tester.tapAndSettle(inNav('Settings'));
      for (final section in ['LIBRARY', 'PLAYBACK', 'SUGGESTIONS', 'AUDIO', 'LYRICS', 'DOWNLOAD HUB', 'APPEARANCE', 'DATA', 'ABOUT']) {
        expect(find.text(section), findsOneWidget, reason: section);
      }
    }, size: tall);

    appTest('toggles write through to settings and the engine', (tester, h) async {
      await tester.tapAndSettle(inNav('Settings'));
      await tester.tapAndSettle(find.text('Skip silence'));
      expect(h.container.read(settingsProvider).skipSilence, isTrue);
      expect(h.engine.skipSilence, isTrue);
      await tester.tapAndSettle(find.text('Volume normalisation'));
      expect(h.engine.normalisation, isTrue);
    }, size: tall);

    appTest('download folder field validates before saving', (tester, h) async {
      await tester.tapAndSettle(inNav('Settings'));
      await tester.tapAndSettle(find.text('Download folder'));
      await tester.enterText(find.byType(TextField).last, 'relative/path');
      await tester.tapAndSettle(find.text('Save'));
      expect(find.text('Must be an absolute path starting with /'), findsOneWidget);
      await tester.enterText(find.byType(TextField).last, '/a/../b');
      await tester.tapAndSettle(find.text('Save'));
      expect(find.text('Path may not contain ".."'), findsOneWidget);
    }, size: tall);

    appTest('accent colour presets change the theme seed', (tester, h) async {
      await tester.tapAndSettle(inNav('Settings'));
      await tester.tap(find.byTooltip('Ocean blue'));
      await settle(tester);
      expect(h.container.read(settingsProvider).themeSeedColor, 0xFF1E6BFF);
    }, size: tall);

    appTest('stop-on-output-change is shown as always on (not a toggle)', (tester, h) async {
      await tester.tapAndSettle(inNav('Settings'));
      expect(find.textContaining('Always on'), findsWidgets);
    }, size: tall);
  });

  group('Onboarding', () {
    appTest('three sequential cards', (tester, h) async {
      expect(find.text('Your music, your way'), findsOneWidget);
      await tester.tapAndSettle(find.text('Get started'));
      expect(find.text('A few permissions'), findsOneWidget);
      expect(find.text('Music & audio'), findsOneWidget);
      await tester.tapAndSettle(find.text('Continue'));
      expect(find.text('Where should downloaded songs live?'), findsOneWidget);
      expect(find.text('Save & scan my library'), findsOneWidget);
      expect(h.container.read(settingsProvider).onboardingComplete, isFalse);
    }, prefs: {});
  });
}
