import 'dart:convert';
import 'dart:io';

import 'package:paattufy/features/library/domain/media_scanner.dart';

/// Loads `test/fixtures/fixture_library.json` (TP §8) into [ScannedSong]s
/// laid out under fake per-artist folders.
List<ScannedSong> loadFixtureSongs({int baseModified = 1000}) {
  final json = jsonDecode(File('test/fixtures/fixture_library.json').readAsStringSync())
      as Map<String, Object?>;
  final songs = (json['songs'] as List).cast<Map<String, Object?>>();
  var id = 100;
  return [
    for (final s in songs)
      () {
        id++;
        final folder = '/storage/emulated/0/Music/${s['artist']}';
        final path = '$folder/${s['fileName']}';
        return ScannedSong(
          mediaStoreId: id,
          title: s['title'] as String,
          artist: s['artist'] as String,
          album: s['album'] as String,
          albumArtist: s['albumArtist'] as String,
          genre: s['genre'] as String,
          year: s['year'] as int,
          trackNumber: s['trackNumber'] as int,
          durationMs: s['durationMs'] as int,
          filePath: path,
          contentUri: 'content://media/external/audio/media/$id',
          folderPath: folder,
          dateAdded: 500 + id,
          dateModified: baseModified + id,
          sizeBytes: 1000 * id,
          format: 'wav',
        );
      }(),
  ];
}

/// In-memory stand-in for the native MediaStore channel. Mirrors its
/// behaviour: exclusion pushdown, min-duration filter, DATE_MODIFIED
/// watermark and paging.
class FakeMediaScanner implements MediaScanner {
  FakeMediaScanner(this.songs);

  List<ScannedSong> songs;
  int scanPageCalls = 0;

  @override
  Future<List<ScannedSong>> scanPage({
    required List<String> excludedFolders,
    required int minDurationMs,
    int? modifiedSinceSec,
    required int offset,
    required int limit,
  }) async {
    scanPageCalls++;
    bool excluded(ScannedSong s) => excludedFolders.any((e) {
          final ex = e.endsWith('/') ? e.substring(0, e.length - 1) : e;
          return s.folderPath == ex || s.folderPath.startsWith('$ex/');
        });
    final filtered = songs
        .where((s) => s.durationMs >= minDurationMs)
        .where((s) => modifiedSinceSec == null || s.dateModified > modifiedSinceSec)
        .where((s) => !excluded(s))
        .toList()
      ..sort((a, b) => a.mediaStoreId.compareTo(b.mediaStoreId));
    return filtered.skip(offset).take(limit).toList();
  }

  @override
  Future<Set<int>> listMediaStoreIds() async =>
      songs.map((s) => s.mediaStoreId).toSet();
}
