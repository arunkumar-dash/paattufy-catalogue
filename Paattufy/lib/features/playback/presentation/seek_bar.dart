import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/formatters.dart';
import '../data/playback_controller.dart';

/// Seek bar with elapsed / remaining (tabular numerals, AP §7.2) and a scrub
/// preview bubble while dragging (AP §5.5).
class SeekBar extends ConsumerStatefulWidget {
  const SeekBar({super.key});

  @override
  ConsumerState<SeekBar> createState() => _SeekBarState();
}

class _SeekBarState extends ConsumerState<SeekBar> {
  double? _drag; // ms while scrubbing

  @override
  Widget build(BuildContext context) {
    final total = ref.watch(playbackControllerProvider.select((s) => s.duration)).inMilliseconds.toDouble();
    final position = ref.watch(positionProvider).value ?? Duration.zero;
    final current = (_drag ?? position.inMilliseconds.toDouble()).clamp(0.0, total <= 0 ? 1.0 : total);
    final scheme = Theme.of(context).colorScheme;
    const tabular = TextStyle(fontFeatures: [FontFeature.tabularFigures()]);

    return Column(mainAxisSize: MainAxisSize.min, children: [
      SizedBox(
        height: 28,
        child: Stack(alignment: Alignment.topCenter, clipBehavior: Clip.none, children: [
          Positioned.fill(
            child: Slider(
              value: current,
              max: total <= 0 ? 1 : total,
              onChangeStart: (v) => setState(() => _drag = v),
              onChanged: total <= 0 ? null : (v) => setState(() => _drag = v),
              onChangeEnd: (v) async {
                await ref.read(playbackControllerProvider.notifier).seek(Duration(milliseconds: v.round()));
                HapticFeedback.selectionClick();
                if (mounted) setState(() => _drag = null);
              },
            ),
          ),
          if (_drag != null)
            Positioned(
              top: -34,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: scheme.primaryContainer, borderRadius: BorderRadius.circular(10)),
                child: Text(formatMs(_drag!.round()), style: tabular.copyWith(color: scheme.onPrimaryContainer, fontWeight: FontWeight.w700)),
              ),
            ),
        ]),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(formatMs(current.round()), style: tabular.copyWith(fontSize: 12, color: scheme.onSurfaceVariant)),
          Text('-${formatMs((total - current).round().clamp(0, 1 << 31))}', style: tabular.copyWith(fontSize: 12, color: scheme.onSurfaceVariant)),
        ]),
      ),
    ]);
  }
}
