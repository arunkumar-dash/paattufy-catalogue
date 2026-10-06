import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;

import 'catalogue.dart';

/// One album/movie card parsed from a listing page.
class ListingItem {
  const ListingItem({
    required this.albumUrl,
    required this.title,
    this.posterUrl,
    this.starring,
    this.music,
    this.director,
    this.year,
  });

  final String albumUrl;
  final String title;
  final String? posterUrl;
  final String? starring;
  final String? music;
  final String? director;
  final int? year;

  @override
  String toString() => 'ListingItem($title, $albumUrl)';
}

/// What an album page exposes: the zip links (AP §3.8, TP §5.9.2).
class AlbumPage {
  const AlbumPage({this.title, this.zipHigh, this.zipLow});
  final String? title;

  /// The preferred (320 kbps) zip.
  final String? zipHigh;

  /// The alternative (128 kbps) zip, used only if the preferred one is absent.
  final String? zipLow;

  String? get bestZip => zipHigh ?? zipLow;
}

/// Reads listing/album pages using only the catalogue's rules: an href pattern
/// for cards and label text anchors ("Starring:", "Music:", "Director:") for
/// captions — no brittle CSS class selectors (TP §5.9.2).
class ListingParser {
  ListingParser(this.config);
  final ListingConfig config;

  late final RegExp _card = RegExp(config.cardLinkHrefPattern);

  List<ListingItem> parseListing(String html, Uri pageUri) {
    final doc = html_parser.parse(html);
    final anchors = doc.querySelectorAll('a[href]');

    // url -> (first-seen order, collected pieces). The same album is often
    // linked twice (poster + title); merge so neither is lost.
    final order = <String>[];
    final pieces = <String, _Card>{};

    for (final a in anchors) {
      final uri = _resolve(pageUri, a.attributes['href']);
      if (uri == null || uri.host != pageUri.host) continue;
      if (!_matchesCard(uri)) continue;
      final key = _canonical(uri);
      final card = pieces.putIfAbsent(key, () {
        order.add(key);
        return _Card();
      });

      final text = _clean(a.text);
      final labelled = _hasAnyLabel(text);
      final candidate = labelled
          ? text
          : _parentCaption(a, config.captionLabels.all, pageUri) ?? text;
      if (candidate.length > card.caption.length) card.caption = candidate;

      final img = a.querySelector('img');
      card.poster ??= _imageUrl(img, pageUri);
      card.altTitle ??= _clean(img?.attributes['alt'] ?? img?.attributes['title'] ?? '');
    }

    final items = <ListingItem>[];
    for (final key in order) {
      final card = pieces[key]!;
      final parsed = _splitCaption(card.caption);
      var title = parsed.title;
      if (title.isEmpty) title = card.altTitle ?? '';
      if (title.isEmpty) title = _titleFromSlug(Uri.parse(key).path);
      items.add(ListingItem(
        albumUrl: key,
        title: title,
        posterUrl: card.poster,
        starring: parsed.starring,
        music: parsed.music,
        director: parsed.director,
        year: _year(Uri.parse(key).path, title),
      ));
    }
    return items;
  }

  AlbumPage parseAlbumPage(String html, Uri pageUri) {
    final doc = html_parser.parse(html);
    String? high, low;
    for (final a in doc.querySelectorAll('a[href]')) {
      final href = a.attributes['href'];
      if (href == null) continue;
      final uri = _resolve(pageUri, href);
      if (uri == null) continue;
      final url = uri.toString();
      if (high == null && href.contains(config.zipLinkHrefContains)) high = url;
      final alt = config.zipLinkAltHrefContains;
      if (low == null && alt != null && alt.isNotEmpty && href.contains(alt)) low = url;
    }
    final h1 = doc.querySelector('h1')?.text;
    final title = _clean(h1 ?? doc.querySelector('title')?.text ?? '');
    return AlbumPage(title: title.isEmpty ? null : title, zipHigh: high, zipLow: low);
  }

  // --- helpers --------------------------------------------------------------

  bool _matchesCard(Uri uri) {
    final path = uri.path;
    if (_card.hasMatch(path)) return true;
    if (path.length > 1 && path.endsWith('/')) return _card.hasMatch(path.substring(0, path.length - 1));
    return false;
  }

  Uri? _resolve(Uri base, String? href) {
    if (href == null || href.trim().isEmpty) return null;
    final h = href.trim();
    if (h.startsWith('#') || h.startsWith('javascript:') || h.startsWith('mailto:')) return null;
    try {
      return base.resolve(h);
    } catch (_) {
      return null;
    }
  }

  String _canonical(Uri u) => u.replace(query: null, fragment: '').toString().replaceFirst(RegExp(r'#$'), '');

  String _clean(String s) => s.replaceAll(RegExp(r'\s+'), ' ').trim();

  bool _hasAnyLabel(String text) => config.captionLabels.all.any((l) => text.contains(l));

  /// When the card's anchor holds only the poster, the caption may sit in a
  /// sibling element; look at the nearest ancestor that contains exactly one
  /// distinct card link.
  String? _parentCaption(Element a, List<String> labels, Uri pageUri) {
    Element? p = a.parent;
    for (var depth = 0; depth < 3 && p != null; depth++, p = p.parent) {
      final distinct = <String>{};
      for (final x in p.querySelectorAll('a[href]')) {
        final u = _resolve(pageUri, x.attributes['href']);
        if (u != null && u.host == pageUri.host && _matchesCard(u)) distinct.add(_canonical(u));
      }
      if (distinct.length > 1) return null;
      final text = _clean(p.text);
      if (labels.any(text.contains)) return text;
    }
    return null;
  }

  String? _imageUrl(Element? img, Uri base) {
    if (img == null) return null;
    for (final attr in const ['data-src', 'data-original', 'data-lazy-src', 'src']) {
      final v = img.attributes[attr];
      if (v != null && v.trim().isNotEmpty && !v.startsWith('data:')) return _resolve(base, v)?.toString();
    }
    final srcset = img.attributes['srcset'];
    if (srcset != null && srcset.trim().isNotEmpty) {
      final first = srcset.split(',').first.trim().split(' ').first;
      return _resolve(base, first)?.toString();
    }
    return null;
  }

  /// "Jailer 2 Starring: A, B Music: C Director: D" → title/starring/music/director.
  ({String title, String? starring, String? music, String? director}) _splitCaption(String caption) {
    final labels = config.captionLabels;
    final found = <String, int>{};
    for (final l in labels.all) {
      final i = caption.indexOf(l);
      if (i >= 0) found[l] = i;
    }
    if (found.isEmpty) return (title: caption.trim(), starring: null, music: null, director: null);
    final starts = found.values.toList()..sort();
    String valueOf(String label) {
      final i = found[label];
      if (i == null) return '';
      final begin = i + label.length;
      final next = starts.where((s) => s > i).fold<int?>(null, (m, s) => m == null || s < m ? s : m);
      return caption.substring(begin, next ?? caption.length).trim();
    }

    String? orNull(String s) => s.isEmpty ? null : s;
    return (
      title: caption.substring(0, starts.first).trim(),
      starring: orNull(valueOf(labels.starring)),
      music: orNull(valueOf(labels.music)),
      director: orNull(valueOf(labels.director)),
    );
  }

  String _titleFromSlug(String path) {
    var slug = path.split('/').where((p) => p.isNotEmpty).lastOrNull ?? '';
    slug = slug.replaceFirst(RegExp(r'-songs(-\d+)?$'), '');
    return slug
        .split('-')
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }

  int? _year(String path, String title) {
    final m = RegExp(r'-((?:19|20)\d{2})(?:-songs|$)').firstMatch(path) ??
        RegExp(r'\b((?:19|20)\d{2})\b').firstMatch(title);
    return m == null ? null : int.tryParse(m.group(1)!);
  }
}

class _Card {
  String caption = '';
  String? poster;
  String? altTitle;
}
