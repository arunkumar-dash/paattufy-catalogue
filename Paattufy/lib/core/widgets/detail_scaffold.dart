import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../entities/entities.dart';
import '../../features/library/presentation/song_actions.dart';
import '../../features/playback/data/playback_controller.dart';
import 'song_artwork.dart';
import 'song_tile.dart';

/// The shared detail-page template (AP §5.3, §7.1): large blurred-art header,
/// title block, `Play` + `Shuffle`, overflow (Play next, Add to queue, Add all
/// to group), then the song list. Used by artist, album, folder and group pages.
class DetailScaffold extends ConsumerWidget {
  const DetailScaffold({
    super.key,
    required this.title,
    this.subtitle,
    required this.songs,
    this.heroUris,
    this.description = '',
    this.extraMenu = const [],
    this.onExtraMenu,
    this.bottom,
    this.groupId,
    this.groupIsStatic = false,
    this.onReorder,
    this.emptyMessage = 'No songs here yet.',
    this.heroIcon = Icons.music_note,
    this.playShuffled = false,
  });

  final String title;
  final String? subtitle;
  final AsyncValue<List<Song>> songs;
  final List<String>? heroUris;

  /// Shown as `Playing from <description>` in the queue.
  final String description;
  final List<PopupMenuEntry<String>> extraMenu;
  final void Function(String value)? onExtraMenu;
  final Widget? bottom;
  final int? groupId;
  final bool groupIsStatic;
  final void Function(Song song, int newIndex)? onReorder;
  final String emptyMessage;
  final IconData heroIcon;

  /// The group's default play mode: `Play` shuffles when true.
  final bool playShuffled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final controller = ref.read(playbackControllerProvider.notifier);
    final playingId = ref.watch(playbackControllerProvider.select((s) => s.current?.id));
    final list = songs.value ?? const <Song>[];
    final uris = heroUris ?? [for (final s in list.take(4)) s.contentUri];

    Widget header() => Stack(children: [
          Positioned.fill(
            child: ClipRect(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                child: uris.isEmpty
                    ? Container(color: scheme.primaryContainer)
                    : SongArtwork(contentUri: uris.first, size: 400, radius: 0),
              ),
            ),
          ),
          Positioned.fill(child: Container(color: scheme.surface.withValues(alpha: 0.55))),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 96, 20, 12),
            child: Column(children: [
              SongMosaic(contentUris: uris, size: 160, radius: 14, icon: heroIcon),
              const SizedBox(height: 14),
              Text(title, style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
              if (subtitle != null) Text(subtitle!, style: TextStyle(color: scheme.onSurfaceVariant), textAlign: TextAlign.center),
              Text('${list.length} songs', style: TextStyle(color: scheme.onSurfaceVariant)),
              const SizedBox(height: 14),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                FilledButton.icon(
                  onPressed: list.isEmpty ? null : () => controller.playSongs(list, shuffle: playShuffled, description: description.isEmpty ? title : description),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Play'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: list.isEmpty
                      ? null
                      : () => controller.playSongs(list, shuffle: true, description: description.isEmpty ? title : description),
                  icon: const Icon(Icons.shuffle),
                  label: const Text('Shuffle'),
                ),
              ]),
            ]),
          ),
        ]);

    Widget rowFor(Song s, int i) {
      final tile = SongTile(
        key: ValueKey('${s.id}#$i'),
        song: s,
        playing: s.id == playingId,
        onTap: () => controller.playSongs(list, startIndex: i, description: description.isEmpty ? title : description),
        onMenu: () => showSongMenu(context, ref, s, groupId: groupId, groupIsStatic: groupIsStatic),
      );
      return tile;
    }

    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverAppBar(
          pinned: true,
          expandedHeight: 480,
          backgroundColor: scheme.surface,
          flexibleSpace: FlexibleSpaceBar(background: header(), collapseMode: CollapseMode.pin),
          title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
          actions: [
            PopupMenuButton<String>(
              onSelected: (v) async {
                switch (v) {
                  case '_next':
                    await controller.playNext(list);
                  case '_queue':
                    await controller.addToQueue(list);
                  case '_group':
                    await showAddToGroupSheet(context, ref, list);
                  default:
                    onExtraMenu?.call(v);
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: '_next', child: Text('Play next')),
                const PopupMenuItem(value: '_queue', child: Text('Add to queue')),
                const PopupMenuItem(value: '_group', child: Text('Add all to group')),
                ...extraMenu,
              ],
            ),
          ],
        ),
        songs.when(
          loading: () => const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator()))),
          error: (e, _) => SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.all(24), child: Text('$e'))),
          data: (items) {
            if (items.isEmpty) {
              return SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.all(40), child: Center(child: Text(emptyMessage))));
            }
            if (onReorder != null) {
              return SliverReorderableList(
                itemCount: items.length,
                onReorderItem: (from, to) => onReorder!(items[from], to),
                itemBuilder: (context, i) => ReorderableDelayedDragStartListener(
                  key: ValueKey('${items[i].id}#$i'),
                  index: i,
                  child: rowFor(items[i], i),
                ),
              );
            }
            return SliverList.builder(itemCount: items.length, itemBuilder: (_, i) => rowFor(items[i], i));
          },
        ),
        if (bottom != null) SliverToBoxAdapter(child: bottom),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ]),
    );
  }
}
