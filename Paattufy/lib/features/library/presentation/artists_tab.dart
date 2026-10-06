import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/song_artwork.dart';
import '../data/library_providers.dart';

/// Artists: list with circular art and `n albums · n songs` (AP §5.3).
class ArtistsTab extends ConsumerWidget {
  const ArtistsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(artistsProvider).when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (artists) {
            if (artists.isEmpty) return const EmptyState(title: 'No artists yet');
            return ListView.builder(
              itemCount: artists.length,
              itemBuilder: (context, i) {
                final a = artists[i];
                return ListTile(
                  leading: SongArtwork(contentUri: a.sampleContentUri, size: 48, radius: 24, icon: Icons.person),
                  title: Text(a.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text('${a.albumCount} ${a.albumCount == 1 ? 'album' : 'albums'} · ${a.songCount} ${a.songCount == 1 ? 'song' : 'songs'}'),
                  onTap: () => context.push(Routes.artist(a.name)),
                );
              },
            );
          },
        );
  }
}
