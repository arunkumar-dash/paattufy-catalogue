import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/settings/app_settings.dart';
import '../features/download_hub/presentation/download_screen.dart';
import '../features/download_hub/presentation/downloads_list.dart';
import '../features/download_hub/presentation/site_screen.dart';
import '../features/groups/presentation/group_detail_screen.dart';
import '../features/groups/presentation/group_editor_screen.dart';
import '../features/groups/presentation/groups_screen.dart';
import '../features/library/presentation/library_details.dart';
import '../features/library/presentation/library_health_screen.dart';
import '../features/library/presentation/library_screen.dart';
import '../features/library/presentation/tag_editor_screen.dart';
import '../features/lyrics/presentation/lyrics_picker_screen.dart';
import '../features/lyrics/presentation/lyrics_screen.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/playback/presentation/now_playing_screen.dart';
import '../features/search/presentation/search_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import 'root_shell.dart';
import 'routes.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

CustomTransitionPage<void> _slideUp(GoRouterState state, Widget child) => CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 280),
      reverseTransitionDuration: const Duration(milliseconds: 240),
      transitionsBuilder: (context, animation, secondary, child) => SlideTransition(
        position: Tween(begin: const Offset(0, 1), end: Offset.zero).chain(CurveTween(curve: Curves.easeOutCubic)).animate(animation),
        child: child,
      ),
    );

/// App routes (AP §4). Bottom-nav tabs live in a [StatefulShellRoute];
/// overlays (Now Playing, Search, Lyrics, detail pages) are pushed on the root
/// navigator so they cover the shell.
final routerProvider = Provider<GoRouter>((ref) {
  final onboarded = ref.watch(settingsProvider.select((s) => s.onboardingComplete));
  final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: onboarded ? Routes.library : Routes.onboarding,
    routes: [
      GoRoute(path: Routes.onboarding, builder: (context, state) => const OnboardingScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => RootShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(routes: [GoRoute(path: Routes.library, builder: (context, state) => const LibraryScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: Routes.groups, builder: (context, state) => const GroupsScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: Routes.download, builder: (context, state) => const DownloadScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: Routes.settings, builder: (context, state) => const SettingsScreen())]),
        ],
      ),
      // Overlays / full-screen routes, reachable from anywhere.
      GoRoute(parentNavigatorKey: rootNavigatorKey, path: Routes.nowPlaying, pageBuilder: (c, s) => _slideUp(s, const NowPlayingScreen())),
      GoRoute(parentNavigatorKey: rootNavigatorKey, path: Routes.search, builder: (c, s) => const SearchScreen()),
      GoRoute(parentNavigatorKey: rootNavigatorKey, path: Routes.lyrics, pageBuilder: (c, s) => _slideUp(s, const LyricsScreen())),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/lyrics-picker',
        builder: (c, s) => LyricsPickerScreen(songId: s.uri.queryParameters['song'] ?? ''),
      ),
      GoRoute(parentNavigatorKey: rootNavigatorKey, path: '/artist', builder: (c, s) => ArtistDetailScreen(name: s.uri.queryParameters['name'] ?? '')),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/album',
        builder: (c, s) => AlbumDetailScreen(title: s.uri.queryParameters['title'] ?? '', artist: s.uri.queryParameters['artist'] ?? ''),
      ),
      GoRoute(parentNavigatorKey: rootNavigatorKey, path: '/folder', builder: (c, s) => FolderDetailScreen(path: s.uri.queryParameters['path'] ?? '')),
      GoRoute(parentNavigatorKey: rootNavigatorKey, path: '/group/:id', builder: (c, s) => GroupDetailScreen(groupId: int.parse(s.pathParameters['id']!))),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/group-edit',
        builder: (c, s) => GroupEditorScreen(
          groupId: int.tryParse(s.uri.queryParameters['id'] ?? ''),
          type: s.uri.queryParameters['type'] ?? 'static',
        ),
      ),
      GoRoute(parentNavigatorKey: rootNavigatorKey, path: '/download/site/:id', builder: (c, s) => SiteScreen(siteId: s.pathParameters['id']!)),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: Routes.downloads,
        builder: (c, s) => Scaffold(appBar: AppBar(title: const Text('Downloads')), body: const DownloadsList()),
      ),
      GoRoute(parentNavigatorKey: rootNavigatorKey, path: Routes.libraryHealth, builder: (c, s) => const LibraryHealthScreen()),
      GoRoute(parentNavigatorKey: rootNavigatorKey, path: '/tag-editor/:id', builder: (c, s) => TagEditorScreen(songId: s.pathParameters['id']!)),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
