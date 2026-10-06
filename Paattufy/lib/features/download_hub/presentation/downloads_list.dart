import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/entities/entities.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/empty_state.dart';
import '../data/download_manager.dart';
import '../data/download_providers.dart';

/// Active transfers with progress / pause / cancel, plus history with
/// re-download and "reveal in library" (AP §5.8).
class DownloadsList extends ConsumerWidget {
  const DownloadsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloads = ref.watch(downloadsProvider);
    final mgr = ref.read(downloadManagerProvider);
    return downloads.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (list) {
        if (list.isEmpty) return const EmptyState(title: 'No downloads yet', message: 'Pick a site and download an album or song.');
        final active = list.where((d) => const {DownloadStatus.running, DownloadStatus.queued, DownloadStatus.paused}.contains(d.status)).toList();
        final history = list.where((d) => !active.contains(d)).toList();
        return ListView(children: [
          if (active.isNotEmpty) const _Header('Active'),
          for (final d in active) _ActiveTile(d: d, mgr: mgr),
          if (history.isNotEmpty) const _Header('History'),
          for (final d in history) _HistoryTile(d: d, mgr: mgr),
        ]);
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
        child: Text(text, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.primary)),
      );
}

class _ActiveTile extends StatelessWidget {
  const _ActiveTile({required this.d, required this.mgr});
  final DownloadRecord d;
  final DownloadManager mgr;

  @override
  Widget build(BuildContext context) {
    final progress = d.bytesTotal > 0 ? (d.bytesDone / d.bytesTotal).clamp(0.0, 1.0) : null;
    final running = d.status == DownloadStatus.running;
    return ListTile(
      title: Text(d.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 4),
        LinearProgressIndicator(value: running ? progress : (d.status == DownloadStatus.queued ? null : progress)),
        const SizedBox(height: 4),
        Text(switch (d.status) {
          DownloadStatus.queued => 'Queued',
          DownloadStatus.paused => d.error ?? 'Paused · ${formatBytes(d.bytesDone)}',
          _ => '${formatBytes(d.bytesDone)}${d.bytesTotal > 0 ? ' of ${formatBytes(d.bytesTotal)}' : ''}',
        }, style: const TextStyle(fontSize: 12)),
      ]),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        if (d.status == DownloadStatus.paused) IconButton(icon: const Icon(Icons.play_arrow), tooltip: 'Resume', onPressed: () => mgr.resume(d.id)),
        if (running || d.status == DownloadStatus.queued) IconButton(icon: const Icon(Icons.pause), tooltip: 'Pause', onPressed: () => mgr.pause(d.id)),
        IconButton(icon: const Icon(Icons.close), tooltip: 'Cancel', onPressed: () => mgr.cancel(d.id)),
      ]),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.d, required this.mgr});
  final DownloadRecord d;
  final DownloadManager mgr;

  @override
  Widget build(BuildContext context) {
    final ok = d.status == DownloadStatus.done;
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(ok ? Icons.check_circle : Icons.error_outline, color: ok ? Colors.green : scheme.error),
      title: Text(d.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(ok ? 'Added ${d.itemsAdded} ${d.itemsAdded == 1 ? 'song' : 'songs'}' : (d.error ?? 'Failed'), maxLines: 2, overflow: TextOverflow.ellipsis),
      trailing: PopupMenuButton<String>(
        onSelected: (v) {
          if (v == 'retry') mgr.retry(d.id);
          if (v == 'reveal' && d.localPath != null) {
            final path = d.localPath!;
            final dir = FileSystemEntity.isDirectorySync(path) ? path : File(path).parent.path;
            context.push(Routes.folder(dir));
          }
        },
        itemBuilder: (_) => [
          const PopupMenuItem(value: 'retry', child: Text('Download again')),
          if (ok && d.localPath != null) const PopupMenuItem(value: 'reveal', child: Text('Reveal in library')),
        ],
      ),
    );
  }
}
