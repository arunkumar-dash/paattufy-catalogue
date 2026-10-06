import 'dart:math';
import 'dart:typed_data';

/// Pure helpers turning Android `Visualizer` byte buffers (and the synthetic
/// fallback) into 0..1 levels, so they are unit-testable (TP §5.10).
class VisualizerMath {
  /// Android FFT capture layout: `[Re0, ReN/2, Re1, Im1, Re2, Im2, …]` as
  /// signed bytes. Returns [bands] log-spaced magnitudes in 0..1.
  static List<double> fftToBands(Uint8List fft, int bands) {
    if (fft.length < 4) return List<double>.filled(bands, 0);
    final pairs = (fft.length - 2) ~/ 2;
    final mags = List<double>.filled(pairs, 0);
    for (var i = 0; i < pairs; i++) {
      final re = _signed(fft[2 + 2 * i]);
      final im = _signed(fft[3 + 2 * i]);
      mags[i] = sqrt(re * re + im * im);
    }
    final out = List<double>.filled(bands, 0);
    for (var b = 0; b < bands; b++) {
      // Log-spaced edges: low bands cover few bins, high bands many.
      final lo = (pow(pairs, b / bands) - 1).floor().clamp(0, pairs - 1);
      final hi = (pow(pairs, (b + 1) / bands) - 1).ceil().clamp(lo + 1, pairs);
      var sum = 0.0;
      for (var i = lo; i < hi; i++) {
        sum += mags[i];
      }
      final avg = sum / (hi - lo);
      // 181 ≈ sqrt(127²+127²) is the max possible magnitude.
      out[b] = (avg / 181 * 2.2).clamp(0.0, 1.0);
    }
    return out;
  }

  static int _signed(int b) => b > 127 ? b - 256 : b;

  /// Waveform bytes (unsigned, 128 = silence) → -1..1.
  static List<double> waveform(Uint8List wave) => [for (final b in wave) (b - 128) / 128.0];

  /// Tempo-driven stand-in used when the platform refuses the tap. Bars pulse
  /// on the beat (from the song's analysed BPM, default 110) with stable
  /// per-bar character; deterministic in `position`, so pause freezes it.
  static List<double> syntheticBands(Duration position, double bpm, int bands, {bool playing = true}) {
    if (!playing) return List<double>.filled(bands, 0.04);
    final t = position.inMilliseconds / 1000.0;
    final beat = (t * bpm / 60.0) % 1.0;
    final kick = pow(1 - beat, 3).toDouble(); // sharp attack, exponential decay
    final out = List<double>.filled(bands, 0);
    for (var b = 0; b < bands; b++) {
      final low = 1 - b / bands; // bass bands follow the kick harder
      final wobble = 0.5 + 0.5 * sin(t * (1.3 + b * 0.37) + b * 1.7);
      final hat = pow((beat * 2) % 1.0, 4).toDouble();
      out[b] = (0.12 + kick * (0.25 + 0.6 * low) + wobble * 0.25 * (1 - low * 0.5) + hat * 0.12 * (1 - low)).clamp(0.0, 1.0);
    }
    return out;
  }

  static List<double> syntheticWave(Duration position, double bpm, int samples, {bool playing = true}) {
    if (!playing) return List<double>.filled(samples, 0);
    final t = position.inMilliseconds / 1000.0;
    final beat = (t * bpm / 60.0) % 1.0;
    final amp = 0.25 + 0.6 * pow(1 - beat, 2).toDouble();
    return [
      for (var i = 0; i < samples; i++)
        amp * (0.6 * sin(2 * pi * (i / samples) * 3 + t * 6) + 0.4 * sin(2 * pi * (i / samples) * 7 - t * 9)),
    ];
  }

  /// Exponential smoothing (fast attack, slower release) for pleasant motion.
  static List<double> smooth(List<double> previous, List<double> next, {double attack = 0.6, double release = 0.2}) {
    if (previous.length != next.length) return next;
    return [
      for (var i = 0; i < next.length; i++)
        previous[i] + (next[i] - previous[i]) * (next[i] > previous[i] ? attack : release),
    ];
  }
}
