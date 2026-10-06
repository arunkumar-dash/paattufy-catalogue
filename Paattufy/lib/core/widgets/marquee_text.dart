import 'package:flutter/material.dart';

/// Single-line text that scrolls horizontally when it doesn't fit (AP §5.5).
class MarqueeText extends StatefulWidget {
  const MarqueeText(this.text, {super.key, this.style, this.pause = const Duration(seconds: 2)});
  final String text;
  final TextStyle? style;
  final Duration pause;

  @override
  State<MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<MarqueeText> with SingleTickerProviderStateMixin {
  final _controller = ScrollController();
  bool _running = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loop());
  }

  @override
  void didUpdateWidget(MarqueeText old) {
    super.didUpdateWidget(old);
    if (old.text != widget.text && _controller.hasClients) _controller.jumpTo(0);
  }

  Future<void> _loop() async {
    if (_running) return;
    _running = true;
    while (mounted) {
      await Future<void>.delayed(widget.pause);
      if (!mounted || !_controller.hasClients) break;
      final max = _controller.position.maxScrollExtent;
      if (max > 0) {
        await _controller.animateTo(max, duration: Duration(milliseconds: (max * 25).round().clamp(800, 12000)), curve: Curves.linear);
        await Future<void>.delayed(widget.pause);
        if (mounted && _controller.hasClients) _controller.jumpTo(0);
      }
    }
    _running = false;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        child: Text(widget.text, style: widget.style, maxLines: 1, softWrap: false),
      );
}
