import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/entities/entities.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/settings/app_settings.dart';
import '../domain/media_scanner.dart';
import 'library_repository.dart';
import 'library_scan_service.dart';
import 'media_store_scanner.dart';

final mediaStoreScannerProvider = Provider<MediaStoreScanner>((ref) => MediaStoreScanner());

final mediaScannerProvider = Provider<MediaScanner>(
  (ref) => ref.watch(mediaStoreScannerProvider),
);

final libraryRepositoryProvider = Provider<LibraryRepository>(
  (ref) => LibraryRepository(ref.watch(databaseProvider)),
);

final libraryScanServiceProvider = Provider<LibraryScanService>(
  (ref) => LibraryScanService(
    ref.watch(mediaScannerProvider),
    ref.watch(libraryRepositoryProvider),
  ),
);

/// Sticky per-tab sort (AP §5.2: "remembered per tab").
class SortState {
  const SortState(this.sort, this.ascending);
  final SongSort sort;
  final bool ascending;
}

class SortNotifier extends Notifier<SortState> {
  SortNotifier(this.tabKey);
  final String tabKey;

  @override
  SortState build() {
    final p = ref.watch(sharedPreferencesProvider);
    final name = p.getString('sort_$tabKey');
    final sort = SongSort.values.where((s) => s.name == name).firstOrNull ?? SongSort.title;
    return SortState(sort, p.getBool('sort_${tabKey}_asc') ?? true);
  }

  Future<void> set(SongSort sort, bool asc) async {
    state = SortState(sort, asc);
    final p = ref.read(sharedPreferencesProvider);
    await p.setString('sort_$tabKey', sort.name);
    await p.setBool('sort_${tabKey}_asc', asc);
  }
}

final songsSortProvider =
    NotifierProvider<SortNotifier, SortState>(() => SortNotifier('songs'));

final songsProvider = StreamProvider<List<Song>>((ref) {
  final sort = ref.watch(songsSortProvider);
  return ref
      .watch(libraryRepositoryProvider)
      .watchSongs(sort: sort.sort, ascending: sort.ascending);
});

final artistsProvider = StreamProvider<List<ArtistSummary>>(
  (ref) => ref.watch(libraryRepositoryProvider).watchArtists(),
);
final albumsProvider = StreamProvider<List<AlbumSummary>>(
  (ref) => ref.watch(libraryRepositoryProvider).watchAlbums(),
);
final foldersProvider = StreamProvider<List<FolderSummary>>(
  (ref) => ref.watch(libraryRepositoryProvider).watchFolders(),
);
final excludedFoldersProvider = StreamProvider<List<String>>(
  (ref) => ref.watch(libraryRepositoryProvider).watchExcludedFolders(),
);

/// Progress of a running scan (songs found so far), or null when idle.
class ScanProgress {
  const ScanProgress({this.found = 0, this.running = false, this.last});
  final int found;
  final bool running;
  final ScanResult? last;
}

class ScanController extends Notifier<ScanProgress> {
  @override
  ScanProgress build() => const ScanProgress();

  Future<ScanResult?> run({bool full = true}) async {
    final svc = ref.read(libraryScanServiceProvider);
    if (svc.isRunning) return null;
    final settings = ref.read(settingsProvider);
    final minMs = settings.ignoreShortClipsSec * 1000;
    state = const ScanProgress(running: true);
    try {
      void progress(int n) => state = ScanProgress(found: n, running: true);
      final result = full
          ? await svc.fullScan(minDurationMs: minMs, onProgress: progress)
          : await svc.incrementalScan(minDurationMs: minMs, onProgress: progress);
      await ref
          .read(settingsProvider.notifier)
          .update((s) => s.copyWith(lastScanAt: DateTime.now().millisecondsSinceEpoch ~/ 1000));
      state = ScanProgress(found: result.total, last: result);
      return result;
    } catch (e) {
      state = const ScanProgress();
      rethrow;
    }
  }
}

final scanControllerProvider =
    NotifierProvider<ScanController, ScanProgress>(ScanController.new);
