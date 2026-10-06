import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/widgets/detail_scaffold.dart';
import '../data/group_providers.dart';

/// Group detail (AP §5.4): the shared detail template plus `Edit rules`,
/// `Duplicate`, `Delete` (built-ins are hidden instead), and drag-reorder for
/// static groups.
class GroupDetailScreen extends ConsumerWidget {
  const GroupDetailScreen({super.key, required this.groupId});
  final int groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final group = ref.watch(groupByIdProvider(groupId)).value;
    final songs = ref.watch(groupSongsProvider(groupId));
    final repo = ref.read(groupRepositoryProvider);
    if (group == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final isStatic = group.type == 'static';

    return DetailScaffold(
      title: group.name,
      subtitle: isStatic ? 'Static group' : (group.isBuiltin ? 'Built-in smart group' : 'Smart group'),
      songs: songs,
      heroIcon: isStatic ? Icons.queue_music : Icons.auto_awesome,
      description: group.name,
      groupId: group.id,
      groupIsStatic: isStatic,
      playShuffled: group.defaultPlayMode == 'shuffle',
      emptyMessage: isStatic ? 'Add songs from the library with "Add to group".' : 'No songs match this rule yet.',
      onReorder: isStatic && group.defaultSort == 'manual' ? (song, to) => repo.reorderStatic(group.id, song.id, to) : null,
      extraMenu: [
        if (!isStatic) const PopupMenuItem(value: 'edit', child: Text('Edit rules')),
        if (isStatic) const PopupMenuItem(value: 'edit', child: Text('Rename / edit')),
        const PopupMenuItem(value: 'dup', child: Text('Duplicate')),
        PopupMenuItem(value: 'delete', child: Text(group.isBuiltin ? 'Hide' : 'Delete')),
      ],
      onExtraMenu: (v) async {
        switch (v) {
          case 'edit':
            context.push(Routes.groupEdit(id: group.id, type: group.type));
          case 'dup':
            final id = await repo.duplicate(group.id);
            if (context.mounted) context.pushReplacement(Routes.group(id));
          case 'delete':
            final ok = await showDialog<bool>(
              context: context,
              builder: (d) => AlertDialog(
                title: Text(group.isBuiltin ? 'Hide "${group.name}"?' : 'Delete "${group.name}"?'),
                content: Text(group.isBuiltin
                    ? 'Built-in groups can\'t be deleted, only hidden. You can show it again from the Groups menu.'
                    : 'Only the group is removed — your songs stay in the library.'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(d, false), child: const Text('Cancel')),
                  FilledButton(onPressed: () => Navigator.pop(d, true), child: Text(group.isBuiltin ? 'Hide' : 'Delete')),
                ],
              ),
            );
            if (ok == true) {
              await repo.delete(group.id);
              if (context.mounted) context.pop();
            }
        }
      },
    );
  }
}
