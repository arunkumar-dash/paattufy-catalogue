
import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/audio_features.dart';
import '../domain/scoring.dart';

/// `song_audio_features` access (TP §4.1). Absence of a row means "not yet
/// analysed", so Metadata-mode scoring applies automatically (AP §3.7a).
class FeatureRepository {
  FeatureRepository(this._db);
  final AppDatabase _db;

  /// Marker stored when a file cannot be decoded, so it is not retried forever.
  static const failedVersion = 'failed';

  Future<void> save(String songId, AudioFeatures f, String modelVersion, {DateTime? at}) =>
      _db.into(_db.songAudioFeaturesTable).insertOnConflictUpdate(
            SongAudioFeaturesTableCompanion.insert(
              songId: songId,
              tempoBpm: f.tempoBpm,
              keyIndex: f.keyIndex,
              keyMode: f.keyMode,
              energy: f.energy,
              acousticness: f.acousticness,
              brightness: f.brightness,
              danceability: f.danceability,
              embeddingBlob: f.hasEmbedding ? AudioFeatures.packFloats(f.embedding!) : Uint8List(0),
              modelVersion: modelVersion,
              analyzedAt: at ?? DateTime.now(),
            ),
          );

  Future<void> markFailed(String songId) => _db.into(_db.songAudioFeaturesTable).insertOnConflictUpdate(
        SongAudioFeaturesTableCompanion.insert(
          songId: songId,
          tempoBpm: 0,
          keyIndex: 0,
          keyMode: 1,
          energy: 0,
          acousticness: 0,
          brightness: 0,
          danceability: 0,
          embeddingBlob: Uint8List(0),
          modelVersion: failedVersion,
          analyzedAt: DateTime.now(),
        ),
      );

  /// Vectors for every successfully analysed song (failed markers skipped).
  Future<Map<String, SongFeatureVector>> loadVectors() async {
    final rows = await (_db.select(_db.songAudioFeaturesTable)
          ..where((t) => t.modelVersion.equals(failedVersion).not()))
        .get();
    return {for (final r in rows) r.songId: SongFeatureVector.from(_toFeatures(r))};
  }

  Future<AudioFeatures?> featuresFor(String songId) async {
    final r = await (_db.select(_db.songAudioFeaturesTable)..where((t) => t.songId.equals(songId)))
        .getSingleOrNull();
    if (r == null || r.modelVersion == failedVersion) return null;
    return _toFeatures(r);
  }

  AudioFeatures _toFeatures(SongAudioFeatures r) {
    final emb = AudioFeatures.unpackFloats(r.embeddingBlob);
    return AudioFeatures(
      tempoBpm: r.tempoBpm,
      keyIndex: r.keyIndex,
      keyMode: r.keyMode,
      energy: r.energy,
      acousticness: r.acousticness,
      brightness: r.brightness,
      danceability: r.danceability,
      embedding: emb.length == AudioFeatures.embeddingDims ? emb : null,
    );
  }

  /// Songs that still need analysis under [currentVersion]: no row yet, or a
  /// row produced by an older pipeline (e.g. before the YAMNet model was
  /// bundled). Newest additions first. Failed markers are never retried.
  Future<List<Song>> songsNeedingAnalysis(String currentVersion, {int limit = 5, List<String>? excludedFolders}) async {
    final s = _db.songs;
    final f = _db.songAudioFeaturesTable;
    final q = _db.select(s).join([
      leftOuterJoin(f, f.songId.equalsExp(s.id)),
    ])
      ..where(f.songId.isNull() |
          (f.modelVersion.equals(currentVersion).not() & f.modelVersion.equals(failedVersion).not()))
      ..orderBy([OrderingTerm.desc(s.dateAdded), OrderingTerm.asc(s.id)])
      ..limit(limit * 4); // over-fetch then drop excluded folders client-side
    final rows = await q.get();
    final ex = excludedFolders ?? const [];
    bool hidden(String folder) => ex.any((e) => folder == e || folder.startsWith('$e/'));
    return [
      for (final r in rows)
        if (!hidden(r.readTable(s).folderPath)) r.readTable(s),
    ].take(limit).toList();
  }

  Future<({int analysed, int total})> progress(String currentVersion) async {
    final total = await _db.songs.count().getSingle();
    final analysed = await (_db.selectOnly(_db.songAudioFeaturesTable)
          ..addColumns([_db.songAudioFeaturesTable.songId.count()])
          ..where(_db.songAudioFeaturesTable.modelVersion.equals(failedVersion).not()))
        .map((r) => r.read(_db.songAudioFeaturesTable.songId.count()) ?? 0)
        .getSingle();
    return (analysed: analysed, total: total);
  }

  Future<void> clearAll() => _db.delete(_db.songAudioFeaturesTable).go();
}
