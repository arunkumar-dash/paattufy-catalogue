import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/song_artwork.dart';
import '../data/library_providers.dart';

/// Albums: 2-column grid, cover + title + artist (AP §5.3).
class AlbumsTab extends ConsumerWidget {
  const AlbumsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(albumsProvider).when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (albums) {
            if (albums.isEmpty) return const EmptyState(title: 'No albums yet');
            return GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 12,
                childAspectRatio: 0.82,
              ),
              itemCount: albums.length,
              itemBuilder: (context, i) {
                final a = albums[i];
                return InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => context.push(Routes.album(a.title, a.artist)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, box) => SongArtwork(contentUri: a.sampleContentUri, size: box.maxWidth, radius: 12, icon: Icons.album),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(a.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text(a.artist, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12)),
                  ]),
                );
              },
            );
          },
        );
  }
}
