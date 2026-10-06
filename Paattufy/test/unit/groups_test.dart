import 'package:flutter_test/flutter_test.dart';
import 'package:paattufy/core/database/app_database.dart';
import 'package:paattufy/features/groups/data/group_repository.dart';
import 'package:paattufy/features/groups/domain/rules.dart';
import 'package:paattufy/features/library/data/library_repository.dart';
import 'package:paattufy/features/playback/data/play_stats_repository.dart';

import '../support/test_db.dart';

/// Fixture library (by MediaStore id order):
///  0 Kanavugal  Ilaiyaraaja  Nizhal Nijam      Melody 1982 4.0s
///  1 Megam      Ilaiyaraaja  Nizhal Nijam      Melody 1982 3.5s
///  2 Poove      Ilaiyaraaja  Vaanam Vasappadum Sad    1986 3.0s
///  3 Thendral   Ilaiyaraaja  Vaanam Vasappadum Sad    1986 4.5s
///  4 Minnal     A. R. Rahman Veyilodu Vilaiyadi Dance  2008 3.0s
///  5 Natpu      A. R. Rahman Veyilodu Vilaiyadi Dance  2008 2.5s
///  6 Kadhal     A. R. Rahman Mazhai Thooralam  Melody 2014 4.0s
///  7 Mazhai     A. R. Rahman Mazhai Thooralam  Melody 2014 3.5s
///  8 Nilavu     Yuvan        Iravukku Aayiram  Sad    2004 3.0s
///  9 Thuli      Yuvan        Iravukku Aayiram  Sad    2004 3.2s
/// 10 Paravai    Yuvan        Kaatru Veliyidai  Dance  2011 2.8s
/// 11 Vennilaa   Yuvan        Kaatru Veliyidai  Melody 2011 3.8s
void main() {
  late AppDatabase db;
  late List<Song> songs;
  late GroupRepository groups;
  late LibraryRepository library;
  final now = DateTime.fromMillisecondsSinceEpoch(10000 * 86400 * 1000); // fixed clock

  Set<String> titles(List<Song> s) => s.map((e) => e.title).toSet();

  Future<Set<String>> eval(SmartRules r) async => titles((await groups.preview(r, peek: 100)).peek);

  setUp(() async {
    (db, songs) = await seededDb();
    library = LibraryRepository(db);
    groups = GroupRepository(db, library, clock: () => now);
  });
  tearDown(() => db.close());

  group('operators (table-driven)', () {
    final cases = <String, (RuleCondition, Set<String>)>{
      'artist equals (case-insensitive)': (
        const RuleCondition(RuleField.artist, RuleOperator.equals, 'ilaiyaraaja'),
        {'Kanavugal', 'Megam', 'Poove', 'Thendral'},
      ),
      'artist notEquals': (
        const RuleCondition(RuleField.artist, RuleOperator.notEquals, 'Ilaiyaraaja'),
        {'Minnal', 'Natpu', 'Kadhal', 'Mazhai', 'Nilavu', 'Thuli', 'Paravai', 'Vennilaa'},
      ),
      'album contains': (
        const RuleCondition(RuleField.album, RuleOperator.contains, 'mazhai'),
        {'Kadhal', 'Mazhai'},
      ),
      'title startsWith': (
        const RuleCondition(RuleField.title, RuleOperator.startsWith, 'th'),
        {'Thendral', 'Thuli'},
      ),
      'genre isAnyOf': (
        const RuleCondition(RuleField.genre, RuleOperator.isAnyOf, ['sad', 'DANCE']),
        {'Poove', 'Thendral', 'Minnal', 'Natpu', 'Nilavu', 'Thuli', 'Paravai'},
      ),
      'year equals': (
        const RuleCondition(RuleField.year, RuleOperator.equals, 2011),
        {'Paravai', 'Vennilaa'},
      ),
      'year between (inclusive)': (
        const RuleCondition(RuleField.year, RuleOperator.between, [1980, 1989]),
        {'Kanavugal', 'Megam', 'Poove', 'Thendral'},
      ),
      'year atLeast': (
        const RuleCondition(RuleField.year, RuleOperator.atLeast, 2011),
        {'Kadhal', 'Mazhai', 'Paravai', 'Vennilaa'},
      ),
      'year atMost': (
        const RuleCondition(RuleField.year, RuleOperator.atMost, 1982),
        {'Kanavugal', 'Megam'},
      ),
      'duration (seconds) atLeast': (
        const RuleCondition(RuleField.duration, RuleOperator.atLeast, 4),
        {'Kanavugal', 'Thendral', 'Kadhal'},
      ),
      'duration between': (
        const RuleCondition(RuleField.duration, RuleOperator.between, [2.5, 2.8]),
        {'Natpu', 'Paravai'},
      ),
      'folder equals': (
        const RuleCondition(RuleField.folderPath, RuleOperator.equals, '/storage/emulated/0/Music/Yuvan Shankar Raja'),
        {'Nilavu', 'Thuli', 'Paravai', 'Vennilaa'},
      ),
      'format equals': (
        const RuleCondition(RuleField.format, RuleOperator.equals, 'WAV'),
        {for (final t in ['Kanavugal', 'Megam', 'Poove', 'Thendral', 'Minnal', 'Natpu', 'Kadhal', 'Mazhai', 'Nilavu', 'Thuli', 'Paravai', 'Vennilaa']) t},
      ),
      'no match': (
        const RuleCondition(RuleField.artist, RuleOperator.equals, 'nobody'),
        <String>{},
      ),
    };
    cases.forEach((name, c) {
      test(name, () async {
        expect(await eval(SmartRules(conditions: [c.$1])), c.$2);
      });
    });

    test('date added: inLastDays uses the injected clock', () async {
      // Fixture dateAdded = 500 + mediaStoreId (ids 101..112) seconds → epoch day 0.
      // "now" is day 10000, so nothing is within the last 30 days...
      expect(await eval(const SmartRules(conditions: [RuleCondition(RuleField.dateAdded, RuleOperator.inLastDays, 30)])), isEmpty);
      // ...but everything is within the last 20000 days.
      expect((await eval(const SmartRules(conditions: [RuleCondition(RuleField.dateAdded, RuleOperator.inLastDays, 20000)]))).length, 12);
    });

    test('date added between epoch seconds', () async {
      expect(
        await eval(const SmartRules(conditions: [RuleCondition(RuleField.dateAdded, RuleOperator.between, [601, 604])])),
        {'Kanavugal', 'Megam', 'Poove', 'Thendral'},
      );
    });
  });

  group('match modes', () {
    const rahman = RuleCondition(RuleField.artist, RuleOperator.equals, 'A. R. Rahman');
    const melody = RuleCondition(RuleField.genre, RuleOperator.equals, 'Melody');

    test('all = AND', () async {
      expect(await eval(const SmartRules(conditions: [rahman, melody])), {'Kadhal', 'Mazhai'});
    });
    test('any = OR', () async {
      expect(
        await eval(const SmartRules(matchMode: MatchMode.any, conditions: [rahman, melody])),
        {'Minnal', 'Natpu', 'Kadhal', 'Mazhai', 'Kanavugal', 'Megam', 'Vennilaa'},
      );
    });
    test('no conditions and no includes matches nothing', () async {
      expect(await eval(const SmartRules()), isEmpty);
    });
  });

  test('"Ilaiyaraaja 80s minus the sad ones" — include/exclude other groups (AP §3.3)',
      () async {
    final sad = await groups.createSmart(
        'Sad songs', const SmartRules(conditions: [RuleCondition(RuleField.genre, RuleOperator.equals, 'Sad')]));
    final id = await groups.createSmart(
      'Raja 80s',
      SmartRules(
        conditions: const [
          RuleCondition(RuleField.artist, RuleOperator.equals, 'Ilaiyaraaja'),
          RuleCondition(RuleField.year, RuleOperator.between, [1980, 1989]),
        ],
        excludeGroupIds: [sad],
      ),
    );
    expect(titles(await groups.songsIn(id)), {'Kanavugal', 'Megam'});
  });

  test('include a static group and a smart group', () async {
    final picks = await groups.createStatic('Picks', songIds: [songs[5].id, songs[10].id]);
    final dance = await groups.createSmart(
        'Dance', const SmartRules(conditions: [RuleCondition(RuleField.genre, RuleOperator.equals, 'Dance')]));
    final id = await groups.createSmart(
      'Combo',
      SmartRules(
        conditions: const [RuleCondition(RuleField.title, RuleOperator.equals, 'Kadhal')],
        matchMode: MatchMode.all,
        includeGroupIds: [picks, dance],
      ),
    );
    expect(titles(await groups.songsIn(id)), {'Kadhal', 'Natpu', 'Paravai', 'Minnal'});
  });

  test('manual pin / exclude overrides survive re-evaluation (AP §11.19)', () async {
    final id = await groups.createSmart(
        'Yuvan', const SmartRules(conditions: [RuleCondition(RuleField.artist, RuleOperator.equals, 'Yuvan Shankar Raja')]));
    await groups.pin(id, songs[0].id); // not matching, pinned in
    await groups.excludeSong(id, songs[8].id); // matching, excluded
    expect(titles(await groups.songsIn(id)), {'Kanavugal', 'Thuli', 'Paravai', 'Vennilaa'});

    // Editing the rules keeps overrides (they're part of the rule set).
    final rules = await groups.rulesFor(id);
    await groups.updateSmart(id, rules: rules.copyWith(matchMode: MatchMode.any));
    expect(titles(await groups.songsIn(id)), {'Kanavugal', 'Thuli', 'Paravai', 'Vennilaa'});

    await groups.clearOverride(id, songs[8].id);
    expect(titles(await groups.songsIn(id)), contains('Nilavu'));
  });

  test('exclude beats include and pin', () async {
    final all = await groups.createStatic('Everything', songIds: songs.map((s) => s.id).toList());
    final id = await groups.createSmart(
      'Not raja',
      SmartRules(
        includeGroupIds: [all],
        conditions: const [],
        excludeGroupIds: [
          await groups.createSmart('Raja', const SmartRules(conditions: [RuleCondition(RuleField.artist, RuleOperator.equals, 'Ilaiyaraaja')]))
        ],
        pinnedSongIds: [songs[0].id], // pinned, but inside the excluded group
      ),
    );
    final result = titles(await groups.songsIn(id));
    expect(result, isNot(contains('Kanavugal')));
    expect(result.length, 8);
  });

  test('cyclic references do not hang and contribute nothing', () async {
    final a = await groups.createSmart('A', const SmartRules(conditions: [RuleCondition(RuleField.title, RuleOperator.equals, 'Megam')]));
    final b = await groups.createSmart('B', SmartRules(includeGroupIds: [a]));
    await groups.updateSmart(a, rules: SmartRules(
      conditions: const [RuleCondition(RuleField.title, RuleOperator.equals, 'Megam')],
      includeGroupIds: [b], // A → B → A
    ));
    expect(titles(await groups.songsIn(a)), {'Megam'});
    expect(titles(await groups.songsIn(b)), {'Megam'});
  });

  test('a group never includes itself', () async {
    final id = await groups.createSmart('Self', const SmartRules(conditions: [RuleCondition(RuleField.year, RuleOperator.equals, 1982)]));
    await groups.updateSmart(id, rules: SmartRules(
      conditions: const [RuleCondition(RuleField.year, RuleOperator.equals, 1982)],
      includeGroupIds: [id],
    ));
    expect(titles(await groups.songsIn(id)), {'Kanavugal', 'Megam'});
  });

  group('static groups', () {
    test('hand-ordered, reorderable, removable', () async {
      final id = await groups.createStatic('Mix', songIds: [songs[3].id, songs[1].id, songs[7].id]);
      expect((await groups.songsIn(id)).map((s) => s.title), ['Thendral', 'Megam', 'Mazhai']);
      await groups.reorderStatic(id, songs[7].id, 0);
      expect((await groups.songsIn(id)).map((s) => s.title), ['Mazhai', 'Thendral', 'Megam']);
      await groups.removeSong(id, songs[3].id);
      expect((await groups.songsIn(id)).map((s) => s.title), ['Mazhai', 'Megam']);
      await groups.addSongs(id, [songs[0].id, songs[1].id]); // duplicate ignored
      expect((await groups.songsIn(id)).map((s) => s.title), ['Mazhai', 'Megam', 'Kanavugal']);
    });

    test('addToGroup: static appends, smart pins', () async {
      final st = await groups.createStatic('S');
      final sm = await groups.createSmart('M', const SmartRules());
      await groups.addToGroup(st, [songs[2].id]);
      await groups.addToGroup(sm, [songs[2].id]);
      expect(titles(await groups.songsIn(st)), {'Poove'});
      expect(titles(await groups.songsIn(sm)), {'Poove'});
    });
  });

  group('sorting & play mode', () {
    test('per-group default sort honoured, overridable', () async {
      final id = await groups.createSmart(
        'Raja',
        const SmartRules(conditions: [RuleCondition(RuleField.artist, RuleOperator.equals, 'Ilaiyaraaja')]),
        defaultSort: GroupSort.duration,
        ascending: false,
        playMode: 'shuffle',
      );
      expect((await groups.songsIn(id)).map((s) => s.title), ['Thendral', 'Kanavugal', 'Megam', 'Poove']);
      expect((await groups.songsIn(id, sort: GroupSort.year, ascending: true)).first.year, 1982);
      expect((await groups.groupById(id))!.defaultPlayMode, 'shuffle');
    });
  });

  group('built-in groups (AP §3.3, §11.18)', () {
    Future<SongGroup> builtin(String key) =>
        (db.select(db.groups)..where((g) => g.builtinKey.equals(key))).getSingle();

    test('favourites follows play_stats.favourite', () async {
      final stats = PlayStatsRepository(db);
      final fav = await builtin(BuiltinGroupKeys.favourites);
      expect(await groups.songsIn(fav.id), isEmpty);
      await stats.toggleFavourite(songs[4].id);
      await stats.toggleFavourite(songs[9].id);
      expect(titles(await groups.songsIn(fav.id)), {'Minnal', 'Thuli'});
      await stats.toggleFavourite(songs[4].id);
      expect(titles(await groups.songsIn(fav.id)), {'Thuli'});
    });

    test('most played: ordered by play count, only played songs', () async {
      final stats = PlayStatsRepository(db);
      for (var i = 0; i < 3; i++) {
        await stats.recordPlayCompleted(songs[6].id);
      }
      await stats.recordPlayCompleted(songs[2].id);
      final most = await builtin(BuiltinGroupKeys.mostPlayed);
      expect((await groups.songsIn(most.id)).map((s) => s.title), ['Kadhal', 'Poove']);
    });

    test('recently played: last 30 days, newest first', () async {
      final stats = PlayStatsRepository(db);
      await stats.recordPlayStarted(songs[0].id, now.subtract(const Duration(days: 5)));
      await stats.recordPlayStarted(songs[1].id, now.subtract(const Duration(days: 1)));
      await stats.recordPlayStarted(songs[2].id, now.subtract(const Duration(days: 90)));
      final recent = await builtin(BuiltinGroupKeys.recentlyPlayed);
      expect((await groups.songsIn(recent.id)).map((s) => s.title), ['Megam', 'Kanavugal']);
    });

    test('recently added reads date_added', () async {
      final recent = await builtin(BuiltinGroupKeys.recentlyAdded);
      expect(await groups.songsIn(recent.id), isEmpty); // fixtures are "old"
    });

    test('cannot be deleted, only hidden; can be restored', () async {
      final fav = await builtin(BuiltinGroupKeys.favourites);
      expect(await groups.delete(fav.id), isFalse);
      expect((await groups.groupById(fav.id))!.isHidden, isTrue);
      expect((await groups.watchSummaries().first).any((g) => g.group.id == fav.id), isFalse);
      await groups.unhide(fav.id);
      expect((await groups.watchSummaries().first).any((g) => g.group.id == fav.id), isTrue);
    });
  });

  test('excluded library folders never leak into groups', () async {
    final id = await groups.createSmart('All Raja',
        const SmartRules(conditions: [RuleCondition(RuleField.artist, RuleOperator.equals, 'Ilaiyaraaja')]));
    await library.excludeFolder('/storage/emulated/0/Music/Ilaiyaraaja');
    expect(await groups.songsIn(id), isEmpty);
    expect((await groups.preview(const SmartRules(conditions: [RuleCondition(RuleField.year, RuleOperator.equals, 1982)]))).count, 0);
  });

  test('duplicate and delete user groups', () async {
    final id = await groups.createSmart('Orig',
        const SmartRules(conditions: [RuleCondition(RuleField.year, RuleOperator.equals, 2008)]));
    final copy = await groups.duplicate(id);
    expect(titles(await groups.songsIn(copy)), {'Minnal', 'Natpu'});
    expect((await groups.groupById(copy))!.name, 'Orig (copy)');
    expect(await groups.delete(id), isTrue);
    expect(await groups.groupById(id), isNull);
    expect(titles(await groups.songsIn(copy)), {'Minnal', 'Natpu'}, reason: 'copy independent');
  });

  test('live preview reports count and a peek limited to N rows', () async {
    final p = await groups.preview(
        const SmartRules(conditions: [RuleCondition(RuleField.format, RuleOperator.equals, 'wav')]),
        peek: 5);
    expect(p.count, 12);
    expect(p.peek, hasLength(5));
  });

  test('rules JSON round-trips (TP §5.2 shape)', () {
    final rules = SmartRules(
      matchMode: MatchMode.any,
      conditions: const [
        RuleCondition(RuleField.artist, RuleOperator.equals, 'Ilaiyaraaja'),
        RuleCondition(RuleField.year, RuleOperator.between, [1980, 1989]),
      ],
      excludeGroupIds: const [7],
      pinnedSongIds: const ['abc'],
    );
    final back = SmartRules.fromJson(rules.toJson());
    expect(back.matchMode, MatchMode.any);
    expect(back.conditions, rules.conditions);
    expect(back.excludeGroupIds, [7]);
    expect(back.pinnedSongIds, ['abc']);
  });

  test('group summaries include counts and mosaic covers', () async {
    await groups.createStatic('Mix', songIds: songs.take(6).map((s) => s.id).toList());
    final s = (await groups.watchSummaries().first).firstWhere((g) => g.group.name == 'Mix');
    expect(s.songCount, 6);
    expect(s.coverContentUris, hasLength(4));
  });
}
