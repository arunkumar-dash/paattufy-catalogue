# Paattufy — Technical Plan (Architecture & Implementation)

> Stage 2 of 2. This document turns `01-abstract-plan.md` into concrete engineering decisions:
> packages, folder structure, data schemas, algorithms, platform integration, and the GitHub
> catalogue setup. Section numbers below are independent of the abstract plan; cross-references
> use `AP §x` to point back at it.

---

## 0. Toolchain & project identity

| Item | Decision |
| --- | --- |
| Framework | Flutter (upgraded to current stable via `flutter upgrade` — **AP §11.3**), Dart with null-safety. |
| Application ID | `com.paattufy.music` (**AP §11.1**). |
| `minSdkVersion` / `targetSdkVersion` / `compileSdkVersion` | All set to the API level for Android 16 (API level 36 at the time of writing — confirm the exact number against the Android SDK installed by `flutter upgrade`/Android Studio before locking `android/app/build.gradle`). Single-device personal build, so no lower bound is carried (**AP §11.2**). |
| Org for `flutter create` | Run `flutter create --org com.paattufy --project-name paattufy .` so `applicationId`/package namespaces derive from `com.paattufy`, never from the local machine account, satisfying **AP §9.1**. |
| State management | Riverpod (`flutter_riverpod` + code-gen `riverpod_annotation`/`riverpod_generator`). Chosen over Bloc for less boilerplate given the number of small, independent feature slices. |
| Persistence | Drift (SQLite) for all relational/query-heavy data; SharedPreferences for simple scalar settings flags. |
| Background audio | `audio_service` + `just_audio` + `audio_session` — the standard, actively-maintained Flutter stack for gapless, backgrounded, notification-integrated playback. |
| Dependency injection | Riverpod's own provider graph; no separate DI package needed. |

---

## 1. Architecture overview

Layered, feature-first structure:

```
presentation/   UI widgets, screens, Riverpod controllers (UI state only)
domain/         entities, repositories (interfaces), use-cases, pure business logic
data/           Drift DAOs, platform channels, HTTP clients, repository implementations
platform/       native Android bridge (Kotlin) for widgets, MediaStore scan, icon swap
```

Each domain concept in AP §3 gets its own feature module under `lib/features/<name>/` with its
own `presentation/`, `domain/`, `data/` subfolders, e.g. `features/queue/`, `features/groups/`,
`features/lyrics/`, `features/suggestions/`, `features/download_hub/`, `features/theme/`.

Cross-feature contracts (the Song entity, "play a group" use-case, etc.) live in `lib/core/`.

Riverpod providers are the seam between layers: a screen watches a provider exposed by the
feature's controller, which calls into domain use-cases, which call data repositories. No layer
reaches two levels down.

---

## 2. Package inventory

| Capability | Package(s) | Notes |
| --- | --- | --- |
| State management | flutter_riverpod, riverpod_annotation, riverpod_generator, build_runner | |
| Local DB | drift, drift_dev, sqlite3_flutter_libs, path_provider | |
| Simple prefs | shared_preferences | |
| Background audio | audio_service, just_audio, audio_session | just_audio handles decode/playback; audio_service owns the media session, notification, background isolate; audio_session negotiates focus/ducking and route info. |
| MediaStore scanning | Custom Kotlin MethodChannel (see §6.1) — not a third-party query package, for full control over incremental scans and folder-exclusion pushdown. | |
| Folder / file picking | file_picker (SAF-backed getDirectoryPath) | Onboarding storage step and Settings Library folder path. |
| Permissions | permission_handler | READ_MEDIA_AUDIO (Android 13+), notifications, Bluetooth connect. |
| In-app browser | webview_flutter (+ webview_flutter_android for the download-interception hook) | |
| Zip extraction | archive | Pure-Dart, no native deps. |
| HTML parsing (listing mode) | html (dart-lang HTML5 parser, querySelector/querySelectorAll) | |
| HTTP | dio | Chosen over plain http for interceptors (ETag caching, retry/backoff). |
| Home-screen widgets | home_widget (Flutter to native bridge) + a small native Kotlin AppWidgetProvider per size (see §6) | |
| Share/open-with | receive_sharing_intent + Android intent-filters in the manifest | |
| Tag editing | Platform channel around a tag read/write library covering MP3 ID3v2, FLAC Vorbis comment, MP4 atoms — evaluated at phase 9 for format coverage. | |
| Background scheduling | workmanager | Drives suggestion-engine audio analysis under charging/idle constraints. |
| On-device ML inference | tflite_flutter | Runs the bundled YAMNet .tflite model for audio embeddings. |
| FFT / DSP | fftea (pure-Dart FFT) | Tempo, key, energy, brightness features. |
| Theming | Built-in Material 3 ColorScheme.fromSeed — no extra package required. | |
| App icon (build-time default) | flutter_launcher_icons (dev dependency, initial adaptive icon only) | Runtime swap uses native activity-aliases, see §5.8. |
| Version/info | package_info_plus | Settings About. |
| Crash-safe journal | Drift itself (WAL mode) — no extra package; see §5.3. | |

---

## 3. Project folder structure

```
paattufy/
  android/                         Kotlin platform code under app/src/main/kotlin/...
  lib/
    core/
      entities/                    Song, Group, QueueItem, PlaybackState, LyricsRecord, ...
      database/                    Drift AppDatabase + tables (§4)
      theming/                     ColorScheme builders, seed presets
      utils/
    features/
      library/                     scan, songs/artists/albums/folders, sort, search, details
      groups/                      static + smart groups, rule engine, editor
      queue/                       deque, suggestion top-up wiring, crash-safe journal
      playback/                    audio_service handler, speed/pitch, repeat/shuffle, output device
      lyrics/                      provider abstraction, LRCLIB client, karaoke UI
      suggestions/                 feature extraction, ML embedding, scoring, background scheduler
      download_hub/                catalogue fetch, browse-mode webview, listing-mode parser, zip
      theme_icon/                  theme picker, launcher icon switcher
      widgets_integration/         home_widget glue code
      visualizer/                  Visualizer tap + CustomPainter renderers
      onboarding/
      settings/
    app.dart                       MaterialApp, routing, root shell (bottom nav + mini player)
    main.dart
  test/
    fixtures/                      generated tone files + fixture metadata (§8)
    unit/
    widget/
  integration_test/
  docs/
    01-abstract-plan.md
    02-technical-plan.md
```

---

## 4. Persistence layer

### 4.1 Drift schema

All tables live in one AppDatabase (single SQLite file), WAL journal mode enabled for
crash-safety.

- **songs** — id (PK, stable hash of media_store_id + file_path), media_store_id, title, artist,
  album, album_artist, genre, year, track_number, duration_ms, file_path, content_uri,
  folder_path, date_added, date_modified, size_bytes, bitrate, sample_rate, format,
  embedded_lrc_path (nullable), last_seen_scan_at. Indexes on artist, album, album_artist, genre,
  year, date_added, folder_path.
- **excluded_folders** — id, folder_path (unique). Checked at scan time (native side, for speed)
  and re-checked in Dart when building library queries, as a safety net.
- **groups** — id, name, type (static/smart), cover_uri, default_sort, default_play_mode,
  match_mode (all/any, smart only), is_builtin, created_at, updated_at.
- **group_conditions** — id, group_id (FK), field, operator, value_json, position.
- **group_static_items** — group_id (FK), song_id (FK), position — ordered membership for static
  groups.
- **group_refs** — group_id (FK), ref_group_id (FK), kind (include/exclude) — the
  include/exclude-other-groups rule (AP §3.3).
- **group_overrides** — group_id (FK), song_id (FK), kind (pin/exclude) — manual overrides on top
  of smart-group rules (AP §11.19).
- **queue_items** — id, sequence (REAL, sparse — see §5.3 for why), song_id (FK), source
  (manual/suggested), added_at. A separate **queue_pointer** singleton table (current_item_id,
  source_description) tracks "now playing".
- **playback_state** — singleton row: position_ms, is_playing, speed, preserve_pitch,
  repeat_mode, shuffle_enabled, output_route, updated_at. Written throttled (at most once per
  second) plus immediately on pause/stop/app-background, per AP §3.5.
- **play_stats** — song_id (PK/FK), play_count, skip_count, last_played_at, favourite (bool) —
  backs Favourites/Recently played/Most played built-ins (AP §3.3, §11.18).
- **lyrics_cache** — song_id (PK/FK), provider_id, synced_lrc, plain_text, source
  (embedded/remote), offset_ms, fetched_at.
- **song_audio_features** — song_id (PK/FK), tempo_bpm, key_index, key_mode, energy,
  acousticness, brightness, danceability, embedding_blob (packed Float32List), model_version,
  analyzed_at. Absence of a row means "not yet analysed" so Metadata-mode fallback applies
  automatically (AP §3.7a).
- **remote_catalogue_cache** — key (download_catalogue/lyrics_providers), json_blob, etag,
  fetched_at.
- **download_history** — id, site_id, title, source_url, local_path, status
  (queued/running/paused/done/failed), bytes_total, bytes_done, started_at, completed_at.

### 4.2 SharedPreferences keys (flat, no schema needed)

theme_seed_color, theme_mode, launcher_icon_variant, suggestion_mode (mood/metadata),
default_speed, skip_back_window_ms, download_folder_path, lyrics_provider_order,
volume_normalisation_enabled, skip_silence_enabled, widget_style, onboarding_complete.

---

## 5. Domain modules

### 5.1 Library & scanning (AP §3.1–3.2, §5.2–5.3)

- **Scan transport**: a custom Kotlin MethodChannel (paattufy/media_store) queries
  MediaStore.Audio.Media via ContentResolver directly — not a third-party plugin — because we
  need (a) selection pushdown for excluded folders (RELATIVE_PATH NOT LIKE per excluded prefix)
  and (b) an incremental mode (DATE_MODIFIED greater than watermark) driven by the Dart side's
  last_seen_scan_at value. Returns a list of maps; Dart maps them into songs rows (upsert by
  media_store_id).
- **Full scan**: onboarding and manual "Rescan now". **Incremental scan**: on app resume and
  after a download-hub extraction, using the watermark.
- **Folder exclusion**: excluded_folders table drives both the native selection args and a
  client-side NOT LIKE filter in every Drift query as a safety net (covers races where a folder is
  excluded after a scan already ran).
- **Details / file path copy**: Details sheet reads file_path directly from the songs row; copy
  action uses Clipboard.setData (AP §11.7).
- **Read-only guarantee**: no code path calls ContentResolver.delete or File.delete — enforced by
  simply never wiring a delete use-case (AP §11.8).

### 5.2 Groups & smart rule engine (AP §3.3, §5.4)

Rule set stored as the group_conditions + group_refs + group_overrides rows described in §4.1,
conceptually equivalent to this JSON (used only for import/export and live-preview diffing, not as
the source of truth):

```json
{
  "matchMode": "all",
  "conditions": [
    {"field": "artist", "operator": "equals", "value": "Ilaiyaraaja"},
    {"field": "year", "operator": "between", "value": [1980, 1989]}
  ],
  "excludeGroupIds": ["group_sad_songs"]
}
```

**Compiler**: the rule tree is compiled into a Drift boolean Expression tree (and/or, equals,
isBetweenValues, like, date-math), executed as a single SELECT over songs joined against the
exclude/include group member sets (computed as sub-selects). Final membership:

```
finalSet = (conditionMatches + includeGroupMembers + manualPins) - excludeGroupMembers - manualExcludes
```

**Live preview**: rule edits debounce 300 ms, then re-run the compiled query against the real
on-device SQLite (fast enough at personal-library scale with the indexes from §4.1); footer shows
"Matches N songs" and a peek limited to 20 rows.

**Built-in groups** (is_builtin = true, hidden not deletable): Favourites (play_stats.favourite),
Recently added (date_added last 30 days, configurable), Recently played / Most played
(play_stats.last_played_at / play_count ordering) — AP §11.18.

### 5.3 Queue (deque) (AP §3.4)

- **Data structure**: queue_items ordered by a sequence REAL column using the classic
  insert-in-the-gap trick (a new item's sequence is the midpoint of its neighbours) so reordering
  and play-next/add-to-queue never require renumbering the whole table; a periodic compaction job
  renumbers if gaps get too small (float precision floor).
- **Verbs** map directly to AP §3.4's table: playSingle (clear + insert one), playGroup (clear +
  bulk insert in the group's order), playNext (sequence = midpoint of current and next),
  addToQueue (sequence = max + 1000), skipForward/skipBack (pointer move; skip-back applies the
  ~3 s-restart rule client-side against playback_state.position_ms), reorder (drag updates
  sequence).
- **Suggestion top-up**: a Riverpod listener watches the count of items after the pointer; when
  it drops below 10, it calls into the suggestion engine (§5.7) for the remainder, tagged
  source = suggested.
- **Crash-safe journal**: every mutation is a Drift transaction against queue_items (already
  durable via WAL) — there is no separate in-memory queue that could diverge, so an abrupt kill
  loses nothing (AP §8.16). On relaunch, the queue is simply re-read from the table.

### 5.4 Playback session & audio engine (AP §3.5)

- audio_service's BaseAudioHandler wraps a just_audio AudioPlayer (or ConcatenatingAudioSource for
  gapless queue playback). audio_session configures the media-playback audio attributes and
  handles focus/ducking.
- **Speed**: stepped values from AP §11.13; just_audio's setSpeed plus setPitch — when "preserve
  pitch" is off (default), pitch drifts naturally with speed (cheapest); when on, pitch is
  explicitly reset to 1.0 via the player's pitch-shifting path (small CPU cost, as flagged in the
  abstract plan).
- **Repeat/shuffle**: LoopMode off/all/one maps to off/repeat-queue/repeat-one; repeat-one loops
  the single current item only, per AP §11.12.
- **Persistence**: playback_state row updated on a 1 s throttle plus immediately on
  pause/stop/backgrounding; restored on cold start before the first frame (a splash gate).

### 5.5 Output device awareness (AP §3.6)

- Register an AudioDeviceCallback (native) / use audio_session's device-change notifications to
  detect route changes (wired plug/unplug, A2DP connect/disconnect, explicit speaker to Bluetooth
  switch).
- On any change: call handler.stop() (not pause), leave queue_items and
  playback_state.position_ms untouched, per AP §11.9-11.10. The now-playing UI shows a "Resume"
  affordance that just calls play() again from the preserved position.
- Bluetooth device display name: BluetoothAdapter/BluetoothDevice.getName() via a thin native
  channel, surfaced in the output-device chip.

---

### 5.6 Lyrics (AP §3.7)

- **LyricsProvider** domain interface: search(query) returning candidates, and
  fetchBest(title, artist, album, durationSec) returning the best signature match.
- **Built-in LrclibProvider**: calls GET https://lrclib.net/api/get (signature match) falling
  back to GET /api/search for the multi-candidate picker, per the confirmed API (AP §11.16, schema
  in §7.2). Sets a descriptive User-Agent header (Paattufy/version, personal-use build) per
  LRCLIB's implementation requirements, and throttles sequential requests by 200-300 ms during any
  batch (e.g. pre-fetching for a whole group).
- **Remote-catalogue-declared providers**: a generic DeclarativeLyricsProvider interprets a
  catalogue entry's search/fetch request templates and response field mappings (schema in §7.2) —
  no new Dart class needed per provider.
- **Resolution order** (AP §11.17): check songs.embedded_lrc_path / sidecar .lrc first; only call
  remote providers if nothing local exists. Remote pick is cached forever in lyrics_cache.
- **Offset**: lyrics_cache.offset_ms, adjusted plus or minus 200 ms from the lyrics screen,
  applied at render time only (never mutates the cached LRC text).

### 5.7 Suggestion engine (AP §3.7a, §11.14-15)

**Feature pipeline** (runs once per song, in a background isolate, only while charging/idle —
scheduled via workmanager):

1. Decode the file to mono PCM at 22050 Hz (via just_audio's platform decode path or a small
   native MediaExtractor/MediaCodec helper if a lower-level tap is needed) for analysis only —
   playback always stays bit-perfect (AP §2, "Local media is the source of truth").
2. **Heuristic scalar features** via fftea-based STFT:
   - Tempo/rhythm: spectral-flux onset envelope, then autocorrelation over a plausible 60-180 BPM
     lag range; peak lag equals BPM.
   - Key/tonality: 12-bin chroma vector correlated against Krumhansl-Schmuckler major/minor key
     profiles; best-fit key plus mode.
   - Energy: RMS level, normalised.
   - Brightness: spectral centroid, averaged over the track.
   - Danceability: sharpness/regularity of the onset-envelope autocorrelation peak (same
     autocorrelation as tempo, reused).
   - Acousticness: proxy via harmonic-versus-percussive energy ratio (median-filtering
     separation).
3. **ML embedding**: run YAMNet (pretrained, Apache-2.0, about 4 MB .tflite, bundled as a Flutter
   asset) via tflite_flutter over about 1 s frames sampled across the track (start/middle/end to
   keep inference cheap); average the 1024-d frame embeddings into one per-song embedding, then
   project to 64 dims with a small fixed random/PCA projection matrix (bundled as a constant
   asset) for cheap storage/comparison.
4. Concatenate tempo, key (one-hot 24), energy, acousticness, brightness, danceability, embedding
   (64) into one vector, normalise, and store as song_audio_features.embedding_blob (packed
   Float32List bytes) plus the individual scalar columns for Metadata-mode tie-breaks.

**Scoring** (both modes share): already-queued songs are a hard reject; recently-played songs get
a multiplicative penalty of max(0.2, 1 - exp(-hoursSincePlayed / 24)).

- **Mood mode**: taste centroid equals the mean feature vector of all songs currently in the
  queue; candidate score equals cosine similarity to the centroid times the recency penalty, with
  a small additive bonus for a same-language or same-artist tag match (a tie-breaker, not the
  primary driver — the vector does the heavy lifting, matching the "same mood is what matters"
  intent from AP §11.14).
- **Metadata mode**: cascading rule match exactly as specified in AP §3.7a (artist, album,
  album-artist, year window, genre, folder, most-played), same penalty terms.
- Candidate pool is always the whole library (AP §11.15); songs with no song_audio_features row
  automatically fall back to Metadata-mode scoring for that candidate even while the overall
  setting is Mood mode.

**Scheduler**: workmanager periodic and one-off tasks constrained to requiresCharging or
requiresDeviceIdle, batch size capped (for example 5 songs per wake), never runs while
playback_state.is_playing is true on battery.

### 5.8 Theme & icon personalisation (AP §3.7b, §7)

- **Theme**: ColorScheme.fromSeed(seedColor, brightness) per Material 3; seed colour presets
  (including the default electric purple) stored as a constant list plus a custom colour picker
  feeding theme_seed_color in SharedPreferences. Optional Now-Playing artwork tint uses
  ColorScheme.fromImageProvider (Flutter's palette generator) scoped to that screen only.
- **Launcher icon runtime swap**: Android does not let an app change its actual icon bitmap at
  runtime; the standard trick (used by Spotify-style "choose your icon" features) is to ship N
  activity-alias entries in the manifest, each pointing at the main launcher activity with a
  different android:icon, all but one android:enabled=false at install time. Switching icons
  means calling PackageManager.setComponentEnabledSetting() to disable the old alias and enable
  the new one, from a small native channel (paattufy/icon_switch). The launcher (and sometimes the
  device) may take a moment to refresh the icon — documented as an OS-level quirk in the Settings
  screen's help text, not a bug.

### 5.9 Download hub (AP §3.8, §5.8)

#### 5.9.1 songspk.com.se — browse mode (AP confirmed)

No parsing rules needed. webview_flutter in-app browser; download interception via the Android
WebView's setDownloadListener (native side) which fires with the URL plus MIME type whenever the
user taps a link that resolves to a downloadable file (.mp3, .zip, or a Content-Disposition
attachment response) rather than another HTML page. The intercepted URL is handed to a normal
background HTTP download (tracked in download_history), while the WebView keeps browsing.

#### 5.9.2 masstamilan.dev — listing mode (verified against live markup)

Confirmed real structure (fetched during this planning pass):

- **Home page** (https://www.masstamilan.dev/) lists album cards; each card is a link whose href
  matches the pattern ^/[a-z0-9-]+-songs(-digits)?$ (slug pattern, e.g. /jailer-2-2026-songs),
  containing a poster image and caption text shaped like "Title Starring: names Music: name
  Director: name". Parsing strategy: don't hand-carve brittle CSS class selectors (they weren't
  visible through the fetch tool's rendered view and can change); instead match by href pattern
  plus label-prefixed text splitting ("Starring:", "Music:", "Director:" as text anchors), which
  is what the catalogue JSON's listing block encodes (schema in §7.1). Exact class names must
  still be confirmed against real page source (View Source or DevTools) during phase-8
  implementation — this plan fixes the pattern, not brittle class strings.
- **Album page** (for example https://www.masstamilan.dev/jailer-2-2026-songs) contains a
  "Download songs in RAR/ZIP format" block with two links whose href contains the literal
  substring /zip320/ (320 kbps, the one we use) and /zip128/. Example observed:
  https://www.masstamilan.dev/downloader/token/timestamp/zip320/id — confirms the abstract plan's
  .../zip320/... pattern exactly (AP §3.8, §11.5).
- **Important, newly-discovered constraint**: the album page itself states that download links
  expire in 1 day. The zip URL is signed/time-boxed per page load. Implementation rule: fetch the
  album page and extract the zip link immediately before starting the download — never cache a
  zip320 URL across app sessions. If a download fails with an expired-link error, re-fetch the
  album page and retry once, transparently.
- Parsing implemented with the html package: document.querySelectorAll('a') then filter by the
  href patterns above; no headless-browser/JS execution needed (the zip link is present in the
  server-rendered HTML).

### 5.10 Visualizer (AP §3.9)

android.media.audiofx.Visualizer, attached to the app's own audioSessionId (obtained from
just_audio's underlying ExoPlayer instance via a native bridge), not the global mix — this taps
only Paattufy's own playback buffer and does not require RECORD_AUDIO (that permission only gates
capturing the microphone or another app's/the device's global output; per-app session capture of
your own audio is unrestricted). setCaptureSize/setDataCaptureListener streams waveform and FFT
magnitude bytes to Dart via an EventChannel; three CustomPainters (bars, radial pulse,
oscilloscope line) render at a throttled frame rate (about 30 fps) to keep it cheap, per AP §3.9,
§11.21.

---

## 6. Android platform integration

| Surface | Implementation sketch |
| --- | --- |
| Notification / lock screen | audio_service's built-in MediaStyle notification — no custom code needed beyond metadata wiring. |
| Foreground service | audio_service's AudioServiceConfig; stops itself when the handler reaches idle. |
| Home-screen widgets | home_widget package writes shared state (title/artist/art path/progress) that three native AppWidgetProvider Kotlin classes (small/medium/large) render via RemoteViews, styled to mirror Spotify's widget layout (AP §11.20); artwork bitmap cached to a file so RemoteViews never re-decodes (AP §8.13). |
| Media buttons | Handled automatically by audio_service's MediaButtonReceiver. |
| Android Auto / quick-settings tile | Exposed for free via the same MediaSessionCompat that audio_service already publishes; quick-settings tile is a small TileService that forwards play/pause to the session. |
| Open with / share-target | intent-filter for ACTION_VIEW/ACTION_SEND with audio/* MIME type in AndroidManifest.xml; receive_sharing_intent surfaces the incoming file/URI to Dart, which enqueues and plays it. |
| System equalizer | Intent(AudioEffect.ACTION_DISPLAY_AUDIO_EFFECT_CONTROL_PANEL) with our audioSessionId extra — no in-app DSP. |
| Audio focus | Configured through audio_session's AudioSessionConfiguration for media playback (duck on transient loss, pause on full loss, resume per Android's standard contract). |
| Tag editor | Native AAR/platform channel around a tag read/write library covering ID3v2 (MP3), Vorbis comments (FLAC), MP4 atoms; writes go through ContentResolver.update/openFileDescriptor respecting scoped storage. |

---

## 7. GitHub repository — creation walkthrough & schemas

You (the user) will create and own this repo, per AP §11.4. Steps:

1. Sign in to GitHub, click New repository.
2. Name it, for example paattufy-catalogue. Visibility: Public (confirmed, AP §11.4 — no token
   strategy needed). Initialise with a README.
3. Create a versioned folder so a future breaking schema change never breaks the current app:
   ```
   v1/download-catalogue.json
   v1/lyrics-providers.json
   ```
4. Paste in the JSON below (schemas plus the two confirmed sites, plus the LRCLIB entry expressed
   in the same declarative shape even though it also ships built-in).
5. Commit to main.
6. The raw URL pattern the app will fetch is:
   ```
   https://raw.githubusercontent.com/<your-github-username>/paattufy-catalogue/main/v1/download-catalogue.json
   https://raw.githubusercontent.com/<your-github-username>/paattufy-catalogue/main/v1/lyrics-providers.json
   ```
7. Paste those two raw URLs into Settings, Download hub, GitHub JSON URL, and Settings, Lyrics,
   Provider catalogue URL.
8. To update later: edit the JSON file in the GitHub web UI (or locally plus push), commit to
   main. The app re-fetches on its configured refresh interval, or immediately on a manual
   "Refresh" tap in the Download hub / Lyrics settings — using a conditional GET with the previous
   response's ETag (stored in remote_catalogue_cache) so unchanged files cost almost nothing.

### 7.1 download-catalogue.json schema

```json
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
        "cardLinkHrefPattern": "^/[a-z0-9-]+-songs(-[0-9]+)?$",
        "captionLabels": {
          "starring": "Starring:",
          "music": "Music:",
          "director": "Director:"
        },
        "albumPage": {
          "zipLinkHrefContains": "/zip320/",
          "zipLinkAltHrefContains": "/zip128/",
          "linkExpiryNote": "Zip links are time-boxed (about 1 day); fetch immediately before download, do not cache long-term."
        }
      }
    },
    {
      "id": "songspk",
      "title": "SongsPK",
      "link": "https://songspk.com.se/",
      "mode": "browse"
    }
  ]
}
```

### 7.2 lyrics-providers.json schema

```json
{
  "schemaVersion": 1,
  "providers": [
    {
      "id": "lrclib",
      "displayName": "LRCLIB",
      "baseUrl": "https://lrclib.net",
      "userAgent": "Paattufy/1.0 (personal-use build)",
      "search": {
        "method": "GET",
        "path": "/api/search",
        "queryParams": {"q": "{query}"},
        "resultsArrayPath": "$",
        "fieldMap": {
          "title": "trackName",
          "artist": "artistName",
          "album": "albumName",
          "durationSec": "duration",
          "synced": "syncedLyrics",
          "plain": "plainLyrics",
          "isInstrumental": "instrumental"
        }
      },
      "fetchBest": {
        "method": "GET",
        "path": "/api/get",
        "queryParams": {
          "track_name": "{title}",
          "artist_name": "{artist}",
          "album_name": "{album}",
          "duration": "{durationSec}"
        }
      },
      "rateLimit": {"minDelayMs": 250}
    }
  ]
}
```

Adding a new provider later means appending another object to providers with the same shape
(assuming it's also a simple REST JSON API); the DeclarativeLyricsProvider (§5.6) interprets it
without an app update.

---

## 8. Testing strategy (implements AP §9)

- **Fixture generator** (test/fixtures/): a small Dart script synthesises sine-wave WAV/MP3 tone
  files (varying duration/tempo/pitch) plus a matching fixture metadata table (title, artist,
  album, genre, year, etc.), so unit/widget/integration tests never touch real music.
- **Unit tests**: Drift's in-memory connection for every DAO/repository test — queue deque ops,
  smart-group rule compiler (table-driven cases per operator/match-mode), suggestion scoring
  maths (given fixed feature vectors, assert expected ranking), LRC parsing/sync, catalogue JSON
  parsing, masstamilan HTML parsing against a saved fixture HTML snapshot (captured once, checked
  into test/fixtures/html/, refreshed manually if the site markup changes).
- **Widget tests**: one per screen in §5 (Library, Groups, Now Playing, Lyrics, Queue, Download
  hub, Settings), driven by fixture data via provider overrides.
- **Integration test** (integration_test/): onboarding, scan (fixtures), sort, build a smart
  group, play group, play-next, suggestion top-up, reorder, kill and relaunch (resume check),
  lyrics pick (mocked provider), catalogue parse (mocked HTTP).
- **Device run**: Android emulator is acceptable pre-device (AP §11.22); real MediaStore,
  Bluetooth routing, widgets, notification, system EQ, and real downloads are validated only on
  the physical Android 16 device afterward.
- **Local test runner**: a scripts/test_all.sh running "flutter analyze && flutter test &&
  flutter test integration_test" — no CI service, per AP §1 (personal build, no store release).

---

## 9. Repository & attribution constraints — technical checklist (enforces AP §9.1)

- **No git init**: never run git init/git add/git commit in this workspace unless explicitly
  asked later; the workspace stays a plain folder.
- **No "Zoho" attribution**: no dependency, asset, template, or generated boilerplate that embeds
  a "Zoho" name/brand/copyright string in pubspec.yaml, the Android manifest, Gradle files, or
  source comments.
- **No "arun-13757" attribution**: always pass --org com.paattufy to flutter create (§0) so
  package namespaces derive from the app, not the machine account; keep author/maintainer fields
  in pubspec.yaml and android/app/build.gradle either omitted or generic (for example "Paattufy"),
  never the local username. Note: ephemeral local build artefacts (local.properties, .gradle/,
  build/) may incidentally contain the local filesystem path — these are build-tool output, never
  committed (no git), and are not considered part of "the project" for this rule.

---

## 10. Phase to engineering task breakdown (maps to AP §10)

| Phase | Key engineering tasks |
| --- | --- |
| 0 | flutter create --org com.paattufy; flutter_launcher_icons default icon; Riverpod + Drift + routing scaffold; fixture generator script; scripts/test_all.sh. |
| 1 | Native MediaStore MethodChannel (full + incremental scan, folder-exclusion pushdown); songs/excluded_folders tables; sort/search/details UI. |
| 2 | audio_service/just_audio/audio_session wiring; notification; foreground service; speed/pitch/repeat/shuffle; playback_state persistence/restore. |
| 3 | queue_items sequence-based deque; all playback verbs; Queue sheet UI + drag-reorder. |
| 4 | groups/group_conditions/group_refs/group_overrides tables; rule compiler; smart rule builder UI + live preview; built-in groups. |
| 5 | Feature-extraction pipeline (fftea + YAMNet via tflite_flutter); song_audio_features table; workmanager scheduler; scoring; Settings toggle. |
| 6 | AudioDeviceCallback/Bluetooth name bridge; stop-on-route-change; output picker UI; system EQ intent. |
| 7 | LyricsProvider abstraction; LrclibProvider; DeclarativeLyricsProvider + catalogue fetch/cache; karaoke UI; offset control. |
| 8 | GitHub catalogue fetch/cache (ETag); songspk WebView download interception; masstamilan HTML parsing (confirm exact selectors against live DevTools) + zip-link-expiry re-fetch logic; archive extraction + rescan trigger. |
| 9 | 3 native AppWidgetProviders + home_widget bridge; Visualizer tap + painters; sleep timer; tag editor AAR/channel; duplicate/broken-file scan; volume normalisation + skip-silence; Android Auto/tile; open-with/share-target; backup/restore JSON export-import; battery/RAM profiling pass. |
| 10 | Full scripts/test_all.sh sweep, then emulator integration run, then physical Android 16 device validation checklist (MediaStore, Bluetooth, widgets, notification, EQ, downloads). |

---

## 11. Open implementation risks to verify at build time

- **Exact API level number for "Android 16"** must be confirmed against the SDK that ships with
  the upgraded Flutter/Android toolchain before it is hard-coded into build.gradle.
- **masstamilan.dev CSS class names** for the home-page cards weren't visible through the fetch
  tool's rendered output (only text and href structure was); the href-pattern/label-text parsing
  strategy in §5.9.2 is robust to that, but confirm against real page source in DevTools during
  phase 8, and keep a saved HTML fixture for the parser's unit test. Zip-link expiry (about 1 day)
  must be handled with a fetch-immediately-before-download policy — this was a new finding from
  this planning pass, not in the original site description.
- **Tag-editing library choice** (native AAR vs. pure-Dart) needs a short spike at phase 9 to
  confirm FLAC/MP4 write support, since most pure-Dart ID3 libraries only cover MP3 well.
- **YAMNet bundling size/licensing**: confirm the exact .tflite asset size against the final app
  size budget; it is Apache-2.0, safe to bundle, but re-verify the license file is included in
  About, Licenses.
- **Visualizer plus own-session capture**: validate on the real Android 16 device that Visualizer
  attached to a non-zero audioSessionId truly requires no runtime permission dialog on that OS
  version, before removing any fallback UI for a permission prompt.
