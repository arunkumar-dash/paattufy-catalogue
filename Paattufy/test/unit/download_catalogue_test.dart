import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:paattufy/features/download_hub/domain/catalogue.dart';
import 'package:paattufy/features/download_hub/domain/listing_parser.dart';

/// The exact JSON published in the GitHub catalogue repo (TP §7.1).
const publishedCatalogue = '''
{
  "schemaVersion": 1,
  "sites": [
    {
      "id": "masstamilan",
      "title": "Masstamilan",
      "link": "https://www.masstamilan.dev/",
      "mode": "listing",
      "listing": {
        "listPageUrl": "https://www.masstamilan.dev/",
        "cardLinkHrefPattern": "^/[a-z0-9-]+-songs(-[0-9]+)?\$",
        "captionLabels": {"starring": "Starring:", "music": "Music:", "director": "Director:"},
        "albumPage": {
          "zipLinkHrefContains": "/zip320/",
          "zipLinkAltHrefContains": "/zip128/",
          "linkExpiryNote": "Zip links are time-boxed (about 1 day); fetch immediately before download, do not cache long-term."
        }
      }
    },
    {"id": "songspk", "title": "SongsPK", "link": "https://songspk.com.se/", "mode": "browse"}
  ]
}
''';

void main() {
  group('DownloadCatalogue.parse', () {
    test('the published catalogue parses into one listing and one browse site', () {
      final cat = DownloadCatalogue.parse(jsonDecode(publishedCatalogue) as Map<String, Object?>);
      expect(cat.sites.map((s) => s.id), ['masstamilan', 'songspk']);
      final mass = cat.sites.first;
      expect(mass.mode, SiteMode.listing);
      expect(mass.title, 'Masstamilan');
      expect(mass.listing!.cardLinkHrefPattern, r'^/[a-z0-9-]+-songs(-[0-9]+)?$');
      expect(mass.listing!.zipLinkHrefContains, '/zip320/');
      expect(mass.listing!.linkExpiryNote, contains('1 day'));
      expect(cat.sites.last.mode, SiteMode.browse);
      expect(cat.sites.last.listing, isNull);
    });

    test('bad entries are skipped individually, not fatal', () {
      final cat = DownloadCatalogue.parse({
        'schemaVersion': 1,
        'sites': [
          {'id': 'a', 'title': 'A', 'link': 'https://a.example/', 'mode': 'browse'},
          {'id': 'a', 'title': 'dup', 'link': 'https://dup.example/', 'mode': 'browse'},
          {'id': 'b', 'title': 'B', 'link': 'not a url', 'mode': 'browse'},
          {'id': 'c', 'title': 'C', 'link': 'https://c.example/', 'mode': 'teleport'},
          {'id': 'd', 'title': 'D', 'link': 'https://d.example/', 'mode': 'listing'},
          {
            'id': 'e',
            'title': 'E',
            'link': 'https://e.example/',
            'mode': 'listing',
            'listing': {'listPageUrl': 'https://e.example/', 'cardLinkHrefPattern': '([unclosed'},
          },
          {'id': 'f', 'title': 'F', 'link': 'ftp://f.example/', 'mode': 'browse'},
          'garbage',
          {'id': 'g', 'title': 'G', 'link': 'https://g.example/', 'mode': 'browse', 'futureField': 1},
        ],
      });
      expect(cat.sites.map((s) => s.id), ['a', 'g']);
    });

    test('unsupported schema or null → empty, never throws', () {
      expect(DownloadCatalogue.parse(null).sites, isEmpty);
      expect(DownloadCatalogue.parse({'schemaVersion': 2, 'sites': []}).sites, isEmpty);
      expect(DownloadCatalogue.parse({'schemaVersion': 1}).sites, isEmpty);
    });
  });

  group('ListingParser (saved HTML fixture, TP §8)', () {
    final catalogue = DownloadCatalogue.parse(jsonDecode(publishedCatalogue) as Map<String, Object?>);
    final parser = ListingParser(catalogue.sites.first.listing!);
    final home = Uri.parse('https://www.masstamilan.dev/');
    final items = parser.parseListing(File('test/fixtures/html/masstamilan_home.html').readAsStringSync(), home);
    ListingItem byUrl(String path) => items.firstWhere((i) => i.albumUrl == 'https://www.masstamilan.dev$path');

    test('only album-card links are picked up, deduplicated, in page order', () {
      expect(items.map((i) => Uri.parse(i.albumUrl).path), [
        '/jailer-2-2026-songs',
        '/leo-songs',
        '/vidaamuyarchi-songs',
        '/ponniyin-selvan-2-songs-2023',
        '/retro-songs',
        '/no-caption-here-2019-songs',
        '/music-only-songs',
      ]);
    });

    test('caption splits into title / starring / music / director via label text', () {
      final jailer = byUrl('/jailer-2-2026-songs');
      expect(jailer.title, 'Jailer 2 (2026)');
      expect(jailer.starring, 'Rajinikanth, Ramya Krishnan');
      expect(jailer.music, 'Anirudh Ravichander');
      expect(jailer.director, 'Nelson Dilipkumar');
      expect(jailer.year, 2026);
    });

    test('absolute hrefs on the same host work; posters resolve to absolute URLs', () {
      final leo = byUrl('/leo-songs');
      expect(leo.title, 'Leo');
      expect(leo.posterUrl, 'https://www.masstamilan.dev/images/leo.jpg', reason: 'data-src beats the data: placeholder');
      expect(byUrl('/jailer-2-2026-songs').posterUrl, 'https://www.masstamilan.dev/images/jailer2.jpg');
    });

    test('poster-link and title-link for the same album merge into one card', () {
      final vida = byUrl('/vidaamuyarchi-songs');
      expect(vida.title, 'Vidaamuyarchi');
      expect(vida.music, 'Anirudh Ravichander');
      expect(vida.posterUrl, 'https://www.masstamilan.dev/images/vida.jpg');
    });

    test('caption in a sibling element is found via the nearest single-card ancestor', () {
      final ps = byUrl('/ponniyin-selvan-2-songs-2023');
      expect(ps.title, 'Ponniyin Selvan 2');
      expect(ps.music, 'A.R. Rahman');
      expect(ps.director, 'Mani Ratnam');
      expect(ps.posterUrl, 'https://www.masstamilan.dev/images/ps2.jpg', reason: 'srcset first candidate');
      expect(ps.year, 2023);
    });

    test('image-only cards fall back to alt text, then to a prettified slug', () {
      expect(byUrl('/retro-songs').title, 'Retro');
      final slug = byUrl('/no-caption-here-2019-songs');
      expect(slug.title, 'No Caption Here 2019');
      expect(slug.year, 2019);
    });

    test('partially labelled captions leave missing fields null', () {
      final m = byUrl('/music-only-songs');
      expect(m.title, 'Music Only Album');
      expect(m.music, 'Yuvan Shankar Raja');
      expect(m.starring, isNull);
      expect(m.director, isNull);
    });

    test('other-host links, sub-paths and non-album pages are ignored', () {
      final urls = items.map((i) => i.albumUrl).join(' ');
      expect(urls, isNot(contains('ads.example.com')));
      expect(urls, isNot(contains('comments')));
      expect(urls, isNot(contains('tamil-movies-a-z')));
    });

    test('empty / hostile HTML yields no items and never throws', () {
      expect(parser.parseListing('', home), isEmpty);
      expect(parser.parseListing('<html><body><a>no href</a><a href="">x</a></body>', home), isEmpty);
      expect(parser.parseListing('<<<not html>>>', home), isEmpty);
    });

    test('labels and pattern come from the catalogue — a different site needs no code', () {
      const cfg = ListingConfig(
        listPageUrl: 'https://other.example/',
        cardLinkHrefPattern: r'^/album/\d+$',
        captionLabels: CaptionLabels(starring: 'Cast:', music: 'Composer:', director: 'Dir:'),
      );
      final other = ListingParser(cfg).parseListing(
        '<a href="/album/7"><img src="/p.png"> Mini Film Cast: A, B Composer: C Dir: D</a><a href="/jailer-2-2026-songs">x</a>',
        Uri.parse('https://other.example/'),
      );
      expect(other, hasLength(1));
      expect(other.single.title, 'Mini Film');
      expect(other.single.starring, 'A, B');
      expect(other.single.music, 'C');
      expect(other.single.director, 'D');
    });
  });

  group('album page (zip links)', () {
    final parser = ListingParser(
      DownloadCatalogue.parse(jsonDecode(publishedCatalogue) as Map<String, Object?>).sites.first.listing!,
    );
    final page = Uri.parse('https://www.masstamilan.dev/jailer-2-2026-songs');

    test('picks the zip320 link as preferred and keeps zip128 as alternative', () {
      final album = parser.parseAlbumPage(File('test/fixtures/html/masstamilan_album.html').readAsStringSync(), page);
      expect(album.zipHigh, 'https://www.masstamilan.dev/downloader/tok3n/1790000000/zip320/4421');
      expect(album.zipLow, 'https://www.masstamilan.dev/downloader/tok3n/1790000000/zip128/4421');
      expect(album.bestZip, album.zipHigh);
      expect(album.title, 'Jailer 2 (2026) Songs Download', reason: 'whitespace collapsed');
    });

    test('falls back to 128 kbps only when 320 is absent', () {
      final album = parser.parseAlbumPage(File('test/fixtures/html/masstamilan_album_128_only.html').readAsStringSync(), page);
      expect(album.zipHigh, isNull);
      expect(album.bestZip, contains('zip128'));
    });

    test('no zip links → bestZip null', () {
      expect(parser.parseAlbumPage('<html><body><a href="/x">x</a></body></html>', page).bestZip, isNull);
    });
  });
}
