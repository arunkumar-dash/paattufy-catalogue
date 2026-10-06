import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/entities/entities.dart';
import '../../../core/settings/app_settings.dart';
import '../../../core/widgets/song_artwork.dart';
import '../../../core/widgets/song_tile.dart';
import '../../groups/data/group_providers.dart';
import '../../library/data/library_providers.dart';
import '../../library/presentation/song_actions.dart';
import '../../playback/data/playback_controller.dart';

const _recentKey = 'recent_searches';

/// Global search (AP §4, §7.1): recent searches, then mixed-type results
/// grouped by Songs / Artists / Albums / Groups, à la YouTube Music.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;
  String _query = '';
  List<String> _recent = [];

  @override
  void initState() {
    super.initState();
    _recent = ref.read(sharedPreferencesProvider).getStringList(_recentKey) ?? [];
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 200), () => setState(() => _query = v.trim()));
  }

  Future<void> _remember(String q) async {
    if (q.trim().isEmpty) return;
    final list = [q.trim(), ..._recent.where((r) => r.toLowerCase() != q.trim().toLowerCase())].take(10).toList();
    setState(() => _recent = list);
    await ref.read(sharedPreferencesProvider).setStringList(_recentKey, list);
  }

  Future<void> _clearRecent() async {
    setState(() => _recent = []);
    await ref.read(sharedPreferencesProvider).remove(_recentKey);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          onChanged: _onChanged,
          onSubmitted: (v) {
            setState(() => _query = v.trim());
            _remember(v);
          },
          decoration: InputDecoration(
            hintText: 'Songs, artists, albums, groups',
            border: InputBorder.none,
            suffixIcon: _controller.text.isEmpty ? null : IconButton(icon: const Icon(Icons.close), onPressed: () { _controller.clear(); setState(() => _query = ''); }),
          ),
        ),
      ),
      body: _query.isEmpty ? _recentView() : _results(),
    );
  }

  Widget _recentView() {
    if (_recent.isEmpty) return const Center(child: Text('Search your library'));
    return ListView(children: [
      ListTile(title: const Text('Recent searches'), trailing: TextButton(onPressed: _clearRecent, child: const Text('Clear'))),
      for (final r in _recent)
        ListTile(
          leading: const Icon(Icons.history),
          title: Text(r),
          onTap: () {
            _controller.text = r;
            setState(() => _query = r);
          },
        ),
    ]);
  }

  Widget _results() {
    final q = _query.toLowerCase();
    final songs = ref.watch(_searchSongs(_query));
    final artists = (ref.watch(artistsProvider).value ?? const []).where((a) => a.name.toLowerCase().contains(q)).take(5).toList();
    final albums = (ref.watch(albumsProvider).value ?? const []).where((a) => a.title.toLowerCase().contains(q)).take(5).toList();
    final groups = (ref.watch(groupSummariesProvider).value ?? const []).where((g) => g.group.name.toLowerCase().contains(q)).take(5).toList();
    final controller = ref.read(playbackControllerProvider.notifier);
    final playingId = ref.watch(playbackControllerProvider.select((s) => s.current?.id));
    final songList = songs.value ?? const <Song>[];

    if (songList.isEmpty && artists.isEmpty && albums.isEmpty && groups.isEmpty && !songs.isLoading) {
      return Center(child: Text('No results for "$_query"'));
    }
    Widget header(String t) => Padding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 4), child: Text(t, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.primary)));
    return ListView(children: [
      if (songList.isNotEmpty) header('Songs'),
      for (final s in songList.take(8))
        SongTile(
          song: s,
          playing: s.id == playingId,
          onTap: () {
            _remember(_query);
            controller.playSong(s);
          },
          onMenu: () => showSongMenu(context, ref, s),
        ),
      if (artists.isNotEmpty) header('Artists'),
      for (final a in artists)
        ListTile(
          leading: SongArtwork(contentUri: a.sampleContentUri, size: 44, radius: 22, icon: Icons.person),
          title: Text(a.name),
          subtitle: Text('${a.songCount} songs'),
          onTap: () {
            _remember(_query);
            context.push(Routes.artist(a.name));
          },
        ),
      if (albums.isNotEmpty) header('Albums'),
      for (final a in albums)
        ListTile(
          leading: SongArtwork(contentUri: a.sampleContentUri, size: 44, radius: 8, icon: Icons.album),
          title: Text(a.title),
          subtitle: Text(a.artist),
          onTap: () {
            _remember(_query);
            context.push(Routes.album(a.title, a.artist));
          },
        ),
      if (groups.isNotEmpty) header('Groups'),
      for (final g in groups)
        ListTile(
          leading: SongMosaic(contentUris: g.coverContentUris, size: 44, radius: 8),
          title: Text(g.group.name),
          subtitle: Text('${g.songCount} songs · ${g.group.type == 'smart' ? 'Smart' : 'Static'}'),
          onTap: () {
            _remember(_query);
            context.push(Routes.group(g.group.id));
          },
        ),
      const SizedBox(height: 24),
    ]);
  }
}

final _searchSongs = StreamProvider.autoDispose.family<List<Song>, String>(
  (ref, q) => ref.watch(libraryRepositoryProvider).watchSongs(query: q),
);
