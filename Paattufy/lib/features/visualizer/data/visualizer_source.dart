import 'dart:async';

import 'package:flutter/services.dart';

import '../domain/visualizer_math.dart';

class VisualizerFrame {
  const VisualizerFrame(this.bands, this.wave);
  final List<double> bands;
  final List<double> wave;
  static final silent = VisualizerFrame(List<double>.filled(32, 0.04), List<double>.filled(128, 0));
}

/// Taps the app's own audio session via `paattufy/visualizer` (TP §5.10).
/// [start] returns false if the platform refuses, so the caller falls back to
/// the procedural animation.
class NativeVisualizerSource {
  NativeVisualizerSource({MethodChannel? method, EventChannel? events})
      : _method = method ?? const MethodChannel('paattufy/visualizer'),
        _events = events ?? const EventChannel('paattufy/visualizer_events');

  final MethodChannel _method;
  final EventChannel _events;
  StreamSubscription<dynamic>? _sub;
  List<double> _bands = VisualizerFrame.silent.bands;
  List<double> _wave = VisualizerFrame.silent.wave;
  final _controller = StreamController<VisualizerFrame>.broadcast();
  Stream<VisualizerFrame> get frames => _controller.stream;

  Future<bool> start(int audioSessionId, {int bands = 32}) async {
    final ok = await _method.invokeMethod<bool>('start', {'audioSessionId': audioSessionId}) ?? false;
    if (!ok) return false;
    _sub = _events.receiveBroadcastStream().listen((e) {
      final m = e as Map;
      final data = m['data'] as Uint8List;
      if (m['kind'] == 'fft') {
        _bands = VisualizerMath.fftToBands(data, bands);
      } else {
        _wave = VisualizerMath.waveform(data);
      }
      _controller.add(VisualizerFrame(_bands, _wave));
    });
    return true;
  }

  Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;
    await _method.invokeMethod<void>('stop');
  }

  void dispose() {
    _sub?.cancel();
    _controller.close();
  }
}
