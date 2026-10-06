import 'package:flutter_test/flutter_test.dart';
import 'package:paattufy/core/database/app_database.dart';
import 'package:paattufy/features/library/data/library_repository.dart';
import 'package:paattufy/features/library/data/library_scan_service.dart';

import '../support/fixture_library.dart';

void main() {
  late AppDatabase db;
  late LibraryRepository repo;
  late FakeMediaScanner scanner;
  late LibraryScanService service;

  setUp(() {
    db = AppDatabase.forTesting();
    repo = LibraryRepository(db);
    scanner = FakeMediaScanner(loadFixtureSongs());
    service = LibraryScanService(scanner, repo, pageSize: 5); // forces paging
  });
  tearDown(() => db.close());

  test('full scan inserts every fixture song across pages', () async {
    final progress = <int>[];
    final r = await service.fullScan(minDurationMs: 0, onProgress: progress.add);
    expect(r.added, 12);
    expect(r.total, 12);
    expect(progress, [5, 10, 12]);
    expect(scanner.scanPageCalls, 3);
  });

  test('ignore-short-clips threshold filters songs', () async {
    final r = await service.fullScan(minDurationMs: 3500);
    // Fixture durations >= 3500: 4000,3500,4500,4000,3500,3800 -> 6 songs.
    expect(r.total, 6);
  });

  test('rescan is idempotent: nothing added, all updated', () async {
    await service.fullScan(minDurationMs: 0);
    final r = await service.fullScan(minDurationMs: 0);
    expect(r.added, 0);
    expect(r.updated, 12);
    expect(r.total, 12);
  });

  test('incremental scan only fetches files modified after the watermark',
      () async {
    await service.fullScan(minDurationMs: 0);
    final watermark = await repo.scanWatermark();

    final fresh = loadFixtureSongs(baseModified: 50000).first;
    scanner.songs = [
      ...scanner.songs,
      // New file with a fresh MediaStore id and modified time.
      fresh.copyForTest(mediaStoreId: 999, title: 'Brand New', dateModified: watermark + 10),
    ];
    final r = await service.incrementalScan(minDurationMs: 0);
    expect(r.added, 1);
    expect(r.total, 13);
  });

  test('files deleted outside the app are forgotten (DB only)', () async {
    await service.fullScan(minDurationMs: 0);
    scanner.songs = scanner.songs.sublist(2);
    final r = await service.incrementalScan(minDurationMs: 0);
    expect(r.removed, 2);
    expect(r.total, 10);
  });

  test('excluded folders: hidden everywhere, retained in DB, skipped on scan',
      () async {
    await service.fullScan(minDurationMs: 0);
    await repo.excludeFolder('/storage/emulated/0/Music/Ilaiyaraaja/');
    final songs = await repo.watchSongs().first;
    expect(songs, hasLength(8));
    expect(songs.any((s) => s.artist == 'Ilaiyaraaja'), isFalse);
    expect(await repo.visibleSongCount(), 8);

    // Artists / albums views honour the same filter.
    expect((await repo.watchArtists().first).map((a) => a.name),
        isNot(contains('Ilaiyaraaja')));
    expect((await repo.watchAlbums().first), hasLength(4));

    // A full rescan must not forget the hidden rows...
    await service.fullScan(minDurationMs: 0);
    expect(await db.select(db.songs).get(), hasLength(12));
    // ...and re-including restores them immediately.
    await repo.includeFolder('/storage/emulated/0/Music/Ilaiyaraaja');
    expect((await repo.watchSongs().first), hasLength(12));
  });

  test('sorting and search', () async {
    await service.fullScan(minDurationMs: 0);
    final byTitle = await repo.watchSongs().first;
    expect(byTitle.first.title, 'Kadhal');
    final desc = await repo.watchSongs(sort: SongSort.title, ascending: false).first;
    expect(desc.first.title, 'Vennilaa');
    final byYear = await repo.watchSongs(sort: SongSort.year, ascending: false).first;
    expect(byYear.first.year, 2014);
    final byDuration = await repo.watchSongs(sort: SongSort.duration).first;
    expect(byDuration.first.durationMs, 2500);

    final hits = await repo.watchSongs(query: 'rahman').first;
    expect(hits, hasLength(4));
    final album = await repo.watchSongs(query: 'VEYIL').first;
    expect(album.map((s) => s.title).toSet(), {'Minnal', 'Natpu'});
    // % and _ are literal, not wildcards.
    expect(await repo.watchSongs(query: '%').first, isEmpty);
  });

  test('artists/albums/folders aggregates', () async {
    await service.fullScan(minDurationMs: 0);
    final artists = await repo.watchArtists().first;
    expect(artists, hasLength(3));
    final ilaiyaraaja = artists.firstWhere((a) => a.name == 'Ilaiyaraaja');
    expect(ilaiyaraaja.songCount, 4);
    expect(ilaiyaraaja.albumCount, 2);
    expect(await repo.watchAlbums().first, hasLength(6));
    final folders = await repo.watchFolders().first;
    expect(folders, hasLength(3));
    expect(folders.every((f) => f.songCount == 4 && !f.excluded), isTrue);
  });
}
