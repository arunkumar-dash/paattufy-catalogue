import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/entities/entities.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/providers/http_providers.dart';
import '../../../core/remote/remote_catalogue.dart';
import '../../../core/settings/app_settings.dart';
import '../../library/data/library_providers.dart';
import '../domain/catalogue.dart';
import '../domain/listing_parser.dart';
import 'download_manager.dart';

class CatalogueState {
  const CatalogueState(this.catalogue, this.fetchedAt, {this.error, this.fromCache = false});
  final DownloadCatalogue catalogue;
  final DateTime? fetchedAt;
  final String? error;
  final bool fromCache;
}

/// The site catalogue, fetched with ETag caching (TP §7.8). Manual "Refresh"
/// calls [refresh], which forces a conditional GET.
class CatalogueController extends AsyncNotifier<CatalogueState> {
  @override
  Future<CatalogueState> build() => _load(force: false);

  Future<CatalogueState> _load({required bool force}) async {
    final settings = ref.read(settingsProvider);
    final r = await ref.read(remoteCatalogueProvider).get(
          RemoteCatalogue.downloadKey,
          settings.downloadCatalogueUrl,
          force: force,
          maxAge: Duration(hours: settings.catalogueRefreshHours),
        );
    return CatalogueState(DownloadCatalogue.parse(r.json), r.fetchedAt, error: r.error, fromCache: r.fromCache);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _load(force: true));
  }
}

final catalogueControllerProvider =
    AsyncNotifierProvider<CatalogueController, CatalogueState>(CatalogueController.new);

/// Lives for the whole app session so transfers continue after leaving the
/// Download tab (AP §3.8: "progress survives leaving the screen").
final downloadManagerProvider = Provider<DownloadManager>((ref) {
  const media = MethodChannel('paattufy/media_store');
  const system = MethodChannel('paattufy/system');
  final manager = DownloadManager(
    db: ref.watch(databaseProvider),
    dio: ref.watch(dioProvider),
    settings: () => ref.read(settingsProvider),
    tempDir: Directory('${Directory.systemTemp.path}/paattufy_downloads'),
    indexFiles: (paths) async {
      await media.invokeMethod<int>('scanFiles', {'paths': paths});
    },
    onLibraryChanged: () async {
      await ref.read(scanControllerProvider.notifier).run(full: false);
    },
    isMetered: () async => (await system.invokeMethod<bool>('isMetered')) ?? false,
  );
  manager.siteResolver = (id) async {
    final cat = await ref.read(catalogueControllerProvider.future);
    return cat.catalogue.sites.where((s) => s.id == id).firstOrNull;
  };
  manager.recover();
  ref.onDispose(manager.dispose);
  return manager;
});

final downloadsProvider = StreamProvider<List<DownloadRecord>>(
  (ref) => ref.watch(downloadManagerProvider).watchAll(),
);

/// Native cards for a listing-mode site, parsed with the catalogue's own rules.
final listingProvider = FutureProvider.autoDispose.family<List<ListingItem>, CatalogueSite>((ref, site) async {
  final cfg = site.listing!;
  final res = await ref.watch(dioProvider).get<String>(
        cfg.listPageUrl,
        options: Options(responseType: ResponseType.plain),
      );
  return ListingParser(cfg).parseListing(res.data ?? '', Uri.parse(cfg.listPageUrl));
});
