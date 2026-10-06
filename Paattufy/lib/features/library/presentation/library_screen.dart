import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../data/library_providers.dart';
import 'albums_tab.dart';
import 'artists_tab.dart';
import 'folders_tab.dart';
import 'songs_tab.dart';

/// Library tab (AP §4): Songs · Artists · Albums · Folders.
class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scan = ref.watch(scanControllerProvider);
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Paattufy'),
          actions: [
            IconButton(icon: const Icon(Icons.search), tooltip: 'Search', onPressed: () => context.push(Routes.search)),
            IconButton(
              icon: const Icon(Icons.sort),
              tooltip: 'Sort',
              onPressed: () => showSortSheet(context, ref),
            ),
            PopupMenuButton<String>(
              onSelected: (v) {
                if (v == 'rescan') ref.read(scanControllerProvider.notifier).run(full: true);
                if (v == 'health') context.push(Routes.libraryHealth);
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'rescan', child: Text('Rescan now')),
                PopupMenuItem(value: 'health', child: Text('Duplicates & broken files')),
              ],
            ),
          ],
          bottom: const TabBar(tabs: [
            Tab(text: 'Songs'),
            Tab(text: 'Artists'),
            Tab(text: 'Albums'),
            Tab(text: 'Folders'),
          ]),
        ),
        body: Column(children: [
          if (scan.running)
            LinearProgressIndicator(
              minHeight: 3,
            ),
          if (scan.running)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Align(alignment: Alignment.centerLeft, child: Text('${scan.found} songs found…', style: Theme.of(context).textTheme.bodySmall)),
            ),
          const Expanded(child: TabBarView(children: [SongsTab(), ArtistsTab(), AlbumsTab(), FoldersTab()])),
        ]),
      ),
    );
  }
}
