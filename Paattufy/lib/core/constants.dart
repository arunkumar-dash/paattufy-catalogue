/// App-wide constants. Anything the user may want to change lives in
/// settings instead (AP §2, "Nothing is hardcoded that might change").
const String appName = 'Paattufy';
const String appUserAgent = 'Paattufy/1.0 (personal-use build)';

/// Default location of the versioned GitHub catalogue (TP §7). Both URLs are
/// editable in Settings; these are only the first-run defaults.
const String defaultCatalogueBase =
    'https://raw.githubusercontent.com/arunkumar-dash/paattufy-catalogue/main/v1';
const String defaultDownloadCatalogueUrl =
    '$defaultCatalogueBase/download-catalogue.json';
const String defaultLyricsCatalogueUrl =
    '$defaultCatalogueBase/lyrics-providers.json';

/// Speed steps (AP §3.5, §11.13).
const List<double> speedSteps = [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0];

/// Skip-back restarts the current song when further than this into it.
const int defaultSkipBackWindowMs = 3000;

/// Suggestion top-up target (AP §3.4).
const int queueTopUpTarget = 10;
