import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/widgets/empty_state.dart';
import '../data/library_providers.dart';

/// Folders: path + count, with the per-folder "Exclude from library" toggle
/// in the overflow menu (AP §5.3).
class FoldersTab extends ConsumerWidget {
  const FoldersTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(libraryRepositoryProvider);
    return ref.watch(foldersProvider).when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (folders) {
            if (folders.isEmpty) return const EmptyState(title: 'No folders yet');
            return ListView.builder(
              itemCount: folders.length,
              itemBuilder: (context, i) {
                final f = folders[i];
                final name = f.path.split('/').where((p) => p.isNotEmpty).lastOrNull ?? f.path;
                return ListTile(
                  leading: Icon(f.excluded ? Icons.folder_off_outlined : Icons.folder_outlined),
                  title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(decoration: f.excluded ? TextDecoration.lineThrough : null)),
                  subtitle: Text('${f.path}\n${f.songCount} songs${f.excluded ? ' · excluded' : ''}', maxLines: 2, overflow: TextOverflow.ellipsis),
                  isThreeLine: true,
                  onTap: f.excluded ? null : () => context.push(Routes.folder(f.path)),
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) async {
                      if (v == 'exclude') {
                        await repo.excludeFolder(f.path);
                      } else {
                        await repo.includeFolder(f.path);
                        await ref.read(scanControllerProvider.notifier).run(full: true);
                      }
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(value: f.excluded ? 'include' : 'exclude', child: Text(f.excluded ? 'Include in library' : 'Exclude from library')),
                    ],
                  ),
                );
              },
            );
          },
        );
  }
}
