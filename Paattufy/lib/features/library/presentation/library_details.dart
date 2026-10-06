import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/entities/entities.dart';
import '../../../core/widgets/detail_scaffold.dart';
import '../data/library_providers.dart';
import '../data/library_repository.dart';

final _artistSongs = StreamProvider.autoDispose.family<List<Song>, String>((ref, name) =>
    ref.watch(libraryRepositoryProvider).watchSongs(artist: name, sort: SongSort.album));

final _albumSongs = StreamProvider.autoDispose.family<List<Song>, (String, String)>((ref, k) =>
    ref.watch(libraryRepositoryProvider).watchSongs(album: k.$1, albumArtist: k.$2, sort: SongSort.title));

final _folderSongs = StreamProvider.autoDispose.family<List<Song>, String>((ref, path) =>
    ref.watch(libraryRepositoryProvider).watchSongs(folder: path));

class ArtistDetailScreen extends ConsumerWidget {
  const ArtistDetailScreen({super.key, required this.name});
  final String name;
  @override
  Widget build(BuildContext context, WidgetRef ref) => DetailScaffold(
        title: name,
        subtitle: 'Artist',
        songs: ref.watch(_artistSongs(name)),
        heroIcon: Icons.person,
        description: name,
      );
}

class AlbumDetailScreen extends ConsumerWidget {
  const AlbumDetailScreen({super.key, required this.title, required this.artist});
  final String title;
  final String artist;
  @override
  Widget build(BuildContext context, WidgetRef ref) => DetailScaffold(
        title: title,
        subtitle: artist,
        songs: ref.watch(_albumSongs((title, artist))),
        heroIcon: Icons.album,
        description: title,
      );
}

class FolderDetailScreen extends ConsumerWidget {
  const FolderDetailScreen({super.key, required this.path});
  final String path;
  @override
  Widget build(BuildContext context, WidgetRef ref) => DetailScaffold(
        title: path.split('/').where((p) => p.isNotEmpty).lastOrNull ?? path,
        subtitle: path,
        songs: ref.watch(_folderSongs(path)),
        heroIcon: Icons.folder,
        description: path.split('/').where((p) => p.isNotEmpty).lastOrNull ?? path,
        extraMenu: const [PopupMenuItem(value: 'exclude', child: Text('Exclude from library'))],
        onExtraMenu: (v) {
          if (v == 'exclude') ref.read(libraryRepositoryProvider).excludeFolder(path);
        },
      );
}
