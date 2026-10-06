import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

import '../../../app/routes.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/settings/app_settings.dart';
import '../../../core/theming/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../download_hub/data/download_providers.dart';
import '../../library/data/library_providers.dart';
import '../../lyrics/data/lyrics_providers.dart';
import '../../playback/data/playback_controller.dart';
import '../../playback/data/playback_extras.dart';
import '../../playback/presentation/now_playing_sheets.dart';
import '../../suggestions/data/suggestion_providers.dart';
import '../../theme_icon/data/icon_switcher.dart';
import '../data/backup_service.dart';
import '../data/reset_service.dart';

/// Settings (AP §5.9): Library · Playback · Suggestions · Audio · Lyrics ·
/// Download hub · Appearance · Data · About.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final controller = ref.read(playbackControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(children: [
        const _Section('Library'),
        ListTile(
          leading: const Icon(Icons.folder_open),
          title: const Text('Download folder'),
          subtitle: Text(s.downloadFolderPath),
          onTap: () => _editDownloadFolder(context, ref),
        ),
        ListTile(
          leading: const Icon(Icons.folder_off_outlined),
          title: const Text('Excluded folders'),
          subtitle: const Text('Skipped on every scan until re-included'),
          onTap: () => _showExcluded(context, ref),
        ),
        ListTile(
          leading: const Icon(Icons.timer_outlined),
          title: Text('Ignore clips shorter than ${s.ignoreShortClipsSec} s'),
          subtitle: Slider(
            value: s.ignoreShortClipsSec.toDouble(),
            max: 60,
            divisions: 12,
            label: '${s.ignoreShortClipsSec} s',
            onChanged: (v) => notifier.update((x) => x.copyWith(ignoreShortClipsSec: v.round())),
            onChangeEnd: (_) => ref.read(scanControllerProvider.notifier).run(full: true),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.refresh),
          title: const Text('Rescan now'),
          subtitle: Consumer(builder: (context, ref, _) {
            final p = ref.watch(scanControllerProvider);
            return Text(p.running ? '${p.found} songs found…' : (p.last == null ? 'Full scan of the whole device' : 'Last scan: ${p.last!.total} songs'));
          }),
          onTap: () => ref.read(scanControllerProvider.notifier).run(full: true),
        ),
        ListTile(
          leading: const Icon(Icons.content_copy_outlined),
          title: const Text('Duplicates & broken files'),
          onTap: () => context.push(Routes.libraryHealth),
        ),
        const _Hint('The library is read-only — Paattufy never deletes or modifies your audio files (tag edits change only metadata).'),

        const _Section('Playback'),
        ListTile(
          leading: const Icon(Icons.speed),
          title: const Text('Default speed'),
          subtitle: Wrap(spacing: 6, children: [
            for (final step in const [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0])
              ChoiceChip(label: Text(speedLabel(step)), selected: s.defaultSpeed == step, onSelected: (_) async {
                await notifier.update((x) => x.copyWith(defaultSpeed: step));
                await controller.setSpeed(step);
              }),
          ]),
        ),
        SwitchListTile(
          secondary: const Icon(Icons.tune),
          title: const Text('Preserve pitch on speed change'),
          subtitle: const Text('Off by default: pitch follows speed'),
          value: s.preservePitch,
          onChanged: (v) async {
            await notifier.update((x) => x.copyWith(preservePitch: v));
            await controller.setPreservePitch(v);
          },
        ),
        SwitchListTile(
          secondary: const Icon(Icons.swap_horiz),
          title: const Text('Soft fade between songs'),
          subtitle: const Text('Fades out the end and fades in the start (true overlap crossfade isn\'t supported by the player)'),
          value: s.crossfade,
          onChanged: (v) => notifier.update((x) => x.copyWith(crossfade: v)),
        ),
        SwitchListTile(
          secondary: const Icon(Icons.restore),
          title: const Text('Resume on launch'),
          subtitle: const Text('Restore the song, queue and position'),
          value: s.resumeOnLaunch,
          onChanged: (v) => notifier.update((x) => x.copyWith(resumeOnLaunch: v)),
        ),
        ListTile(
          leading: const Icon(Icons.skip_previous),
          title: Text('Skip-back window: ${(s.skipBackWindowMs / 1000).toStringAsFixed(0)} s'),
          subtitle: const Text('Past this point "previous" restarts the song; before it goes back one song'),
          trailing: DropdownButton<int>(
            value: [1000, 2000, 3000, 4000, 5000].contains(s.skipBackWindowMs) ? s.skipBackWindowMs : 3000,
            items: [for (final ms in [1000, 2000, 3000, 4000, 5000]) DropdownMenuItem(value: ms, child: Text('${ms ~/ 1000} s'))],
            onChanged: (v) => notifier.update((x) => x.copyWith(skipBackWindowMs: v)),
          ),
        ),
        const ListTile(
          leading: Icon(Icons.bluetooth_audio),
          title: Text('Stop on output change'),
          subtitle: Text('Always on — any change of output device stops playback; tap play to resume where you were'),
          enabled: false,
        ),
        const ListTile(leading: Icon(Icons.all_inclusive), title: Text('Gapless playback'), subtitle: Text('Always on'), enabled: false),

        const _Section('Suggestions'),
        RadioGroup<SuggestionMode>(
          groupValue: s.suggestionMode,
          onChanged: (v) => notifier.update((x) => x.copyWith(suggestionMode: v)),
          child: const Column(children: [
            RadioListTile<SuggestionMode>(
              value: SuggestionMode.mood,
              title: Text('Mood (ML)'),
              subtitle: Text('What comes next should feel like what is playing — learned from the audio itself'),
            ),
            RadioListTile<SuggestionMode>(
              value: SuggestionMode.metadata,
              title: Text('Metadata (rule-based)'),
              subtitle: Text('Same artist → album → album artist → year → genre → folder → most played'),
            ),
          ]),
        ),
        const _AnalysisTile(),

        const _Section('Audio'),
        ListTile(
          leading: const Icon(Icons.equalizer),
          title: const Text('System equalizer'),
          subtitle: const Text('Opens the platform equalizer bound to Paattufy — no in-app DSP'),
          onTap: () async {
            final ok = await ref.read(outputPlatformProvider).openEqualizer(ref.read(audioEngineProvider).audioSessionId ?? 0);
            if (!ok && context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No system equalizer available')));
          },
        ),
        ListTile(leading: const Icon(Icons.speaker_group_outlined), title: const Text('Output device'), onTap: () => showOutputSheet(context)),
        SwitchListTile(
          secondary: const Icon(Icons.volume_up_outlined),
          title: const Text('Volume normalisation'),
          subtitle: const Text('Opt-in, off by default to keep playback untouched'),
          value: s.volumeNormalisation,
          onChanged: (v) async {
            await notifier.update((x) => x.copyWith(volumeNormalisation: v));
            await controller.applyAudioSettings();
          },
        ),
        SwitchListTile(
          secondary: const Icon(Icons.fast_forward_outlined),
          title: const Text('Skip silence'),
          value: s.skipSilence,
          onChanged: (v) async {
            await notifier.update((x) => x.copyWith(skipSilence: v));
            await controller.applyAudioSettings();
          },
        ),

        const _Section('Lyrics'),
        _LyricsProviders(),
        SwitchListTile(
          secondary: const Icon(Icons.skip_next_outlined),
          title: const Text('Try next provider on no result'),
          value: s.tryNextLyricsProvider,
          onChanged: (v) => notifier.update((x) => x.copyWith(tryNextLyricsProvider: v)),
        ),
        SwitchListTile(
          secondary: const Icon(Icons.cloud_download_outlined),
          title: const Text('Auto-fetch lyrics on play'),
          value: s.autoFetchLyrics,
          onChanged: (v) => notifier.update((x) => x.copyWith(autoFetchLyrics: v)),
        ),
        ListTile(
          leading: const Icon(Icons.link),
          title: const Text('Provider catalogue URL'),
          subtitle: Text(s.lyricsCatalogueUrl, maxLines: 2, overflow: TextOverflow.ellipsis),
          onTap: () async {
            final v = await _editText(context, 'Provider catalogue URL', s.lyricsCatalogueUrl, keyboard: TextInputType.url);
            if (v != null) {
              await notifier.update((x) => x.copyWith(lyricsCatalogueUrl: v));
              ref.invalidate(lyricsProviderSpecsProvider);
            }
          },
          trailing: IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh now',
            onPressed: () async {
              await ref.read(lyricsCatalogueProvider).providers(s.lyricsCatalogueUrl, force: true);
              ref.invalidate(lyricsProviderSpecsProvider);
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Provider catalogue refreshed')));
            },
          ),
        ),
        Consumer(builder: (context, ref, _) {
          return FutureBuilder<int>(
            future: ref.read(lyricsRepositoryProvider).cacheSize(),
            builder: (context, snap) => ListTile(
              leading: const Icon(Icons.delete_sweep_outlined),
              title: const Text('Clear lyrics cache'),
              subtitle: Text('${snap.data ?? 0} songs cached (per-song sync offsets are kept)'),
              onTap: () async {
                await ref.read(lyricsRepositoryProvider).clearCache();
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lyrics cache cleared')));
              },
            ),
          );
        }),

        const _Section('Download hub'),
        ListTile(
          leading: const Icon(Icons.link),
          title: const Text('GitHub JSON URL'),
          subtitle: Text(s.downloadCatalogueUrl, maxLines: 2, overflow: TextOverflow.ellipsis),
          onTap: () async {
            final v = await _editText(context, 'GitHub JSON URL', s.downloadCatalogueUrl, keyboard: TextInputType.url);
            if (v != null) {
              await notifier.update((x) => x.copyWith(downloadCatalogueUrl: v));
              await ref.read(catalogueControllerProvider.notifier).refresh();
            }
          },
        ),
        ListTile(
          leading: const Icon(Icons.update),
          title: const Text('Refresh interval'),
          trailing: DropdownButton<int>(
            value: [1, 6, 24, 72, 168].contains(s.catalogueRefreshHours) ? s.catalogueRefreshHours : 24,
            items: const [
              DropdownMenuItem(value: 1, child: Text('1 hour')),
              DropdownMenuItem(value: 6, child: Text('6 hours')),
              DropdownMenuItem(value: 24, child: Text('Daily')),
              DropdownMenuItem(value: 72, child: Text('3 days')),
              DropdownMenuItem(value: 168, child: Text('Weekly')),
            ],
            onChanged: (v) => notifier.update((x) => x.copyWith(catalogueRefreshHours: v)),
          ),
        ),
        SwitchListTile(
          secondary: const Icon(Icons.wifi),
          title: const Text('Wi-Fi only'),
          value: s.downloadWifiOnly,
          onChanged: (v) => notifier.update((x) => x.copyWith(downloadWifiOnly: v)),
        ),

        const _Section('Appearance'),
        ListTile(
          leading: const Icon(Icons.brightness_6_outlined),
          title: const Text('Theme'),
          subtitle: SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(value: ThemeMode.system, label: Text('System')),
              ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
              ButtonSegment(value: ThemeMode.light, label: Text('Light')),
            ],
            selected: {s.themeMode},
            onSelectionChanged: (m) => notifier.update((x) => x.copyWith(themeMode: m.first)),
          ),
        ),
        const _SeedColorPicker(),
        SwitchListTile(
          secondary: const Icon(Icons.palette_outlined),
          title: const Text('Dynamic colour from artwork'),
          subtitle: const Text('Tints the Now Playing screen from the current album art'),
          value: s.dynamicArtworkColor,
          onChanged: (v) => notifier.update((x) => x.copyWith(dynamicArtworkColor: v)),
        ),
        const _IconPicker(),
        SwitchListTile(
          secondary: const Icon(Icons.graphic_eq),
          title: const Text('Visualizer by default'),
          subtitle: const Text('Replaces the album art on Now Playing; no microphone permission needed'),
          value: s.visualizerEnabled,
          onChanged: (v) => notifier.update((x) => x.copyWith(visualizerEnabled: v)),
        ),
        ListTile(
          leading: const Icon(Icons.widgets_outlined),
          title: const Text('Widget style'),
          subtitle: const Text('Spotify-style (default)'),
        ),

        const _Section('Data'),
        ListTile(
          leading: const Icon(Icons.upload_file),
          title: const Text('Back up app data'),
          subtitle: const Text('Groups, queue, play counts and lyric picks → JSON file'),
          onTap: () => _backup(context, ref),
        ),
        ListTile(
          leading: const Icon(Icons.download_for_offline_outlined),
          title: const Text('Restore from backup'),
          onTap: () => _restore(context, ref),
        ),

        const _Section('About'),
        const _AboutTiles(),
        const SizedBox(height: 24),
      ]),
    );
  }

  // --- actions ---------------------------------------------------------------------------

  Future<String?> _editText(BuildContext context, String title, String initial, {TextInputType? keyboard, String? helper}) {
    final c = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder: (d) => AlertDialog(
        title: Text(title),
        content: TextField(controller: c, keyboardType: keyboard, autofocus: true, decoration: InputDecoration(helperText: helper, helperMaxLines: 3)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(d), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(d, c.text.trim()), child: const Text('Save')),
        ],
      ),
    );
  }

  /// Editable absolute path with inline guidance and a validation check before
  /// saving (AP §5.9): must be absolute, free of `..`, and writable.
  Future<void> _editDownloadFolder(BuildContext context, WidgetRef ref) async {
    final s = ref.read(settingsProvider);
    final c = TextEditingController(text: s.downloadFolderPath);
    String? error;
    await showDialog<void>(
      context: context,
      builder: (d) => StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          title: const Text('Download folder'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(
              controller: c,
              decoration: InputDecoration(
                helperText: 'An absolute path, e.g. /storage/emulated/0/Music/Paattufy',
                helperMaxLines: 3,
                errorText: error,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.folder_open),
                  tooltip: 'Pick a folder',
                  onPressed: () async {
                    final picked = await FilePicker.getDirectoryPath();
                    if (picked != null) setState(() => c.text = picked);
                  },
                ),
              ),
            ),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(d), child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                final err = await validateDownloadFolder(c.text.trim());
                if (err != null) {
                  setState(() => error = err);
                  return;
                }
                await ref.read(settingsProvider.notifier).update((x) => x.copyWith(downloadFolderPath: c.text.trim().replaceAll(RegExp(r'/+$'), '')));
                if (d.mounted) Navigator.pop(d);
              },
              child: const Text('Save'),
            ),
          ],
        );
      }),
    );
  }

  Future<void> _showExcluded(BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => Consumer(builder: (context, ref, _) {
        final excluded = ref.watch(excludedFoldersProvider).value ?? const [];
        final repo = ref.read(libraryRepositoryProvider);
        return SafeArea(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            ListTile(
              title: const Text('Excluded folders'),
              trailing: FilledButton.tonalIcon(
                icon: const Icon(Icons.add),
                label: const Text('Add'),
                onPressed: () async {
                  final p = await FilePicker.getDirectoryPath();
                  if (p != null) await repo.excludeFolder(p);
                },
              ),
            ),
            if (excluded.isEmpty) const Padding(padding: EdgeInsets.all(24), child: Text('Nothing excluded. Hide WhatsApp audio, recordings or notification tones here.')),
            Flexible(
              child: ListView(shrinkWrap: true, children: [
                for (final f in excluded)
                  ListTile(
                    leading: const Icon(Icons.folder_off_outlined),
                    title: Text(f, maxLines: 2, overflow: TextOverflow.ellipsis),
                    trailing: IconButton(icon: const Icon(Icons.close), tooltip: 'Include again', onPressed: () async {
                      await repo.includeFolder(f);
                      await ref.read(scanControllerProvider.notifier).run(full: true);
                    }),
                  ),
              ]),
            ),
          ]),
        );
      }),
    );
  }

  Future<void> _backup(BuildContext context, WidgetRef ref) async {
    final json = await BackupService(ref.read(databaseProvider)).exportJson(ref.read(settingsProvider));
    final stamp = DateTime.now().toIso8601String().split('T').first;
    final uri = await FilePicker.saveFile(fileName: 'paattufy-backup-$stamp.json', bytes: Uint8List.fromList(utf8.encode(json)), mimeType: 'application/json');
    if (context.mounted && uri != null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Backup saved')));
    }
  }

  Future<void> _restore(BuildContext context, WidgetRef ref) async {
    final picked = await FilePicker.pickFile();
    final path = picked?.path;
    if (path == null) return;
    try {
      final text = await File(path).readAsString();
      final (report, merged) = await BackupService(ref.read(databaseProvider)).restore(text, ref.read(settingsProvider));
      if (merged != null) await ref.read(settingsProvider.notifier).update((_) => merged);
      await ref.read(playbackControllerProvider.notifier).reloadFromDatabase();
      if (!context.mounted) return;
      await showDialog<void>(
        context: context,
        builder: (d) => AlertDialog(
          title: const Text('Restore complete'),
          content: Text('${report.groups} groups · ${report.statsRestored} play histories · ${report.lyricsRestored} lyric picks'
              '${report.queueRestored ? ' · queue' : ''}\n'
              '${report.songsUnmatched == 0 ? 'Every song was matched.' : '${report.songsUnmatched} songs from the backup weren\'t found on this device.'}'),
          actions: [TextButton(onPressed: () => Navigator.pop(d), child: const Text('OK'))],
        ),
      );
    } on BackupFormatException catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }
}

/// Validation used by the editable download-folder field.
Future<String?> validateDownloadFolder(String path) async {
  if (path.isEmpty) return 'Enter a folder path';
  if (!path.startsWith('/')) return 'Must be an absolute path starting with /';
  if (path.split('/').contains('..')) return 'Path may not contain ".."';
  try {
    final dir = Directory(path);
    await dir.create(recursive: true);
    final probe = File('$path/.paattufy_write_test');
    await probe.writeAsString('ok');
    await probe.delete(); // our own probe file, never library media
  } catch (_) {
    return 'Paattufy can\'t write to this folder — check the path and All-files access';
  }
  return null;
}

class _Section extends StatelessWidget {
  const _Section(this.title);
  final String title;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 4),
        child: Text(title.toUpperCase(), style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Theme.of(context).colorScheme.primary, letterSpacing: 1.1, fontWeight: FontWeight.w800)),
      );
}

class _Hint extends StatelessWidget {
  const _Hint(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
        child: Text(text, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
      );
}

class _AnalysisTile extends ConsumerWidget {
  const _AnalysisTile();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(analysisControllerProvider);
    final c = ref.read(analysisControllerProvider.notifier);
    if (p.total == 0 && !p.running) WidgetsBinding.instance.addPostFrameCallback((_) => c.refresh());
    return ListTile(
      leading: const Icon(Icons.auto_graph),
      title: Text('Analysed ${p.analysed} of ${p.total} songs'),
      subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Runs in small batches while charging, never during playback on battery'),
        if (p.total > 0) Padding(padding: const EdgeInsets.only(top: 6), child: LinearProgressIndicator(value: p.analysed / p.total)),
      ]),
      trailing: p.running
          ? TextButton(onPressed: c.cancel, child: const Text('Stop'))
          : TextButton(onPressed: c.runNow, child: const Text('Analyse now')),
    );
  }
}

class _LyricsProviders extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final specs = ref.watch(lyricsProviderSpecsProvider).value ?? const [];
    final s = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final ids = [for (final p in specs) p.id];
    final ordered = [...s.lyricsProviderOrder.where(ids.contains), ...ids.where((i) => !s.lyricsProviderOrder.contains(i))];
    return ExpansionTile(
      leading: const Icon(Icons.lyrics_outlined),
      title: const Text('Providers'),
      subtitle: Text('${ordered.length} available · drag to set the order'),
      children: [
        ReorderableListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          onReorderItem: (from, to) {
            final next = [...ordered];
            next.insert(to, next.removeAt(from));
            notifier.update((x) => x.copyWith(lyricsProviderOrder: next));
          },
          children: [
            for (var i = 0; i < ordered.length; i++)
              SwitchListTile(
                key: ValueKey(ordered[i]),
                secondary: ReorderableDragStartListener(index: i, child: const Icon(Icons.drag_handle)),
                title: Text(specs.firstWhere((p) => p.id == ordered[i]).displayName),
                subtitle: Text(ordered[i] == 'lrclib' ? 'Built-in default' : 'From the GitHub catalogue'),
                value: !s.disabledLyricsProviders.contains(ordered[i]),
                onChanged: (on) => notifier.update((x) => x.copyWith(
                      disabledLyricsProviders: on ? (x.disabledLyricsProviders.where((d) => d != ordered[i]).toList()) : [...x.disabledLyricsProviders, ordered[i]],
                    )),
              ),
          ],
        ),
      ],
    );
  }
}

class _SeedColorPicker extends ConsumerWidget {
  const _SeedColorPicker();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final isPreset = seedPresets.any((p) => p.color.toARGB32() == s.themeSeedColor);
    return ListTile(
      leading: const Icon(Icons.color_lens_outlined),
      title: const Text('Accent colour'),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Wrap(spacing: 10, runSpacing: 10, children: [
          for (final p in seedPresets)
            Tooltip(
              message: p.name,
              child: GestureDetector(
                onTap: () => notifier.update((x) => x.copyWith(themeSeedColor: p.color.toARGB32())),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: p.color,
                  child: p.color.toARGB32() == s.themeSeedColor ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
                ),
              ),
            ),
          GestureDetector(
            onTap: () async {
              final c = await _customColor(context, Color(s.themeSeedColor));
              if (c != null) await notifier.update((x) => x.copyWith(themeSeedColor: c.toARGB32()));
            },
            child: CircleAvatar(
              radius: 18,
              backgroundColor: isPreset ? Theme.of(context).colorScheme.surfaceContainerHighest : Color(s.themeSeedColor),
              child: Icon(isPreset ? Icons.colorize : Icons.check, size: 18, color: Colors.white),
            ),
          ),
        ]),
      ),
    );
  }

  Future<Color?> _customColor(BuildContext context, Color initial) {
    var hsv = HSVColor.fromColor(initial);
    return showDialog<Color>(
      context: context,
      builder: (d) => StatefulBuilder(builder: (context, setState) {
        Widget slider(String label, double v, double max, Color Function(double) track, ValueChanged<double> on) => Row(children: [
              SizedBox(width: 28, child: Text(label)),
              Expanded(child: Slider(value: v, max: max, onChanged: (x) => setState(() => on(x)))),
            ]);
        return AlertDialog(
          title: const Text('Custom accent colour'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(height: 48, decoration: BoxDecoration(color: hsv.toColor(), borderRadius: BorderRadius.circular(12))),
            slider('H', hsv.hue, 360, (x) => HSVColor.fromAHSV(1, x, 1, 1).toColor(), (x) => hsv = hsv.withHue(x)),
            slider('S', hsv.saturation, 1, (x) => hsv.withSaturation(x).toColor(), (x) => hsv = hsv.withSaturation(x)),
            slider('V', hsv.value, 1, (x) => hsv.withValue(x).toColor(), (x) => hsv = hsv.withValue(x)),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(d), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(d, hsv.toColor()), child: const Text('Use')),
          ],
        );
      }),
    );
  }
}

class _IconPicker extends ConsumerWidget {
  const _IconPicker();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    return ListTile(
      leading: const Icon(Icons.apps),
      title: const Text('Launcher icon colourway'),
      subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 8),
        Wrap(spacing: 10, runSpacing: 10, children: [
          for (var i = 0; i < seedPresets.length; i++)
            GestureDetector(
              onTap: () async {
                final ok = await IconSwitcher().set(i);
                if (ok) await ref.read(settingsProvider.notifier).update((x) => x.copyWith(launcherIconVariant: i));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? 'Icon changed — your launcher may take a moment to refresh it' : 'Could not change the icon')));
                }
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: seedPresets[i].color,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: s.launcherIconVariant == i ? Theme.of(context).colorScheme.onSurface : Colors.transparent, width: 2),
                ),
                child: Image.asset('assets/icon/icon_foreground.png', color: Colors.white),
              ),
            ),
        ]),
        const SizedBox(height: 6),
        Text('Android can\'t change an icon in place, so Paattufy swaps launcher entries. The launcher (and sometimes the device) may take a moment to show the new icon — that\'s an OS quirk, not a bug.',
            style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ]),
    );
  }
}

class _AboutTiles extends ConsumerWidget {
  const _AboutTiles();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(children: [
      FutureBuilder<PackageInfo>(
        future: PackageInfo.fromPlatform(),
        builder: (context, snap) => ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text('Paattufy'),
          subtitle: Text(snap.hasData ? 'Version ${snap.data!.version} (${snap.data!.buildNumber})' : '…'),
          onTap: () => showLicensePage(context: context, applicationName: 'Paattufy', applicationVersion: snap.data?.version),
          trailing: const Text('Licenses'),
        ),
      ),
      FutureBuilder<int>(
        future: _storageUsed(),
        builder: (context, snap) => ListTile(
          leading: const Icon(Icons.sd_storage_outlined),
          title: const Text('Storage used by the app'),
          subtitle: Text(snap.hasData ? formatBytes(snap.data!) : 'Calculating…'),
        ),
      ),
      ListTile(
        leading: Icon(Icons.restart_alt, color: Theme.of(context).colorScheme.error),
        title: const Text('Reset app data'),
        subtitle: const Text('Clears groups, play counts, lyric picks, queue and settings. Your music is untouched.'),
        onTap: () async {
          final ok = await showDialog<bool>(
            context: context,
            builder: (d) => AlertDialog(
              title: const Text('Reset app data?'),
              content: const Text('This removes your groups, play counts, lyric picks, queue and settings. Songs on your device are not affected.'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(d, false), child: const Text('Cancel')),
                FilledButton(onPressed: () => Navigator.pop(d, true), child: const Text('Reset')),
              ],
            ),
          );
          if (ok != true) return;
          await ref.read(playbackControllerProvider.notifier).clearQueue();
          await ResetService(ref.read(databaseProvider)).resetAppData();
          await ref.read(settingsProvider.notifier).update((_) => const AppSettings(onboardingComplete: true));
          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('App data reset')));
        },
      ),
    ]);
  }

  Future<int> _storageUsed() async {
    var total = 0;
    final docs = await getApplicationDocumentsDirectory();
    final cache = await getApplicationCacheDirectory();
    for (final dir in [docs, cache]) {
      if (!dir.existsSync()) continue;
      await for (final e in dir.list(recursive: true, followLinks: false)) {
        if (e is File) total += await e.length();
      }
    }
    return total;
  }
}
