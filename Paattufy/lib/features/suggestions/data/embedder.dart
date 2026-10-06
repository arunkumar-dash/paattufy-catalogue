import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:tflite_flutter/tflite_flutter.dart';

import '../domain/audio_features.dart';

/// Turns ~1 s mono frames (16 kHz) into a 64-d embedding.
abstract class AudioEmbedder {
  /// Bumps whenever the model or projection changes, so stored vectors from an
  /// older pipeline get re-analysed.
  String get version;

  /// Averaged, projected embedding for the given 16 kHz frames, or null if
  /// inference failed.
  Future<Float32List?> embed(List<Float32List> frames16k);
  void close();
}

/// Fixed random projection 1024 → 64 (TP §5.7 step 3). Generated from a fixed
/// seed, so the matrix is identical on every device and run — equivalent to
/// the "bundled constant" in the plan without shipping a 256 KB asset.
class RandomProjection {
  RandomProjection({this.inDims = 1024, this.outDims = AudioFeatures.embeddingDims, int seed = 0x70617474}) {
    final rng = Random(seed);
    _matrix = Float32List(inDims * outDims);
    final scale = 1 / sqrt(outDims);
    for (var i = 0; i < _matrix.length; i++) {
      // Box–Muller Gaussian
      final u1 = max(rng.nextDouble(), 1e-12), u2 = rng.nextDouble();
      _matrix[i] = (sqrt(-2 * log(u1)) * cos(2 * pi * u2) * scale).toDouble();
    }
  }

  final int inDims;
  final int outDims;
  late final Float32List _matrix;

  Float32List project(Float32List v) {
    assert(v.length == inDims);
    final out = Float32List(outDims);
    for (var o = 0; o < outDims; o++) {
      var s = 0.0;
      final base = o * inDims;
      for (var i = 0; i < inDims; i++) {
        s += v[i] * _matrix[base + i];
      }
      out[o] = s;
    }
    return out;
  }
}

/// YAMNet (Apache-2.0, ≈4 MB .tflite) via tflite_flutter. The model file is an
/// optional Flutter asset: if it isn't bundled, [tryLoad] returns null and the
/// app transparently runs on heuristic features alone.
///
/// The TF Hub "classification" build only exposes the 521 AudioSet class
/// scores; the full build also exposes the 1024-d embedding. Both work: the
/// embedding is used when present, otherwise the class scores (a semantic
/// "what does this sound like" vector) are projected the same way.
class YamnetEmbedder implements AudioEmbedder {
  YamnetEmbedder._(this._interpreter, this._embeddingOutput, this._outputShapes, this._dims)
      : _projection = RandomProjection(inDims: _dims);

  static const assetPath = 'assets/models/yamnet.tflite';
  static const frameSamples = 15600; // 0.975 s @ 16 kHz

  final Interpreter _interpreter;
  final int _embeddingOutput;
  final List<List<int>> _outputShapes;
  final int _dims;
  final RandomProjection _projection;

  @override
  String get version => _dims == 1024 ? 'yamnet-v1' : 'yamnet-scores-v1';

  static Future<YamnetEmbedder?> tryLoad() async {
    try {
      await rootBundle.load(assetPath); // throws if not bundled
      final interpreter = await Interpreter.fromAsset(assetPath);
      final outs = interpreter.getOutputTensors();
      final shapes = [for (final t in outs) List<int>.from(t.shape)];
      // Prefer the 1024-d embedding output; fall back to the 521 class scores.
      var idx = shapes.indexWhere((s) => s.isNotEmpty && s.last == 1024);
      var dims = 1024;
      if (idx < 0) {
        idx = shapes.indexWhere((s) => s.isNotEmpty && s.last == 521);
        dims = 521;
      }
      if (idx < 0) {
        interpreter.close();
        return null;
      }
      return YamnetEmbedder._(interpreter, idx, shapes, dims);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Float32List?> embed(List<Float32List> frames16k) async {
    if (frames16k.isEmpty) return null;
    try {
      final sum = Float32List(_dims);
      var n = 0;
      for (final frame in frames16k) {
        final input = Float32List(frameSamples);
        input.setRange(0, min(frame.length, frameSamples), frame);
        final outputs = <int, Object>{
          for (var i = 0; i < _outputShapes.length; i++) i: _zeros(_outputShapes[i]),
        };
        _interpreter.runForMultipleInputs([input.reshape([frameSamples])], outputs);
        final emb = _flatten(outputs[_embeddingOutput]!);
        // Output may hold several patches; average them.
        final patches = emb.length ~/ _dims;
        for (var p = 0; p < patches; p++) {
          for (var i = 0; i < _dims; i++) {
            sum[i] += emb[p * _dims + i] / patches;
          }
        }
        n++;
      }
      if (n == 0) return null;
      for (var i = 0; i < _dims; i++) {
        sum[i] /= n;
      }
      return _projection.project(sum);
    } catch (_) {
      return null;
    }
  }

  Object _zeros(List<int> shape) {
    if (shape.length == 1) return List<double>.filled(shape[0], 0);
    return List.generate(shape[0], (_) => _zeros(shape.sublist(1)));
  }

  List<double> _flatten(Object o) {
    if (o is List<double>) return o;
    if (o is List) return [for (final e in o) ..._flatten(e as Object)];
    return [(o as num).toDouble()];
  }

  @override
  void close() => _interpreter.close();
}
