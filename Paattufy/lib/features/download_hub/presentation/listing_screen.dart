import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../data/download_providers.dart';
import '../domain/catalogue.dart';
import '../domain/listing_parser.dart';

/// Listing mode (AP §5.8): native cards of parsed recent releases →
/// `Download all` → zip → auto-extract → rescan → "Added N songs" toast.
class ListingScreen extends ConsumerWidget {
  const ListingScreen({super.key, required this.site});
  final CatalogueSite site;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(listingProvider(site));
    return Scaffold(
      appBar: AppBar(title: Text(site.title), actions: [
        IconButton(icon: const Icon(Icons.refresh), onPressed: () => ref.invalidate(listingProvider(site))),
      ]),
      body: items.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Padding(padding: const EdgeInsets.all(24), child: Text('Could not load ${site.title}.\n$e', textAlign: TextAlign.center))),
        data: (list) {
          if (list.isEmpty) {
            return Center(child: Padding(padding: const EdgeInsets.all(24), child: Text('No albums found. The site layout may have changed — update the catalogue rules on GitHub.', textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant))));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: list.length,
            itemBuilder: (context, i) => _AlbumCard(site: site, item: list[i]),
          );
        },
      ),
    );
  }
}

class _AlbumCard extends ConsumerWidget {
  const _AlbumCard({required this.site, required this.item});
  final CatalogueSite site;
  final ListingItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          width: 110,
          height: 140,
          child: item.posterUrl == null
              ? Container(color: scheme.surfaceContainerHighest, child: const Icon(Icons.album, size: 40))
              : Image.network(item.posterUrl!, fit: BoxFit.cover, errorBuilder: (_, _, _) => Container(color: scheme.surfaceContainerHighest, child: const Icon(Icons.album, size: 40))),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(item.title, style: Theme.of(context).textTheme.titleMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
              if (item.year != null) Text('${item.year}', style: TextStyle(color: scheme.onSurfaceVariant)),
              if (item.music != null) Text('Music: ${item.music}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13)),
              if (item.starring != null) Text(item.starring!, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
              const SizedBox(height: 10),
              FilledButton.icon(
                icon: const Icon(Icons.download, size: 18),
                label: const Text('Download all'),
                onPressed: () async {
                  await ref.read(downloadManagerProvider).enqueueAlbum(site, item);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Downloading ${item.title}'),
                    action: SnackBarAction(label: 'View', onPressed: () => context.go(Routes.download)),
                  ));
                },
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}
