import 'dart:ui';

import 'package:flutter/material.dart' hide RepeatMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/entities/entities.dart';
import '../../../core/settings/app_settings.dart';
import '../../../core/widgets/marquee_text.dart';
import '../../../core/widgets/song_artwork.dart';
import '../../library/data/artwork_cache.dart';
import '../../library/presentation/song_actions.dart';
import '../../lyrics/presentation/lyrics_widgets.dart';
import '../../visualizer/presentation/visualizer_view.dart';
import '../data/playback_controller.dart';
import '../domain/audio_engine.dart';
import 'now_playing_sheets.dart';
import 'seek_bar.dart';

/// Now Playing (AP §5.5): vertical stack on a blurred artwork background.
class NowPlayingScreen extends ConsumerStatefulWidget {
  const NowPlayingScreen({super.key});

  @override
  ConsumerState<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends ConsumerState<NowPlayingScreen> {
  bool? _showVisualizer; // null → follow the setting
  ColorScheme? _artScheme;
  String? _artSchemeFor;

  Future<void> _updateArtScheme(Song? song, bool enabled) async {
    if (!enabled || song == null) {
      if (_artScheme != null) setState(() => _artScheme = null);
      return;
    }
    if (_artSchemeFor == song.id) return;
    _artSchemeFor = song.id;
    final bytes = await ref.read(artworkCacheProvider).bytes(song.contentUri, size: 128);
    if (bytes == null || !mounted) return;
    final scheme = await ColorScheme.fromImageProvider(provider: MemoryImage(bytes), brightness: Brightness.dark);
    if (mounted && _artSchemeFor == song.id) setState(() => _artScheme = scheme);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(playbackControllerProvider);
    final settings = ref.watch(settingsProvider);
    final song = state.current;
    final controller = ref.read(playbackControllerProvider.notifier);

    WidgetsBinding.instance.addPostFrameCallback((_) => _updateArtScheme(song, settings.dynamicArtworkColor));

    if (song == null) {
      return Scaffold(
        appBar: AppBar(leading: IconButton(icon: const Icon(Icons.keyboard_arrow_down), onPressed: () => context.pop())),
        body: const Center(child: Text('Nothing playing')),
      );
    }

    final baseTheme = Theme.of(context);
    final theme = _artScheme == null ? baseTheme : baseTheme.copyWith(colorScheme: _artScheme);
    final scheme = theme.colorScheme;
    final visualizerOn = _showVisualizer ?? settings.visualizerEnabled;

    return Theme(
      data: theme,
      child: Scaffold(
        backgroundColor: scheme.surface,
        body: GestureDetector(
          onVerticalDragEnd: (d) {
            if ((d.primaryVelocity ?? 0) > 300) context.pop();
          },
          child: Stack(children: [
            // Blurred artwork background
            Positioned.fill(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: SongArtwork(contentUri: song.contentUri, size: 300, radius: 0),
              ),
            ),
            Positioned.fill(child: Container(color: scheme.surface.withValues(alpha: 0.72))),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(children: [
                  // 1. handle · output chip · overflow
                  Row(children: [
                    IconButton(icon: const Icon(Icons.keyboard_arrow_down), tooltip: 'Close', onPressed: () => context.pop()),
                    Expanded(
                      child: Center(
                        child: ActionChip(
                          avatar: Icon(state.route.startsWith('bluetooth') ? Icons.bluetooth_audio : state.route.startsWith('wired') ? Icons.headphones : Icons.speaker_phone, size: 18),
                          label: Text(routeLabel(state.route), maxLines: 1, overflow: TextOverflow.ellipsis),
                          onPressed: () => showOutputSheet(context),
                        ),
                      ),
                    ),
                    _Overflow(song: song, visualizerOn: visualizerOn, onToggleVisualizer: () => setState(() => _showVisualizer = !visualizerOn)),
                  ]),
                  // 2. art area (tap flips art ⇄ visualizer)
                  Expanded(
                    child: Center(
                      child: LayoutBuilder(builder: (context, box) {
                        final side = box.maxWidth.clamp(0.0, box.maxHeight).toDouble();
                        return GestureDetector(
                          onTap: () => setState(() => _showVisualizer = !visualizerOn),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: visualizerOn
                                ? VisualizerView(key: const ValueKey('viz'), size: side, style: VisualizerStyle.values[settings.visualizerStyle.clamp(0, 2)])
                                : Hero(
                                    tag: 'now-playing-art',
                                    child: SongArtwork(key: const ValueKey('art'), contentUri: song.contentUri, size: side, radius: 16, icon: Icons.music_note),
                                  ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // 3. title / artist + favourite
                  Row(children: [
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        SizedBox(height: 30, child: MarqueeText(song.title, style: Theme.of(context).textTheme.titleLarge)),
                        SizedBox(height: 22, child: MarqueeText(song.artist, style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 15))),
                      ]),
                    ),
                    _FavouriteButton(songId: song.id),
                  ]),
                  const SizedBox(height: 8),
                  // 4. seek bar
                  const SeekBar(),
                  // 5. transport row
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    IconButton(
                      icon: Icon(Icons.shuffle, color: state.shuffle ? scheme.primary : scheme.onSurfaceVariant),
                      tooltip: 'Shuffle',
                      onPressed: controller.toggleShuffle,
                    ),
                    IconButton(icon: const Icon(Icons.skip_previous), iconSize: 38, onPressed: controller.skipPrevious),
                    Container(
                      decoration: BoxDecoration(color: scheme.primary, shape: BoxShape.circle),
                      child: IconButton(
                        iconSize: 44,
                        color: scheme.onPrimary,
                        icon: state.loading
                            ? SizedBox(width: 30, height: 30, child: CircularProgressIndicator(strokeWidth: 3, color: scheme.onPrimary))
                            : Icon(state.playing ? Icons.pause : Icons.play_arrow),
                        onPressed: controller.togglePlayPause,
                      ),
                    ),
                    IconButton(icon: const Icon(Icons.skip_next), iconSize: 38, onPressed: controller.skipNext),
                    IconButton(
                      icon: Icon(
                        state.repeat == RepeatMode.one ? Icons.repeat_one : Icons.repeat,
                        color: state.repeat == RepeatMode.off ? scheme.onSurfaceVariant : scheme.primary,
                      ),
                      tooltip: switch (state.repeat) { RepeatMode.off => 'Repeat off', RepeatMode.all => 'Repeat queue', RepeatMode.one => 'Repeat one' },
                      onPressed: controller.cycleRepeat,
                    ),
                  ]),
                  const SizedBox(height: 4),
                  // 6. secondary row
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    ActionChip(label: Text(speedLabel(state.speed)), onPressed: () => showSpeedSheet(context)),
                    const SizedBox(width: 8),
                    ActionChip(avatar: const Icon(Icons.lyrics_outlined, size: 18), label: const Text('Lyrics'), onPressed: () => context.push(Routes.lyrics)),
                    const SizedBox(width: 8),
                    ActionChip(avatar: const Icon(Icons.queue_music, size: 18), label: const Text('Queue'), onPressed: () => showQueueSheet(context)),
                  ]),
                  const SizedBox(height: 10),
                  // 7. lyrics peek strip
                  const LyricsPeek(),
                  const SizedBox(height: 10),
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _FavouriteButton extends ConsumerWidget {
  const _FavouriteButton({required this.songId});
  final String songId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fav = ref.watch(isFavouriteProvider(songId)).value ?? false;
    return IconButton(
      icon: Icon(fav ? Icons.favorite : Icons.favorite_border, color: fav ? Theme.of(context).colorScheme.primary : null),
      tooltip: fav ? 'Remove from Favourites' : 'Add to Favourites',
      onPressed: () => ref.read(playStatsRepositoryProvider).toggleFavourite(songId),
    );
  }
}

class _Overflow extends ConsumerWidget {
  const _Overflow({required this.song, required this.visualizerOn, required this.onToggleVisualizer});
  final Song song;
  final bool visualizerOn;
  final VoidCallback onToggleVisualizer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      onSelected: (v) async {
        switch (v) {
          case 'viz':
            onToggleVisualizer();
          case 'vizstyle':
            final s = ref.read(settingsProvider);
            await ref.read(settingsProvider.notifier).update((x) => x.copyWith(visualizerStyle: (s.visualizerStyle + 1) % 3, visualizerEnabled: true));
          case 'lyrics':
            context.push(Routes.lyrics);
          case 'group':
            await showAddToGroupSheet(context, ref, [song]);
          case 'details':
            await showSongDetails(context, ref, song);
          case 'album':
            context.push(Routes.album(song.album, song.albumArtist ?? song.artist));
          case 'artist':
            context.push(Routes.artist(song.artist));
          case 'sleep':
            await showSleepTimerSheet(context);
          case 'tags':
            context.push(Routes.tagEditor(song.id));
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem(value: 'viz', child: Text(visualizerOn ? 'Show album art' : 'Show visualizer')),
        const PopupMenuItem(value: 'vizstyle', child: Text('Change visualizer style')),
        const PopupMenuItem(value: 'lyrics', child: Text('Lyrics')),
        const PopupMenuItem(value: 'group', child: Text('Add to group')),
        const PopupMenuItem(value: 'details', child: Text('Details')),
        const PopupMenuItem(value: 'album', child: Text('Go to album')),
        const PopupMenuItem(value: 'artist', child: Text('Go to artist')),
        const PopupMenuItem(value: 'sleep', child: Text('Sleep timer')),
        const PopupMenuItem(value: 'tags', child: Text('Edit tags')),
      ],
    );
  }
}

