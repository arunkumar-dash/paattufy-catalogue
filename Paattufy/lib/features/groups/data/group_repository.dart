import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../library/data/library_repository.dart';
import '../domain/rules.dart';
import 'rule_compiler.dart';

/// Sort keys groups may default to: the library ones plus play-history and the
/// hand-ordered `manual` (static groups).
class GroupSort {
  static const manual = 'manual';
  static const title = 'title';
  static const artist = 'artist';
  static const album = 'album';
  static const dateAdded = 'dateAdded';
  static const duration = 'duration';
  static const year = 'year';
  static const lastPlayed = 'lastPlayed';
  static const playCount = 'playCount';

  static const all = [manual, title, artist, album, dateAdded, duration, year, lastPlayed, playCount];
}

class GroupSummary {
  const GroupSummary(this.group, this.songCount, this.coverContentUris);
  final SongGroup group;
  final int songCount;

  /// Up to four song URIs for the 2×2 art mosaic (AP §5.4).
  final List<String> coverContentUris;
}

class RulePreview {
  const RulePreview(this.count, this.peek);
  final int count;
  final List<Song> peek;
}

/// Static + smart groups (TP §5.2).
class GroupRepository {
  GroupRepository(this._db, this._library, {DateTime Function()? clock})
      : _clock = clock ?? DateTime.now,
        _compiler = RuleCompiler(_db, clock: clock);

  final AppDatabase _db;
  final LibraryRepository _library;
  final DateTime Function() _clock;
  final RuleCompiler _compiler;

  RuleCompiler get compiler => _compiler;

  // --- listing -------------------------------------------------------------

  Stream<List<SongGroup>> watchGroupRows({bool includeHidden = false}) =>
      (_db.select(_db.groups)
            ..where((g) => includeHidden ? const Constant(true) : g.isHidden.equals(false))
            ..orderBy([
              (g) => OrderingTerm.desc(g.isBuiltin),
              (g) => OrderingTerm.asc(g.name.lower()),
            ]))
          .watch();

  Stream<List<GroupSummary>> watchSummaries() {
    final trigger = _db.tableUpdates(TableUpdateQuery.onAllTables([
      _db.groups,
      _db.groupConditions,
      _db.groupStaticItems,
      _db.groupRefs,
      _db.groupOverrides,
      _db.songs,
      _db.playStats,
      _db.excludedFolders,
    ]));
    return Stream<void>.multi((c) {
      c.add(null);
      final sub = trigger.listen((_) => c.add(null), onError: c.addError);
      c.onCancel = sub.cancel;
    }).asyncMap((_) async {
      final rows = await (_db.select(_db.groups)
            ..where((g) => g.isHidden.equals(false))
            ..orderBy([(g) => OrderingTerm.desc(g.isBuiltin), (g) => OrderingTerm.asc(g.name.lower())]))
          .get();
      final out = <GroupSummary>[];
      for (final g in rows) {
        final songs = await songsIn(g.id);
        out.add(GroupSummary(g, songs.length, [for (final s in songs.take(4)) s.contentUri]));
      }
      return out;
    });
  }

  Future<SongGroup?> groupById(int id) =>
      (_db.select(_db.groups)..where((g) => g.id.equals(id))).getSingleOrNull();

  // --- creation / editing ---------------------------------------------------

  Future<int> createStatic(String name, {List<String> songIds = const []}) async {
    final now = _clock();
    return _db.transaction(() async {
      final id = await _db.into(_db.groups).insert(GroupsCompanion.insert(
            name: name,
            type: 'static',
            defaultSort: const Value(GroupSort.manual),
            createdAt: now,
            updatedAt: now,
          ));
      await addSongs(id, songIds);
      return id;
    });
  }

  Future<int> createSmart(
    String name,
    SmartRules rules, {
    String defaultSort = GroupSort.title,
    bool ascending = true,
    String playMode = 'ordered',
  }) async {
    final now = _clock();
    return _db.transaction(() async {
      final id = await _db.into(_db.groups).insert(GroupsCompanion.insert(
            name: name,
            type: 'smart',
            matchMode: Value(rules.matchMode.name),
            defaultSort: Value(defaultSort),
            defaultSortAscending: Value(ascending),
            defaultPlayMode: Value(playMode),
            createdAt: now,
            updatedAt: now,
          ));
      await _writeRules(id, rules);
      return id;
    });
  }

  Future<void> updateSmart(
    int groupId, {
    String? name,
    SmartRules? rules,
    String? defaultSort,
    bool? ascending,
    String? playMode,
    String? coverUri,
  }) =>
      _db.transaction(() async {
        await (_db.update(_db.groups)..where((g) => g.id.equals(groupId))).write(GroupsCompanion(
          name: name == null ? const Value.absent() : Value(name),
          matchMode: rules == null ? const Value.absent() : Value(rules.matchMode.name),
          defaultSort: defaultSort == null ? const Value.absent() : Value(defaultSort),
          defaultSortAscending: ascending == null ? const Value.absent() : Value(ascending),
          defaultPlayMode: playMode == null ? const Value.absent() : Value(playMode),
          coverUri: coverUri == null ? const Value.absent() : Value(coverUri),
          updatedAt: Value(_clock()),
        ));
        if (rules != null) await _writeRules(groupId, rules);
      });

  Future<void> _writeRules(int groupId, SmartRules rules) async {
    await (_db.delete(_db.groupConditions)..where((c) => c.groupId.equals(groupId))).go();
    await (_db.delete(_db.groupRefs)..where((r) => r.groupId.equals(groupId))).go();
    await (_db.delete(_db.groupOverrides)..where((o) => o.groupId.equals(groupId))).go();
    for (var i = 0; i < rules.conditions.length; i++) {
      final c = rules.conditions[i];
      await _db.into(_db.groupConditions).insert(GroupConditionsCompanion.insert(
            groupId: groupId,
            field: c.field.name,
            operator: c.operator.name,
            valueJson: jsonEncode(c.value),
            position: Value(i),
          ));
    }
    for (final id in rules.includeGroupIds) {
      if (id == groupId) continue;
      await _db.into(_db.groupRefs).insert(
            GroupRefsCompanion.insert(groupId: groupId, refGroupId: id, kind: 'include'),
            mode: InsertMode.insertOrReplace,
          );
    }
    for (final id in rules.excludeGroupIds) {
      if (id == groupId) continue;
      await _db.into(_db.groupRefs).insert(
            GroupRefsCompanion.insert(groupId: groupId, refGroupId: id, kind: 'exclude'),
            mode: InsertMode.insertOrReplace,
          );
    }
    for (final s in rules.pinnedSongIds) {
      await _db.into(_db.groupOverrides).insert(
            GroupOverridesCompanion.insert(groupId: groupId, songId: s, kind: 'pin'),
            mode: InsertMode.insertOrReplace,
          );
    }
    for (final s in rules.excludedSongIds) {
      await _db.into(_db.groupOverrides).insert(
            GroupOverridesCompanion.insert(groupId: groupId, songId: s, kind: 'exclude'),
            mode: InsertMode.insertOrReplace,
          );
    }
  }

  Future<SmartRules> rulesFor(int groupId) => _compiler.loadRules(groupId);

  Future<void> rename(int groupId, String name) =>
      (_db.update(_db.groups)..where((g) => g.id.equals(groupId)))
          .write(GroupsCompanion(name: Value(name), updatedAt: Value(_clock())));

  /// Built-in groups can be hidden but never deleted (AP §3.3).
  Future<bool> delete(int groupId) async {
    final g = await groupById(groupId);
    if (g == null) return false;
    if (g.isBuiltin) {
      await (_db.update(_db.groups)..where((x) => x.id.equals(groupId)))
          .write(const GroupsCompanion(isHidden: Value(true)));
      return false;
    }
    await (_db.delete(_db.groups)..where((x) => x.id.equals(groupId))).go();
    return true;
  }

  Future<void> unhide(int groupId) => (_db.update(_db.groups)..where((x) => x.id.equals(groupId)))
      .write(const GroupsCompanion(isHidden: Value(false)));

  Future<int> duplicate(int groupId) async {
    final g = (await groupById(groupId))!;
    final name = '${g.name} (copy)';
    if (g.type == 'static') {
      final ids = (await songsIn(groupId)).map((s) => s.id).toList();
      final id = await createStatic(name, songIds: ids);
      await updateSmart(id, defaultSort: g.defaultSort, ascending: g.defaultSortAscending, playMode: g.defaultPlayMode);
      return id;
    }
    return createSmart(
      name,
      await rulesFor(groupId),
      defaultSort: g.defaultSort,
      ascending: g.defaultSortAscending,
      playMode: g.defaultPlayMode,
    );
  }

  // --- static membership ------------------------------------------------------

  Future<void> addSongs(int groupId, List<String> songIds) async {
    if (songIds.isEmpty) return;
    await _db.transaction(() async {
      final posMax = _db.groupStaticItems.position.max();
      final row = await (_db.selectOnly(_db.groupStaticItems)
            ..addColumns([posMax])
            ..where(_db.groupStaticItems.groupId.equals(groupId)))
          .getSingle();
      var pos = (row.read(posMax) ?? -1) + 1;
      for (final id in songIds) {
        await _db.into(_db.groupStaticItems).insert(
              GroupStaticItemsCompanion.insert(groupId: groupId, songId: id, position: pos),
              mode: InsertMode.insertOrIgnore,
            );
        pos++;
      }
    });
  }

  Future<void> removeSong(int groupId, String songId) => (_db.delete(_db.groupStaticItems)
        ..where((t) => t.groupId.equals(groupId) & t.songId.equals(songId)))
      .go();

  /// Drag-reorder within a static group; positions are renumbered densely.
  Future<void> reorderStatic(int groupId, String songId, int toIndex) => _db.transaction(() async {
        final items = await (_db.select(_db.groupStaticItems)
              ..where((t) => t.groupId.equals(groupId))
              ..orderBy([(t) => OrderingTerm.asc(t.position)]))
            .get();
        final from = items.indexWhere((i) => i.songId == songId);
        if (from < 0) return;
        final ids = items.map((i) => i.songId).toList();
        final moved = ids.removeAt(from);
        ids.insert(toIndex.clamp(0, ids.length), moved);
        for (var i = 0; i < ids.length; i++) {
          await (_db.update(_db.groupStaticItems)
                ..where((t) => t.groupId.equals(groupId) & t.songId.equals(ids[i])))
              .write(GroupStaticItemsCompanion(position: Value(i)));
        }
      });

  // --- smart overrides (AP §3.3, §11.19) -----------------------------------------

  Future<void> pin(int groupId, String songId) => _setOverride(groupId, songId, 'pin');
  Future<void> excludeSong(int groupId, String songId) => _setOverride(groupId, songId, 'exclude');
  Future<void> clearOverride(int groupId, String songId) => (_db.delete(_db.groupOverrides)
        ..where((o) => o.groupId.equals(groupId) & o.songId.equals(songId)))
      .go();

  Future<void> _setOverride(int groupId, String songId, String kind) =>
      _db.into(_db.groupOverrides).insert(
            GroupOverridesCompanion.insert(groupId: groupId, songId: songId, kind: kind),
            mode: InsertMode.insertOrReplace,
          );

  /// "Add to group" from a song menu: static → append; smart → pin.
  Future<void> addToGroup(int groupId, List<String> songIds) async {
    final g = await groupById(groupId);
    if (g == null) return;
    if (g.type == 'static') {
      await addSongs(groupId, songIds);
    } else {
      for (final id in songIds) {
        await pin(groupId, id);
      }
    }
  }

  // --- evaluation --------------------------------------------------------------------

  /// Members of [groupId], sorted by [sort]/[ascending] (defaults to the
  /// group's own default sort). Excluded library folders are always honoured.
  Future<List<Song>> songsIn(int groupId, {String? sort, bool? ascending}) async {
    final g = await groupById(groupId);
    if (g == null) return const [];
    final excluded = await _library.excludedFolders();
    final member = await _compiler.membership(groupId);
    return _query(member, excluded, sort ?? g.defaultSort, ascending ?? g.defaultSortAscending,
        staticGroupId: g.type == 'static' ? groupId : null);
  }

  Stream<List<Song>> watchSongsIn(int groupId, {String? sort, bool? ascending}) {
    final trigger = _db.tableUpdates(TableUpdateQuery.onAllTables([
      _db.groups,
      _db.groupConditions,
      _db.groupStaticItems,
      _db.groupRefs,
      _db.groupOverrides,
      _db.songs,
      _db.playStats,
      _db.excludedFolders,
    ]));
    return Stream<void>.multi((c) {
      c.add(null);
      final sub = trigger.listen((_) => c.add(null), onError: c.addError);
      c.onCancel = sub.cancel;
    }).asyncMap((_) => songsIn(groupId, sort: sort, ascending: ascending));
  }

  /// Live preview for the rule builder (TP §5.2): evaluates an *unsaved* rule
  /// set against the real on-device data.
  Future<RulePreview> preview(SmartRules rules, {int peek = 20}) async {
    final excluded = await _library.excludedFolders();
    final expr = await _compiler.compileRules(rules);
    final all = await _query(expr, excluded, GroupSort.title, true);
    return RulePreview(all.length, all.take(peek).toList());
  }

  Future<List<Song>> _query(
    Expression<bool> member,
    List<String> excluded,
    String sort,
    bool asc, {
    int? staticGroupId,
  }) {
    final songs = _db.songs;
    final q = _db.select(_db.songs)
      ..where((t) => member & _library.notExcluded(t, excluded));
    OrderingTerm term(Expression e) =>
        OrderingTerm(expression: e, mode: asc ? OrderingMode.asc : OrderingMode.desc);
    final orderings = <OrderingTerm Function($SongsTable)>[];
    if (sort == GroupSort.manual && staticGroupId != null) {
      orderings.add((t) => OrderingTerm.asc(CustomExpression<int>(
          '(SELECT gsi.position FROM group_static_items gsi WHERE gsi.group_id = $staticGroupId AND gsi.song_id = songs.id)')));
    } else {
      orderings.add((t) => switch (sort) {
            GroupSort.artist => term(t.artist.lower()),
            GroupSort.album => term(t.album.lower()),
            GroupSort.dateAdded => term(t.dateAdded),
            GroupSort.duration => term(t.durationMs),
            GroupSort.year => term(t.year),
            GroupSort.lastPlayed => term(CustomExpression<int>(
                '(SELECT CAST(ps.last_played_at AS INTEGER) FROM play_stats ps WHERE ps.song_id = songs.id)')),
            GroupSort.playCount => term(CustomExpression<int>(
                'COALESCE((SELECT ps.play_count FROM play_stats ps WHERE ps.song_id = songs.id), 0)')),
            _ => term(t.title.lower()),
          });
    }
    orderings.add((t) => OrderingTerm.asc(t.title.lower()));
    q.orderBy(orderings);
    // `songs` alias is referenced by the correlated sub-selects above.
    assert(songs.actualTableName == 'songs');
    return q.get();
  }
}
