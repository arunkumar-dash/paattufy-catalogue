import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/settings/app_settings.dart';

class RestoreReport {
  const RestoreReport({
    this.groups = 0,
    this.songsMatched = 0,
    this.songsUnmatched = 0,
    this.statsRestored = 0,
    this.lyricsRestored = 0,
    this.queueRestored = false,
  });
  final int groups;
  final int songsMatched;
  final int songsUnmatched;
  final int statsRestored;
  final int lyricsRestored;
  final bool queueRestored;

  @override
  String toString() =>
      'RestoreReport(groups: $groups, matched: $songsMatched, unmatched: $songsUnmatched, stats: $statsRestored, lyrics: $lyricsRestored, queue: $queueRestored)';
}

class BackupFormatException implements Exception {
  BackupFormatException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Backup / restore of the irreplaceable app data — hand-built groups, play
/// counts, lyric picks, the queue and settings — to one JSON file (AP §8.11).
///
/// Song identity is `hash(mediaStoreId + path)`, and MediaStore ids change
/// across reinstalls, so the backup refers to songs by **file path** (with a
/// title+artist+duration fallback) and re-maps them on restore.
class BackupService {
  BackupService(this._db);
  final AppDatabase _db;

  static const schemaVersion = 1;

  // --- export ---------------------------------------------------------------

  Future<String> exportJson(AppSettings settings, {DateTime? now}) async {
    final songs = await _db.select(_db.songs).get();
    final refOf = <String, int>{};
    final refs = <Map<String, Object?>>[];
    int ref(String songId) => refOf.putIfAbsent(songId, () {
          final s = songs.firstWhere((x) => x.id == songId);
          refs.add({'path': s.filePath, 'title': s.title, 'artist': s.artist, 'durationMs': s.durationMs});
          return refs.length - 1;
        });

    final groups = await _db.select(_db.groups).get();
    final keyOf = {for (var i = 0; i < groups.length; i++) groups[i].id: i};
    final groupsJson = <Map<String, Object?>>[];
    for (final g in groups) {
      final conds = await (_db.select(_db.groupConditions)
            ..where((c) => c.groupId.equals(g.id))
            ..orderBy([(c) => OrderingTerm.asc(c.position)]))
          .get();
      final grefs = await (_db.select(_db.groupRefs)..where((r) => r.groupId.equals(g.id))).get();
      final overrides = await (_db.select(_db.groupOverrides)..where((o) => o.groupId.equals(g.id))).get();
      final items = await (_db.select(_db.groupStaticItems)
            ..where((i) => i.groupId.equals(g.id))
            ..orderBy([(i) => OrderingTerm.asc(i.position)]))
          .get();
      groupsJson.add({
        'key': keyOf[g.id],
        'name': g.name,
        'type': g.type,
        'builtinKey': g.builtinKey,
        'hidden': g.isHidden,
        'coverUri': g.coverUri,
        'defaultSort': g.defaultSort,
        'defaultSortAscending': g.defaultSortAscending,
        'defaultPlayMode': g.defaultPlayMode,
        'matchMode': g.matchMode,
        'conditions': [
          for (final c in conds) {'field': c.field, 'operator': c.operator, 'value': jsonDecode(c.valueJson)},
        ],
        'include': [for (final r in grefs) if (r.kind == 'include' && keyOf[r.refGroupId] != null) keyOf[r.refGroupId]],
        'exclude': [for (final r in grefs) if (r.kind == 'exclude' && keyOf[r.refGroupId] != null) keyOf[r.refGroupId]],
        'pins': [for (final o in overrides) if (o.kind == 'pin') ref(o.songId)],
        'excludes': [for (final o in overrides) if (o.kind == 'exclude') ref(o.songId)],
        'items': [for (final i in items) ref(i.songId)],
      });
    }

    final stats = await _db.select(_db.playStats).get();
    final statsJson = [
      for (final s in stats)
        {
          'ref': ref(s.songId),
          'playCount': s.playCount,
          'skipCount': s.skipCount,
          'lastPlayedAt': s.lastPlayedAt?.toIso8601String(),
          'favourite': s.favourite,
        },
    ];

    final lyrics = await _db.select(_db.lyricsCache).get();
    final lyricsJson = [
      for (final l in lyrics)
        {
          'ref': ref(l.songId),
          'providerId': l.providerId,
          'syncedLrc': l.syncedLrc,
          'plainText': l.plainText,
          'source': l.source,
          'offsetMs': l.offsetMs,
        },
    ];

    final queueRows = await (_db.select(_db.queueItems)
          ..orderBy([(t) => OrderingTerm.asc(t.sequence), (t) => OrderingTerm.asc(t.id)]))
        .get();
    final pointer = await (_db.select(_db.queuePointer)..where((t) => t.id.equals(1))).getSingle();
    final currentIndex = queueRows.indexWhere((q) => q.id == pointer.currentItemId);

    final excluded = await _db.select(_db.excludedFolders).get();

    return const JsonEncoder.withIndent('  ').convert({
      'app': 'paattufy',
      'schemaVersion': schemaVersion,
      'exportedAt': (now ?? DateTime.now()).toUtc().toIso8601String(),
      'settings': settings.toJson(),
      'excludedFolders': [for (final e in excluded) e.folderPath],
      'songs': refs,
      'groups': groupsJson,
      'playStats': statsJson,
      'lyrics': lyricsJson,
      'queue': {
        'items': [for (final q in queueRows) {'ref': ref(q.songId), 'source': q.source}],
        'currentIndex': currentIndex,
        'description': pointer.sourceDescription,
      },
    });
  }

  // --- restore --------------------------------------------------------------------

  /// Parses and validates without touching the database.
  static Map<String, Object?> parse(String source) {
    final Object? decoded;
    try {
      decoded = jsonDecode(source);
    } catch (_) {
      throw BackupFormatException('This file is not valid JSON');
    }
    if (decoded is! Map || decoded['app'] != 'paattufy') {
      throw BackupFormatException('This is not a Paattufy backup');
    }
    final v = (decoded['schemaVersion'] as num?)?.toInt();
    if (v == null || v > schemaVersion) {
      throw BackupFormatException('Backup was made by a newer version (schema $v)');
    }
    return decoded.cast<String, Object?>();
  }

  /// Restores into the current library. Groups and the queue are *replaced*;
  /// play stats and lyric picks are upserted. Returns the merged settings for
  /// the caller to persist.
  Future<(RestoreReport, AppSettings?)> restore(String source, AppSettings current) async {
    final data = parse(source);
    final refs = (data['songs'] as List? ?? const []).cast<Map>();

    final songs = await _db.select(_db.songs).get();
    final byPath = {for (final s in songs) s.filePath: s};
    final byMeta = <String, Song>{};
    for (final s in songs) {
      byMeta.putIfAbsent('${s.title.toLowerCase()}|${s.artist.toLowerCase()}|${s.durationMs ~/ 2000}', () => s);
    }
    final resolved = <int, Song?>{};
    var matched = 0, unmatched = 0;
    for (var i = 0; i < refs.length; i++) {
      final r = refs[i];
      final s = byPath[r['path']] ??
          byMeta['${(r['title'] as String? ?? '').toLowerCase()}|${(r['artist'] as String? ?? '').toLowerCase()}|${((r['durationMs'] as num?) ?? 0).toInt() ~/ 2000}'];
      resolved[i] = s;
      s == null ? unmatched++ : matched++;
    }
    Song? song(Object? ref) => ref is num ? resolved[ref.toInt()] : null;

    var groupCount = 0, statsCount = 0, lyricsCount = 0;
    var queueRestored = false;

    await _db.transaction(() async {
      // --- groups
      final groupsJson = (data['groups'] as List? ?? const []).cast<Map>();
      await (_db.delete(_db.groups)..where((g) => g.isBuiltin.equals(false))).go();
      final idOfKey = <int, int>{};
      final now = DateTime.now();
      for (final g in groupsJson) {
        final key = (g['key'] as num).toInt();
        if (g['builtinKey'] != null) {
          final row = await (_db.select(_db.groups)..where((x) => x.builtinKey.equals(g['builtinKey'] as String)))
              .getSingleOrNull();
          if (row != null) {
            idOfKey[key] = row.id;
            await (_db.update(_db.groups)..where((x) => x.id.equals(row.id)))
                .write(GroupsCompanion(isHidden: Value(g['hidden'] == true)));
          }
          continue;
        }
        final id = await _db.into(_db.groups).insert(GroupsCompanion.insert(
              name: g['name'] as String,
              type: g['type'] as String,
              coverUri: Value(g['coverUri'] as String?),
              defaultSort: Value((g['defaultSort'] as String?) ?? 'title'),
              defaultSortAscending: Value(g['defaultSortAscending'] != false),
              defaultPlayMode: Value((g['defaultPlayMode'] as String?) ?? 'ordered'),
              matchMode: Value((g['matchMode'] as String?) ?? 'all'),
              isHidden: Value(g['hidden'] == true),
              createdAt: now,
              updatedAt: now,
            ));
        idOfKey[key] = id;
        groupCount++;
      }
      for (final g in groupsJson) {
        final id = idOfKey[(g['key'] as num).toInt()];
        if (id == null || g['builtinKey'] != null) continue;
        final conds = (g['conditions'] as List? ?? const []).cast<Map>();
        for (var i = 0; i < conds.length; i++) {
          await _db.into(_db.groupConditions).insert(GroupConditionsCompanion.insert(
                groupId: id,
                field: conds[i]['field'] as String,
                operator: conds[i]['operator'] as String,
                valueJson: jsonEncode(conds[i]['value']),
                position: Value(i),
              ));
        }
        for (final kind in const ['include', 'exclude']) {
          for (final k in (g[kind] as List? ?? const [])) {
            final ref = idOfKey[(k as num).toInt()];
            if (ref == null || ref == id) continue;
            await _db.into(_db.groupRefs).insert(
                  GroupRefsCompanion.insert(groupId: id, refGroupId: ref, kind: kind),
                  mode: InsertMode.insertOrReplace,
                );
          }
        }
        for (final entry in {'pins': 'pin', 'excludes': 'exclude'}.entries) {
          for (final r in (g[entry.key] as List? ?? const [])) {
            final s = song(r);
            if (s == null) continue;
            await _db.into(_db.groupOverrides).insert(
                  GroupOverridesCompanion.insert(groupId: id, songId: s.id, kind: entry.value),
                  mode: InsertMode.insertOrReplace,
                );
          }
        }
        var pos = 0;
        for (final r in (g['items'] as List? ?? const [])) {
          final s = song(r);
          if (s == null) continue;
          await _db.into(_db.groupStaticItems).insert(
                GroupStaticItemsCompanion.insert(groupId: id, songId: s.id, position: pos++),
                mode: InsertMode.insertOrIgnore,
              );
        }
      }

      // --- play stats
      for (final s in (data['playStats'] as List? ?? const []).cast<Map>()) {
        final so = song(s['ref']);
        if (so == null) continue;
        await _db.into(_db.playStats).insertOnConflictUpdate(PlayStatsCompanion.insert(
              songId: so.id,
              playCount: Value((s['playCount'] as num?)?.toInt() ?? 0),
              skipCount: Value((s['skipCount'] as num?)?.toInt() ?? 0),
              lastPlayedAt: Value(s['lastPlayedAt'] == null ? null : DateTime.tryParse(s['lastPlayedAt'] as String)),
              favourite: Value(s['favourite'] == true),
            ));
        statsCount++;
      }

      // --- lyric picks
      for (final l in (data['lyrics'] as List? ?? const []).cast<Map>()) {
        final so = song(l['ref']);
        if (so == null) continue;
        await _db.into(_db.lyricsCache).insertOnConflictUpdate(LyricsCacheCompanion.insert(
              songId: so.id,
              providerId: (l['providerId'] as String?) ?? 'none',
              syncedLrc: Value(l['syncedLrc'] as String?),
              plainText: Value(l['plainText'] as String?),
              source: (l['source'] as String?) ?? 'remote',
              offsetMs: Value((l['offsetMs'] as num?)?.toInt() ?? 0),
              fetchedAt: DateTime.now(),
            ));
        lyricsCount++;
      }

      // --- excluded folders
      for (final f in (data['excludedFolders'] as List? ?? const []).whereType<String>()) {
        await _db.into(_db.excludedFolders).insert(
              ExcludedFoldersCompanion.insert(folderPath: f),
              mode: InsertMode.insertOrIgnore,
            );
      }

      // --- queue (replace only if something maps)
      final q = data['queue'];
      if (q is Map) {
        final items = (q['items'] as List? ?? const []).cast<Map>();
        final mapped = [for (final i in items) (song(i['ref']), i['source'] as String? ?? 'manual')]
            .where((e) => e.$1 != null)
            .toList();
        if (mapped.isNotEmpty) {
          await _db.delete(_db.queueItems).go();
          final ids = <int>[];
          for (var i = 0; i < mapped.length; i++) {
            ids.add(await _db.into(_db.queueItems).insert(QueueItemsCompanion.insert(
                  sequence: (i + 1) * 1000.0,
                  songId: mapped[i].$1!.id,
                  source: Value(mapped[i].$2),
                  addedAt: DateTime.now(),
                )));
          }
          final idx = (q['currentIndex'] as num?)?.toInt() ?? 0;
          await (_db.update(_db.queuePointer)..where((t) => t.id.equals(1))).write(QueuePointerCompanion(
            currentItemId: Value(ids[idx.clamp(0, ids.length - 1)]),
            sourceDescription: Value((q['description'] as String?) ?? ''),
          ));
          queueRestored = true;
        }
      }
    });

    final settingsJson = data['settings'];
    final merged = settingsJson is Map ? current.mergeJson(settingsJson.cast<String, Object?>()) : null;
    return (
      RestoreReport(
        groups: groupCount,
        songsMatched: matched,
        songsUnmatched: unmatched,
        statsRestored: statsCount,
        lyricsRestored: lyricsCount,
        queueRestored: queueRestored,
      ),
      merged,
    );
  }
}
