import 'package:drift/drift.dart' show OrderingTerm;
import 'package:paattufy/core/database/app_database.dart';
import 'package:paattufy/features/library/data/library_repository.dart';
import 'package:paattufy/features/library/data/library_scan_service.dart';

import 'fixture_library.dart';

/// In-memory database pre-populated with the 12 fixture songs, ordered by
/// MediaStore id (kanavugal, megam, poove, ... vennilaa).
Future<(AppDatabase, List<Song>)> seededDb() async {
  final db = AppDatabase.forTesting();
  final repo = LibraryRepository(db);
  await LibraryScanService(FakeMediaScanner(loadFixtureSongs()), repo)
      .fullScan(minDurationMs: 0);
  final songs = await (db.select(db.songs)
        ..orderBy([(t) => OrderingTerm.asc(t.mediaStoreId)]))
      .get();
  return (db, songs);
}
