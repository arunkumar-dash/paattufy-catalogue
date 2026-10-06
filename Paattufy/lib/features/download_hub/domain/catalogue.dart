/// The download-hub catalogue (TP §7.1): the site list and, for listing-mode
/// sites, the rules for reading them — all declared in the GitHub JSON so a
/// markup change means editing the repo, not the app (AP §3.8).
enum SiteMode { browse, listing }

class CaptionLabels {
  const CaptionLabels({this.starring = 'Starring:', this.music = 'Music:', this.director = 'Director:'});
  final String starring;
  final String music;
  final String director;
  List<String> get all => [starring, music, director];
}

class ListingConfig {
  const ListingConfig({
    required this.listPageUrl,
    required this.cardLinkHrefPattern,
    this.captionLabels = const CaptionLabels(),
    this.zipLinkHrefContains = '/zip320/',
    this.zipLinkAltHrefContains = '/zip128/',
    this.linkExpiryNote,
  });

  final String listPageUrl;
  final String cardLinkHrefPattern;
  final CaptionLabels captionLabels;
  final String zipLinkHrefContains;
  final String? zipLinkAltHrefContains;
  final String? linkExpiryNote;

  static ListingConfig? fromJson(Object? j) {
    if (j is! Map) return null;
    final list = j['listPageUrl'], pattern = j['cardLinkHrefPattern'];
    if (list is! String || pattern is! String) return null;
    try {
      RegExp(pattern);
    } catch (_) {
      return null; // a bad regex in the catalogue must not crash the app
    }
    final labels = j['captionLabels'];
    final album = j['albumPage'] is Map ? j['albumPage'] as Map : const {};
    String label(String k, String d) => (labels is Map && labels[k] is String) ? labels[k] as String : d;
    return ListingConfig(
      listPageUrl: list,
      cardLinkHrefPattern: pattern,
      captionLabels: CaptionLabels(
        starring: label('starring', 'Starring:'),
        music: label('music', 'Music:'),
        director: label('director', 'Director:'),
      ),
      zipLinkHrefContains: (album['zipLinkHrefContains'] as String?) ?? '/zip320/',
      zipLinkAltHrefContains: album['zipLinkAltHrefContains'] as String?,
      linkExpiryNote: album['linkExpiryNote'] as String?,
    );
  }
}

class CatalogueSite {
  const CatalogueSite({
    required this.id,
    required this.title,
    required this.link,
    required this.mode,
    this.listing,
  });

  final String id;
  final String title;
  final String link;
  final SiteMode mode;
  final ListingConfig? listing;

  static CatalogueSite? fromJson(Object? j) {
    if (j is! Map) return null;
    final id = j['id'], title = j['title'], link = j['link'], mode = j['mode'];
    if (id is! String || title is! String || link is! String) return null;
    final uri = Uri.tryParse(link);
    if (uri == null || !(uri.scheme == 'https' || uri.scheme == 'http') || uri.host.isEmpty) return null;
    switch (mode) {
      case 'browse':
        return CatalogueSite(id: id, title: title, link: link, mode: SiteMode.browse);
      case 'listing':
        final cfg = ListingConfig.fromJson(j['listing']);
        if (cfg == null) return null;
        return CatalogueSite(id: id, title: title, link: link, mode: SiteMode.listing, listing: cfg);
      default:
        return null; // unknown mode: skipped so newer catalogues degrade gracefully
    }
  }
}

class DownloadCatalogue {
  const DownloadCatalogue(this.sites);
  final List<CatalogueSite> sites;

  static const supportedSchema = 1;

  /// Parses the catalogue JSON. Malformed sites are skipped individually; an
  /// unsupported schema version yields an empty catalogue.
  static DownloadCatalogue parse(Map<String, Object?>? json) {
    if (json == null || (json['schemaVersion'] as num?)?.toInt() != supportedSchema) {
      return const DownloadCatalogue([]);
    }
    final seen = <String>{};
    final sites = <CatalogueSite>[];
    for (final s in (json['sites'] as List? ?? const [])) {
      final site = CatalogueSite.fromJson(s);
      if (site != null && seen.add(site.id)) sites.add(site);
    }
    return DownloadCatalogue(sites);
  }
}
