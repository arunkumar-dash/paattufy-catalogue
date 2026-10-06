import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants.dart';
import '../remote/remote_catalogue.dart';
import 'core_providers.dart';

/// One shared Dio with sane timeouts and the descriptive User-Agent.
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 30),
    headers: {'User-Agent': appUserAgent},
  ));
  ref.onDispose(dio.close);
  return dio;
});

final remoteCatalogueProvider = Provider<RemoteCatalogue>(
  (ref) => RemoteCatalogue(ref.watch(databaseProvider), ref.watch(dioProvider)),
);
