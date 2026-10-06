import 'dart:typed_data';

import 'package:flutter/services.dart';

/// Decodes an excerpt to mono float PCM for analysis only (TP §5.7 step 1).
abstract class PcmDecoder {
  Future<Float32List?> decode(
    String contentUri, {
    required int sampleRate,
    required int startMs,
    required int durationMs,
  });
}

/// Native MediaExtractor/MediaCodec decode via the `paattufy/audio_decode`
/// channel (part of the `paattufy_native` plugin, so it also exists in the
/// workmanager background engine).
class NativePcmDecoder implements PcmDecoder {
  NativePcmDecoder([MethodChannel? channel])
      : _channel = channel ?? const MethodChannel('paattufy/audio_decode');
  final MethodChannel _channel;

  @override
  Future<Float32List?> decode(
    String contentUri, {
    required int sampleRate,
    required int startMs,
    required int durationMs,
  }) async {
    final bytes = await _channel.invokeMethod<Uint8List>('decode', {
      'contentUri': contentUri,
      'sampleRate': sampleRate,
      'startMs': startMs,
      'durationMs': durationMs,
    });
    if (bytes == null || bytes.isEmpty) return null;
    final aligned = Uint8List.fromList(bytes);
    return aligned.buffer.asFloat32List(0, aligned.lengthInBytes ~/ 4);
  }
}
