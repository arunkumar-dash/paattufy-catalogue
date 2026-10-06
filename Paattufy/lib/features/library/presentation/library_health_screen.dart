import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/entities/entities.dart';
import '../../../core/widgets/empty_state.dart';
import '../data/library_health.dart';
import '../data/library_providers.dart';
import 'song_actions.dart';

class _Report {
  const _Report(this.duplicates, this.broken);
  final List<DuplicateGroup> duplicates;
  final List<BrokenFile> broken;
}

final _healthProvider = FutureProvider.autoDispose<_Report>((ref) async {
  final songs = await ref.watch(libraryRepositoryProvider).allVisibleSongs();
  const health = LibraryHealth();
  return _Report(health.findDuplicates(songs), await health.findBroken(songs));
});

/// Duplicate & broken-file report (AP §8.7). Report-only: the library is
/// read-only, so there is no delete action — the file path is shown so you can
/// deal with it in a file manager.
class LibraryHealthScreen extends ConsumerWidget {
  const LibraryHealthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final report = ref.watch(_healthProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Duplicates & broken files'), actions: [
        IconButton(icon: const Icon(Icons.refresh), onPressed: () => ref.invalidate(_healthProvider)),
      ]),
      body: report.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (r) {
          if (r.duplicates.isEmpty && r.broken.isEmpty) {
            return const EmptyState(title: 'All clear', message: 'No duplicates or broken files found.');
          }
          return ListView(children: [
            if (r.duplicates.isNotEmpty) _header(context, '${r.duplicates.length} duplicate ${r.duplicates.length == 1 ? 'set' : 'sets'}'),
            for (final g in r.duplicates)
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 0), child: Text(g.reason, style: Theme.of(context).textTheme.labelLarge)),
                  for (final s in g.songs) _songRow(context, ref, s),
                ]),
              ),
            if (r.broken.isNotEmpty) _header(context, '${r.broken.length} broken ${r.broken.length == 1 ? 'file' : 'files'}'),
            for (final b in r.broken)
              ListTile(
                leading: const Icon(Icons.broken_image_outlined),
                title: Text(b.song.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text('${switch (b.reason) { BrokenReason.zeroDuration => 'Zero length', BrokenReason.zeroSize => 'Empty file', BrokenReason.missingFile => 'File missing' }}\n${b.song.filePath}', maxLines: 3),
                isThreeLine: true,
                onTap: () => showSongDetails(context, ref, b.song),
              ),
          ]);
        },
      ),
    );
  }

  Widget _header(BuildContext context, String t) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
        child: Text(t, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.primary)),
      );

  Widget _songRow(BuildContext context, WidgetRef ref, Song s) => ListTile(
        dense: true,
        title: Text(s.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(s.filePath, maxLines: 2, overflow: TextOverflow.ellipsis),
        onTap: () => showSongDetails(context, ref, s),
      );
}
