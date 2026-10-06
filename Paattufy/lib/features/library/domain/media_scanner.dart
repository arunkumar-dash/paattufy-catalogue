/// One audio file as reported by the platform media index.
class ScannedSong {
  const ScannedSong({
    required this.mediaStoreId,
    required this.title,
    required this.artist,
    required this.album,
    this.albumArtist,
    this.genre,
    this.year,
    this.trackNumber,
    required this.durationMs,
    required this.filePath,
    required this.contentUri,
    required this.folderPath,
    this.dateAdded = 0,
    this.dateModified = 0,
    this.sizeBytes = 0,
    this.bitrate,
    this.sampleRate,
    this.format = '',
    this.embeddedLrcPath,
  });

  final int mediaStoreId;
  final String title;
  final String? artist;
  final String? album;
  final String? albumArtist;
  final String? genre;
  final int? year;
  final int? trackNumber;
  final int durationMs;
  final String filePath;
  final String contentUri;
  final String folderPath;
  final int dateAdded;
  final int dateModified;
  final int sizeBytes;
  final int? bitrate;
  final int? sampleRate;
  final String format;
  final String? embeddedLrcPath;

  /// Test/seed helper.
  ScannedSong copyForTest({int? mediaStoreId, String? title, int? dateModified}) =>
      ScannedSong(
        mediaStoreId: mediaStoreId ?? this.mediaStoreId,
        title: title ?? this.title,
        artist: artist,
        album: album,
        albumArtist: albumArtist,
        genre: genre,
        year: year,
        trackNumber: trackNumber,
        durationMs: durationMs,
        filePath: mediaStoreId == null ? filePath : '$folderPath/$mediaStoreId.mp3',
        contentUri: contentUri,
        folderPath: folderPath,
        dateAdded: dateAdded,
        dateModified: dateModified ?? this.dateModified,
        sizeBytes: sizeBytes,
        bitrate: bitrate,
        sampleRate: sampleRate,
        format: format,
        embeddedLrcPath: embeddedLrcPath,
      );

  static ScannedSong fromMap(Map<Object?, Object?> m) {
    int? i(Object? v) => (v as num?)?.toInt();
    return ScannedSong(
      mediaStoreId: i(m['mediaStoreId'])!,
      title: (m['title'] as String?) ?? 'Unknown title',
      artist: m['artist'] as String?,
      album: m['album'] as String?,
      albumArtist: m['albumArtist'] as String?,
      genre: m['genre'] as String?,
      year: i(m['year']),
      trackNumber: i(m['trackNumber']),
      durationMs: i(m['durationMs']) ?? 0,
      filePath: m['filePath'] as String,
      contentUri: m['contentUri'] as String,
      folderPath: (m['folderPath'] as String?) ?? '',
      dateAdded: i(m['dateAdded']) ?? 0,
      dateModified: i(m['dateModified']) ?? 0,
      sizeBytes: i(m['sizeBytes']) ?? 0,
      bitrate: i(m['bitrate']),
      sampleRate: i(m['sampleRate']),
      format: (m['format'] as String?) ?? '',
      embeddedLrcPath: m['embeddedLrcPath'] as String?,
    );
  }
}

/// Transport for reading the device's audio index. The production
/// implementation is the native MediaStore channel; tests use a fake.
abstract class MediaScanner {
  /// One page of audio files. [modifiedSinceSec] switches on incremental mode.
  Future<List<ScannedSong>> scanPage({
    required List<String> excludedFolders,
    required int minDurationMs,
    int? modifiedSinceSec,
    required int offset,
    required int limit,
  });

  /// Every MediaStore audio id currently on the device (unfiltered), used to
  /// detect files that have been deleted outside the app.
  Future<Set<int>> listMediaStoreIds();
}
