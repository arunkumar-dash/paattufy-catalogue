import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/entities/entities.dart';
import '../../../core/utils/formatters.dart';
import '../../groups/data/group_providers.dart';
import '../../playback/data/playback_controller.dart';
import '../data/library_providers.dart';

void _toast(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message), duration: const Duration(seconds: 2)));
}

/// Row menu (AP §5.2): Play, Play next, Add to queue, Add to group, Go to
/// artist, Go to album, Lyrics, Details, Share. There is deliberately no
/// delete-file action — the library is read-only (AP §11.8).
Future<void> showSongMenu(
  BuildContext context,
  WidgetRef ref,
  Song song, {
  int? groupId,
  bool groupIsStatic = false,
}) {
  final controller = ref.read(playbackControllerProvider.notifier);
  final nowPlaying = ref.read(playbackControllerProvider).current != null;
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheet) {
      Widget item(IconData icon, String label, Future<void> Function() onTap, {bool pop = true}) => ListTile(
            leading: Icon(icon),
            title: Text(label),
            onTap: () async {
              if (pop) Navigator.of(sheet).pop();
              await onTap();
            },
          );
      return SafeArea(
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            ListTile(
              title: Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text('${song.artist} · ${song.album}', maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            const Divider(height: 1),
            item(Icons.play_arrow, 'Play', () => controller.playSong(song)),
            if (nowPlaying) item(Icons.playlist_play, 'Play now (keep queue)', () => controller.playNow(song)),
            item(Icons.skip_next, 'Play next', () async {
              await controller.playNext([song]);
              if (context.mounted) _toast(context, 'Playing next');
            }),
            item(Icons.queue_music, 'Add to queue', () async {
              await controller.addToQueue([song]);
              if (context.mounted) _toast(context, 'Added to queue');
            }),
            item(Icons.playlist_add, 'Add to group', () async {
              if (context.mounted) await showAddToGroupSheet(context, ref, [song]);
            }),
            if (groupId != null)
              item(Icons.remove_circle_outline, groupIsStatic ? 'Remove from group' : 'Exclude from this group', () async {
                final repo = ref.read(groupRepositoryProvider);
                groupIsStatic ? await repo.removeSong(groupId, song.id) : await repo.excludeSong(groupId, song.id);
              }),
            item(Icons.person_outline, 'Go to artist', () async => context.push(Routes.artist(song.artist))),
            item(Icons.album_outlined, 'Go to album', () async => context.push(Routes.album(song.album, song.albumArtist ?? song.artist))),
            item(Icons.lyrics_outlined, 'Lyrics', () async => context.push(Routes.lyricsPicker(song.id))),
            item(Icons.info_outline, 'Details', () async {
              if (context.mounted) await showSongDetails(context, ref, song);
            }),
            item(Icons.edit_outlined, 'Edit tags', () async => context.push(Routes.tagEditor(song.id))),
            item(Icons.share_outlined, 'Share', () async {
              await const MethodChannel('paattufy/system')
                  .invokeMethod<bool>('shareAudio', {'contentUri': song.contentUri, 'title': song.title});
            }),
          ]),
        ),
      );
    },
  );
}

/// Details (AP §5.2): full metadata plus the file path with tap-to-copy
/// (AP §11.7).
Future<void> showSongDetails(BuildContext context, WidgetRef ref, Song song) async {
  // Bitrate / sample rate are read lazily from the file the first time.
  final scanner = ref.read(mediaStoreScannerProvider);
  Map<String, Object?> probe = const {};
  try {
    probe = await scanner.probe(song.contentUri);
  } catch (_) {}
  final bitrate = (probe['bitrate'] as int?) ?? song.bitrate;
  final sampleRate = (probe['sampleRate'] as int?) ?? song.sampleRate;
  if (!context.mounted) return;

  final rows = <(String, String)>[
    ('Title', song.title),
    ('Artist', song.artist),
    ('Album', song.album),
    if (song.albumArtist != null) ('Album artist', song.albumArtist!),
    if (song.genre != null) ('Genre', song.genre!),
    if (song.year != null) ('Year', '${song.year}'),
    if (song.trackNumber != null) ('Track', '${song.trackNumber}'),
    ('Duration', formatMs(song.durationMs)),
    ('Format', song.format.isEmpty ? '—' : song.format.toUpperCase()),
    if (bitrate != null) ('Bitrate', '${(bitrate / 1000).round()} kbps'),
    if (sampleRate != null) ('Sample rate', '$sampleRate Hz'),
    ('Size', formatBytes(song.sizeBytes)),
    ('Added', DateTime.fromMillisecondsSinceEpoch(song.dateAdded * 1000).toString().split('.').first),
  ];

  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheet) => SafeArea(
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        builder: (context, scroll) => ListView(
          controller: scroll,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          children: [
            Text('Details', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            for (final (k, v) in rows)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  SizedBox(width: 110, child: Text(k, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant))),
                  Expanded(child: Text(v)),
                ]),
              ),
            const SizedBox(height: 12),
            Text('File path', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: 4),
            Card(
              child: ListTile(
                title: SelectableText(song.filePath, style: const TextStyle(fontSize: 13)),
                trailing: const Icon(Icons.copy),
                onTap: () async {
                  await Clipboard.setData(ClipboardData(text: song.filePath));
                  if (context.mounted) _toast(context, 'File path copied');
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// "Add to group": static groups append, smart groups pin (AP §3.3).
Future<void> showAddToGroupSheet(BuildContext context, WidgetRef ref, List<Song> songs) async {
  final repo = ref.read(groupRepositoryProvider);
  final groups = (await repo.watchGroupRows().first).where((g) => !g.isBuiltin).toList();
  if (!context.mounted) return;
  final ids = songs.map((s) => s.id).toList();
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheet) => SafeArea(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        ListTile(
          leading: const Icon(Icons.add),
          title: const Text('New group…'),
          onTap: () async {
            Navigator.of(sheet).pop();
            final name = await _askName(context);
            if (name == null || name.trim().isEmpty) return;
            await repo.createStatic(name.trim(), songIds: ids);
            if (context.mounted) _toast(context, 'Added to "${name.trim()}"');
          },
        ),
        const Divider(height: 1),
        Flexible(
          child: ListView(
            shrinkWrap: true,
            children: [
              for (final g in groups)
                ListTile(
                  leading: Icon(g.type == 'smart' ? Icons.auto_awesome : Icons.queue_music),
                  title: Text(g.name),
                  subtitle: Text(g.type == 'smart' ? 'Smart group — will be pinned in' : 'Static group'),
                  onTap: () async {
                    Navigator.of(sheet).pop();
                    await repo.addToGroup(g.id, ids);
                    if (context.mounted) _toast(context, 'Added to "${g.name}"');
                  },
                ),
              if (groups.isEmpty)
                const Padding(padding: EdgeInsets.all(24), child: Text('No groups yet — create one above.')),
            ],
          ),
        ),
      ]),
    ),
  );
}

Future<String?> _askName(BuildContext context) {
  final c = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (d) => AlertDialog(
      title: const Text('New group'),
      content: TextField(controller: c, autofocus: true, decoration: const InputDecoration(labelText: 'Name'), textCapitalization: TextCapitalization.sentences),
      actions: [
        TextButton(onPressed: () => Navigator.pop(d), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.pop(d, c.text), child: const Text('Create')),
      ],
    ),
  );
}
