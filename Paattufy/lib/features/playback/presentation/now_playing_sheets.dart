import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants.dart';
import '../../groups/data/group_providers.dart';
import '../data/output_service.dart';
import '../data/playback_controller.dart';
import '../data/playback_extras.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/song_artwork.dart';

String speedLabel(double s) => s == s.roundToDouble() ? '${s.toStringAsFixed(1)}×' : '$s×';

/// Stepped speed picker with the preserve-pitch toggle (AP §3.5).
Future<void> showSpeedSheet(BuildContext context) => showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => Consumer(builder: (context, ref, _) {
        final s = ref.watch(playbackControllerProvider);
        final c = ref.read(playbackControllerProvider.notifier);
        return SafeArea(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const ListTile(title: Text('Playback speed')),
            Wrap(spacing: 8, children: [
              for (final step in speedSteps)
                ChoiceChip(label: Text(speedLabel(step)), selected: s.speed == step, onSelected: (_) => c.setSpeed(step)),
            ]),
            SwitchListTile(
              title: const Text('Preserve pitch'),
              subtitle: const Text('Off: pitch rises and falls with speed (cheapest). On: pitch stays constant.'),
              value: s.preservePitch,
              onChanged: c.setPreservePitch,
            ),
          ]),
        );
      }),
    );

/// Output picker (AP §3.6): shows the active route and opens the system
/// switcher to move between the phone speaker and Bluetooth.
Future<void> showOutputSheet(BuildContext context) => showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => Consumer(builder: (context, ref, _) {
        final devices = ref.watch(outputDevicesProvider);
        final platform = ref.read(outputPlatformProvider);
        final engineSession = ref.read(audioEngineProvider).audioSessionId ?? 0;
        return SafeArea(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const ListTile(title: Text('Output device'), subtitle: Text('Any output change stops playback; tap play to resume where you were.')),
            devices.when(
              loading: () => const Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()),
              error: (e, _) => Padding(padding: const EdgeInsets.all(16), child: Text('$e')),
              data: (list) => Column(children: [
                for (final d in list)
                  ListTile(
                    leading: Icon(switch (d.kind) { 'bluetooth' => Icons.bluetooth_audio, 'wired' => Icons.headphones, _ => Icons.speaker_phone }),
                    title: Text(d.name),
                    trailing: d.active ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary) : null,
                    onTap: () async {
                      Navigator.of(context).pop();
                      await platform.openSwitcher();
                    },
                  ),
              ]),
            ),
            ListTile(leading: const Icon(Icons.swap_horiz), title: const Text('Switch output…'), onTap: () {
              Navigator.of(context).pop();
              platform.openSwitcher();
            }),
            ListTile(
              leading: const Icon(Icons.equalizer),
              title: const Text('System equalizer'),
              onTap: () async {
                Navigator.of(context).pop();
                final ok = await platform.openEqualizer(engineSession);
                if (!ok && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No system equalizer available on this device')));
                }
              },
            ),
          ]),
        );
      }),
    );

Future<void> showSleepTimerSheet(BuildContext context) => showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => Consumer(builder: (context, ref, _) {
        final timer = ref.watch(sleepTimerProvider);
        final st = ref.watch(sleepTimerStateProvider).value ?? timer.state;
        return SafeArea(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            ListTile(
              title: const Text('Sleep timer'),
              subtitle: Text(!st.active ? 'Off' : st.endOfTrack ? 'Stops at the end of this track' : 'Stops in ${formatDuration(st.remaining ?? Duration.zero)}'),
            ),
            Wrap(spacing: 8, runSpacing: 4, children: [
              for (final m in const [5, 10, 15, 30, 45, 60])
                ActionChip(label: Text('$m min'), onPressed: () {
                  timer.startIn(Duration(minutes: m));
                  Navigator.of(context).pop();
                }),
              ActionChip(
                avatar: const Icon(Icons.music_note, size: 16),
                label: const Text('End of track'),
                onPressed: () {
                  timer.startAtEndOfTrack(ref.read(playbackControllerProvider).currentItemId);
                  Navigator.of(context).pop();
                },
              ),
            ]),
            if (st.active) TextButton(onPressed: () { timer.cancel(); Navigator.of(context).pop(); }, child: const Text('Turn off')),
            const SizedBox(height: 8),
          ]),
        );
      }),
    );

/// Queue sheet (AP §5.7): Now playing → Next up (drag-reorder, swipe to remove)
/// → Suggested (spark icon, Not interested / Keep).
class QueueSheet extends ConsumerWidget {
  const QueueSheet({super.key, required this.scrollController});
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapAsync = ref.watch(queueSnapshotProvider);
    final controller = ref.read(playbackControllerProvider.notifier);
    final scheme = Theme.of(context).colorScheme;
    return snapAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (snap) {
        final upcoming = snap.upcoming;
        final firstSuggested = upcoming.indexWhere((e) => e.isSuggested);
        final baseIndex = snap.currentIndex + 1;
        return CustomScrollView(controller: scrollController, slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 8, 8),
              child: Row(children: [
                Expanded(
                  child: Text(snap.sourceDescription.isEmpty ? 'Queue' : 'Playing from ${snap.sourceDescription}',
                      style: Theme.of(context).textTheme.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
                TextButton(
                  onPressed: snap.isEmpty
                      ? null
                      : () async {
                          final name = await _ask(context);
                          if (name == null || name.trim().isEmpty) return;
                          await ref.read(groupRepositoryProvider).createStatic(name.trim(), songIds: [for (final e in snap.entries) e.song.id]);
                          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Saved as "${name.trim()}"')));
                        },
                  child: const Text('Save as group'),
                ),
                TextButton(onPressed: snap.isEmpty ? null : controller.clearQueue, child: const Text('Clear')),
              ]),
            ),
          ),
          if (snap.current != null) ...[
            _label(context, 'Now playing'),
            SliverToBoxAdapter(child: _row(context, ref, snap.current!.song, playing: true)),
          ],
          if (upcoming.isNotEmpty) _label(context, firstSuggested == 0 ? 'Suggested' : 'Next up'),
          SliverReorderableList(
            itemCount: upcoming.length,
            onReorderItem: (from, to) => controller.reorder(upcoming[from].id, baseIndex + to),
            itemBuilder: (context, i) {
              final e = upcoming[i];
              final tile = Dismissible(
                key: ValueKey('dismiss-${e.id}'),
                direction: DismissDirection.endToStart,
                background: Container(color: scheme.errorContainer, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), child: Icon(Icons.delete_outline, color: scheme.onErrorContainer)),
                onDismissed: (_) => controller.removeFromQueue(e.id),
                child: Material(
                  color: scheme.surface,
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    if (i == firstSuggested && firstSuggested > 0)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                        child: Align(alignment: Alignment.centerLeft, child: Text('Suggested', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: scheme.primary))),
                      ),
                    _row(
                      context,
                      ref,
                      e.song,
                      suggested: e.isSuggested,
                      onTap: () => controller.playItem(e.id),
                      onKeep: e.isSuggested ? () => controller.keepSuggested(e.id) : null,
                      onDismiss: e.isSuggested ? () => controller.dismissSuggested(e.id) : null,
                      handle: ReorderableDragStartListener(index: i, child: const Padding(padding: EdgeInsets.all(12), child: Icon(Icons.drag_handle))),
                    ),
                  ]),
                ),
              );
              return KeyedSubtree(key: ValueKey('q-${e.id}'), child: tile);
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ]);
      },
    );
  }

  Widget _label(BuildContext context, String text) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Text(text, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).colorScheme.primary)),
        ),
      );

  Widget _row(BuildContext context, WidgetRef ref, dynamic song,
      {bool playing = false, bool suggested = false, VoidCallback? onTap, VoidCallback? onKeep, VoidCallback? onDismiss, Widget? handle}) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      onTap: onTap,
      leading: SongArtwork(contentUri: song.contentUri, size: 44),
      title: Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: playing ? scheme.primary : null, fontWeight: FontWeight.w600)),
      subtitle: Row(children: [
        if (suggested) Padding(padding: const EdgeInsets.only(right: 4), child: Icon(Icons.auto_awesome, size: 13, color: scheme.primary)),
        Expanded(child: Text(song.artist, maxLines: 1, overflow: TextOverflow.ellipsis)),
      ]),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        if (onDismiss != null) IconButton(tooltip: 'Not interested', icon: const Icon(Icons.thumb_down_outlined, size: 20), onPressed: onDismiss),
        if (onKeep != null) IconButton(tooltip: 'Keep', icon: const Icon(Icons.push_pin_outlined, size: 20), onPressed: onKeep),
        ?handle,
      ]),
    );
  }

  Future<String?> _ask(BuildContext context) {
    final c = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (d) => AlertDialog(
        title: const Text('Save queue as group'),
        content: TextField(controller: c, autofocus: true, decoration: const InputDecoration(labelText: 'Group name')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(d), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(d, c.text), child: const Text('Save')),
        ],
      ),
    );
  }
}

Future<void> showQueueSheet(BuildContext context) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        builder: (context, scroll) => QueueSheet(scrollController: scroll),
      ),
    );

/// Re-export so Now Playing can show the route label.
String routeLabel(String route) => OutputRoute.parse(route).label;
