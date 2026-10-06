import 'package:paattufy/core/entities/entities.dart';

Song mkSong(
  String id, {
  String? title,
  String artist = 'Artist',
  String album = 'Album',
  String? albumArtist,
  String? genre,
  int? year,
  String folder = '/m/a',
  int durationMs = 200000,
}) =>
    Song(
      id: id,
      mediaStoreId: id.hashCode,
      title: title ?? 'Song $id',
      artist: artist,
      album: album,
      albumArtist: albumArtist,
      genre: genre,
      year: year,
      trackNumber: 1,
      durationMs: durationMs,
      filePath: '$folder/$id.mp3',
      contentUri: 'content://media/$id',
      folderPath: folder,
      dateAdded: 0,
      dateModified: 0,
      sizeBytes: 0,
      format: 'mp3',
      lastSeenScanAt: 0,
    );
