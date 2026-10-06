import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../playback/data/playback_controller.dart';
import '../data/lyrics_providers.dart';
import '../domain/lrc.dart';
import 'lyrics_widgets.dart';

/// Full-screen karaoke lyrics (AP §5.6): the active line is bold, scaled and
/// full-opacity; past lines are dimmed, upcoming lines dimmer; auto-scroll
/// keeps the active line centred; tapping a line seeks to it; a "jump back to
/// current" pill appears while the user scrolls manually; ±0.2 s offset
/// control is saved per song.
class LyricsScreen extends ConsumerStatefulWidget {
  const LyricsScreen({super.key});

  @override
  ConsumerState<LyricsScreen> createState() => _LyricsScreenState();
}

class _LyricsScreenState extends ConsumerState<LyricsScreen> {
  final _scroll = ScrollController();
  List<GlobalKey> _keys = [];
  bool _userScrolling = false;
  int _lastIdx = -2;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _center(int idx, {bool animate = true}) {
    if (idx < 0 || idx >= _keys.length) return;
    final ctx = _keys[idx].currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(ctx, alignment: 0.42, duration: animate ? const Duration(milliseconds: 380) : Duration.zero, curve: Curves.easeInOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    final song = ref.watch(playbackControllerProvider.select((s) => s.current));
    final lyrics = ref.watch(currentLyricsProvider).value;
    final lines = ref.watch(currentLyricLinesProvider);
    final idx = ref.watch(activeLyricIndexProvider);
    final offset = ref.watch(currentLyricsOffsetProvider);
    final scheme = Theme.of(context).colorScheme;
    final controller = ref.read(playbackControllerProvider.notifier);

    if (_keys.length != lines.length) _keys = List.generate(lines.length, (_) => GlobalKey());
    if (idx != _lastIdx) {
      _lastIdx = idx;
      if (!_userScrolling) WidgetsBinding.instance.addPostFrameCallback((_) => _center(idx));
    }

    Future<void> nudge(int delta) async {
      if (song == null) return;
      await ref.read(lyricsRepositoryProvider).adjustOffset(song, delta);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(song?.title ?? 'Lyrics', maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            tooltip: 'Search lyrics',
            icon: const Icon(Icons.manage_search),
            onPressed: song == null ? null : () => context.push(Routes.lyricsPicker(song.id)),
          ),
        ],
        bottom: lines.isEmpty
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(44),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  IconButton(icon: const Icon(Icons.remove), tooltip: '−0.2 s', onPressed: () => nudge(-200)),
                  Text('Sync ${offset >= 0 ? '+' : ''}${(offset / 1000).toStringAsFixed(1)} s'),
                  IconButton(icon: const Icon(Icons.add), tooltip: '+0.2 s', onPressed: () => nudge(200)),
                ]),
              ),
      ),
      body: Builder(builder: (context) {
        if (lines.isEmpty) {
          if (lyrics != null && lyrics.hasPlain) {
            return ListView(padding: const EdgeInsets.all(24), children: [SelectableText(lyrics.plain!, style: const TextStyle(fontSize: 18, height: 1.6))]);
          }
          return Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text('No lyrics for this song yet'),
              const SizedBox(height: 12),
              if (song != null) FilledButton(onPressed: () => context.push(Routes.lyricsPicker(song.id)), child: const Text('Search lyrics')),
            ]),
          );
        }
        return Stack(children: [
          NotificationListener<ScrollNotification>(
            onNotification: (n) {
              if (n is ScrollStartNotification && n.dragDetails != null) setState(() => _userScrolling = true);
              return false;
            },
            child: SingleChildScrollView(
              controller: _scroll,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: MediaQuery.sizeOf(context).height * 0.35),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                for (var i = 0; i < lines.length; i++)
                  InkWell(
                    key: _keys[i],
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      controller.seek(Lrc.seekTimeFor(lines, i, offsetMs: offset));
                      setState(() => _userScrolling = false);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                      child: AnimatedScale(
                        scale: i == idx ? 1.0 : 0.88,
                        alignment: Alignment.centerLeft,
                        duration: const Duration(milliseconds: 260),
                        curve: Curves.easeOut,
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 260),
                          style: TextStyle(
                            fontSize: 26,
                            height: 1.25,
                            fontWeight: i == idx ? FontWeight.w800 : FontWeight.w600,
                            color: i == idx
                                ? scheme.onSurface
                                : (i < idx ? scheme.onSurface.withValues(alpha: 0.42) : scheme.onSurface.withValues(alpha: 0.28)),
                          ),
                          child: Text(lines[i].text.isEmpty ? '♪' : lines[i].text),
                        ),
                      ),
                    ),
                  ),
              ]),
            ),
          ),
          if (_userScrolling)
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Center(
                child: FilledButton.tonalIcon(
                  icon: const Icon(Icons.my_location, size: 18),
                  label: const Text('Jump back to current'),
                  onPressed: () {
                    setState(() => _userScrolling = false);
                    _center(idx);
                  },
                ),
              ),
            ),
        ]);
      }),
    );
  }
}
