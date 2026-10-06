import 'dart:collection';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'library_providers.dart';
import 'media_store_scanner.dart';

/// Lazy artwork loader (AP §2 "lazy artwork") with a small in-memory LRU and a
/// disk cache. The disk copy is what the media notification and home-screen
/// widgets read, so they never re-decode bitmaps (AP §8.13).
class ArtworkCache {
  ArtworkCache(this._source, {this.capacity = 120, Future<Directory> Function()? cacheDir})
      : _cacheDir = cacheDir ?? _defaultDir;

  final MediaStoreScanner _source;
  final int capacity;
  final Future<Directory> Function() _cacheDir;
  final LinkedHashMap<String, Uint8List?> _lru = LinkedHashMap();

  static Future<Directory> _defaultDir() async {
    final base = await getApplicationCacheDirectory();
    final dir = Directory(p.join(base.path, 'artwork'));
    if (!dir.existsSync()) dir.createSync(recursive: true);
    return dir;
  }

  static String _fileName(String contentUri) =>
      '${contentUri.replaceAll(RegExp(r'[^A-Za-z0-9]'), '_')}.jpg';

  /// JPEG bytes for [contentUri], or null when the file has no artwork.
  Future<Uint8List?> bytes(String contentUri, {int size = 256}) async {
    final key = '$contentUri@$size';
    if (_lru.containsKey(key)) {
      final v = _lru.remove(key);
      _lru[key] = v;
      return v;
    }
    final data = await _source.artwork(contentUri, size: size);
    _lru[key] = data;
    if (_lru.length > capacity) _lru.remove(_lru.keys.first);
    return data;
  }

  /// A cached JPEG file for the notification / widgets, or null if no art.
  Future<File?> file(String contentUri, {int size = 512}) async {
    final dir = await _cacheDir();
    final f = File(p.join(dir.path, _fileName(contentUri)));
    if (f.existsSync() && f.lengthSync() > 0) return f;
    final data = await _source.artwork(contentUri, size: size);
    if (data == null) return null;
    await f.writeAsBytes(data, flush: true);
    return f;
  }
}

final artworkCacheProvider = Provider<ArtworkCache>(
  (ref) => ArtworkCache(ref.watch(mediaStoreScannerProvider)),
);
