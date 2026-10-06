import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../playback/data/playback_controller.dart';
import '../../suggestions/data/suggestion_providers.dart';
import '../data/visualizer_source.dart';
import '../domain/visualizer_math.dart';

enum VisualizerStyle { bars, radial, scope }

/// Retro "Windows Media Player" visualiser replacing the album art (AP §3.9).
/// Driven by the app's own audio session — no microphone permission — or, when
/// the platform refuses the tap, a tempo-synced procedural animation.
class VisualizerView extends ConsumerStatefulWidget {
  const VisualizerView({super.key, required this.style, this.size = 300});
  final VisualizerStyle style;
  final double size;

  @override
  ConsumerState<VisualizerView> createState() => _VisualizerViewState();
}

class _VisualizerViewState extends ConsumerState<VisualizerView> with SingleTickerProviderStateMixin {
  static const _bands = 32;
  late final Ticker _ticker;
  final NativeVisualizerSource _native = NativeVisualizerSource();
  VisualizerFrame _nativeFrame = VisualizerFrame.silent;
  bool _useNative = false;
  List<double> _bandsNow = List<double>.filled(_bands, 0.04);
  List<double> _waveNow = List<double>.filled(128, 0);
  double _bpm = 110;
  Duration _last = Duration.zero;
  final _repaint = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
    _attach();
  }

  Future<void> _attach() async {
    final sessionId = ref.read(audioEngineProvider).audioSessionId;
    if (sessionId != null && sessionId != 0) {
      try {
        _useNative = await _native.start(sessionId, bands: _bands);
      } catch (_) {
        _useNative = false;
      }
      if (_useNative) _native.frames.listen((f) => _nativeFrame = f);
    }
    final song = ref.read(playbackControllerProvider).current;
    if (song != null) {
      final f = await ref.read(featureRepositoryProvider).featuresFor(song.id);
      if (f != null) _bpm = f.tempoBpm;
    }
  }

  void _onTick(Duration elapsed) {
    // ~30 fps is plenty for a low-fidelity visualiser and keeps it cheap.
    if ((elapsed - _last).inMilliseconds < 33) return;
    _last = elapsed;
    final playing = ref.read(playbackControllerProvider).playing;
    final pos = ref.read(audioEngineProvider).position;
    final targetBands = _useNative ? _nativeFrame.bands : VisualizerMath.syntheticBands(pos, _bpm, _bands, playing: playing);
    final targetWave = _useNative ? _nativeFrame.wave : VisualizerMath.syntheticWave(pos, _bpm, 128, playing: playing);
    _bandsNow = VisualizerMath.smooth(_bandsNow, targetBands);
    _waveNow = targetWave;
    _repaint.value++;
  }

  @override
  void dispose() {
    _ticker.dispose();
    _native.stop();
    _native.dispose();
    _repaint.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: widget.size,
        height: widget.size,
        color: Colors.black,
        child: CustomPaint(
          painter: _VisualizerPainter(() => _bandsNow, () => _waveNow, widget.style, color, _repaint),
        ),
      ),
    );
  }
}

class _VisualizerPainter extends CustomPainter {
  _VisualizerPainter(this.bands, this.wave, this.style, this.color, Listenable repaint) : super(repaint: repaint);
  final List<double> Function() bands;
  final List<double> Function() wave;
  final VisualizerStyle style;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final b = bands();
    final w = wave();
    switch (style) {
      case VisualizerStyle.bars:
        _bars(canvas, size, b);
      case VisualizerStyle.radial:
        _radial(canvas, size, b);
      case VisualizerStyle.scope:
        _scope(canvas, size, w);
    }
  }

  void _bars(Canvas canvas, Size size, List<double> b) {
    final n = b.length;
    final gap = 3.0;
    final bw = (size.width - gap * (n + 1)) / n;
    final paint = Paint();
    for (var i = 0; i < n; i++) {
      final h = max(3.0, b[i] * size.height * 0.92);
      final x = gap + i * (bw + gap);
      paint.shader = LinearGradient(colors: [color, Color.lerp(color, Colors.white, 0.6)!], begin: Alignment.bottomCenter, end: Alignment.topCenter)
          .createShader(Rect.fromLTWH(x, size.height - h, bw, h));
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x, size.height - h, bw, h), const Radius.circular(2)), paint);
    }
  }

  void _radial(Canvas canvas, Size size, List<double> b) {
    final c = size.center(Offset.zero);
    final base = size.shortestSide * 0.22;
    final maxLen = size.shortestSide * 0.26;
    final bass = b.take(6).fold<double>(0, (a, x) => a + x) / 6;
    canvas.drawCircle(c, base * (0.9 + bass * 0.35), Paint()..color = color.withValues(alpha: 0.25));
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final n = b.length * 2; // mirrored
    for (var i = 0; i < n; i++) {
      final v = b[i < b.length ? i : n - 1 - i];
      final a = 2 * pi * i / n - pi / 2;
      final r0 = base, r1 = base + 4 + v * maxLen;
      canvas.drawLine(c + Offset(cos(a), sin(a)) * r0, c + Offset(cos(a), sin(a)) * r1, paint);
    }
  }

  void _scope(Canvas canvas, Size size, List<double> w) {
    final mid = size.height / 2;
    final path = Path();
    for (var i = 0; i < w.length; i++) {
      final x = size.width * i / (w.length - 1);
      final y = mid - w[i] * size.height * 0.4;
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    canvas.drawLine(Offset(0, mid), Offset(size.width, mid), Paint()..color = color.withValues(alpha: 0.2));
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_VisualizerPainter old) => old.style != style || old.color != color;
}
