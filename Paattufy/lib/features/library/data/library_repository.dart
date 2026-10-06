import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';

enum SongSort { title, artist, album, dateAdded, duration, year }

extension SongSortLabel on SongSort {
  String get label => switch (this) {
        SongSort.title => 'Title',
        SongSort.artist => 'Artist',
        SongSort.album => 'Album',
        SongSort.dateAdded => 'Date added',
        SongSort.duration => 'Duration',
        SongSort.year => 'Year',
      };
}

class ArtistSummary {
  const ArtistSummary(this.name, this.albumCount, this.songCount, this.sampleContentUri);
  final String name;
  final int albumCount;
  final int songCount;
  final String? sampleContentUri;
}

class AlbumSummary {
  const AlbumSummary(this.title, this.artist, this.songCount, this.year, this.sampleContentUri);
  final String title;
  final String artist;
  final int songCount;
  final int? year;
  final String? sampleContentUri;
}

class FolderSummary {
  const FolderSummary(this.path, this.songCount, {this.excluded = false});
  final String path;
  final int songCount;
  final bool excluded;
}

/// Read-only library queries plus scan-result persistence (TP §5.1).
///
/// Every query applies the excluded-folder filter as a safety net on top of
/// the native pushdown, covering the race where a folder is excluded after a
/// scan already ran. There is deliberately no delete-file code path anywhere
/// (AP §11.8); [removeMissing] only forgets database rows.
class LibraryRepository {
  LibraryRepository(this._db);

  final AppDatabase _db;

  // --- exclusion ---------------------------------------------------------

  Stream<List<String>> watchExcludedFolders() => (_db.select(_db.excludedFolders)
        ..orderBy([(t) => OrderingTerm.asc(t.folderPath)]))
      .watch()
      .map((rows) => rows.map((r) => r.folderPath).toList());

  Future<List<String>> excludedFolders() async =>
      (await _db.select(_db.excludedFolders).get())
          .map((r) => r.folderPath)
          .toList();

  Future<void> excludeFolder(String path) => _db.into(_db.excludedFolders).insert(
        ExcludedFoldersCompanion.insert(folderPath: _normalise(path)),
        mode: InsertMode.insertOrIgnore,
      );

  Future<void> includeFolder(String path) => (_db.delete(_db.excludedFolders)
        ..where((t) => t.folderPath.equals(_normalise(path))))
      .go();

  static String _normalise(String p) =>
      p.length > 1 && p.endsWith('/') ? p.substring(0, p.length - 1) : p;

  /// `folder_path` is neither an excluded folder nor inside one.
  Expression<bool> notExcluded($SongsTable t, List<String> excluded) {
    Expression<bool> expr = const Constant(true);
    for (final raw in excluded) {
      final ex = _normalise(raw);
      final inside = t.folderPath.equals(ex) |
          t.folderPath.substr(1, ex.length + 1).equals('$ex/');
      expr = expr & inside.not();
    }
    return expr;
  }

  Expression<bool> _matches($SongsTable t, String query) {
    final q = query.trim().toLowerCase();
    Expression<bool> has(GeneratedColumn<String> c) =>
        FunctionCallExpression<int>('instr', [c.lower(), Variable<String>(q)])
            .isBiggerThanValue(0);
    return has(t.title) | has(t.artist) | has(t.album) | has(t.albumArtist);
  }

  // --- songs -------------------------------------------------------------

  Stream<List<Song>> watchSongs({
    SongSort sort = SongSort.title,
    bool ascending = true,
    String query = '',
    String? artist,
    String? album,
    String? albumArtist,
    String? folder,
  }) {
    return _watchExcluded().asyncMap((excluded) {
      final q = _db.select(_db.songs)
        ..where((t) {
          Expression<bool> w = notExcluded(t, excluded);
          if (query.trim().isNotEmpty) w = w & _matches(t, query);
          if (artist != null) w = w & t.artist.equals(artist);
          if (album != null) {
            w = w & t.album.equals(album);
            if (albumArtist != null) {
              w = w & (t.albumArtist.equals(albumArtist) |
                  (t.albumArtist.isNull() & t.artist.equals(albumArtist)));
            }
          }
          if (folder != null) w = w & t.folderPath.equals(folder);
          return w;
        })
        ..orderBy(_orderingFor(sort, ascending));
      return q.get();
    });
  }

  /// Re-emits the exclusion list whenever it changes; song tables are watched
  /// by the asyncMap consumer via Drift's table-update stream.
  Stream<List<String>> _watchExcluded() {
    final trigger = _db.tableUpdates(
      TableUpdateQuery.onAllTables([_db.songs, _db.excludedFolders]),
    );
    return Stream<void>.multi((c) {
      c.add(null);
      final sub = trigger.listen((_) => c.add(null), onError: c.addError);
      c.onCancel = sub.cancel;
    }).asyncMap((_) => excludedFolders());
  }

  List<OrderingTerm Function($SongsTable)> _orderingFor(SongSort sort, bool asc) {
    OrderingTerm term(Expression e) =>
        OrderingTerm(expression: e, mode: asc ? OrderingMode.asc : OrderingMode.desc);
    return [
      (t) => switch (sort) {
            SongSort.title => term(t.title.lower()),
            SongSort.artist => term(t.artist.lower()),
            SongSort.album => term(t.album.lower()),
            SongSort.dateAdded => term(t.dateAdded),
            SongSort.duration => term(t.durationMs),
            SongSort.year => term(t.year),
          },
      (t) => OrderingTerm.asc(t.title.lower()),
    ];
  }

  Future<Song?> songById(String id) =>
      (_db.select(_db.songs)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<Song?> songByContentUri(String uri) =>
      (_db.select(_db.songs)..where((t) => t.contentUri.equals(uri))).getSingleOrNull();

  Future<List<Song>> songsByIds(Iterable<String> ids) async {
    final list = ids.toList();
    if (list.isEmpty) return const [];
    final rows = await (_db.select(_db.songs)..where((t) => t.id.isIn(list))).get();
    final byId = {for (final s in rows) s.id: s};
    return [for (final id in list) if (byId[id] != null) byId[id]!];
  }

  /// Every visible song (excluded folders removed). Used by the suggestion
  /// engine and group evaluation as the candidate pool.
  Future<List<Song>> allVisibleSongs() async {
    final excluded = await excludedFolders();
    return (_db.select(_db.songs)..where((t) => notExcluded(t, excluded))).get();
  }

  Future<int> visibleSongCount() async {
    final excluded = await excludedFolders();
    final count = _db.songs.id.count();
    final row = await (_db.selectOnly(_db.songs)
          ..addColumns([count])
          ..where(notExcluded(_db.songs, excluded)))
        .getSingle();
    return row.read(count) ?? 0;
  }

  // --- derived views -----------------------------------------------------

  Stream<List<ArtistSummary>> watchArtists() =>
      _watchExcluded().asyncMap((excluded) async {
        final songs = _db.songs;
        final songCount = songs.id.count();
        final albumCount = songs.album.count(distinct: true);
        final sample = songs.contentUri.min();
        final rows = await (_db.selectOnly(songs)
              ..addColumns([songs.artist, songCount, albumCount, sample])
              ..where(notExcluded(songs, excluded))
              ..groupBy([songs.artist])
              ..orderBy([OrderingTerm.asc(songs.artist.lower())]))
            .get();
        return [
          for (final r in rows)
            ArtistSummary(r.read(songs.artist)!, r.read(albumCount) ?? 0,
                r.read(songCount) ?? 0, r.read(sample)),
        ];
      });

  Stream<List<AlbumSummary>> watchAlbums() =>
      _watchExcluded().asyncMap((excluded) async {
        final songs = _db.songs;
        final artistExpr = coalesce([songs.albumArtist, songs.artist]);
        final songCount = songs.id.count();
        final year = songs.year.max();
        final sample = songs.contentUri.min();
        final rows = await (_db.selectOnly(songs)
              ..addColumns([songs.album, artistExpr, songCount, year, sample])
              ..where(notExcluded(songs, excluded))
              ..groupBy([songs.album, artistExpr])
              ..orderBy([OrderingTerm.asc(songs.album.lower())]))
            .get();
        return [
          for (final r in rows)
            AlbumSummary(r.read(songs.album)!, r.read(artistExpr)!,
                r.read(songCount) ?? 0, r.read(year), r.read(sample)),
        ];
      });

  /// Folders including excluded ones (flagged), so the Folders tab can offer
  /// the re-include toggle.
  Stream<List<FolderSummary>> watchFolders() =>
      _watchExcluded().asyncMap((excluded) async {
        final songs = _db.songs;
        final songCount = songs.id.count();
        final rows = await (_db.selectOnly(songs)
              ..addColumns([songs.folderPath, songCount])
              ..groupBy([songs.folderPath])
              ..orderBy([OrderingTerm.asc(songs.folderPath.lower())]))
            .get();
        bool isExcluded(String path) => excluded.any((e) {
              final ex = _normalise(e);
              return path == ex || path.startsWith('$ex/');
            });
        return [
          for (final r in rows)
            FolderSummary(r.read(songs.folderPath)!, r.read(songCount) ?? 0,
                excluded: isExcluded(r.read(songs.folderPath)!)),
        ];
      });

  // --- persistence of scan results ---------------------------------------

  /// Upserts by MediaStore-derived id. Returns (inserted, updated).
  Future<(int, int)> upsertScanned(
    List<SongsCompanion> rows,
  ) async {
    if (rows.isEmpty) return (0, 0);
    final existing = (await (_db.selectOnly(_db.songs)
              ..addColumns([_db.songs.id]))
            .get())
        .map((r) => r.read(_db.songs.id)!)
        .toSet();
    var inserted = 0;
    for (final r in rows) {
      if (!existing.contains(r.id.value)) inserted++;
    }
    await _db.batch((b) => b.insertAllOnConflictUpdate(_db.songs, rows));
    return (inserted, rows.length - inserted);
  }

  /// Forgets rows whose MediaStore id no longer exists on the device.
  /// Database-only: files are never touched (AP §11.8).
  Future<int> removeMissing(Set<int> presentMediaStoreIds) async {
    final rows = await (_db.selectOnly(_db.songs)
          ..addColumns([_db.songs.id, _db.songs.mediaStoreId]))
        .get();
    final gone = [
      for (final r in rows)
        if (!presentMediaStoreIds.contains(r.read(_db.songs.mediaStoreId)))
          r.read(_db.songs.id)!,
    ];
    if (gone.isEmpty) return 0;
    await (_db.delete(_db.songs)..where((t) => t.id.isIn(gone))).go();
    return gone.length;
  }

  /// Highest `date_modified` currently stored — the incremental watermark.
  Future<int> scanWatermark() async {
    final max = _db.songs.dateModified.max();
    final row = await (_db.selectOnly(_db.songs)..addColumns([max])).getSingle();
    return row.read(max) ?? 0;
  }

  /// Updates the stored technical details after a `probe`.
  Future<void> updateTechnical(String songId, {int? bitrate, int? sampleRate}) =>
      (_db.update(_db.songs)..where((t) => t.id.equals(songId))).write(
        SongsCompanion(
          bitrate: bitrate == null ? const Value.absent() : Value(bitrate),
          sampleRate: sampleRate == null ? const Value.absent() : Value(sampleRate),
        ),
      );
}
