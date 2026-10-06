import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/settings/app_settings.dart';
import '../../library/data/library_providers.dart';
import '../../settings/data/permissions_service.dart';
import '../../settings/presentation/settings_screen.dart' show validateDownloadFolder;

/// First run (AP §5.1): full-bleed electric-purple gradient, app mark centred,
/// three sequential cards — what Paattufy does → permissions → storage + scan.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pages = PageController();
  int _page = 0;
  late final TextEditingController _folder = TextEditingController(text: ref.read(settingsProvider).downloadFolderPath);
  String? _folderError;
  bool _scanStarted = false;

  @override
  void dispose() {
    _pages.dispose();
    _folder.dispose();
    super.dispose();
  }

  void _go(int page) {
    setState(() => _page = page);
    _pages.animateToPage(page, duration: const Duration(milliseconds: 280), curve: Curves.easeOutCubic);
  }

  static const _ctaStyle = ButtonStyle(
    backgroundColor: WidgetStatePropertyAll(Colors.white),
    foregroundColor: WidgetStatePropertyAll(Color(0xFF4B12B5)),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF9B5CFF), Color(0xFF6A1FE0), Color(0xFF2B0A6B)]),
        ),
        child: SafeArea(
          child: Column(children: [
            const SizedBox(height: 20),
            Image.asset('assets/icon/icon_foreground.png', width: 96, height: 96, color: Colors.white),
            const Text('Paattufy', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
            const SizedBox(height: 12),
            Expanded(
              child: PageView(
                controller: _pages,
                physics: const NeverScrollableScrollPhysics(),
                children: [_welcome(), _permissions(), _storage()],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16, top: 8),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                for (var i = 0; i < 3; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == _page ? 22 : 8,
                    height: 8,
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: i == _page ? 1 : 0.4), borderRadius: BorderRadius.circular(4)),
                  ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _card({required String title, required List<Widget> children, required Widget cta}) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Card(
          color: Colors.black.withValues(alpha: 0.35),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
              const SizedBox(height: 14),
              Expanded(child: ListView(children: children)),
              const SizedBox(height: 12),
              cta,
            ]),
          ),
        ),
      );

  Widget _bullet(IconData icon, String title, String body) => Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
              Text(body, style: TextStyle(color: Colors.white.withValues(alpha: 0.8))),
            ]),
          ),
        ]),
      );

  Widget _welcome() => _card(
        title: 'Your music, your way',
        children: [
          _bullet(Icons.offline_bolt, 'Offline first', 'Your whole library, groups and lyrics work with no network.'),
          _bullet(Icons.auto_awesome_motion, 'Groups that stay current', 'Hand-pick songs or build rules that keep themselves up to date.'),
          _bullet(Icons.lyrics, 'Lyrics, queue & mood', 'Synced lyrics, a smart queue and a download hub you control.'),
        ],
        cta: FilledButton(onPressed: () => _go(1), style: _ctaStyle, child: const Text('Get started')),
      );

  Widget _permissions() {
    final svc = ref.read(permissionsServiceProvider);
    Widget tile(AppPermission p) {
      final granted = ref.watch(permissionStatusProvider(p)).value ?? false;
      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(children: [
          Icon(granted ? Icons.check_circle : Icons.radio_button_unchecked, color: granted ? Colors.greenAccent : Colors.white70),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(p.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              Text(p.reason, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13)),
            ]),
          ),
          const SizedBox(width: 8),
          if (!granted)
            FilledButton.tonal(
              onPressed: () async {
                await svc.request(p);
                ref.invalidate(permissionStatusProvider(p));
              },
              child: const Text('Grant'),
            ),
        ]),
      );
    }

    return _card(
      title: 'A few permissions',
      children: [for (final p in AppPermission.values) tile(p)],
      cta: FilledButton(onPressed: () => _go(2), style: _ctaStyle, child: const Text('Continue')),
    );
  }

  Widget _storage() {
    final scan = ref.watch(scanControllerProvider);
    final done = _scanStarted && !scan.running && scan.last != null;
    return _card(
      title: 'Where should downloaded songs live?',
      children: [
        Text('Songs you download are saved here and added to your library. You can change this later in Settings.', style: TextStyle(color: Colors.white.withValues(alpha: 0.85))),
        const SizedBox(height: 14),
        TextField(
          controller: _folder,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Download folder',
            labelStyle: const TextStyle(color: Colors.white70),
            helperText: 'An absolute path, e.g. /storage/emulated/0/Music/Paattufy',
            helperMaxLines: 2,
            helperStyle: const TextStyle(color: Colors.white60),
            errorText: _folderError,
            enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white54)),
            suffixIcon: IconButton(
              icon: const Icon(Icons.folder_open, color: Colors.white),
              onPressed: () async {
                final p = await FilePicker.getDirectoryPath();
                if (p != null) setState(() => _folder.text = p);
              },
            ),
          ),
        ),
        const SizedBox(height: 18),
        if (_scanStarted)
          Card(
            color: Colors.white.withValues(alpha: 0.12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                if (!done) const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white)) else const Icon(Icons.check_circle, color: Colors.greenAccent),
                const SizedBox(width: 14),
                Text(done ? '${scan.last!.total} songs found' : '${_fmt(scan.found)} songs found…', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
              ]),
            ),
          ),
      ],
      cta: FilledButton(
        style: _ctaStyle,
        onPressed: scan.running ? null : (done ? _finish : _startScan),
        child: Text(done ? 'Finish' : 'Save & scan my library'),
      ),
    );
  }

  String _fmt(int n) => n.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');

  Future<void> _startScan() async {
    final path = _folder.text.trim().replaceAll(RegExp(r'/+$'), '');
    final err = await validateDownloadFolder(path);
    if (err != null) {
      setState(() => _folderError = err);
      return;
    }
    setState(() {
      _folderError = null;
      _scanStarted = true;
    });
    await ref.read(settingsProvider.notifier).update((s) => s.copyWith(downloadFolderPath: path));
    await ref.read(scanControllerProvider.notifier).run(full: true);
  }

  Future<void> _finish() async {
    await ref.read(settingsProvider.notifier).update((s) => s.copyWith(onboardingComplete: true));
    if (mounted) context.go(Routes.library);
  }
}
