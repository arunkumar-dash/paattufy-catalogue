import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

import '../../../app/routes.dart';
import '../data/download_manager.dart';
import '../data/download_providers.dart';
import '../domain/catalogue.dart';

class _Intercepted {
  _Intercepted(this.url, this.name, this.headers, this.pageUrl);
  final String url;
  final String name;
  final Map<String, String> headers;
  final String? pageUrl;
}

/// Browse mode (AP §5.8, TP §5.9.1): an in-app browser with a slim toolbar.
/// Android's WebView DownloadListener fires when a tapped link resolves to a
/// file (not an HTML page); we show an interception bar and hand the URL —
/// with the cookies / referer / user-agent the page used — to the download
/// manager while the WebView keeps browsing.
class BrowseScreen extends ConsumerStatefulWidget {
  const BrowseScreen({super.key, required this.site});
  final CatalogueSite site;

  @override
  ConsumerState<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends ConsumerState<BrowseScreen> {
  late final WebViewController _web;
  final _hook = const MethodChannel('paattufy/download_hook');
  int _progress = 0;
  bool _canBack = false, _canForward = false;
  _Intercepted? _pending;
  String _title = '';

  @override
  void initState() {
    super.initState();
    _web = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onProgress: (p) => setState(() => _progress = p),
        onPageFinished: (_) async {
          final back = await _web.canGoBack();
          final fwd = await _web.canGoForward();
          final title = await _web.getTitle();
          if (mounted) {
            setState(() {
            _canBack = back;
            _canForward = fwd;
            _title = title ?? '';
          });
          }
        },
      ))
      ..loadRequest(Uri.parse(widget.site.link));

    _hook.setMethodCallHandler((call) async {
      if (call.method != 'download') return null;
      final a = (call.arguments as Map).cast<Object?, Object?>();
      final url = a['url'] as String;
      final cookies = a['cookies'] as String?;
      final headers = <String, String>{
        if (cookies != null && cookies.isNotEmpty) 'Cookie': cookies,
        if (a['userAgent'] is String) 'User-Agent': a['userAgent'] as String,
        if (a['referer'] is String) 'Referer': a['referer'] as String,
      };
      var name = filenameFromContentDisposition(a['contentDisposition'] as String?) ?? Uri.tryParse(url)?.pathSegments.where((s) => s.isNotEmpty).lastOrNull ?? 'download';
      try {
        name = Uri.decodeComponent(name);
      } catch (_) {}
      if (mounted) setState(() => _pending = _Intercepted(url, name, headers, a['referer'] as String?));
      return null;
    });
    // Attach once the platform WebView exists.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final platform = _web.platform;
      if (platform is AndroidWebViewController) {
        await _hook.invokeMethod<bool>('attach', {'webViewIdentifier': platform.webViewIdentifier});
      }
    });
  }

  @override
  void dispose() {
    _hook.setMethodCallHandler(null);
    super.dispose();
  }

  Future<void> _startDownload() async {
    final p = _pending!;
    setState(() => _pending = null);
    await ref.read(downloadManagerProvider).enqueueFile(siteId: widget.site.id, title: p.name, url: p.url, headers: p.headers, pageUrl: p.pageUrl);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Downloading ${p.name}'),
      action: SnackBarAction(label: 'View', onPressed: () => context.go(Routes.download)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return PopScope(
      canPop: !_canBack,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop && _canBack) await _web.goBack();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_title.isEmpty ? widget.site.title : _title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16)),
          actions: [
            IconButton(icon: const Icon(Icons.arrow_back), onPressed: _canBack ? _web.goBack : null),
            IconButton(icon: const Icon(Icons.arrow_forward), onPressed: _canForward ? _web.goForward : null),
            IconButton(icon: const Icon(Icons.refresh), onPressed: _web.reload),
            IconButton(
              icon: const Icon(Icons.open_in_browser),
              tooltip: 'Open in browser',
              onPressed: () async {
                final url = await _web.currentUrl() ?? widget.site.link;
                await const MethodChannel('paattufy/system').invokeMethod<bool>('openExternal', {'url': url});
              },
            ),
          ],
          bottom: _progress < 100 ? PreferredSize(preferredSize: const Size.fromHeight(2), child: LinearProgressIndicator(value: _progress / 100, minHeight: 2)) : null,
        ),
        body: Column(children: [
          Expanded(child: WebViewWidget(controller: _web)),
          if (_pending != null)
            Material(
              color: scheme.primaryContainer,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                  child: Row(children: [
                    Icon(Icons.download, color: scheme.onPrimaryContainer),
                    const SizedBox(width: 12),
                    Expanded(child: Text(_pending!.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: scheme.onPrimaryContainer))),
                    TextButton(onPressed: () => setState(() => _pending = null), child: const Text('Dismiss')),
                    FilledButton(onPressed: _startDownload, child: const Text('Download')),
                  ]),
                ),
              ),
            ),
        ]),
      ),
    );
  }
}
