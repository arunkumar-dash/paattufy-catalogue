import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../playback/data/playback_controller.dart';
import '../data/lyrics_providers.dart';
import '../domain/lrc.dart';

/// Parsed lines for the current song (empty when only plain / none).
final currentLyricLinesProvider = Provider<List<LyricLine>>((ref) {
  final r = ref.watch(currentLyricsProvider).value;
  if (r == null || !r.hasSynced) return const [];
  return Lrc.parse(r.synced!).lines;
});

final currentLyricsOffsetProvider = Provider<int>((ref) => ref.watch(currentLyricsProvider).value?.offsetMs ?? 0);

/// Active line index for the current playback position + per-song offset.
final activeLyricIndexProvider = Provider<int>((ref) {
  final lines = ref.watch(currentLyricLinesProvider);
  final pos = ref.watch(positionProvider).value ?? Duration.zero;
  final off = ref.watch(currentLyricsOffsetProvider);
  return Lrc.activeIndex(lines, pos, offsetMs: off);
});

/// One-line peek on Now Playing: current synced line with faint neighbours;
/// tap to expand to the full-screen view (AP §5.5–5.6).
class LyricsPeek extends ConsumerWidget {
  const LyricsPeek({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lyrics = ref.watch(currentLyricsProvider);
    final lines = ref.watch(currentLyricLinesProvider);
    final idx = ref.watch(activeLyricIndexProvider);
    final song = ref.watch(playbackControllerProvider.select((s) => s.current));
    final scheme = Theme.of(context).colorScheme;

    Widget body;
    if (song == null) {
      body = const SizedBox.shrink();
    } else if (lines.isNotEmpty) {
      String at(int i) => i >= 0 && i < lines.length ? lines[i].text : '';
      body = Column(mainAxisSize: MainAxisSize.min, children: [
        Text(at(idx - 1), maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: scheme.onSurface.withValues(alpha: 0.35), fontSize: 13)),
        const SizedBox(height: 2),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: Text(idx < 0 ? '♪' : (at(idx).isEmpty ? '♪' : at(idx)),
              key: ValueKey(idx), maxLines: 2, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        ),
        const SizedBox(height: 2),
        Text(at(idx + 1), maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: scheme.onSurface.withValues(alpha: 0.35), fontSize: 13)),
      ]);
    } else if (lyrics.value?.hasPlain ?? false) {
      body = Text('Lyrics available — tap to read', style: TextStyle(color: scheme.onSurfaceVariant));
    } else if (lyrics.isLoading) {
      body = Text('Looking for lyrics…', style: TextStyle(color: scheme.onSurfaceVariant));
    } else {
      body = Text('No lyrics found — tap to search', style: TextStyle(color: scheme.onSurfaceVariant));
    }

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => lines.isNotEmpty || (lyrics.value?.hasPlain ?? false) ? context.push(Routes.lyrics) : (song == null ? null : context.push(Routes.lyricsPicker(song.id))),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(color: scheme.surfaceContainerHigh.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(16)),
        child: body,
      ),
    );
  }
}
