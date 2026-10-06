import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/entities/entities.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/song_tile.dart';
import '../../playback/data/playback_controller.dart';
import '../data/library_providers.dart';
import '../data/library_repository.dart';
import 'song_actions.dart';

Future<void> showSortSheet(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    useRootNavigator: true, // cover the tab bar so all options fit
    builder: (sheet) => Consumer(builder: (context, ref, _) {
      final current = ref.watch(songsSortProvider);
      final notifier = ref.read(songsSortProvider.notifier);
      return SafeArea(
        child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          const ListTile(title: Text('Sort songs by')),
          RadioGroup<SongSort>(
            groupValue: current.sort,
            onChanged: (v) => notifier.set(v!, current.ascending),
            child: Column(children: [
              for (final s in SongSort.values) RadioListTile<SongSort>(value: s, title: Text(s.label)),
            ]),
          ),
          SwitchListTile(
            title: const Text('Ascending'),
            value: current.ascending,
            onChanged: (v) => notifier.set(current.sort, v),
          ),
        ])),
      );
    }),
  );
}

/// Songs tab (AP §5.2): header chips, sortable list, fast-scroll index rail
/// that reflects the active sort key, long-press multi-select with bulk actions.
class SongsTab extends ConsumerStatefulWidget {
  const SongsTab({super.key});

  @override
  ConsumerState<SongsTab> createState() => _SongsTabState();
}

class _SongsTabState extends ConsumerState<SongsTab> {
  static const double rowExtent = 60;
  final _scroll = ScrollController();
  final Set<String> _selected = {};
  bool get _selecting => _selected.isNotEmpty;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  String _indexKey(Song s, SongSort sort) {
    final text = switch (sort) {
      SongSort.artist => s.artist,
      SongSort.album => s.album,
      _ => s.title,
    };
    final c = text.isEmpty ? '#' : text[0].toUpperCase();
    return RegExp(r'[A-Z]').hasMatch(c) ? c : '#';
  }

  @override
  Widget build(BuildContext context) {
    final songsAsync = ref.watch(songsProvider);
    final sort = ref.watch(songsSortProvider);
    final playingId = ref.watch(playbackControllerProvider.select((s) => s.current?.id));
    final controller = ref.read(playbackControllerProvider.notifier);
    final scheme = Theme.of(context).colorScheme;

    return songsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (songs) {
        if (songs.isEmpty) {
          return EmptyState(
            title: 'No songs yet',
            message: 'Paattufy reads your device library. Grant access and scan to see your music.',
            action: FilledButton(onPressed: () => ref.read(scanControllerProvider.notifier).run(full: true), child: const Text('Scan now')),
          );
        }
        final textSort = sort.sort == SongSort.title || sort.sort == SongSort.artist || sort.sort == SongSort.album;
        final firstIndexOf = <String, int>{};
        if (textSort) {
          for (var i = 0; i < songs.length; i++) {
            firstIndexOf.putIfAbsent(_indexKey(songs[i], sort.sort), () => i);
          }
        }

        return Column(children: [
          if (_selecting)
            _SelectionBar(
              count: _selected.length,
              onClose: () => setState(_selected.clear),
              onAll: () => setState(() => _selected.addAll(songs.map((s) => s.id))),
              onRange: () {
                final idx = [for (var i = 0; i < songs.length; i++) if (_selected.contains(songs[i].id)) i];
                if (idx.length < 2) return;
                setState(() => _selected.addAll(songs.sublist(idx.first, idx.last + 1).map((s) => s.id)));
              },
              onPlayNext: () async {
                await controller.playNext(_chosen(songs));
                setState(_selected.clear);
              },
              onQueue: () async {
                await controller.addToQueue(_chosen(songs));
                setState(_selected.clear);
              },
              onGroup: () async {
                final chosen = _chosen(songs);
                await showAddToGroupSheet(context, ref, chosen);
                if (mounted) setState(_selected.clear);
              },
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Row(children: [
                ActionChip(
                  avatar: const Icon(Icons.shuffle, size: 18),
                  label: const Text('Shuffle all'),
                  onPressed: () => controller.playSongs(songs, shuffle: true, description: 'Library'),
                ),
                const SizedBox(width: 8),
                ActionChip(
                  avatar: const Icon(Icons.play_arrow, size: 18),
                  label: const Text('Play all'),
                  onPressed: () => controller.playSongs(songs, description: 'Library'),
                ),
                const Spacer(),
                Text('${songs.length} songs', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
              ]),
            ),
          Expanded(
            child: Stack(children: [
              ListView.builder(
                controller: _scroll,
                itemExtent: rowExtent,
                itemCount: songs.length,
                padding: EdgeInsets.only(right: textSort ? 20 : 0, bottom: 8),
                itemBuilder: (context, i) {
                  final s = songs[i];
                  return SongTile(
                    song: s,
                    playing: s.id == playingId,
                    selecting: _selecting,
                    selected: _selected.contains(s.id),
                    onTap: () {
                      if (_selecting) {
                        setState(() => _selected.contains(s.id) ? _selected.remove(s.id) : _selected.add(s.id));
                      } else {
                        controller.playSong(s);
                      }
                    },
                    onLongPress: () => setState(() => _selected.add(s.id)),
                    onMenu: () => showSongMenu(context, ref, s),
                  );
                },
              ),
              if (textSort && firstIndexOf.length > 1)
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: _IndexRail(
                    letters: firstIndexOf.keys.toList(),
                    onLetter: (l) {
                      final i = firstIndexOf[l];
                      if (i != null && _scroll.hasClients) {
                        _scroll.jumpTo((i * rowExtent).clamp(0, _scroll.position.maxScrollExtent));
                      }
                    },
                  ),
                ),
            ]),
          ),
        ]);
      },
    );
  }

  List<Song> _chosen(List<Song> all) => [for (final s in all) if (_selected.contains(s.id)) s];
}

class _SelectionBar extends StatelessWidget {
  const _SelectionBar({
    required this.count,
    required this.onClose,
    required this.onAll,
    required this.onRange,
    required this.onPlayNext,
    required this.onQueue,
    required this.onGroup,
  });
  final int count;
  final VoidCallback onClose, onAll, onRange, onPlayNext, onQueue, onGroup;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(children: [
          IconButton(icon: const Icon(Icons.close), onPressed: onClose),
          Text('$count selected'),
          const Spacer(),
          IconButton(icon: const Icon(Icons.select_all), tooltip: 'Select all', onPressed: onAll),
          IconButton(icon: const Icon(Icons.unfold_more), tooltip: 'Select range', onPressed: onRange),
          IconButton(icon: const Icon(Icons.skip_next), tooltip: 'Play next', onPressed: onPlayNext),
          IconButton(icon: const Icon(Icons.queue_music), tooltip: 'Add to queue', onPressed: onQueue),
          IconButton(icon: const Icon(Icons.playlist_add), tooltip: 'Add to group', onPressed: onGroup),
        ]),
      ),
    );
  }
}

class _IndexRail extends StatelessWidget {
  const _IndexRail({required this.letters, required this.onLetter});
  final List<String> letters;
  final ValueChanged<String> onLetter;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return LayoutBuilder(builder: (context, box) {
      void pick(double dy) {
        final i = (dy / box.maxHeight * letters.length).floor().clamp(0, letters.length - 1);
        onLetter(letters[i]);
      }

      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onVerticalDragStart: (d) => pick(d.localPosition.dy),
        onVerticalDragUpdate: (d) => pick(d.localPosition.dy),
        onTapDown: (d) => pick(d.localPosition.dy),
        child: SizedBox(
          width: 20,
          child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            for (final l in letters) Text(l, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
          ]),
        ),
      );
    });
  }
}
