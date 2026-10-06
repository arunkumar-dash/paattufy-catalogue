
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/entities/entities.dart';
import '../../lyrics/data/lyrics_repository.dart';
import '../../lyrics/domain/lrc.dart';

class TagInfo {
  const TagInfo({
    this.title,
    this.artist,
    this.album,
    this.albumArtist,
    this.genre,
    this.year,
    this.track,
    this.lyrics,
    this.hasArtwork = false,
  });
  final String? title, artist, album, albumArtist, genre, year, track, lyrics;
  final bool hasArtwork;

  static TagInfo? fromMap(Map<Object?, Object?>? m) {
    if (m == null || m['supported'] != true) return null;
    String? s(String k) => m[k] as String?;
    return TagInfo(
      title: s('title'),
      artist: s('artist'),
      album: s('album'),
      albumArtist: s('albumArtist'),
      genre: s('genre'),
      year: s('year'),
      track: s('track'),
      lyrics: s('lyrics'),
      hasArtwork: m['hasArtwork'] == true,
    );
  }
}

/// Tag read/write through the native TagLib bridge (AP §8.6): fixes wrong
/// title/artist/album/year/artwork on files scraped off the web, which also
/// improves grouping and lyrics matching.
class TagService {
  TagService({MethodChannel? tags, MethodChannel? media})
      : _tags = tags ?? const MethodChannel('paattufy/tag_editor'),
        _media = media ?? const MethodChannel('paattufy/media_store');
  final MethodChannel _tags;
  final MethodChannel _media;

  Future<TagInfo?> read(Song song) async {
    try {
      return TagInfo.fromMap(await _tags.invokeMapMethod<Object?, Object?>('read', {'contentUri': song.contentUri}));
    } catch (_) {
      // No native bridge (tests, background engines) or an unreadable file:
      // tags are an enhancement, never a requirement.
      return null;
    }
  }

  Future<bool> write(Song song, Map<String, String> fields) async {
    final ok = await _tags.invokeMethod<bool>('write', {'contentUri': song.contentUri, 'filePath': song.filePath, 'fields': fields});
    if (ok == true) await _media.invokeMethod<int>('scanFiles', {'paths': [song.filePath]});
    return ok ?? false;
  }

  Future<bool> setArtwork(Song song, Uint8List? bytes, {String mime = 'image/jpeg'}) async {
    final ok = await _tags.invokeMethod<bool>(
        'setArtwork', {'contentUri': song.contentUri, 'filePath': song.filePath, 'bytes': bytes, 'mime': mime});
    if (ok == true) await _media.invokeMethod<int>('scanFiles', {'paths': [song.filePath]});
    return ok ?? false;
  }
}

final tagServiceProvider = Provider<TagService>((ref) => TagService());

/// Embedded lyrics (USLT / Vorbis LYRICS) as a local source: an embedded tag
/// wins over any remote pick (AP §3.7, §11.17). Synced if the text parses as LRC.
class TagLyricsSource implements LocalLyricsSource {
  TagLyricsSource(this._tags);
  final TagService _tags;

  @override
  Future<({String? synced, String? plain})?> read(Song song) async {
    final info = await _tags.read(song);
    final text = info?.lyrics;
    if (text == null || text.trim().isEmpty) return null;
    final parsed = Lrc.parse(text);
    return parsed.isSynced ? (synced: text, plain: Lrc.toPlain(parsed.lines)) : (synced: null, plain: text);
  }
}
