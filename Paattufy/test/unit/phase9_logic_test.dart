import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paattufy/core/database/app_database.dart';
import 'package:paattufy/core/settings/app_settings.dart';
import 'package:paattufy/features/groups/data/group_repository.dart';
import 'package:paattufy/features/groups/domain/rules.dart';
import 'package:paattufy/features/library/data/library_health.dart';
import 'package:paattufy/features/library/data/library_repository.dart';
import 'package:paattufy/features/library/data/library_scan_service.dart';
import 'package:paattufy/features/library/domain/media_scanner.dart';
import 'package:paattufy/features/playback/data/output_service.dart';
import 'package:paattufy/features/playback/data/play_stats_repository.dart';
import 'package:paattufy/features/playback/data/sleep_timer.dart';
import 'package:paattufy/features/queue/data/queue_repository.dart';
import 'package:paattufy/features/settings/data/backup_service.dart';

import '../support/fixture_library.dart';
import '../support/song_factory.dart';
import '../support/test_db.dart';

class FakeOutputPlatform implements OutputPlatform {
  FakeOutputPlatform(this.initial);
  String initial;
  final controller = StreamController<String>.broadcast(sync: true);
  @override
  Future<String> currentRoute() async => initial;
  @override
  Stream<String> get routeChanges => controller.stream;
  @override
  Future<List<OutputDevice>> listOutputs() async => const [];
  @override
  Future<bool> openSwitcher() async => true;
  @override
  Future<bool> openEqualizer(int audioSessionId) async => true;
}

void main() {
  group('OutputWatcher (AP §3.6: every route change stops playback)', () {
    test('reports every real change: BT connect, BT→speaker switch, wired plug/unplug', () async {
      final platform = FakeOutputPlatform('speaker');
      final seen = <String>[];
      final w = OutputWatcher(platform, onChange: (r) async => seen.add(r));
      await w.start();
      platform.controller.add('bluetooth:Buds');
      platform.controller.add('speaker'); // switched back while BT still paired
      platform.controller.add('wired:Headphones');
      platform.controller.add('speaker');
      expect(seen, ['bluetooth:Buds', 'speaker', 'wired:Headphones', 'speaker']);
      await w.dispose();
    });

    test('duplicate events and the initial route do not stop playback', () async {
      final platform = FakeOutputPlatform('bluetooth:Buds');
      final seen = <String>[];
      final w = OutputWatcher(platform, onChange: (r) async => seen.add(r));
      await w.start();
      platform.controller.add('bluetooth:Buds');
      platform.controller.add('bluetooth:Buds');
      expect(seen, isEmpty);
      platform.controller.add('speaker');
      expect(seen, ['speaker']);
      expect(w.current, 'speaker');
      await w.dispose();
    });

    test('route parsing', () {
      expect(OutputRoute.parse('speaker').label, 'Phone speaker');
      expect(OutputRoute.parse('bluetooth:WH-1000XM5').kind, 'bluetooth');
      expect(OutputRoute.parse('bluetooth:WH-1000XM5').label, 'WH-1000XM5');
      expect(OutputRoute.parse('wired:USB: DAC').name, 'USB: DAC', reason: 'only the first colon splits');
    });
  });

  group('SleepTimer (AP §8.1)', () {
    test('fires after N minutes and reports remaining time', () {
      fakeAsync((async) {
        var fired = 0;
        final t = SleepTimer(onFire: () async => fired++);
        t.startIn(const Duration(minutes: 30));
        expect(t.state.active, isTrue);
        async.elapse(const Duration(minutes: 29));
        expect(fired, 0);
        async.elapse(const Duration(minutes: 1, seconds: 1));
        expect(fired, 1);
        expect(t.state.active, isFalse);
        t.dispose();
      });
    });

    test('cancel prevents firing; restarting replaces the previous timer', () {
      fakeAsync((async) {
        var fired = 0;
        final t = SleepTimer(onFire: () async => fired++);
        t.startIn(const Duration(minutes: 10));
        t.cancel();
        async.elapse(const Duration(minutes: 20));
        expect(fired, 0);
        t.startIn(const Duration(minutes: 10));
        async.elapse(const Duration(minutes: 5));
        t.startIn(const Duration(minutes: 10)); // restart
        async.elapse(const Duration(minutes: 6));
        expect(fired, 0);
        async.elapse(const Duration(minutes: 5));
        expect(fired, 1);
        t.dispose();
      });
    });

    test('end-of-track fires only when the track changes or ends', () {
      var fired = 0;
      final t = SleepTimer(onFire: () async => fired++);
      t.startAtEndOfTrack(7);
      t.onTrackBoundary(7); // same track: no
      expect(fired, 0);
      t.onTrackBoundary(8); // moved on: stop
      expect(fired, 1);
      t.onTrackBoundary(9); // already fired, no repeat
      expect(fired, 1);
      t.dispose();
    });

    test('end-of-track also fires when the queue ends (null)', () {
      var fired = 0;
      final t = SleepTimer(onFire: () async => fired++);
      t.startAtEndOfTrack(3);
      t.onTrackBoundary(null);
      expect(fired, 1);
      t.dispose();
    });
  });

  group('LibraryHealth (AP §8.7)', () {
    const health = LibraryHealth();

    test('duplicates: same title+artist and similar duration, ignoring (feat)/[remaster] noise', () {
      final a = mkSong('a', title: 'Kanavugal', artist: 'Raja', durationMs: 240000);
      final b = mkSong('b', title: 'Kanavugal (Remastered)', artist: 'raja', durationMs: 241000);
      final c = mkSong('c', title: 'Kanavugal', artist: 'Raja', durationMs: 300000); // different length
      final d = mkSong('d', title: 'Other', artist: 'Raja', durationMs: 240000);
      final groups = health.findDuplicates([a, b, c, d]);
      expect(groups, hasLength(1));
      expect(groups.single.songs.map((s) => s.id).toSet(), {'a', 'b'});
      expect(groups.single.reason, contains('title'));
    });

    test('duplicates: identical size+duration with different tags (renamed copies)', () {
      final x = mkSong('x', title: 'Track 01', artist: 'A', durationMs: 1000).copyWith(sizeBytes: 5000);
      final y = mkSong('y', title: 'Completely different', artist: 'B', durationMs: 1000).copyWith(sizeBytes: 5000);
      final groups = health.findDuplicates([x, y]);
      expect(groups.single.reason, contains('size'));
    });

    test('broken: zero duration, zero size, missing file', () async {
      final ok = mkSong('ok');
      final noDur = mkSong('nodur', durationMs: 0);
      final noSize = mkSong('nosize').copyWith(sizeBytes: 0);
      final missing = mkSong('missing').copyWith(sizeBytes: 10);
      final broken = await health.findBroken(
        [ok.copyWith(sizeBytes: 10), noDur, noSize, missing],
        exists: (p) async => !p.contains('missing'),
      );
      expect({for (final b in broken) b.song.id: b.reason}, {
        'nodur': BrokenReason.zeroDuration,
        'nosize': BrokenReason.zeroSize,
        'missing': BrokenReason.missingFile,
      });
    });
  });

  group('Backup / restore (AP §8.11)', () {
    late AppDatabase dbA;
    late List<Song> songsA;

    setUp(() async {
      (dbA, songsA) = await seededDb();
    });
    tearDown(() => dbA.close());

    /// A "fresh install": same files on disk, but MediaStore assigned new ids.
    Future<(AppDatabase, List<Song>)> reinstalledDb() async {
      final db = AppDatabase.forTesting();
      final scanned = [
        for (final s in loadFixtureSongs())
          ScannedSong(
            mediaStoreId: s.mediaStoreId + 5000,
            title: s.title,
            artist: s.artist,
            album: s.album,
            albumArtist: s.albumArtist,
            genre: s.genre,
            year: s.year,
            trackNumber: s.trackNumber,
            durationMs: s.durationMs,
            filePath: s.filePath,
            contentUri: s.contentUri.replaceFirst('/1', '/5001'),
            folderPath: s.folderPath,
            dateAdded: s.dateAdded,
            dateModified: s.dateModified,
            sizeBytes: s.sizeBytes,
            format: s.format,
          ),
      ];
      await LibraryScanService(FakeMediaScanner(scanned), LibraryRepository(db)).fullScan(minDurationMs: 0);
      final songs = await (db.select(db.songs)..orderBy([(t) => OrderingTerm.asc(t.mediaStoreId)])).get();
      return (db, songs);
    }

    Future<String> buildRichBackup() async {
      final library = LibraryRepository(dbA);
      final groups = GroupRepository(dbA, library);
      final sad = await groups.createSmart(
          'Sad songs', const SmartRules(conditions: [RuleCondition(RuleField.genre, RuleOperator.equals, 'Sad')]));
      await groups.createSmart(
        'Raja 80s minus sad',
        SmartRules(
          conditions: const [
            RuleCondition(RuleField.artist, RuleOperator.equals, 'Ilaiyaraaja'),
            RuleCondition(RuleField.year, RuleOperator.between, [1980, 1989]),
          ],
          excludeGroupIds: [sad],
          pinnedSongIds: [songsA[4].id],
        ),
        defaultSort: GroupSort.year,
        ascending: false,
      );
      final mix = await groups.createStatic('Road trip', songIds: [songsA[7].id, songsA[2].id, songsA[9].id]);
      expect(mix, greaterThan(0));
      await groups.delete((await (dbA.select(dbA.groups)..where((g) => g.builtinKey.equals('recently_added'))).getSingle()).id);

      final stats = PlayStatsRepository(dbA);
      await stats.recordPlayCompleted(songsA[0].id);
      await stats.recordPlayCompleted(songsA[0].id);
      await stats.toggleFavourite(songsA[3].id);
      await dbA.into(dbA.lyricsCache).insert(LyricsCacheCompanion.insert(
          songId: songsA[1].id, providerId: 'lrclib', syncedLrc: const Value('[00:01.00]hi'), source: 'remote', offsetMs: const Value(400), fetchedAt: DateTime.now()));
      final queue = QueueRepository(dbA);
      final snap = await queue.replaceWith([songsA[5], songsA[6], songsA[8]], description: 'Resume me');
      await queue.setPointer(snap.entries[1].id);
      await LibraryRepository(dbA).excludeFolder('/storage/emulated/0/Music/Yuvan Shankar Raja');

      return BackupService(dbA).exportJson(const AppSettings(defaultSpeed: 1.25, crossfade: true));
    }

    test('export is valid, versioned JSON with song refs by path', () async {
      final json = await buildRichBackup();
      final data = BackupService.parse(json);
      expect(data['schemaVersion'], 1);
      expect(data['app'], 'paattufy');
      final refs = (data['songs'] as List).cast<Map>();
      expect(refs.every((r) => (r['path'] as String).startsWith('/storage/')), isTrue);
      expect((data['groups'] as List).length, 7, reason: '4 built-ins + 3 user groups');
    });

    test('round-trip into a fresh install with DIFFERENT MediaStore ids', () async {
      final json = await buildRichBackup();
      final (dbB, songsB) = await reinstalledDb();
      addTearDown(dbB.close);
      expect(songsB[0].id, isNot(songsA[0].id), reason: 'ids really differ');

      final (report, settings) = await BackupService(dbB).restore(json, const AppSettings());
      expect(report.songsUnmatched, 0);
      expect(report.groups, 3);
      expect(report.queueRestored, isTrue);
      expect(settings!.defaultSpeed, 1.25);
      expect(settings.crossfade, isTrue);

      final groupsB = GroupRepository(dbB, LibraryRepository(dbB));
      final names = (await dbB.select(dbB.groups).get()).map((g) => g.name).toSet();
      expect(names, containsAll({'Sad songs', 'Raja 80s minus sad', 'Road trip'}));

      Future<SongGroup> g(String name) => (dbB.select(dbB.groups)..where((x) => x.name.equals(name))).getSingle();
      // smart group with exclude-group ref + pin + sort survived and evaluates identically
      final raja = await g('Raja 80s minus sad');
      expect(raja.defaultSort, GroupSort.year);
      expect(raja.defaultSortAscending, isFalse);
      expect((await groupsB.songsIn(raja.id)).map((s) => s.title).toSet(), {'Kanavugal', 'Megam', 'Minnal'});
      // static group keeps order ('Thuli' is in the restored *excluded* Yuvan folder, so hidden)
      expect((await groupsB.songsIn((await g('Road trip')).id)).map((s) => s.title), ['Mazhai', 'Poove']);
      final roadTripId = (await g('Road trip')).id;
      final membership = await (dbB.select(dbB.groupStaticItems)..where((i) => i.groupId.equals(roadTripId))).get();
      expect(membership, hasLength(3), reason: 'all three members restored; one is merely hidden by the exclusion');
      // built-in hidden flag restored
      expect((await (dbB.select(dbB.groups)..where((x) => x.builtinKey.equals('recently_added'))).getSingle()).isHidden, isTrue);

      // play counts, favourites, lyrics + offsets
      final statsB = PlayStatsRepository(dbB);
      expect((await statsB.statFor(songsB[0].id))!.playCount, 2);
      expect((await statsB.statFor(songsB[3].id))!.favourite, isTrue);
      final lyric = await (dbB.select(dbB.lyricsCache)..where((l) => l.songId.equals(songsB[1].id))).getSingle();
      expect(lyric.offsetMs, 400);
      expect(lyric.syncedLrc, contains('hi'));

      // queue + pointer + excluded folders
      final q = await QueueRepository(dbB).snapshot();
      expect(q.entries.map((e) => e.song.title), ['Natpu', 'Kadhal', 'Nilavu']);
      expect(q.current!.song.title, 'Kadhal');
      expect(q.sourceDescription, 'Resume me');
      expect(await LibraryRepository(dbB).excludedFolders(), ['/storage/emulated/0/Music/Yuvan Shankar Raja']);
    });

    test('songs missing from the new library are reported, not fatal', () async {
      final json = await buildRichBackup();
      final dbB = AppDatabase.forTesting();
      addTearDown(dbB.close);
      final partial = loadFixtureSongs().take(3).toList(); // only 3 songs exist on the new device
      await LibraryScanService(FakeMediaScanner(partial), LibraryRepository(dbB)).fullScan(minDurationMs: 0);
      final (report, _) = await BackupService(dbB).restore(json, const AppSettings());
      expect(report.songsUnmatched, greaterThan(0));
      expect(report.songsMatched, greaterThan(0));
    });

    test('restore replaces user groups but keeps built-ins; is idempotent', () async {
      final json = await buildRichBackup();
      final (dbB, _) = await reinstalledDb();
      addTearDown(dbB.close);
      await GroupRepository(dbB, LibraryRepository(dbB)).createStatic('Stale group');
      await BackupService(dbB).restore(json, const AppSettings());
      await BackupService(dbB).restore(json, const AppSettings());
      final names = (await dbB.select(dbB.groups).get()).where((g) => !g.isBuiltin).map((g) => g.name).toList()..sort();
      expect(names, ['Raja 80s minus sad', 'Road trip', 'Sad songs']);
      expect((await dbB.select(dbB.groups).get()).where((g) => g.isBuiltin), hasLength(4));
    });

    test('matching falls back to title+artist+duration when the path changed', () async {
      final json = await buildRichBackup();
      final dbB = AppDatabase.forTesting();
      addTearDown(dbB.close);
      final moved = [
        for (final s in loadFixtureSongs())
          s.copyForTest(mediaStoreId: s.mediaStoreId + 1, title: s.title), // new path via copyForTest
      ];
      await LibraryScanService(FakeMediaScanner(moved), LibraryRepository(dbB)).fullScan(minDurationMs: 0);
      final (report, _) = await BackupService(dbB).restore(json, const AppSettings());
      expect(report.songsUnmatched, 0);
    });

    test('rejects garbage, foreign JSON and newer schemas with clear messages', () async {
      expect(() => BackupService.parse('not json'), throwsA(isA<BackupFormatException>()));
      expect(() => BackupService.parse('{"hello":1}'), throwsA(isA<BackupFormatException>()));
      expect(() => BackupService.parse(jsonEncode({'app': 'paattufy', 'schemaVersion': 99})),
          throwsA(predicate((e) => e.toString().contains('newer'))));
      final (dbB, _) = await reinstalledDb();
      addTearDown(dbB.close);
      await expectLater(BackupService(dbB).restore('garbage', const AppSettings()), throwsA(isA<BackupFormatException>()));
    });
  });
}
