import 'dart:math';
import 'dart:typed_data';

import 'package:paattufy/features/suggestions/data/pcm_decoder.dart';

/// Returns synthetic PCM keyed by content URI; unknown URIs "fail to decode".
class FakePcmDecoder implements PcmDecoder {
  FakePcmDecoder(this.signals);
  final Map<String, Float32List> signals;
  final List<String> decoded = [];
  ({int startMs, int durationMs})? lastWindow;

  @override
  Future<Float32List?> decode(String contentUri,
      {required int sampleRate, required int startMs, required int durationMs}) async {
    decoded.add(contentUri);
    lastWindow = (startMs: startMs, durationMs: durationMs);
    return signals[contentUri];
  }
}

Float32List synthTone(double freq, {double seconds = 6, double amp = 0.3, int sr = 22050}) =>
    Float32List.fromList([for (var i = 0; i < sr * seconds; i++) amp * sin(2 * pi * freq * i / sr)]);
