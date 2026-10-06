import 'package:flutter/services.dart';

import '../domain/media_scanner.dart';

/// [MediaScanner] backed by the native `paattufy/media_store` channel.
class MediaStoreScanner implements MediaScanner {
  MediaStoreScanner([MethodChannel? channel])
      : _channel = channel ?? const MethodChannel('paattufy/media_store');

  final MethodChannel _channel;

  @override
  Future<List<ScannedSong>> scanPage({
    required List<String> excludedFolders,
    required int minDurationMs,
    int? modifiedSinceSec,
    required int offset,
    required int limit,
  }) async {
    final raw = await _channel.invokeListMethod<Map<Object?, Object?>>(
      'scanPage',
      {
        'excluded': excludedFolders,
        'minDurationMs': minDurationMs,
        'modifiedSince': modifiedSinceSec,
        'offset': offset,
        'limit': limit,
      },
    );
    return (raw ?? const []).map(ScannedSong.fromMap).toList();
  }

  @override
  Future<Set<int>> listMediaStoreIds() async {
    final raw = await _channel.invokeListMethod<num>('listIds');
    return (raw ?? const []).map((n) => n.toInt()).toSet();
  }

  /// Embedded artwork as JPEG bytes, or null when the file has none.
  Future<Uint8List?> artwork(String contentUri, {int size = 256}) =>
      _channel.invokeMethod<Uint8List>(
        'artwork',
        {'contentUri': contentUri, 'size': size},
      );

  /// Extra technical details (bitrate, sample rate, mime) for the Details sheet.
  Future<Map<String, Object?>> probe(String contentUri) async {
    final raw = await _channel.invokeMapMethod<String, Object?>(
      'probe',
      {'contentUri': contentUri},
    );
    return raw ?? const {};
  }
}
