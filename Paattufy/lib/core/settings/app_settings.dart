import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';

enum SuggestionMode { mood, metadata }

/// Immutable snapshot of every scalar setting (TP §4.2). Persisted flat in
/// SharedPreferences.
@immutable
class AppSettings {
  const AppSettings({
    this.themeSeedColor = 0xFF8B3DFF,
    this.themeMode = ThemeMode.dark,
    this.dynamicArtworkColor = false,
    this.launcherIconVariant = 0,
    this.suggestionMode = SuggestionMode.mood,
    this.defaultSpeed = 1.0,
    this.preservePitch = false,
    this.skipBackWindowMs = defaultSkipBackWindowMs,
    this.downloadFolderPath = '/storage/emulated/0/Music/Paattufy',
    this.lyricsProviderOrder = const [],
    this.disabledLyricsProviders = const [],
    this.tryNextLyricsProvider = true,
    this.autoFetchLyrics = true,
    this.volumeNormalisation = false,
    this.skipSilence = false,
    this.crossfade = false,
    this.resumeOnLaunch = true,
    this.widgetStyle = 'spotify',
    this.onboardingComplete = false,
    this.downloadCatalogueUrl = defaultDownloadCatalogueUrl,
    this.lyricsCatalogueUrl = defaultLyricsCatalogueUrl,
    this.catalogueRefreshHours = 24,
    this.downloadWifiOnly = false,
    this.ignoreShortClipsSec = 10,
    this.visualizerEnabled = false,
    this.visualizerStyle = 0,
    this.lastScanAt = 0,
  });

  final int themeSeedColor;
  final ThemeMode themeMode;
  final bool dynamicArtworkColor;
  final int launcherIconVariant;
  final SuggestionMode suggestionMode;
  final double defaultSpeed;
  final bool preservePitch;
  final int skipBackWindowMs;
  final String downloadFolderPath;
  final List<String> lyricsProviderOrder;
  final List<String> disabledLyricsProviders;
  final bool tryNextLyricsProvider;
  final bool autoFetchLyrics;
  final bool volumeNormalisation;
  final bool skipSilence;
  final bool crossfade;
  final bool resumeOnLaunch;
  final String widgetStyle;
  final bool onboardingComplete;
  final String downloadCatalogueUrl;
  final String lyricsCatalogueUrl;
  final int catalogueRefreshHours;
  final bool downloadWifiOnly;
  final int ignoreShortClipsSec;
  final bool visualizerEnabled;
  final int visualizerStyle;

  /// Epoch seconds of the last completed scan (incremental-scan watermark).
  final int lastScanAt;

  AppSettings copyWith({
    int? themeSeedColor,
    ThemeMode? themeMode,
    bool? dynamicArtworkColor,
    int? launcherIconVariant,
    SuggestionMode? suggestionMode,
    double? defaultSpeed,
    bool? preservePitch,
    int? skipBackWindowMs,
    String? downloadFolderPath,
    List<String>? lyricsProviderOrder,
    List<String>? disabledLyricsProviders,
    bool? tryNextLyricsProvider,
    bool? autoFetchLyrics,
    bool? volumeNormalisation,
    bool? skipSilence,
    bool? crossfade,
    bool? resumeOnLaunch,
    String? widgetStyle,
    bool? onboardingComplete,
    String? downloadCatalogueUrl,
    String? lyricsCatalogueUrl,
    int? catalogueRefreshHours,
    bool? downloadWifiOnly,
    int? ignoreShortClipsSec,
    bool? visualizerEnabled,
    int? visualizerStyle,
    int? lastScanAt,
  }) {
    return AppSettings(
      themeSeedColor: themeSeedColor ?? this.themeSeedColor,
      themeMode: themeMode ?? this.themeMode,
      dynamicArtworkColor: dynamicArtworkColor ?? this.dynamicArtworkColor,
      launcherIconVariant: launcherIconVariant ?? this.launcherIconVariant,
      suggestionMode: suggestionMode ?? this.suggestionMode,
      defaultSpeed: defaultSpeed ?? this.defaultSpeed,
      preservePitch: preservePitch ?? this.preservePitch,
      skipBackWindowMs: skipBackWindowMs ?? this.skipBackWindowMs,
      downloadFolderPath: downloadFolderPath ?? this.downloadFolderPath,
      lyricsProviderOrder: lyricsProviderOrder ?? this.lyricsProviderOrder,
      disabledLyricsProviders:
          disabledLyricsProviders ?? this.disabledLyricsProviders,
      tryNextLyricsProvider:
          tryNextLyricsProvider ?? this.tryNextLyricsProvider,
      autoFetchLyrics: autoFetchLyrics ?? this.autoFetchLyrics,
      volumeNormalisation: volumeNormalisation ?? this.volumeNormalisation,
      skipSilence: skipSilence ?? this.skipSilence,
      crossfade: crossfade ?? this.crossfade,
      resumeOnLaunch: resumeOnLaunch ?? this.resumeOnLaunch,
      widgetStyle: widgetStyle ?? this.widgetStyle,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      downloadCatalogueUrl: downloadCatalogueUrl ?? this.downloadCatalogueUrl,
      lyricsCatalogueUrl: lyricsCatalogueUrl ?? this.lyricsCatalogueUrl,
      catalogueRefreshHours:
          catalogueRefreshHours ?? this.catalogueRefreshHours,
      downloadWifiOnly: downloadWifiOnly ?? this.downloadWifiOnly,
      ignoreShortClipsSec: ignoreShortClipsSec ?? this.ignoreShortClipsSec,
      visualizerEnabled: visualizerEnabled ?? this.visualizerEnabled,
      visualizerStyle: visualizerStyle ?? this.visualizerStyle,
      lastScanAt: lastScanAt ?? this.lastScanAt,
    );
  }

  static AppSettings load(SharedPreferences p) {
    const d = AppSettings();
    return AppSettings(
      themeSeedColor: p.getInt('theme_seed_color') ?? d.themeSeedColor,
      themeMode: _enumByName(ThemeMode.values, p.getString('theme_mode')) ??
          d.themeMode,
      dynamicArtworkColor:
          p.getBool('dynamic_artwork_color') ?? d.dynamicArtworkColor,
      launcherIconVariant:
          p.getInt('launcher_icon_variant') ?? d.launcherIconVariant,
      suggestionMode: _enumByName(
              SuggestionMode.values, p.getString('suggestion_mode')) ??
          d.suggestionMode,
      defaultSpeed: p.getDouble('default_speed') ?? d.defaultSpeed,
      preservePitch: p.getBool('preserve_pitch') ?? d.preservePitch,
      skipBackWindowMs:
          p.getInt('skip_back_window_ms') ?? d.skipBackWindowMs,
      downloadFolderPath:
          p.getString('download_folder_path') ?? d.downloadFolderPath,
      lyricsProviderOrder:
          p.getStringList('lyrics_provider_order') ?? d.lyricsProviderOrder,
      disabledLyricsProviders: p.getStringList('lyrics_providers_disabled') ??
          d.disabledLyricsProviders,
      tryNextLyricsProvider:
          p.getBool('lyrics_try_next') ?? d.tryNextLyricsProvider,
      autoFetchLyrics: p.getBool('lyrics_auto_fetch') ?? d.autoFetchLyrics,
      volumeNormalisation:
          p.getBool('volume_normalisation_enabled') ?? d.volumeNormalisation,
      skipSilence: p.getBool('skip_silence_enabled') ?? d.skipSilence,
      crossfade: p.getBool('crossfade_enabled') ?? d.crossfade,
      resumeOnLaunch: p.getBool('resume_on_launch') ?? d.resumeOnLaunch,
      widgetStyle: p.getString('widget_style') ?? d.widgetStyle,
      onboardingComplete:
          p.getBool('onboarding_complete') ?? d.onboardingComplete,
      downloadCatalogueUrl:
          p.getString('download_catalogue_url') ?? d.downloadCatalogueUrl,
      lyricsCatalogueUrl:
          p.getString('lyrics_catalogue_url') ?? d.lyricsCatalogueUrl,
      catalogueRefreshHours:
          p.getInt('catalogue_refresh_hours') ?? d.catalogueRefreshHours,
      downloadWifiOnly: p.getBool('download_wifi_only') ?? d.downloadWifiOnly,
      ignoreShortClipsSec:
          p.getInt('ignore_short_clips_sec') ?? d.ignoreShortClipsSec,
      visualizerEnabled:
          p.getBool('visualizer_enabled') ?? d.visualizerEnabled,
      visualizerStyle: p.getInt('visualizer_style') ?? d.visualizerStyle,
      lastScanAt: p.getInt('last_scan_at') ?? d.lastScanAt,
    );
  }

  Future<void> save(SharedPreferences p) async {
    await Future.wait([
      p.setInt('theme_seed_color', themeSeedColor),
      p.setString('theme_mode', themeMode.name),
      p.setBool('dynamic_artwork_color', dynamicArtworkColor),
      p.setInt('launcher_icon_variant', launcherIconVariant),
      p.setString('suggestion_mode', suggestionMode.name),
      p.setDouble('default_speed', defaultSpeed),
      p.setBool('preserve_pitch', preservePitch),
      p.setInt('skip_back_window_ms', skipBackWindowMs),
      p.setString('download_folder_path', downloadFolderPath),
      p.setStringList('lyrics_provider_order', lyricsProviderOrder),
      p.setStringList('lyrics_providers_disabled', disabledLyricsProviders),
      p.setBool('lyrics_try_next', tryNextLyricsProvider),
      p.setBool('lyrics_auto_fetch', autoFetchLyrics),
      p.setBool('volume_normalisation_enabled', volumeNormalisation),
      p.setBool('skip_silence_enabled', skipSilence),
      p.setBool('crossfade_enabled', crossfade),
      p.setBool('resume_on_launch', resumeOnLaunch),
      p.setString('widget_style', widgetStyle),
      p.setBool('onboarding_complete', onboardingComplete),
      p.setString('download_catalogue_url', downloadCatalogueUrl),
      p.setString('lyrics_catalogue_url', lyricsCatalogueUrl),
      p.setInt('catalogue_refresh_hours', catalogueRefreshHours),
      p.setBool('download_wifi_only', downloadWifiOnly),
      p.setInt('ignore_short_clips_sec', ignoreShortClipsSec),
      p.setBool('visualizer_enabled', visualizerEnabled),
      p.setInt('visualizer_style', visualizerStyle),
      p.setInt('last_scan_at', lastScanAt),
    ]);
  }

  /// JSON form used by backup/restore (Phase 9).
  Map<String, Object?> toJson() => {
        'themeSeedColor': themeSeedColor,
        'themeMode': themeMode.name,
        'dynamicArtworkColor': dynamicArtworkColor,
        'launcherIconVariant': launcherIconVariant,
        'suggestionMode': suggestionMode.name,
        'defaultSpeed': defaultSpeed,
        'preservePitch': preservePitch,
        'skipBackWindowMs': skipBackWindowMs,
        'downloadFolderPath': downloadFolderPath,
        'lyricsProviderOrder': lyricsProviderOrder,
        'disabledLyricsProviders': disabledLyricsProviders,
        'tryNextLyricsProvider': tryNextLyricsProvider,
        'autoFetchLyrics': autoFetchLyrics,
        'volumeNormalisation': volumeNormalisation,
        'skipSilence': skipSilence,
        'crossfade': crossfade,
        'resumeOnLaunch': resumeOnLaunch,
        'widgetStyle': widgetStyle,
        'downloadCatalogueUrl': downloadCatalogueUrl,
        'lyricsCatalogueUrl': lyricsCatalogueUrl,
        'catalogueRefreshHours': catalogueRefreshHours,
        'downloadWifiOnly': downloadWifiOnly,
        'ignoreShortClipsSec': ignoreShortClipsSec,
        'visualizerEnabled': visualizerEnabled,
        'visualizerStyle': visualizerStyle,
      };

  AppSettings mergeJson(Map<String, Object?> j) {
    T? pick<T>(String k) => j[k] is T ? j[k] as T : null;
    return copyWith(
      themeSeedColor: pick<int>('themeSeedColor'),
      themeMode: _enumByName(ThemeMode.values, pick<String>('themeMode')),
      dynamicArtworkColor: pick<bool>('dynamicArtworkColor'),
      launcherIconVariant: pick<int>('launcherIconVariant'),
      suggestionMode:
          _enumByName(SuggestionMode.values, pick<String>('suggestionMode')),
      defaultSpeed: pick<num>('defaultSpeed')?.toDouble(),
      preservePitch: pick<bool>('preservePitch'),
      skipBackWindowMs: pick<int>('skipBackWindowMs'),
      downloadFolderPath: pick<String>('downloadFolderPath'),
      lyricsProviderOrder:
          (j['lyricsProviderOrder'] as List?)?.whereType<String>().toList(),
      disabledLyricsProviders:
          (j['disabledLyricsProviders'] as List?)?.whereType<String>().toList(),
      tryNextLyricsProvider: pick<bool>('tryNextLyricsProvider'),
      autoFetchLyrics: pick<bool>('autoFetchLyrics'),
      volumeNormalisation: pick<bool>('volumeNormalisation'),
      skipSilence: pick<bool>('skipSilence'),
      crossfade: pick<bool>('crossfade'),
      resumeOnLaunch: pick<bool>('resumeOnLaunch'),
      widgetStyle: pick<String>('widgetStyle'),
      downloadCatalogueUrl: pick<String>('downloadCatalogueUrl'),
      lyricsCatalogueUrl: pick<String>('lyricsCatalogueUrl'),
      catalogueRefreshHours: pick<int>('catalogueRefreshHours'),
      downloadWifiOnly: pick<bool>('downloadWifiOnly'),
      ignoreShortClipsSec: pick<int>('ignoreShortClipsSec'),
      visualizerEnabled: pick<bool>('visualizerEnabled'),
      visualizerStyle: pick<int>('visualizerStyle'),
    );
  }
}

T? _enumByName<T extends Enum>(List<T> values, String? name) {
  if (name == null) return null;
  for (final v in values) {
    if (v.name == name) return v;
  }
  return null;
}

/// Overridden in `main()` with the real instance (and in tests with
/// `SharedPreferences.setMockInitialValues`).
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPreferencesProvider not overridden'),
);

class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() => AppSettings.load(ref.watch(sharedPreferencesProvider));

  Future<void> update(AppSettings Function(AppSettings s) change) async {
    state = change(state);
    await state.save(ref.read(sharedPreferencesProvider));
  }
}

final settingsProvider =
    NotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);
