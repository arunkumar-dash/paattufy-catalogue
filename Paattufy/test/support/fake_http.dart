import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

class RecordedRequest {
  RecordedRequest(this.method, this.uri, this.headers);
  final String method;
  final Uri uri;
  final Map<String, dynamic> headers;
}

typedef FakeHandler = FutureOr<FakeResponse?> Function(RequestOptions options);

class FakeResponse {
  const FakeResponse(this.body, {this.status = 200, this.headers = const {}})
      : bytes = null,
        failAfterBytes = null;
  const FakeResponse.bytes(Uint8List this.bytes,
      {this.status = 200, this.headers = const {}, this.failAfterBytes})
      : body = '';
  final String body;
  final Uint8List? bytes;

  /// Emit this many bytes then throw, simulating a dropped connection.
  final int? failAfterBytes;
  final int status;
  final Map<String, List<String>> headers;

  static FakeResponse json(Object data, {int status = 200, Map<String, List<String>> headers = const {}}) =>
      FakeResponse(jsonEncode(data), status: status, headers: {
        Headers.contentTypeHeader: ['application/json'],
        ...headers,
      });
}

/// Dio adapter that answers from a handler; returning null = connection error.
class FakeHttpAdapter implements HttpClientAdapter {
  FakeHttpAdapter(this.handler);
  FakeHandler handler;
  final List<RecordedRequest> requests = [];

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    requests.add(RecordedRequest(options.method, options.uri, Map.of(options.headers)));
    final r = await handler(options);
    if (r == null) {
      throw DioException.connectionError(requestOptions: options, reason: 'offline');
    }
    final data = r.bytes;
    if (data != null) {
      final cut = r.failAfterBytes;
      final stream = cut == null
          ? Stream<Uint8List>.value(data)
          : (() async* {
              yield Uint8List.sublistView(data, 0, cut);
              throw DioException.connectionError(requestOptions: options, reason: 'connection dropped');
            })();
      return ResponseBody(stream, r.status, headers: r.headers);
    }
    return ResponseBody.fromString(r.body, r.status, headers: r.headers);
  }

  @override
  void close({bool force = false}) {}
}

Dio fakeDio(FakeHttpAdapter adapter) => Dio()..httpClientAdapter = adapter;
