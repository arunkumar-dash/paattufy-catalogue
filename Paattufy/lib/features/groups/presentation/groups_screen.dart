import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/song_artwork.dart';
import '../data/group_providers.dart';
import '../data/group_repository.dart';

/// Groups tab (AP §5.4): cards with a 2×2 art mosaic, name, `n songs` and a
/// Smart / Static badge; FAB → New group.
class GroupsScreen extends ConsumerWidget {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = ref.watch(groupSummariesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Groups'), actions: [
        PopupMenuButton<String>(
          onSelected: (v) {
            if (v == 'hidden') _showHidden(context, ref);
          },
          itemBuilder: (_) => const [PopupMenuItem(value: 'hidden', child: Text('Hidden groups'))],
        ),
      ]),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('New group'),
        onPressed: () => _chooseType(context),
      ),
      body: groups.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (list) {
          if (list.isEmpty) return const EmptyState(title: 'No groups yet', message: 'Hand-pick songs or build a rule.');
          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 14, crossAxisSpacing: 12, childAspectRatio: 0.78),
            itemCount: list.length,
            itemBuilder: (context, i) => _GroupCard(summary: list[i]),
          );
        },
      ),
    );
  }

  void _chooseType(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheet) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            leading: const Icon(Icons.checklist),
            title: const Text('Hand-pick songs'),
            subtitle: const Text('A static group — your own ordered list'),
            onTap: () {
              Navigator.pop(sheet);
              context.push(Routes.groupEdit(type: 'static'));
            },
          ),
          ListTile(
            leading: const Icon(Icons.auto_awesome),
            title: const Text('Build a rule'),
            subtitle: const Text('A smart group that stays current as songs are added'),
            onTap: () {
              Navigator.pop(sheet);
              context.push(Routes.groupEdit(type: 'smart'));
            },
          ),
        ]),
      ),
    );
  }

  Future<void> _showHidden(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(groupRepositoryProvider);
    final all = await repo.watchGroupRows(includeHidden: true).first;
    final hidden = all.where((g) => g.isHidden).toList();
    if (!context.mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheet) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const ListTile(title: Text('Hidden groups')),
          if (hidden.isEmpty) const Padding(padding: EdgeInsets.all(24), child: Text('Nothing hidden.')),
          for (final g in hidden)
            ListTile(
              title: Text(g.name),
              trailing: TextButton(onPressed: () async {
                await repo.unhide(g.id);
                if (sheet.mounted) Navigator.pop(sheet);
              }, child: const Text('Show')),
            ),
        ]),
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({required this.summary});
  final GroupSummary summary;

  @override
  Widget build(BuildContext context) {
    final g = summary.group;
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => context.push(Routes.group(g.id)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, box) => Stack(children: [
              SongMosaic(contentUris: summary.coverContentUris, size: box.maxWidth.clamp(0.0, box.maxHeight).toDouble(), radius: 14),
              Positioned(
                left: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: g.type == 'smart' ? scheme.primary : scheme.secondaryContainer, borderRadius: BorderRadius.circular(10)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(g.type == 'smart' ? Icons.auto_awesome : Icons.queue_music, size: 12, color: g.type == 'smart' ? scheme.onPrimary : scheme.onSecondaryContainer),
                    const SizedBox(width: 4),
                    Text(g.type == 'smart' ? 'Smart' : 'Static', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: g.type == 'smart' ? scheme.onPrimary : scheme.onSecondaryContainer)),
                  ]),
                ),
              ),
            ]),
          ),
        ),
        const SizedBox(height: 6),
        Text(g.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
        Text('${summary.songCount} ${summary.songCount == 1 ? 'song' : 'songs'}', style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12)),
      ]),
    );
  }
}
