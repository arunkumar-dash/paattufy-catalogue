import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/utils/song_id.dart';
import '../domain/media_scanner.dart';
import 'library_repository.dart';

class ScanResult {
  const ScanResult({
    required this.added,
    required this.updated,
    required this.removed,
    required this.total,
  });
  final int added;
  final int updated;
  final int removed;
  final int total;

  @override
  String toString() =>
      'ScanResult(added: $added, updated: $updated, removed: $removed, total: $total)';
}

/// Full and incremental library scans (TP §5.1).
///
/// * Full scan: onboarding and manual "Rescan now".
/// * Incremental scan: app resume and after a download-hub extraction; only
///   files modified after the watermark are fetched.
class LibraryScanService {
  LibraryScanService(this._scanner, this._repo, {this.pageSize = 500});

  final MediaScanner _scanner;
  final LibraryRepository _repo;
  final int pageSize;

  bool _running = false;
  bool get isRunning => _running;

  Future<ScanResult> fullScan({
    required int minDurationMs,
    void Function(int found)? onProgress,
    int? nowSec,
  }) =>
      _scan(
        incremental: false,
        minDurationMs: minDurationMs,
        onProgress: onProgress,
        nowSec: nowSec,
      );

  Future<ScanResult> incrementalScan({
    required int minDurationMs,
    void Function(int found)? onProgress,
    int? nowSec,
  }) =>
      _scan(
        incremental: true,
        minDurationMs: minDurationMs,
        onProgress: onProgress,
        nowSec: nowSec,
      );

  Future<ScanResult> _scan({
    required bool incremental,
    required int minDurationMs,
    void Function(int found)? onProgress,
    int? nowSec,
  }) async {
    if (_running) {
      throw StateError('A scan is already running');
    }
    _running = true;
    try {
      final scanAt = nowSec ?? DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final excluded = await _repo.excludedFolders();
      final since = incremental ? await _repo.scanWatermark() : null;

      var added = 0;
      var updated = 0;
      var found = 0;
      var offset = 0;
      while (true) {
        final page = await _scanner.scanPage(
          excludedFolders: excluded,
          minDurationMs: minDurationMs,
          modifiedSinceSec: since,
          offset: offset,
          limit: pageSize,
        );
        if (page.isEmpty) break;
        final (a, u) =
            await _repo.upsertScanned(page.map((s) => _toCompanion(s, scanAt)).toList());
        added += a;
        updated += u;
        found += page.length;
        offset += page.length;
        onProgress?.call(found);
        if (page.length < pageSize) break;
      }

      // Detect files deleted outside the app. Uses the unfiltered id list so
      // songs in excluded folders are retained (hidden, not forgotten).
      final present = await _scanner.listMediaStoreIds();
      final removed = await _repo.removeMissing(present);
      final total = await _repo.visibleSongCount();
      return ScanResult(added: added, updated: updated, removed: removed, total: total);
    } finally {
      _running = false;
    }
  }

  SongsCompanion _toCompanion(ScannedSong s, int scanAt) {
    return SongsCompanion.insert(
      id: songIdFor(s.mediaStoreId, s.filePath),
      mediaStoreId: s.mediaStoreId,
      title: s.title,
      artist: Value(s.artist ?? 'Unknown artist'),
      album: Value(s.album ?? 'Unknown album'),
      albumArtist: Value(s.albumArtist),
      genre: Value(s.genre),
      year: Value(s.year),
      trackNumber: Value(s.trackNumber),
      durationMs: Value(s.durationMs),
      filePath: s.filePath,
      contentUri: s.contentUri,
      folderPath: s.folderPath,
      dateAdded: Value(s.dateAdded),
      dateModified: Value(s.dateModified),
      sizeBytes: Value(s.sizeBytes),
      bitrate: Value(s.bitrate),
      sampleRate: Value(s.sampleRate),
      format: Value(s.format),
      embeddedLrcPath: Value(s.embeddedLrcPath),
      lastSeenScanAt: Value(scanAt),
    );
  }
}
