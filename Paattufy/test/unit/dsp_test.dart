import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:paattufy/features/suggestions/domain/dsp.dart';

const sr = 22050;

Float32List clickTrain(double bpm, double seconds, {double amp = 0.8}) {
  final n = (sr * seconds).round();
  final out = Float32List(n);
  final period = 60 / bpm * sr;
  final rng = Random(1);
  for (var beat = 0; beat * period < n; beat++) {
    final start = (beat * period).round();
    for (var i = 0; i < 110 && start + i < n; i++) {
      // 5 ms decaying noise burst = a drum-like transient
      out[start + i] = ((rng.nextDouble() * 2 - 1) * amp * (1 - i / 110)).toDouble();
    }
  }
  return out;
}

Float32List chord(List<double> freqs, double seconds, {double amp = 0.3}) {
  final n = (sr * seconds).round();
  final out = Float32List(n);
  for (var i = 0; i < n; i++) {
    var s = 0.0;
    for (final f in freqs) {
      // fundamental + two soft harmonics, like a real instrument
      s += sin(2 * pi * f * i / sr) + 0.4 * sin(2 * pi * 2 * f * i / sr) + 0.2 * sin(2 * pi * 3 * f * i / sr);
    }
    out[i] = (s / freqs.length / 1.6 * amp).toDouble();
  }
  return out;
}

Float32List sine(double f, double seconds, double amp) => Float32List.fromList(
    [for (var i = 0; i < (sr * seconds).round(); i++) amp * sin(2 * pi * f * i / sr)]);

Float32List noise(double seconds, double amp) {
  final rng = Random(7);
  return Float32List.fromList([for (var i = 0; i < (sr * seconds).round(); i++) amp * (rng.nextDouble() * 2 - 1)]);
}

void main() {
  final dsp = Dsp(sampleRate: sr);

  group('tempo', () {
    for (final bpm in [90.0, 120.0, 140.0]) {
      test('click train at $bpm BPM', () {
        final r = dsp.analyse(clickTrain(bpm, 16));
        expect(r.tempoBpm, closeTo(bpm, 3), reason: 'got ${r.tempoBpm}');
      });
    }
  });

  group('key', () {
    test('C major triad → C major', () {
      final r = dsp.analyse(chord([261.63, 329.63, 392.00], 6));
      expect(r.keyIndex, 0);
      expect(r.keyMode, 1);
    });
    test('A minor triad → A minor', () {
      final r = dsp.analyse(chord([220.0, 261.63, 329.63], 6));
      expect(r.keyIndex, 9);
      expect(r.keyMode, 0);
    });
    test('G major triad → G major', () {
      final r = dsp.analyse(chord([196.0, 246.94, 293.66], 6));
      expect(r.keyIndex, 7);
      expect(r.keyMode, 1);
    });
  });

  test('energy scales with loudness and stays within 0..1', () {
    final quiet = dsp.analyse(sine(440, 3, 0.05));
    final loud = dsp.analyse(sine(440, 3, 0.6));
    expect(loud.energy, greaterThan(quiet.energy));
    expect(loud.energy, inInclusiveRange(0, 1));
    expect(quiet.rms, closeTo(0.05 / sqrt2, 0.005));
  });

  test('brightness: high tone is brighter than low tone', () {
    final low = dsp.analyse(sine(300, 3, 0.3));
    final high = dsp.analyse(sine(5000, 3, 0.3));
    expect(high.brightness, greaterThan(low.brightness + 0.3));
  });

  test('acousticness: sustained harmonic material > percussive clicks', () {
    final tonal = dsp.analyse(chord([261.63, 329.63, 392.0], 8));
    final percussive = dsp.analyse(clickTrain(120, 8));
    expect(tonal.acousticness, greaterThan(percussive.acousticness));
  });

  test('danceability: regular pulse > noise', () {
    final pulse = dsp.analyse(clickTrain(120, 16));
    final random = dsp.analyse(noise(16, 0.3));
    expect(pulse.danceability, greaterThan(random.danceability));
  });

  test('very short / silent input is handled without throwing', () {
    final silent = dsp.analyse(Float32List(sr * 5));
    expect(silent.energy, 0);
    expect(silent.tempoBpm, inInclusiveRange(60, 180));
    final tiny = dsp.analyse(Float32List(100));
    expect(tiny.tempoBpm, inInclusiveRange(60, 180));
  });
}
