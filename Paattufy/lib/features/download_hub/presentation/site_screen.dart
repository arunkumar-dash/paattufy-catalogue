import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/download_providers.dart';
import '../domain/catalogue.dart';
import 'browse_screen.dart';
import 'listing_screen.dart';

/// Resolves a catalogue site id to its screen: browse mode → in-app browser,
/// listing mode → native cards.
class SiteScreen extends ConsumerWidget {
  const SiteScreen({super.key, required this.siteId});
  final String siteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cat = ref.watch(catalogueControllerProvider);
    return cat.when(
      loading: () => Scaffold(appBar: AppBar(), body: const Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(appBar: AppBar(), body: Center(child: Text('$e'))),
      data: (c) {
        final site = c.catalogue.sites.where((s) => s.id == siteId).firstOrNull;
        if (site == null) return Scaffold(appBar: AppBar(), body: const Center(child: Text('This site is no longer in the catalogue.')));
        return site.mode == SiteMode.listing ? ListingScreen(site: site) : BrowseScreen(site: site);
      },
    );
  }
}
