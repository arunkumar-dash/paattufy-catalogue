import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:paattufy/core/database/app_database.dart';
import 'package:paattufy/core/settings/app_settings.dart';
import 'package:paattufy/features/download_hub/data/download_manager.dart';
import 'package:paattufy/features/download_hub/domain/catalogue.dart';
import 'package:paattufy/features/download_hub/domain/listing_parser.dart';

import '../support/fake_http.dart';

Uint8List bytesOf(int n, {int seed = 1}) => Uint8List.fromList([for (var i = 0; i < n; i++) (i * 31 + seed) & 0xFF]);

Uint8List makeZip(Map<String, List<int>> files) {
  final a = Archive();
  files.forEach((name, data) => a.addFile(ArchiveFile(name, data.length, data)));
  return Uint8List.fromList(ZipEncoder().encode(a));
}

final masstamilan = CatalogueSite(
  id: 'masstamilan',
  title: 'Masstamilan',
  link: 'https://www.masstamilan.dev/',
  mode: SiteMode.listing,
  listing: const ListingConfig(
    listPageUrl: 'https://www.masstamilan.dev/',
    cardLinkHrefPattern: r'^/[a-z0-9-]+-songs(-[0-9]+)?$',
  ),
);
const item = ListingItem(albumUrl: 'https://www.masstamilan.dev/jailer-2-2026-songs', title: 'Jailer 2 (2026)');

String albumHtml(String token) => '''
<html><body><h1>Jailer 2</h1>
<a href="/downloader/$token/1790000000/zip128/4421">128</a>
<a href="/downloader/$token/1790000000/zip320/4421">320</a></body></html>''';

void main() {
  late AppDatabase db;
  late Directory root;
  late FakeHttpAdapter http;
  late DownloadManager mgr;
  late List<List<String>> indexed;
  var rescans = 0;
  var metered = false;
  var settings = const AppSettings();
  final albumFetches = <String>[];
  var token = 'tokA';

  Future<DownloadRecord> waitFor(int id, Set<String> statuses, {Duration timeout = const Duration(seconds: 10)}) async {
    final end = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(end)) {
      final r = await mgr.byId(id);
      if (r != null && statuses.contains(r.status)) return r;
      await Future<void>.delayed(const Duration(milliseconds: 15));
    }
    throw TimeoutException('download $id never reached $statuses; is ${(await mgr.byId(id))?.status} ${(await mgr.byId(id))?.error}');
  }

  setUp(() async {
    db = AppDatabase.forTesting();
    root = Directory.systemTemp.createTempSync('paattufy_dl_test');
    indexed = [];
    rescans = 0;
    metered = false;
    albumFetches.clear();
    token = 'tokA';
    settings = AppSettings(downloadFolderPath: '${root.path}/Music/Paattufy');
    http = FakeHttpAdapter((o) => const FakeResponse('', status: 404));
    mgr = DownloadManager(
      db: db,
      dio: fakeDio(http),
      settings: () => settings,
      tempDir: Directory('${root.path}/tmp'),
      indexFiles: (paths) async => indexed.add(paths),
      onLibraryChanged: () async => rescans++,
      isMetered: () async => metered,
      fetchHtml: (url) async {
        albumFetches.add(url);
        return albumHtml(token);
      },
    );
    mgr.siteResolver = (id) async => masstamilan;
  });

  tearDown(() async {
    mgr.dispose();
    await db.close();
    root.deleteSync(recursive: true);
  });

  group('helpers', () {
    test('sanitizeFileName', () {
      expect(sanitizeFileName('a/b\\c:d*e?f"g<h>i|j.mp3'), 'a_b_c_d_e_f_g_h_i_j.mp3');
      expect(sanitizeFileName('  ..hidden. '), 'hidden');
      expect(sanitizeFileName('', fallback: 'x'), 'x');
      expect(sanitizeFileName('../../etc/passwd'), '.._.._etc_passwd'.replaceFirst(RegExp(r'^\.+'), ''));
      expect(sanitizeFileName('${'x' * 300}.mp3').length, lessThanOrEqualTo(120));
      expect(sanitizeFileName('${'x' * 300}.mp3'), endsWith('.mp3'));
    });
    test('Content-Disposition parsing', () {
      expect(filenameFromContentDisposition('attachment; filename="Song One.mp3"'), 'Song One.mp3');
      expect(filenameFromContentDisposition("attachment; filename*=UTF-8''Song%20Two.mp3"), 'Song Two.mp3');
      expect(filenameFromContentDisposition('attachment; filename=plain.mp3; size=3'), 'plain.mp3');
      expect(filenameFromContentDisposition(null), isNull);
      expect(filenameFromContentDisposition('inline'), isNull);
    });
    test('content type → extension', () {
      expect(extensionForContentType('audio/mpeg; charset=x'), '.mp3');
      expect(extensionForContentType('application/zip'), '.zip');
      expect(extensionForContentType('text/html'), isNull);
    });
  });

  group('single files', () {
    test('mp3 lands in the download folder, is indexed, triggers a rescan', () async {
      final data = bytesOf(5000);
      http.handler = (o) => FakeResponse.bytes(data, headers: {
            Headers.contentTypeHeader: ['audio/mpeg'],
            Headers.contentLengthHeader: ['${data.length}'],
            'content-disposition': ['attachment; filename="Kanavugal.mp3"'],
          });
      final id = await mgr.enqueueFile(siteId: 'songspk', title: 'Kanavugal', url: 'https://songspk.example/dl/1');
      final r = await waitFor(id, {DownloadStatus.done, DownloadStatus.failed});
      expect(r.status, DownloadStatus.done, reason: r.error);
      final file = File('${root.path}/Music/Paattufy/Kanavugal.mp3');
      expect(file.existsSync(), isTrue);
      expect(file.readAsBytesSync(), data);
      expect(r.bytesDone, 5000);
      expect(r.bytesTotal, 5000);
      expect(r.itemsAdded, 1);
      expect(r.localPath, file.path);
      expect(indexed.single, [file.path]);
      expect(rescans, 1);
      expect(File('${root.path}/tmp/dl_$id.part').existsSync(), isFalse, reason: 'temp part cleaned up');
    });

    test('name collisions never overwrite: second file becomes "name (1).mp3"', () async {
      http.handler = (o) => FakeResponse.bytes(bytesOf(100), headers: {
            Headers.contentTypeHeader: ['audio/mpeg'],
            'content-disposition': ['attachment; filename="same.mp3"'],
          });
      final a = await mgr.enqueueFile(siteId: 's', title: 'a', url: 'https://x.example/1');
      await waitFor(a, {DownloadStatus.done});
      final b = await mgr.enqueueFile(siteId: 's', title: 'b', url: 'https://x.example/2');
      await waitFor(b, {DownloadStatus.done});
      final dir = Directory('${root.path}/Music/Paattufy');
      expect(dir.listSync().map((e) => e.path.split('/').last).toSet(), {'same.mp3', 'same (1).mp3'});
    });

    test('file name falls back to URL segment, then content type', () async {
      http.handler = (o) => FakeResponse.bytes(bytesOf(50), headers: {Headers.contentTypeHeader: ['audio/mpeg']});
      final id = await mgr.enqueueFile(siteId: 's', title: 'Fallback Title', url: 'https://x.example/files/track%20one.mp3');
      await waitFor(id, {DownloadStatus.done});
      expect(File('${root.path}/Music/Paattufy/track one.mp3').existsSync(), isTrue);
      final id2 = await mgr.enqueueFile(siteId: 's', title: 'No Ext', url: 'https://x.example/get?id=7');
      await waitFor(id2, {DownloadStatus.done});
      expect(File('${root.path}/Music/Paattufy/No Ext.mp3').existsSync(), isTrue);
    });

    test('headers (cookies/referer) captured from the browser are replayed', () async {
      http.handler = (o) => FakeResponse.bytes(bytesOf(10), headers: {Headers.contentTypeHeader: ['audio/mpeg']});
      final id = await mgr.enqueueFile(
        siteId: 'songspk',
        title: 't',
        url: 'https://songspk.example/a.mp3',
        headers: {'Cookie': 'sid=abc', 'Referer': 'https://songspk.example/page'},
      );
      await waitFor(id, {DownloadStatus.done});
      expect(http.requests.single.headers['Cookie'], 'sid=abc');
      expect(http.requests.single.headers['Referer'], 'https://songspk.example/page');
    });

    test('an HTML page, a non-audio file and a 404 fail cleanly with a reason', () async {
      http.handler = (o) => FakeResponse.bytes(Uint8List.fromList(utf8.encode('<html>sorry</html>')),
          headers: {Headers.contentTypeHeader: ['text/html']});
      var id = await mgr.enqueueFile(siteId: 's', title: 'x', url: 'https://x.example/a');
      var r = await waitFor(id, {DownloadStatus.failed, DownloadStatus.done});
      expect(r.status, DownloadStatus.failed);
      expect(r.error, contains('expired'));

      http.handler = (o) => FakeResponse.bytes(bytesOf(10), headers: {
            Headers.contentTypeHeader: ['application/pdf'],
            'content-disposition': ['attachment; filename="doc.pdf"'],
          });
      id = await mgr.enqueueFile(siteId: 's', title: 'x', url: 'https://x.example/b');
      r = await waitFor(id, {DownloadStatus.failed, DownloadStatus.done});
      expect(r.status, DownloadStatus.failed);
      expect(r.error, contains('Not an audio file'));
      expect(Directory('${root.path}/Music/Paattufy').listSync().where((e) => e.path.endsWith('.pdf')), isEmpty);
    });
  });

  group('zip extraction', () {
    test('keeps audio only, flattens folders, and neutralises zip-slip names', () async {
      final zip = makeZip({
        '01 - Kanavugal.mp3': bytesOf(300, seed: 1),
        'CD1/02 - Megam.MP3': bytesOf(300, seed: 2),
        '../../evil.mp3': bytesOf(100, seed: 3),
        '/abs/path/abs.mp3': bytesOf(100, seed: 4),
        'cover.jpg': bytesOf(50),
        'readme.txt': bytesOf(20),
        'ads.html': bytesOf(20),
      });
      http.handler = (o) => FakeResponse.bytes(zip, headers: {
            Headers.contentTypeHeader: ['application/zip'],
            'content-disposition': ['attachment; filename="Album One.zip"'],
          });
      final id = await mgr.enqueueFile(siteId: 'songspk', title: 'Album One', url: 'https://x.example/zip');
      final r = await waitFor(id, {DownloadStatus.done, DownloadStatus.failed});
      expect(r.status, DownloadStatus.done, reason: r.error);
      final dir = Directory('${root.path}/Music/Paattufy/Album One');
      final names = dir.listSync().map((e) => e.path.split('/').last).toSet();
      expect(names, {'01 - Kanavugal.mp3', '02 - Megam.MP3', 'evil.mp3', 'abs.mp3'});
      expect(r.itemsAdded, 4);
      expect(r.localPath, dir.path);
      // Nothing escaped the album folder.
      expect(File('${root.path}/Music/evil.mp3').existsSync(), isFalse);
      expect(File('${root.path}/evil.mp3').existsSync(), isFalse);
      expect(File('/abs/path/abs.mp3').existsSync(), isFalse);
      expect(indexed.single.toSet(), {for (final n in names) '${dir.path}/$n'});
      expect(File('${dir.path}/01 - Kanavugal.mp3').readAsBytesSync(), bytesOf(300, seed: 1));
    });

    test('zip detected by magic bytes even without extension or content type', () async {
      final zip = makeZip({'a.mp3': bytesOf(64)});
      http.handler = (o) => FakeResponse.bytes(zip, headers: {Headers.contentTypeHeader: ['application/octet-stream']});
      final id = await mgr.enqueueFile(siteId: 's', title: 'Mystery', url: 'https://x.example/download?id=3');
      final r = await waitFor(id, {DownloadStatus.done, DownloadStatus.failed});
      expect(r.status, DownloadStatus.done, reason: r.error);
      expect(File('${root.path}/Music/Paattufy/Mystery/a.mp3').existsSync(), isTrue);
    });

    test('a zip with no audio fails and leaves no empty folder', () async {
      http.handler = (o) => FakeResponse.bytes(makeZip({'cover.jpg': bytesOf(10)}),
          headers: {Headers.contentTypeHeader: ['application/zip']});
      final id = await mgr.enqueueFile(siteId: 's', title: 'Empty', url: 'https://x.example/z.zip');
      final r = await waitFor(id, {DownloadStatus.done, DownloadStatus.failed});
      expect(r.status, DownloadStatus.failed);
      expect(r.error, contains('no audio'));
      expect(Directory('${root.path}/Music/Paattufy/Empty').existsSync(), isFalse);
      expect(rescans, 0);
    });

    test('re-downloading an album never overwrites existing tracks', () async {
      final zip = makeZip({'t.mp3': bytesOf(40, seed: 9)});
      http.handler = (o) => FakeResponse.bytes(zip, headers: {
            Headers.contentTypeHeader: ['application/zip'],
            'content-disposition': ['attachment; filename="Alb.zip"'],
          });
      final a = await mgr.enqueueFile(siteId: 's', title: 'Alb', url: 'https://x.example/1.zip');
      await waitFor(a, {DownloadStatus.done});
      final b = await mgr.enqueueFile(siteId: 's', title: 'Alb', url: 'https://x.example/2.zip');
      await waitFor(b, {DownloadStatus.done});
      final names = Directory('${root.path}/Music/Paattufy/Alb').listSync().map((e) => e.path.split('/').last).toSet();
      expect(names, {'t.mp3', 't (1).mp3'});
    });
  });

  group('listing-mode album + expiring links (TP §5.9.2)', () {
    test('the album page is fetched right before the download and the zip320 link is used', () async {
      final zip = makeZip({'1.mp3': bytesOf(80), '2.mp3': bytesOf(80, seed: 2)});
      http.handler = (o) {
        expect(albumFetches, isNotEmpty, reason: 'page fetched before any transfer');
        return FakeResponse.bytes(zip, headers: {Headers.contentTypeHeader: ['application/zip']});
      };
      final id = await mgr.enqueueAlbum(masstamilan, item);
      final r = await waitFor(id, {DownloadStatus.done, DownloadStatus.failed});
      expect(r.status, DownloadStatus.done, reason: r.error);
      expect(http.requests.single.uri.toString(), 'https://www.masstamilan.dev/downloader/tokA/1790000000/zip320/4421');
      expect(r.itemsAdded, 2);
      expect(Directory('${root.path}/Music/Paattufy/Jailer 2 (2026)').existsSync(), isTrue);
    });

    test('an expired link triggers ONE transparent re-fetch + retry', () async {
      final zip = makeZip({'1.mp3': bytesOf(80)});
      http.handler = (o) {
        if (o.uri.path.contains('/tokA/')) {
          return const FakeResponse('<html>link expired</html>', headers: {
            Headers.contentTypeHeader: ['text/html'],
          });
        }
        return FakeResponse.bytes(zip, headers: {Headers.contentTypeHeader: ['application/zip']});
      };
      // The site hands out a new token each time the page is loaded.
      final tokens = ['tokA', 'tokB'];
      mgr = DownloadManager(
        db: db,
        dio: fakeDio(http),
        settings: () => settings,
        tempDir: Directory('${root.path}/tmp'),
        indexFiles: (paths) async => indexed.add(paths),
        onLibraryChanged: () async => rescans++,
        fetchHtml: (url) async {
          albumFetches.add(url);
          return albumHtml(tokens.removeAt(0));
        },
      );
      final id = await mgr.enqueueAlbum(masstamilan, item);
      final r = await waitFor(id, {DownloadStatus.done, DownloadStatus.failed});
      expect(r.status, DownloadStatus.done, reason: r.error);
      expect(albumFetches, hasLength(2), reason: 'page re-fetched for the retry');
      expect(http.requests.map((q) => q.uri.path.split('/')[2]).toList(), ['tokA', 'tokB']);
    });

    test('a link that is still expired on the retry fails with a clear message', () async {
      http.handler = (o) => const FakeResponse('gone', status: 410);
      final id = await mgr.enqueueAlbum(masstamilan, item);
      final r = await waitFor(id, {DownloadStatus.done, DownloadStatus.failed});
      expect(r.status, DownloadStatus.failed);
      expect(r.error, contains('expired'));
      expect(albumFetches, hasLength(2), reason: 'exactly one retry, not a loop');
    });

    test('zip320 absent → falls back to zip128 from the same page', () async {
      http.handler = (o) => FakeResponse.bytes(makeZip({'1.mp3': bytesOf(30)}), headers: {Headers.contentTypeHeader: ['application/zip']});
      mgr = DownloadManager(
        db: db,
        dio: fakeDio(http),
        settings: () => settings,
        tempDir: Directory('${root.path}/tmp'),
        indexFiles: (paths) async {},
        onLibraryChanged: () async {},
        fetchHtml: (url) async => '<a href="/d/t/1/zip128/9">128</a>',
      );
      final id = await mgr.enqueueAlbum(masstamilan, item);
      await waitFor(id, {DownloadStatus.done, DownloadStatus.failed});
      expect(http.requests.single.uri.path, contains('zip128'));
    });

    test('a page without any zip link fails descriptively', () async {
      mgr = DownloadManager(
        db: db,
        dio: fakeDio(http),
        settings: () => settings,
        tempDir: Directory('${root.path}/tmp'),
        indexFiles: (paths) async {},
        onLibraryChanged: () async {},
        fetchHtml: (url) async => '<html>nothing here</html>',
      );
      final id = await mgr.enqueueAlbum(masstamilan, item);
      final r = await waitFor(id, {DownloadStatus.done, DownloadStatus.failed});
      expect(r.status, DownloadStatus.failed);
      expect(r.error, contains('No zip link'));
    });
  });

  group('resume / pause / cancel / retry', () {
    final full = bytesOf(10000, seed: 5);

    FakeResponse rangeAware(RequestOptions o, {int? failAfter}) {
      final range = o.headers['Range'] as String?;
      final headers = {
        Headers.contentTypeHeader: ['audio/mpeg'],
        'content-disposition': ['attachment; filename="big.mp3"'],
      };
      if (range != null) {
        final start = int.parse(RegExp(r'bytes=(\d+)-').firstMatch(range)!.group(1)!);
        return FakeResponse.bytes(Uint8List.sublistView(full, start), status: 206, headers: {
          ...headers,
          'content-range': ['bytes $start-${full.length - 1}/${full.length}'],
        });
      }
      return FakeResponse.bytes(full, failAfterBytes: failAfter, headers: {
        ...headers,
        Headers.contentLengthHeader: ['${full.length}'],
      });
    }

    test('a dropped connection keeps the partial file and Resume continues with Range',
        () async {
      http.handler = (o) => rangeAware(o, failAfter: 4000);
      final id = await mgr.enqueueFile(siteId: 's', title: 'big', url: 'https://x.example/big');
      var r = await waitFor(id, {DownloadStatus.failed, DownloadStatus.done});
      expect(r.status, DownloadStatus.failed);
      expect(File('${root.path}/tmp/dl_$id.part').lengthSync(), 4000);

      http.handler = (o) => rangeAware(o);
      await mgr.resume(id);
      r = await waitFor(id, {DownloadStatus.done, DownloadStatus.failed});
      expect(r.status, DownloadStatus.done, reason: r.error);
      expect(http.requests.last.headers['Range'], 'bytes=4000-');
      expect(File('${root.path}/Music/Paattufy/big.mp3').readAsBytesSync(), full, reason: 'byte-identical after resume');
    });

    test('server that ignores Range restarts from zero without corrupting the file', () async {
      http.handler = (o) => rangeAware(o, failAfter: 3000);
      final id = await mgr.enqueueFile(siteId: 's', title: 'big', url: 'https://x.example/big');
      await waitFor(id, {DownloadStatus.failed});
      http.handler = (o) => FakeResponse.bytes(full, headers: { // always 200, never 206
            Headers.contentTypeHeader: ['audio/mpeg'],
            'content-disposition': ['attachment; filename="big.mp3"'],
            Headers.contentLengthHeader: ['${full.length}'],
          });
      await mgr.resume(id);
      final r = await waitFor(id, {DownloadStatus.done, DownloadStatus.failed});
      expect(r.status, DownloadStatus.done, reason: r.error);
      expect(File('${root.path}/Music/Paattufy/big.mp3').readAsBytesSync(), full);
    });

    test('pause keeps the partial file; cancel discards it and leaves a retryable row', () async {
      final gate = Completer<void>();
      http.handler = (o) async {
        await gate.future;
        return rangeAware(o);
      };
      final id = await mgr.enqueueFile(siteId: 's', title: 'big', url: 'https://x.example/big');
      await waitFor(id, {DownloadStatus.running});
      // Pre-seed a partial to prove pause keeps it.
      Directory('${root.path}/tmp').createSync(recursive: true);
      File('${root.path}/tmp/dl_$id.part').writeAsBytesSync(full.sublist(0, 1234));
      await mgr.pause(id);
      gate.complete();
      var r = await waitFor(id, {DownloadStatus.paused});
      expect(r.status, DownloadStatus.paused);
      expect(File('${root.path}/tmp/dl_$id.part').existsSync(), isTrue);

      await mgr.resume(id);
      r = await waitFor(id, {DownloadStatus.done, DownloadStatus.failed});
      expect(r.status, DownloadStatus.done, reason: r.error);
      expect(File('${root.path}/Music/Paattufy/big.mp3').readAsBytesSync(), full);

      // cancel path
      final gate2 = Completer<void>();
      http.handler = (o) async {
        await gate2.future;
        return rangeAware(o);
      };
      final id2 = await mgr.enqueueFile(siteId: 's', title: 'other', url: 'https://x.example/other');
      await waitFor(id2, {DownloadStatus.running});
      await mgr.cancel(id2);
      gate2.complete();
      r = await waitFor(id2, {DownloadStatus.failed});
      expect(r.error, 'Cancelled');
      expect(File('${root.path}/tmp/dl_$id2.part').existsSync(), isFalse);

      http.handler = (o) => rangeAware(o);
      await mgr.retry(id2);
      r = await waitFor(id2, {DownloadStatus.done, DownloadStatus.failed});
      expect(r.status, DownloadStatus.done, reason: r.error);
    });

    test('recover(): rows left "running" by a killed process become resumable', () async {
      final id = await mgr.enqueueFile(siteId: 's', title: 't', url: 'https://x.example/t');
      await waitFor(id, {DownloadStatus.done, DownloadStatus.failed});
      await (db.update(db.downloadHistory)).write(const DownloadHistoryCompanion(status: Value(DownloadStatus.running)));
      await mgr.recover();
      expect((await mgr.byId(id))!.status, DownloadStatus.paused);
    });
  });

  group('policy', () {
    test('Wi-Fi only + metered network → waits instead of downloading', () async {
      settings = AppSettings(downloadFolderPath: '${root.path}/Music/Paattufy', downloadWifiOnly: true);
      metered = true;
      http.handler = (o) => FakeResponse.bytes(bytesOf(10), headers: {Headers.contentTypeHeader: ['audio/mpeg']});
      final id = await mgr.enqueueFile(siteId: 's', title: 't', url: 'https://x.example/a.mp3');
      final r = await waitFor(id, {DownloadStatus.paused, DownloadStatus.done});
      expect(r.status, DownloadStatus.paused);
      expect(r.error, contains('Wi-Fi'));
      expect(http.requests, isEmpty);

      metered = false;
      await mgr.resume(id);
      expect((await waitFor(id, {DownloadStatus.done, DownloadStatus.failed})).status, DownloadStatus.done);
    });

    test('at most maxConcurrent downloads run at once; the rest queue', () async {
      mgr = DownloadManager(
        db: db,
        dio: fakeDio(http),
        settings: () => settings,
        tempDir: Directory('${root.path}/tmp'),
        indexFiles: (paths) async {},
        onLibraryChanged: () async {},
        maxConcurrent: 1,
      );
      final gate = Completer<void>();
      http.handler = (o) async {
        await gate.future;
        return FakeResponse.bytes(bytesOf(10), headers: {
          Headers.contentTypeHeader: ['audio/mpeg'],
          'content-disposition': ['attachment; filename="${o.uri.pathSegments.last}.mp3"'],
        });
      };
      final a = await mgr.enqueueFile(siteId: 's', title: 'a', url: 'https://x.example/a');
      final b = await mgr.enqueueFile(siteId: 's', title: 'b', url: 'https://x.example/b');
      await waitFor(a, {DownloadStatus.running});
      expect((await mgr.byId(b))!.status, DownloadStatus.queued);
      gate.complete();
      await waitFor(a, {DownloadStatus.done});
      await waitFor(b, {DownloadStatus.done});
    });

    test('completed stream announces finished downloads (drives the toast)', () async {
      http.handler = (o) => FakeResponse.bytes(bytesOf(10), headers: {Headers.contentTypeHeader: ['audio/mpeg']});
      final future = mgr.completed.first;
      final id = await mgr.enqueueFile(siteId: 's', title: 't', url: 'https://x.example/t.mp3');
      final done = await future.timeout(const Duration(seconds: 5));
      expect(done.id, id);
      expect(done.itemsAdded, 1);
    });
  });
}
