import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';

/// Play-count / skip-count / last-played / favourite (AP §8.2, §8.4). Backs
/// the built-in groups and suggestion scoring.
class PlayStatsRepository {
  PlayStatsRepository(this._db);
  final AppDatabase _db;

  Future<void> _ensure(String songId) => _db.into(_db.playStats).insert(
        PlayStatsCompanion.insert(songId: songId),
        mode: InsertMode.insertOrIgnore,
      );

  Future<void> recordPlayStarted(String songId, DateTime at) async {
    await _ensure(songId);
    await (_db.update(_db.playStats)..where((t) => t.songId.equals(songId)))
        .write(PlayStatsCompanion(lastPlayedAt: Value(at)));
  }

  Future<void> recordPlayCompleted(String songId) async {
    await _ensure(songId);
    await _db.customStatement(
      'UPDATE play_stats SET play_count = play_count + 1 WHERE song_id = ?',
      [songId],
    );
  }

  Future<void> recordSkip(String songId) async {
    await _ensure(songId);
    await _db.customStatement(
      'UPDATE play_stats SET skip_count = skip_count + 1 WHERE song_id = ?',
      [songId],
    );
  }

  Future<bool> toggleFavourite(String songId) async {
    await _ensure(songId);
    final row = await (_db.select(_db.playStats)..where((t) => t.songId.equals(songId))).getSingle();
    final next = !row.favourite;
    await (_db.update(_db.playStats)..where((t) => t.songId.equals(songId)))
        .write(PlayStatsCompanion(favourite: Value(next)));
    return next;
  }

  Stream<bool> watchFavourite(String songId) =>
      (_db.select(_db.playStats)..where((t) => t.songId.equals(songId)))
          .watchSingleOrNull()
          .map((r) => r?.favourite ?? false);

  Future<PlayStat?> statFor(String songId) =>
      (_db.select(_db.playStats)..where((t) => t.songId.equals(songId))).getSingleOrNull();

  Future<Map<String, PlayStat>> allStats() async => {
        for (final s in await _db.select(_db.playStats).get()) s.songId: s,
      };
}
