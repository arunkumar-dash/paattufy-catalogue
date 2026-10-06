import '../../../core/database/app_database.dart';

/// Settings → About → Reset: wipes user-created app data (groups, stats, lyric
/// picks, queue, features, caches, download history). The media library itself
/// is never touched — it is read-only (AP §11.8).
class ResetService {
  ResetService(this._db);
  final AppDatabase _db;

  Future<void> resetAppData() => _db.transaction(() async {
        await (_db.delete(_db.groups)..where((g) => g.isBuiltin.equals(false))).go();
        await _db.delete(_db.queueItems).go();
        await _db.customStatement('UPDATE queue_pointer SET current_item_id = NULL, source_description = ""');
        await _db.delete(_db.playStats).go();
        await _db.delete(_db.lyricsCache).go();
        await _db.delete(_db.songAudioFeaturesTable).go();
        await _db.delete(_db.remoteCatalogueCache).go();
        await _db.delete(_db.downloadHistory).go();
        await _db.delete(_db.excludedFolders).go();
        await _db.customStatement('UPDATE groups SET is_hidden = 0');
      });
}
