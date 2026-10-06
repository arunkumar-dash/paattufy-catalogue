import 'dart:math';
import 'dart:typed_data';

/// Per-song audio fingerprint (TP §5.7): heuristic scalars from the decoded
/// audio plus an optional learned embedding.
class AudioFeatures {
  const AudioFeatures({
    required this.tempoBpm,
    required this.keyIndex,
    required this.keyMode,
    required this.energy,
    required this.acousticness,
    required this.brightness,
    required this.danceability,
    this.embedding,
  });

  /// 60–180.
  final double tempoBpm;

  /// 0 = C … 11 = B.
  final int keyIndex;

  /// 1 = major, 0 = minor.
  final int keyMode;

  /// Normalised RMS loudness, 0..1.
  final double energy;

  /// Harmonic-vs-percussive ratio, 0..1.
  final double acousticness;

  /// Mean spectral centroid, normalised 0..1.
  final double brightness;

  /// Regularity of the rhythmic pulse, 0..1.
  final double danceability;

  /// 64-d projected YAMNet embedding, or null when the model isn't bundled or
  /// inference failed for this song (Mood mode then compares heuristics only).
  final Float32List? embedding;

  bool get hasEmbedding => embedding != null && embedding!.isNotEmpty;

  static const int heuristicDims = 1 + 24 + 4; // tempo + key one-hot + 4 scalars
  static const int embeddingDims = 64;

  /// Weight of the key block relative to the scalar features.
  static const double keyWeight = 0.5;

  /// Weight of the (L2-normalised) embedding block.
  static const double embeddingWeight = 1.5;

  /// Heuristic part of the feature vector (TP §5.7 step 4): tempo (scaled to
  /// 0..1 over 60–180 BPM), key one-hot ×24, energy, acousticness, brightness,
  /// danceability.
  ///
  /// Scalars are centred on 0.5 before use: cosine similarity over all-positive
  /// vectors is squeezed into ~0.9–1.0 no matter how different two songs are,
  /// which would make Mood scores incomparable with Metadata-fallback scores.
  /// Centring gives dissimilar songs genuinely low (even negative) similarity.
  Float32List heuristicVector() {
    final v = Float32List(heuristicDims);
    v[0] = ((tempoBpm - 60) / 120).clamp(0.0, 1.0) - 0.5;
    final keySlot = 1 + keyIndex.clamp(0, 11) + (keyMode == 1 ? 12 : 0);
    v[keySlot] = keyWeight;
    v[25] = energy.clamp(0.0, 1.0) - 0.5;
    v[26] = acousticness.clamp(0.0, 1.0) - 0.5;
    v[27] = brightness.clamp(0.0, 1.0) - 0.5;
    v[28] = danceability.clamp(0.0, 1.0) - 0.5;
    return v;
  }

  /// L2-normalised, weighted embedding block, or null.
  Float32List? embeddingVector() {
    final e = embedding;
    if (e == null || e.isEmpty) return null;
    var n = 0.0;
    for (final x in e) {
      n += x * x;
    }
    n = sqrt(n);
    if (n == 0) return null;
    final out = Float32List(e.length);
    for (var i = 0; i < e.length; i++) {
      out[i] = (e[i] / n * embeddingWeight).toDouble();
    }
    return out;
  }

  /// Full vector: heuristics followed by the embedding block (zeros if absent).
  Float32List fullVector() {
    final h = heuristicVector();
    final e = embeddingVector();
    final out = Float32List(heuristicDims + embeddingDims);
    out.setRange(0, heuristicDims, h);
    if (e != null) out.setRange(heuristicDims, heuristicDims + embeddingDims, e);
    return out;
  }

  /// Approximate RMS used for per-track loudness normalisation.
  double get approximateRms => energy * 0.25;

  static Uint8List packFloats(Float32List f) => f.buffer.asUint8List(f.offsetInBytes, f.lengthInBytes);

  static Float32List unpackFloats(Uint8List bytes) {
    if (bytes.isEmpty) return Float32List(0);
    final copy = Uint8List.fromList(bytes); // aligned copy
    return copy.buffer.asFloat32List(0, copy.lengthInBytes ~/ 4);
  }
}

/// Cosine similarity on the heuristic block, or the full vector when both
/// sides have an embedding. Mood mode's "closeness to the taste centroid".
double featureSimilarity(
  Float32List aHeur,
  Float32List? aEmb,
  Float32List bHeur,
  Float32List? bEmb,
) {
  var dot = 0.0, na = 0.0, nb = 0.0;
  for (var i = 0; i < aHeur.length; i++) {
    dot += aHeur[i] * bHeur[i];
    na += aHeur[i] * aHeur[i];
    nb += bHeur[i] * bHeur[i];
  }
  if (aEmb != null && bEmb != null) {
    for (var i = 0; i < aEmb.length; i++) {
      dot += aEmb[i] * bEmb[i];
      na += aEmb[i] * aEmb[i];
      nb += bEmb[i] * bEmb[i];
    }
  }
  if (na == 0 || nb == 0) return 0;
  return dot / (sqrt(na) * sqrt(nb));
}
