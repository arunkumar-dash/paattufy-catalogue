import '../../../core/remote/remote_catalogue.dart';
import 'declarative_provider.dart';

/// The lyrics-provider catalogue: the built-in LRCLIB default merged with
/// whatever the remote `lyrics-providers.json` declares (AP §3.7). A remote
/// entry with the same `id` overrides the built-in one.
class LyricsCatalogue {
  LyricsCatalogue(this._remote);
  final RemoteCatalogue _remote;

  static const supportedSchema = 1;

  Future<List<ProviderSpec>> providers(
    String url, {
    bool force = false,
    Duration maxAge = const Duration(hours: 24),
  }) async {
    final result = await _remote.get(RemoteCatalogue.lyricsKey, url, force: force, maxAge: maxAge);
    return mergeProviders(result.json);
  }

  /// Pure merge step, unit-tested: built-in first, remote entries appended or
  /// overriding by id; malformed entries and unsupported schemas are ignored.
  static List<ProviderSpec> mergeProviders(Map<String, Object?>? json) {
    final merged = <String, ProviderSpec>{ProviderSpec.lrclib.id: ProviderSpec.lrclib};
    if (json != null && (json['schemaVersion'] as num?)?.toInt() == supportedSchema) {
      for (final entry in (json['providers'] as List? ?? const [])) {
        final spec = ProviderSpec.fromJson(entry);
        if (spec != null) merged[spec.id] = spec;
      }
    }
    return merged.values.toList();
  }
}
