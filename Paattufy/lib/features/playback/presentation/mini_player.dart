import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/widgets/song_artwork.dart';
import '../data/playback_controller.dart';

/// Persistent mini player docked above the tab bar (AP §7.1): tap or swipe up
/// to expand to Now Playing.
class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(playbackControllerProvider);
    final song = state.current;
    if (song == null) return const SizedBox.shrink();
    final controller = ref.read(playbackControllerProvider.notifier);
    final scheme = Theme.of(context).colorScheme;
    final position = ref.watch(positionProvider).value ?? Duration.zero;
    final total = state.duration.inMilliseconds;
    final progress = total <= 0 ? 0.0 : (position.inMilliseconds / total).clamp(0.0, 1.0);

    return GestureDetector(
      onTap: () => context.push(Routes.nowPlaying),
      onVerticalDragEnd: (d) {
        if ((d.primaryVelocity ?? 0) < -200) context.push(Routes.nowPlaying);
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(8, 0, 8, 6),
        decoration: BoxDecoration(color: scheme.surfaceContainerHigh, borderRadius: BorderRadius.circular(14)),
        clipBehavior: Clip.antiAlias,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 4, 6),
            child: Row(children: [
              Hero(tag: 'now-playing-art', child: SongArtwork(contentUri: song.contentUri, size: 44, radius: 8)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(
                    state.stoppedByRouteChange ? 'Output changed — tap play to resume' : song.artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: state.stoppedByRouteChange ? scheme.primary : scheme.onSurfaceVariant),
                  ),
                ]),
              ),
              IconButton(
                icon: Icon(state.playing ? Icons.pause : Icons.play_arrow),
                iconSize: 30,
                onPressed: controller.togglePlayPause,
              ),
              IconButton(icon: const Icon(Icons.skip_next), onPressed: controller.skipNext),
            ]),
          ),
          LinearProgressIndicator(value: progress, minHeight: 2, backgroundColor: Colors.transparent),
        ]),
      ),
    );
  }
}
