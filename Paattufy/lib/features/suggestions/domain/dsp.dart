import 'dart:math';
import 'dart:typed_data';

import 'package:fftea/fftea.dart';

/// Heuristic scalar features from mono PCM (TP §5.7 step 2). Pure Dart, no
/// platform dependencies, so it is unit-tested against synthetic signals.
class DspResult {
  const DspResult({
    required this.tempoBpm,
    required this.keyIndex,
    required this.keyMode,
    required this.energy,
    required this.acousticness,
    required this.brightness,
    required this.danceability,
    required this.rms,
  });
  final double tempoBpm;
  final int keyIndex;
  final int keyMode;
  final double energy;
  final double acousticness;
  final double brightness;
  final double danceability;
  final double rms;
}

class Dsp {
  Dsp({this.sampleRate = 22050});

  final int sampleRate;

  // Krumhansl–Schmuckler key profiles (C major / C minor).
  static const List<double> majorProfile = [
    6.35, 2.23, 3.48, 2.33, 4.38, 4.09, 2.52, 5.19, 2.39, 3.66, 2.29, 2.88,
  ];
  static const List<double> minorProfile = [
    6.33, 2.68, 3.52, 5.38, 2.60, 3.53, 2.54, 4.75, 3.98, 2.69, 3.34, 3.17,
  ];

  static const int _chromaFft = 2048;
  static const int _chromaHop = 512;
  static const int _onsetFft = 1024;
  static const int _onsetHop = 256;
  static const int _bands = 96;

  DspResult analyse(Float32List pcm) {
    final audio = Float64List(pcm.length);
    var sumSq = 0.0;
    for (var i = 0; i < pcm.length; i++) {
      audio[i] = pcm[i].toDouble();
      sumSq += audio[i] * audio[i];
    }
    final rms = pcm.isEmpty ? 0.0 : sqrt(sumSq / pcm.length);

    final spectral = _spectralPass(audio);
    final (tempo, dance) = _tempoAndDanceability(audio);
    final (keyIdx, mode) = _key(spectral.chroma);

    return DspResult(
      tempoBpm: tempo,
      keyIndex: keyIdx,
      keyMode: mode,
      energy: (rms / 0.25).clamp(0.0, 1.0),
      acousticness: spectral.harmonicRatio,
      brightness: (spectral.meanCentroidHz / 8000).clamp(0.0, 1.0),
      danceability: dance,
      rms: rms,
    );
  }

  // --- chroma / centroid / HPSS -------------------------------------------

  ({List<double> chroma, double meanCentroidHz, double harmonicRatio}) _spectralPass(Float64List audio) {
    final stft = STFT(_chromaFft, Window.hanning(_chromaFft));
    final bins = _chromaFft ~/ 2 + 1;
    final binHz = sampleRate / _chromaFft;

    // bin → pitch class (or -1 when outside 55 Hz–4 kHz)
    final pc = Int8List(bins);
    for (var k = 0; k < bins; k++) {
      final f = k * binHz;
      if (f < 55 || f > 4000) {
        pc[k] = -1;
      } else {
        pc[k] = ((12 * (log(f / 440) / ln2) + 69).round() % 12 + 12) % 12;
      }
    }
    // linear band edges for the HPSS band spectrogram (kept small on purpose)
    final bandOf = Int16List(bins);
    final perBand = bins / _bands;
    for (var k = 0; k < bins; k++) {
      bandOf[k] = min(_bands - 1, (k / perBand).floor());
    }

    final chroma = List<double>.filled(12, 0);
    var centroidSum = 0.0;
    var centroidFrames = 0;
    final bandFrames = <Float32List>[];

    stft.run(audio, (Float64x2List freq) {
      final mags = freq.discardConjugates().magnitudes();
      var num = 0.0, den = 0.0;
      final band = Float32List(_bands);
      for (var k = 0; k < bins && k < mags.length; k++) {
        final m = mags[k];
        num += m * k * binHz;
        den += m;
        if (pc[k] >= 0) chroma[pc[k]] += m * m;
        band[bandOf[k]] += m.toDouble();
      }
      if (den > 1e-9) {
        centroidSum += num / den;
        centroidFrames++;
      }
      bandFrames.add(band);
    }, _chromaHop);

    final harmonic = _harmonicRatio(bandFrames);
    return (
      chroma: chroma,
      meanCentroidHz: centroidFrames == 0 ? 0.0 : centroidSum / centroidFrames,
      harmonicRatio: harmonic,
    );
  }

  /// Median-filtering HPSS (TP §5.7): harmonic = median across time,
  /// percussive = median across frequency; ratio H / (H + P).
  double _harmonicRatio(List<Float32List> frames) {
    const half = 8; // 17-tap medians
    final t = frames.length;
    if (t < 2 * half + 1) return 0.5;
    var hEnergy = 0.0, pEnergy = 0.0;
    final window = List<double>.filled(2 * half + 1, 0);
    // Subsample frames for speed on long excerpts.
    final step = max(1, t ~/ 600);
    for (var i = half; i < t - half; i += step) {
      final frame = frames[i];
      for (var b = half; b < _bands - half; b++) {
        for (var d = -half; d <= half; d++) {
          window[d + half] = frames[i + d][b];
        }
        final h = _median(window);
        for (var d = -half; d <= half; d++) {
          window[d + half] = frame[b + d];
        }
        final p = _median(window);
        hEnergy += h * h;
        pEnergy += p * p;
      }
    }
    final total = hEnergy + pEnergy;
    return total <= 0 ? 0.5 : (hEnergy / total).clamp(0.0, 1.0);
  }

  double _median(List<double> values) {
    final copy = List<double>.of(values)..sort();
    return copy[copy.length ~/ 2];
  }

  // --- key --------------------------------------------------------------------

  (int, int) _key(List<double> chroma) {
    final total = chroma.fold<double>(0, (a, b) => a + b);
    if (total <= 0) return (0, 1);
    var best = -2.0;
    var bestKey = 0;
    var bestMode = 1;
    for (var mode = 0; mode < 2; mode++) {
      final profile = mode == 1 ? majorProfile : minorProfile;
      for (var tonic = 0; tonic < 12; tonic++) {
        final rotated = [for (var i = 0; i < 12; i++) profile[(i - tonic + 12) % 12]];
        final r = _pearson(chroma, rotated);
        if (r > best) {
          best = r;
          bestKey = tonic;
          bestMode = mode;
        }
      }
    }
    return (bestKey, bestMode);
  }

  double _pearson(List<double> a, List<double> b) {
    final n = a.length;
    final ma = a.reduce((x, y) => x + y) / n;
    final mb = b.reduce((x, y) => x + y) / n;
    var num = 0.0, da = 0.0, db = 0.0;
    for (var i = 0; i < n; i++) {
      num += (a[i] - ma) * (b[i] - mb);
      da += (a[i] - ma) * (a[i] - ma);
      db += (b[i] - mb) * (b[i] - mb);
    }
    if (da == 0 || db == 0) return 0;
    return num / sqrt(da * db);
  }

  // --- tempo & danceability ---------------------------------------------------------

  /// Spectral-flux onset envelope → autocorrelation over 60–180 BPM lags.
  /// Danceability reuses the same autocorrelation (TP §5.7).
  (double, double) _tempoAndDanceability(Float64List audio) {
    final onset = _onsetEnvelope(audio);
    final fps = sampleRate / _onsetHop;
    if (onset.length < fps * 4) return (120.0, 0.0);

    // Normalise: subtract a moving mean, half-wave rectify, unit-variance.
    final env = _normaliseOnset(onset, (fps * 0.5).round());
    final minLag = (60 * fps / 180).floor();
    final maxLag = (60 * fps / 60).ceil();
    final ac = Float64List(maxLag + 2);
    for (var lag = 0; lag <= maxLag + 1; lag++) {
      var s = 0.0;
      for (var i = 0; i + lag < env.length; i++) {
        s += env[i] * env[i + lag];
      }
      ac[lag] = s / (env.length - lag);
    }
    if (ac[0] <= 1e-12) return (120.0, 0.0);

    var bestLag = minLag;
    var bestScore = -double.infinity;
    for (var lag = minLag; lag <= maxLag; lag++) {
      final bpm = 60 * fps / lag;
      // Log-Gaussian prior centred on 110 BPM resolves octave ambiguity.
      final prior = exp(-0.5 * pow(log(bpm / 110) / ln2, 2));
      final score = ac[lag] * prior;
      if (score > bestScore) {
        bestScore = score;
        bestLag = lag;
      }
    }
    // Parabolic interpolation for sub-frame lag precision.
    var refined = bestLag.toDouble();
    if (bestLag > minLag && bestLag < maxLag) {
      final y0 = ac[bestLag - 1], y1 = ac[bestLag], y2 = ac[bestLag + 1];
      final denom = y0 - 2 * y1 + y2;
      if (denom != 0) refined += 0.5 * (y0 - y2) / denom;
    }
    final bpm = (60 * fps / refined).clamp(60.0, 180.0);

    var mean = 0.0;
    for (var lag = minLag; lag <= maxLag; lag++) {
      mean += ac[lag];
    }
    mean /= (maxLag - minLag + 1);
    final sharpness = ((ac[bestLag] - mean) / ac[0]).clamp(0.0, 1.0);
    return (bpm, sharpness);
  }

  Float64List _onsetEnvelope(Float64List audio) {
    final stft = STFT(_onsetFft, Window.hanning(_onsetFft));
    final flux = <double>[];
    Float64List? prev;
    stft.run(audio, (Float64x2List freq) {
      final mags = freq.discardConjugates().magnitudes();
      if (prev != null) {
        var f = 0.0;
        for (var k = 0; k < mags.length; k++) {
          final d = mags[k] - prev![k];
          if (d > 0) f += d;
        }
        flux.add(f);
      }
      prev = Float64List.fromList(mags);
    }, _onsetHop);
    return Float64List.fromList(flux);
  }

  Float64List _normaliseOnset(Float64List onset, int window) {
    final n = onset.length;
    final out = Float64List(n);
    var running = 0.0;
    final prefix = Float64List(n + 1);
    for (var i = 0; i < n; i++) {
      running += onset[i];
      prefix[i + 1] = running;
    }
    var sumSq = 0.0;
    for (var i = 0; i < n; i++) {
      final lo = max(0, i - window), hi = min(n, i + window + 1);
      final localMean = (prefix[hi] - prefix[lo]) / (hi - lo);
      final v = max(0.0, onset[i] - localMean);
      out[i] = v;
      sumSq += v * v;
    }
    final std = sqrt(sumSq / n);
    if (std > 0) {
      for (var i = 0; i < n; i++) {
        out[i] /= std;
      }
    }
    return out;
  }
}
