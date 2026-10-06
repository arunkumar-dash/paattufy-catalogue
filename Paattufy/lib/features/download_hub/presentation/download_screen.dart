import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/widgets/empty_state.dart';
import '../data/download_manager.dart';
import '../data/download_providers.dart';
import '../domain/catalogue.dart';
import 'downloads_list.dart';

/// Download tab (AP §5.8): site catalogue from the GitHub JSON + downloads.
class DownloadScreen extends ConsumerWidget {
  const DownloadScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(downloadsProvider).value?.where((d) => d.status == DownloadStatus.running || d.status == DownloadStatus.queued).length ?? 0;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Download'),
          bottom: TabBar(tabs: [
            const Tab(text: 'Sites'),
            Tab(child: Row(mainAxisSize: MainAxisSize.min, children: [const Text('Downloads'), if (active > 0) ...[const SizedBox(width: 6), Badge(label: Text('$active'))]])),
          ]),
        ),
        body: const TabBarView(children: [_SitesTab(), DownloadsList()]),
      ),
    );
  }
}

class _SitesTab extends ConsumerWidget {
  const _SitesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(catalogueControllerProvider);
    final scheme = Theme.of(context).colorScheme;
    return state.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => EmptyState(title: 'Could not load the catalogue', message: '$e', action: FilledButton(onPressed: () => ref.read(catalogueControllerProvider.notifier).refresh(), child: const Text('Retry'))),
      data: (cat) => RefreshIndicator(
        onRefresh: () => ref.read(catalogueControllerProvider.notifier).refresh(),
        child: ListView(padding: const EdgeInsets.all(12), children: [
          Row(children: [
            Expanded(
              child: Text(
                cat.fetchedAt == null ? 'Not loaded yet' : 'Last updated ${_ago(cat.fetchedAt!)}${cat.fromCache ? ' (cached)' : ''}',
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
            ),
            TextButton.icon(onPressed: () => ref.read(catalogueControllerProvider.notifier).refresh(), icon: const Icon(Icons.refresh, size: 18), label: const Text('Refresh')),
          ]),
          if (cat.error != null)
            Card(color: scheme.errorContainer, child: ListTile(leading: const Icon(Icons.cloud_off), title: const Text('Offline — showing the last saved list'), subtitle: Text(cat.error!, maxLines: 2, overflow: TextOverflow.ellipsis))),
          if (cat.catalogue.sites.isEmpty)
            const Padding(padding: EdgeInsets.only(top: 60), child: EmptyState(title: 'No sites yet', message: 'Add sites to your catalogue JSON on GitHub, then tap Refresh.')),
          for (final site in cat.catalogue.sites) _SiteCard(site: site),
        ]),
      ),
    );
  }

  static String _ago(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 1) return 'just now';
    if (d.inMinutes < 60) return '${d.inMinutes} min ago';
    if (d.inHours < 24) return '${d.inHours} h ago';
    return '${d.inDays} d ago';
  }
}

class _SiteCard extends StatelessWidget {
  const _SiteCard({required this.site});
  final CatalogueSite site;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final listing = site.mode == SiteMode.listing;
    return Card(
      child: ListTile(
        leading: CircleAvatar(backgroundColor: scheme.primaryContainer, child: Icon(listing ? Icons.view_list : Icons.public, color: scheme.onPrimaryContainer)),
        title: Text(site.title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(Uri.parse(site.link).host),
        trailing: Chip(label: Text(listing ? 'Recent list' : 'Browse'), visualDensity: VisualDensity.compact),
        onTap: () => context.push(Routes.site(site.id)),
      ),
    );
  }
}
