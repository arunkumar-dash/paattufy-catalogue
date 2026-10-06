# Paattufy — Abstract Plan (Product & Layout)

> Stage 1 of 2. This document fixes **what** the app is, **how it is laid out**, and **how the user
> moves through it**. No code, no package names, no schemas — those live in
> `02-technical-plan.md` (written after the open questions at the end are answered).

---

## 1. One-line definition

**Paattufy** is an offline-first Android music player for a personal library, with user-defined
**Groups** (smart collections), a **deque-based queue** with suggestion top-up, time-synced lyrics
from a free provider, Bluetooth/speaker output awareness, and a self-updating **download hub**
driven by a JSON file hosted in a GitHub repo.

Scope for this build: **Android only** (phone, portrait-first). Personal use, no store release.

---

## 2. Design pillars

| Pillar | What it means in practice |
| --- | --- |
| Offline is the default | Library, groups, queue, playback state, lyrics cache all work with zero network. Network is only for lyrics fetch + download hub. |
| Local media is the source of truth | The device's MediaStore is the library. The app never copies or re-encodes audio. Bit-perfect passthrough. |
| The queue is one clear mental model | A double-ended queue. Every playback action is expressed as an operation on it (`playNow`, `playNext`, `addToQueue`). No hidden second list. |
| Resume exactly where you left off | Song + queue + position + shuffle/repeat/speed survive process death and reboot. |
| Cheap on battery & RAM | One player instance, one foreground service, lazy artwork, no polling loops, stop work when nothing is playing. |
| Nothing is hardcoded that might change | Download sites **and lyrics providers** come from remote JSON in a GitHub repo; storage folder, theme, behaviour toggles come from settings. |
| Familiar by design | The UI deliberately mirrors the conventions of Spotify (primary), Apple Music and YouTube Music, so nothing needs learning. See §7.1. |
| The user owns the look | A full-app colour theme is user-selectable, and the launcher icon itself can be swapped between 9 colourways. See §7.2–7.3. |

---

## 3. Core domain concepts (abstract, no schema yet)

### 3.1 Song
A track that exists as a file on the device. Carries title, artist, album, album artist, year,
track number, duration, file path/URI, date added, size, bitrate/sample rate, artwork reference,
and a stable identity so it survives rescans.

### 3.2 Library
The full set of Songs — scanned from the **whole device**, minus any folders the user excludes —
plus derived views: **Artists**, **Albums**, **Folders**, **Years**. Rebuilt by a **scan** (full on
first run, incremental afterwards).

### 3.3 Group — the headline feature
A **Group** is a named, ordered-or-sorted collection of songs. Two flavours behind one UI:

- **Static group** — an explicit, hand-picked, user-ordered list (a classic playlist).
- **Smart group** — a saved *rule set*. Membership is computed from the library, so it stays
  current as songs are added.

A smart group's rule set is built from **conditions** on: artist, album artist, album, genre,
release year (exact / range), date added (exact / range / "last N days"), duration, folder path,
title text, file format. Conditions combine with **match all / match any**, and a group can also
**include or exclude other groups** — so "Ilaiyaraaja 80s minus the sad ones" is expressible.

A group additionally stores its own **default sort** and **default play mode** (in order / shuffle).

A smart group's computed membership can be **manually overridden**: pin an extra song in even if it
doesn't match the rules, or exclude a specific song even if it does. Overrides persist alongside
the rule set and survive re-evaluation.

Groups are first-class playback targets everywhere: play now, play next, add to queue, shuffle-play.

**Built-in smart groups** ship by default and can't be deleted (only hidden): **Favourites**,
**Recently added**, **Recently played**, **Most played**.

### 3.4 Queue (deque)
The live play order. Semantics, as specified:

| User action | Effect on the deque |
| --- | --- |
| Play a **single song** | Queue is **cleared** and contains only that song. |
| Play a **group** | Group's songs (in its sort/shuffle order) become the queue; playback starts at the head. |
| Play a **new song** while something plays | Inserted at the **front** and played immediately. |
| **Play next** (song or group) | Inserted **immediately after** the currently playing item. |
| **Add to queue** | Appended to the **tail**. |
| Skip forward | Advance head pointer. |
| Skip back | If more than **~3 s** into the current song, restart it from 0:00. If less than ~3 s in, go to the previous item — **never more than one song back**. |
| Reorder | User drags items in the Queue screen. |

**Suggestion top-up:** whenever the queue holds **fewer than 10 upcoming songs**, the suggestion
engine appends songs until it reaches 10. Suggestions are derived from **all songs currently in the
queue** (the ≤9 present), not from a single seed. Suggested items are visually marked and are
dropped/recomputed when the user changes the queue meaningfully.

### 3.5 Playback session
The single source of truth for: current item, position, duration, playing/paused, speed
(**stepped**: 0.5× / 0.75× / 1.0× / 1.25× / 1.5× / 1.75× / 2.0×, with a **preserve pitch** toggle
that defaults **off**), repeat mode (**off → repeat-queue → repeat-one**, where repeat-one loops
the single current track, not the whole queue twice), shuffle on/off, active output device.
Persisted continuously (throttled) and restored on relaunch.

### 3.6 Output device
The app knows the current audio route (phone speaker, wired, Bluetooth A2DP, and which Bluetooth
device). Rules:
- User can see the active route and **switch** between phone speaker and connected Bluetooth.
- **Any output-device change stops playback** — wired plug/unplug, Bluetooth connect/disconnect, or
  switching between speaker and Bluetooth, every one of them, no exceptions (explicit requirement —
  not pause-and-resume; playback stops and the user restarts it).
- **Queue and position are preserved** across that stop, so one tap on play resumes exactly where
  it left off.
- Standard Bluetooth/headset media buttons (play, pause, next, previous) are honoured.

### 3.7 Lyrics
Per song, the app can hold: no lyrics, plain lyrics, or **time-synced** lyrics. Sources, in order —
and **an embedded/sidecar result always wins over a remote pick**; remote lookup only runs when no
local synced lyrics exist:
1. Embedded tag in the file / a sidecar `.lrc` next to the file.
2. Remote lookup against a free, key-less lyrics provider ([LRCLIB](https://lrclib.net/docs) by
   default), which returns **multiple candidate results** — the user picks one (the MX Player /
   OpenSubtitles pattern), with a search box to refine the query. The chosen result is cached and
   pinned to that song forever.

Synced lyrics render as a Spotify-style karaoke view: active line highlighted and scaled, smooth
auto-scroll, tap a line to seek there, tap-to-expand into a full-screen reader.

**Providers are not hardcoded.** The same GitHub repo that serves the download catalogue also
serves a **lyrics-provider catalogue**: a list of provider definitions (display name, base URL,
the shape of its search and fetch calls, and how to read title/artist/duration/synced-lyrics out
of its response). The app ships with LRCLIB as the built-in default, then merges in whatever the
remote file declares. So when a provider dies or a better one appears, the repo file is edited —
no rebuild. Settings exposes: provider order, enable/disable per provider, and "try next provider
automatically on no-result". Step-by-step instructions for creating this repo and both catalogue
files (schema, example entries, how to update them) are in `02-technical-plan.md`.

### 3.7a Suggestion engine
The engine that tops the queue up to 10 songs. It runs fully offline and has **two modes, switchable
in Settings → Suggestions (see §5.9)**:

- **Mood mode (default)** — the intent is Spotify-like: *what comes next should feel like what is
  playing*, driven by a small **on-device ML model**, not hand-tuned rules. Each song gets an
  **audio fingerprint** computed once, in the background, from the actual decoded audio:
  **tempo/rhythm**, **key/tonality**, energy, **acousticness**, brightness, danceability — combined
  into a learned **mood embedding** that also captures timbre/genre character. A song's fingerprint
  plus its tags (artist, year, **language**) form a vector. The queue's existing songs are averaged
  into a **taste centroid**, and candidates are ranked by closeness to that centroid — so the whole
  queue's mood matters, not just the last song played.
- **Metadata mode** — no audio analysis, no model: same artist → same album → same album-artist →
  year window → genre → folder → most-played. Instant, zero cost, works before any analysis has
  run. This is also the automatic fallback for any song not yet fingerprinted.

Both modes share the same hard rules: **already-queued songs are rejected outright**, and
**recently-played songs are penalised**. Candidates are drawn from the **whole library**, never
restricted to the currently playing group. Analysis is opportunistic — it happens while charging
or idle, in small batches, never during playback on battery — so it costs nothing at play time.
The technical plan specifies the exact model, features, and scoring maths.

### 3.7b Theme & icon personalisation
- **App theme** — the user picks a seed colour (a palette of presets, including the default
  electric purple, plus a custom picker) and a light/dark/system mode. Every surface, accent,
  control and the widgets follow it. Optionally the Now Playing screen can additionally tint
  itself from the current artwork.
- **Launcher icon** — 9 colourways of the `figure.dance` mark (same white glyph, different
  background). The user chooses one in Settings and the Android launcher icon changes in place.

### 3.8 Download hub
A **remote catalogue JSON** in a GitHub repo, fetched (and cached) at runtime, so the site list can
be changed by editing the repo — no app rebuild. Each catalogue entry declares:
- a **display title** for the site,
- its **link**, and
- its **mode**:
  - **Browse mode** — "this is just a homepage": open it in an in-app browser; the user navigates
    and taps a download link; the app intercepts the download.
  - **Listing mode** — the site lists recent movies/albums in a parseable shape: the app parses
    that listing, shows it as native cards, and the user downloads a whole album zip with one tap.
    The app extracts the zip into the library folder and triggers a rescan.

Crucially, **the parsing rules live in the JSON too**, not in the app — each listing-mode entry
carries the selectors/patterns used to read the site's listing page and to find the download link
on an album page. If a site changes its markup, the repo file is edited, not the app.

The two confirmed sites, as verified against their live HTML:

| Site | Mode | What the app does |
| --- | --- | --- |
| `masstamilan.dev` | **Listing** | Home page lists latest albums as poster cards with title, starring, music director. Each card links to an album page that exposes a `.../zip320/...` link (and a 128 kbps variant). The app shows the cards natively, downloads the 320 kbps zip, extracts it, rescans. |
| `songspk.com.se` | **Browse** | User browses in the in-app browser and taps either an individual song or a zip; the app intercepts and downloads it. |

Downloads land in a **user-chosen directory**, asked for during onboarding and changeable in
Settings. Download progress is visible and survives leaving the screen.

Confirmed: `masstamilan.dev` zips are **not password-protected**; downloads can be a mix of whole
album zips and single mp3s depending on the site. Step-by-step instructions for creating the public
GitHub repo and the download-catalogue JSON (schema, example entries, how to add/edit a site) are
in `02-technical-plan.md`.

### 3.9 Visualizer
A toggleable retro "Windows Media Player" style visualization that replaces the album art on the
Now Playing screen. It is driven by a **beat-reactive approximation derived from the audio's own
frequency content — no microphone permission is requested**. Deliberately minimalistic patterns
(bars, radial pulse, oscilloscope-style line) at modest resolution; low fidelity is acceptable and
cheap. Off by default; switchable from the Now Playing menu.

---

## 4. Information architecture

```
Onboarding (first run only)
  └─ Welcome → Permissions → Pick library/download folder → Initial scan → Home

Root shell: bottom navigation (4 tabs) + persistent Mini Player
  ├─ Tab 1  Library
  │     ├─ Songs        (sortable, sticky index, multi-select)
  │     ├─ Artists      → Artist detail
  │     ├─ Albums       → Album detail
  │     └─ Folders      → Folder detail
  ├─ Tab 2  Groups
  │     ├─ Group list   (static + smart, with covers/counts)
  │     ├─ Group detail (songs, play / shuffle / play next / queue)
  │     └─ Group editor (static picker  |  smart rule builder)
  ├─ Tab 3  Download
  │     ├─ Site catalogue (from GitHub JSON)
  │     ├─ In-app browser (browse-mode sites)
  │     ├─ Recent listing (listing-mode sites)
  │     └─ Downloads      (active + history)
  └─ Tab 4  Settings

Overlays / full-screen routes (reachable from anywhere)
  ├─ Now Playing   (swipe up from Mini Player)
  │     ├─ Art / Visualizer
  │     ├─ Lyrics panel  → Full-screen lyrics
  │     ├─ Output picker
  │     ├─ Speed picker
  │     └─ Queue sheet   (view + drag-reorder)
  ├─ Search (global: songs, artists, albums, groups)
  └─ Lyrics picker (candidate results for the current song)
```

---

## 5. Screen-by-screen layout

### 5.1 Onboarding
Full-bleed electric-purple gradient, app mark centred, three sequential cards:
1. **What Paattufy does** — three bullets, one CTA.
2. **Permissions** — audio/media read, notifications, Bluetooth, each with a one-line reason and a
   per-item grant button; clear "why" text, no scary walls.
3. **Storage** — "Where should downloaded songs live?" → system folder picker; shows the chosen
   path; explains it can be changed later. Then a scan progress card (`1,248 songs found…`).

### 5.2 Library — Songs
- App bar: `Paattufy` · search icon · sort icon · overflow.
- **Sort sheet**: Title, Artist, Album, Date added, Duration, Year + asc/desc toggle. Sticky —
  remembered per tab.
- Row: artwork (rounded 44dp) · title · `artist · album` · duration · row menu.
- Row menu: Play, Play next, Add to queue, Add to group, Go to artist, Go to album, Lyrics,
  Details, Share. **(The library is read-only — no delete-file action anywhere in the app.)**
- **Details** shows full metadata plus the **file path**, with a tap-to-copy action.
- **Long-press → multi-select mode**: select all / range, then bulk Play next, Add to queue,
  Add to group.
- Fast-scroll index rail on the right that reflects the active sort key.
- Header chips: `Shuffle all` and `Play all`.

### 5.3 Library — Artists / Albums / Folders
Grid for Albums (2–3 cols, cover + title + artist), list for Artists (circular art, `n albums ·
n songs`) and Folders (path + count). Detail pages share one template: large blurred-art header,
title block, `Play` + `Shuffle` buttons, overflow (Play next, Add to queue, Add all to group),
then the song list. Each Folder row also has an **Exclude from library** toggle in its overflow
menu — excluded folders are skipped on every scan until re-included (see Settings → Library).

### 5.4 Groups
- **Group list**: cards showing a 2×2 art mosaic, name, `n songs`, and a badge distinguishing
  **Smart** from **Static**. FAB → "New group" → choose *Hand-pick songs* or *Build a rule*.
- **Smart rule builder** — the important screen:
  - Name field + optional cover.
  - `Match [all ▾] of the following:` then a list of condition rows.
  - Each condition row: `[field ▾] [operator ▾] [value]` with the value editor adapting to the
    field (artist/album → searchable chip picker; year → number or range slider; date added →
    date range or "last N days"; duration → range; text → contains/equals).
  - `+ Add condition`, `+ Include group`, `+ Exclude group`.
  - **Live preview** footer: `Matches 84 songs` with a peek list, updating as rules change.
  - Default sort + default play mode selectors.
- **Group detail**: same template as album detail, plus `Edit rules`, `Duplicate`, `Delete`, and —
  for static groups — drag-reorder.

### 5.5 Now Playing
Vertical stack, generous spacing, background = blurred dominant colour of the artwork:
1. Drag handle · output-device chip (shows `Phone speaker` / device name, tap → output picker) ·
   overflow menu (Visualizer, Lyrics, Add to group, Details, Go to album/artist, Sleep timer).
2. **Art area** — album art, or the visualizer when enabled. Tapping flips between them.
3. Title / artist (marquee on overflow) + favourite toggle.
4. Seek bar with elapsed / remaining, scrub preview.
5. Transport row: shuffle · previous · **play/pause** (large) · next · repeat.
6. Secondary row: `1.0×` speed chip · Lyrics chip · Queue chip.
7. **Lyrics peek strip** — current synced line; tap to expand to full-screen lyrics.

### 5.6 Lyrics
- **Peek**: one active line + faint neighbours, on the Now Playing screen.
- **Full-screen**: karaoke list — active line bold/scaled/full-opacity, past lines dimmed,
  upcoming lines dimmer; auto-scroll keeps the active line centred; tapping a line seeks to its
  timestamp; a "jump back to current" pill appears while the user scrolls manually.
- **Offset control** (`−/+ 0.2 s`) to nudge sync, saved per song.
- **Provider picker**: `Search lyrics` → editable artist/title query → result cards showing
  track/artist/album, duration match indicator, and a `Synced` / `Plain` badge → preview → `Use
  this`. The choice is remembered.

### 5.7 Queue
Bottom sheet (expandable to full screen):
- Header: `Playing from <source>` (song / group / suggestion), plus `Clear`, `Save as group`.
- Sections: **Now playing** → **Next up** (drag-reorderable) → **Suggested** (marked with a spark
  icon, `Not interested` / `Keep`).
- Swipe a row to remove. Drag handles on the right.

### 5.8 Download hub
- **Catalogue**: cards from the GitHub JSON — site title, mode badge (`Browse` / `Recent list`),
  and a refresh action with a "last updated" timestamp.
- **Browse mode**: in-app browser with a slim toolbar (back/forward/reload/open-external), and a
  download interception bar at the bottom when a media/zip link is tapped.
- **Listing mode**: native cards of parsed recent releases (poster, title, year, song count) →
  `Download all` → zip download → auto-extract → rescan → "Added 12 songs" toast.
- **Downloads**: active transfers with progress/pause/cancel; history with re-download and
  "reveal in library".

### 5.9 Settings
Grouped list:
- **Library** — download folder path (editable text field; must be an absolute path the app has
  access to, e.g. `/storage/emulated/0/Music/Paattufy`, with inline format guidance and a
  validation check before saving), excluded folders (multi-select picker, mirrors the per-folder
  toggle in Folders), rescan now, ignore short clips (< N s). The library is read-only — there is
  no delete-file action anywhere in the app.
- **Playback** — default speed, **preserve pitch on speed change (toggle, default off)**,
  crossfade off/on, resume on launch, stop-on-output-change (always on, every route change,
  surfaced here so it's discoverable, not a toggle), skip-back window (~3 s), gapless.
- **Suggestions** — mode: **Mood (ML)** or **Metadata (rule-based)**, per §3.7a.
- **Audio** — open **system equalizer**, output preference, volume normalisation (opt-in, off by
  default), skip silence (toggle).
- **Lyrics** — provider order, enable/disable per provider, "try next provider on no-result",
  auto-fetch on play, cache size / clear cache.
- **Download hub** — GitHub JSON URL, refresh interval, Wi-Fi-only.
- **Appearance** — theme (system/dark/light), seed colour presets + custom picker, dynamic colour
  from artwork, launcher icon colourway (9 options), visualizer default, widget style (Spotify's
  look by default).
- **Data** — backup/restore app data (groups, queue, play counts, lyric picks) to a JSON file.
- **About** — version, storage usage, reset.

---

## 6. Android system surfaces

| Surface | Behaviour |
| --- | --- |
| Notification / lock screen | Media-style notification with artwork, title/artist, seek bar, prev / play-pause / next, and a dismiss when stopped. Works with screen locked. |
| Foreground service | Keeps playback alive in the background; stops itself when playback stops so no battery is wasted. |
| Home-screen widgets | Three sizes, styled to match **Spotify's** widget look — **small** (art + play/pause), **medium** (art + title/artist + prev/play/next), **large** (adds seek progress + queue peek + shuffle/repeat). Artwork bitmaps are cached so widgets never re-decode. Taps deep-link into Now Playing. |
| Media buttons | Headset/Bluetooth play, pause, play-pause toggle, next, previous, and long-press behaviours. |
| Android Auto / quick-settings tile | Exposed via the existing media session — no extra playback logic needed. |
| Open with / share-target | Tapping an audio file in a file manager, or sharing one to Paattufy, opens it here and plays it. |
| System equalizer | Launched via the platform's audio-effect control panel bound to our session — no in-app DSP, so no quality loss. |
| Audio focus | Pause on transient loss (call, notification), duck where appropriate, resume where the user expects it. |

---

## 7. Visual identity

### 7.1 UI conventions (Spotify / Apple Music / YouTube Music)

The UI deliberately mirrors the players everyone already knows, so nothing needs learning:

- **Bottom tab bar + persistent Mini Player** docked just above it, à la Spotify — tap to expand,
  swipe up for the full Now Playing screen, swipe down or tap-outside to collapse back.
- **Now Playing** layout (art, transport row, secondary chips, lyrics peek, swipe-up Queue sheet)
  follows Spotify's structure most closely; the karaoke lyrics view is a direct analogue of
  Spotify's synced-lyrics screen.
- **Artist / Album / Folder detail** pages use the large-blurred-header-plus-song-list template
  common to Apple Music and Spotify detail pages: hero art, title block, primary `Play`/`Shuffle`
  actions, then the track list.
- **Global search** (recent searches, mixed-type results grouped by songs/artists/albums/groups)
  follows YouTube Music's search conventions.
- **Groups** occupy the tab Spotify would call "Your Library" playlists — cards with art mosaics,
  a static/smart badge standing in for Spotify's own playlist-vs-algorithmic distinction.

### 7.2 Brand mark & palette

- **App name:** Paattufy
- **Mark:** the SF Symbols `figure.dance` glyph, pure **white**, centred on an **electric purple**
  background. Android adaptive icon: purple background layer + white glyph foreground layer,
  within the safe zone. Also used as the splash mark and as the empty-state motif.
- **Palette:** electric purple as the seed colour for a Material 3 dark-first scheme; near-black
  surfaces; artwork-derived accents on Now Playing only.
- **Type:** Material 3 defaults with tightened headline weights; numerals tabular in the seek bar.
- **Motion:** 200–300 ms emphasised easing; shared-element art transition from mini player to Now
  Playing; lyrics lines animate scale+opacity, never jumping.

### 7.3 Theme & icon personalisation

Full spec in §3.7b. Visually: each seed-colour preset generates a complete Material 3 tonal
palette applied app-wide (including widgets); **9 launcher-icon colourways** of the same
`figure.dance` mark are offered, switched in place from Settings → Appearance, matching Spotify's
own "pick your app icon" pattern.

---

## 8. Additional standard-player features (confirmed in scope)

All confirmed, and folded into the phase plan (§10):

1. **Sleep timer** — stop after N minutes or at end of track.
2. **Favourites** — a heart, which is really just an auto-maintained group.
3. **Global search** across songs/artists/albums/groups, with recent searches.
4. **Play-count, last-played, skip-count** — needed anyway to make suggestions good, and enables
   "Most played", "Recently played", "Never played" smart groups for free.
5. **Gapless playback + optional crossfade.**
6. **Tag editor** — fix wrong title/artist/album/year/artwork on a file. Critical for a local
   library scraped off the web, and it directly improves grouping and lyrics matching.
7. **Duplicate & broken-file detection** after imports.
8. **Folder blacklist** — hide WhatsApp audio, recordings, notification tones from the library.
9. **Volume normalisation toggle** (ReplayGain-style, opt-in and off by default to respect your
   "no quality loss" rule).
10. **Skip silence** for long recordings.
11. **Backup / restore of app data** (groups, queue, play counts, lyric picks) to a JSON file —
    important because this is a personal app with hand-built smart groups you don't want to lose.
12. **Android Auto / quick-settings tile** — optional, low effort with the media session already in
    place.
13. **Widget + notification artwork caching** so the widget doesn't re-decode bitmaps.
14. **"Open with" / share-target handling** — tap an audio file in a file manager, it plays here.
15. **Headphone-unplug behaviour** — stops playback, per the stop-on-every-route-change rule in
    §3.6. Not a separate setting — it's always stop.
16. **Crash-safe queue journal** so an abrupt kill never loses the queue.

Deliberately out of scope: online streaming, accounts/sync, podcasts, video, iOS.

---

## 9. Build & validation approach (abstract)

1. Everything is built against a **sample library** — a set of generated tone files plus fixture
   metadata — so the full app can be exercised on the desktop/emulator with no real music and no
   real device.
2. Every layer (queue deque, group rule evaluation, suggestion top-up, sort, persistence,
   lyrics parsing/sync, catalogue parsing) is covered by **unit tests** against those fixtures.
3. Every screen gets a **widget test** driven by the same fixtures.
4. An **end-to-end integration test** walks: onboarding → scan → sort → build a smart group →
   play group → play-next → suggestion top-up → reorder → resume after restart → lyrics pick →
   catalogue parse.
5. Only after that suite is green do we install on the phone. The device run then validates the
   things a test cannot: real MediaStore, real Bluetooth routing, media buttons, widgets,
   notification, system equalizer, real downloads.

### 9.1 Repository & attribution constraints

- **No git initialisation** — do not run `git init` or create any commits in this workspace unless
  explicitly asked to later.
- **No attribution to "Zoho"** anywhere in the project — code, comments, config, generated files,
  or any other artefact.
- **No attribution to the local username "arun-13757"** anywhere in the project — author/owner
  fields, embedded file paths, package metadata, comments, or any other artefact.

---

## 10. Delivery phases

| Phase | Outcome |
| --- | --- |
| 0 | Project scaffold, icon, theme, navigation shell, sample-data harness, CI-less test runner. |
| 1 | Library: whole-device scan, folder exclusions, songs/artists/albums/folders, sorting, search, details (incl. file path + copy). |
| 2 | Playback core: player, media session, notification, background, speed, repeat, shuffle, resume. |
| 3 | Queue deque + all playback verbs + queue UI + reorder. |
| 4 | Groups: static + smart rule engine + editor + live preview. |
| 5 | Suggestions engine + queue top-up. |
| 6 | Output-device awareness, switching, stop-on-change, media buttons, system EQ. |
| 7 | Lyrics: fetch, multi-result picker, cache, synced karaoke UI, offset. |
| 8 | Download hub: GitHub catalogue, browser mode, listing mode, zip extract, rescan. |
| 9 | Widgets (3 sizes, Spotify-styled, cached art), visualizer, sleep timer, tag editor, duplicate/broken-file detection, volume normalisation, skip silence, Android Auto/quick-settings tile, open-with/share-target, crash-safe queue journal, backup/restore, polish + battery/RAM pass. |
| 10 | Full test sweep on sample data → then the on-device run. |

---

## 11. Decisions (resolved)

All open questions from the first draft are answered. Where an answer changed the spec above, the
relevant section is referenced.

**Identity & build**
1. Application ID: **`com.paattufy.music`**.
2. Min/target Android version: built against **Android 16** (the only target device) for both
   `minSdk` and `targetSdk` — this is a single-device personal build, so no backward-compat range
   is needed.
3. **`flutter upgrade`** to current stable is approved before work starts.

**Download hub**
4. GitHub repo will be **public**, created and provided by the user. Step-by-step repo-creation and
   JSON-schema instructions (for both the download catalogue and the lyrics-provider catalogue) are
   written up in `02-technical-plan.md`.
5. Confirmed listing-mode site: `masstamilan.dev` (home page → album page → `.../zip320/...` link,
   not password-protected). Confirmed browse-mode site: `songspk.com.se` (individual songs or zips).
   See §3.8.
6. Downloads are a mix of **album zips and single mp3s**, none password-protected.

**Library & storage**
7. Scans the **whole device**; user can **exclude specific folders** (§3.2, §5.3, §5.9). Song
   Details shows the **file path with tap-to-copy** (§5.2). The download/library folder path is
   **user-editable in Settings** with inline format guidance (§5.9).
8. Library is **read-only** — no delete-file action anywhere in the app (§5.2).

**Playback details**
9. Stop-on-output-change applies to **every** route change, no exceptions (§3.6).
10. Queue and position are **preserved** across that stop (§3.6).
11. Skip-back: **restart current song** if > ~3 s in, else **go back one song**, never two (§3.4).
12. Repeat cycle is **off → repeat-queue → repeat-one**, and repeat-one loops the single current
    track (not "play the queue twice") (§3.5).
13. Speed is **stepped** (0.5×/0.75×/1.0×/1.25×/1.5×/1.75×/2.0×) with a **preserve-pitch toggle,
    default off** (§3.5, §5.9).

**Suggestions**
14. Mood mode uses an **on-device ML model** over tempo/rhythm, key, acousticness, brightness,
    danceability and a learned mood/genre embedding, not hand-tuned rules (§3.7a). User can switch
    to the simpler Metadata mode in Settings → Suggestions (§5.9).
15. Suggestions are drawn from the **whole library**, never just the playing group (§3.7a).

**Lyrics**
16. Built on **LRCLIB** (`lrclib.net`) as the default provider, pluggable via the GitHub-hosted
    catalogue (§3.7).
17. An **embedded/sidecar `.lrc` always wins** over a remote pick (§3.7).

**Groups**
18. **Favourites**, **Recently added**, **Recently played**, **Most played** ship as built-in smart
    groups (§3.3).
19. Smart groups support **manual pin-in / exclude overrides** on top of their rules (§3.3).

**Widgets & visualizer**
20. Widgets are styled to match **Spotify's** widget look (§6, §5.9).
21. Visualizer is a **beat-reactive fake driven by the audio's own frequency content** — no
    microphone permission, minimalistic patterns, low fidelity accepted (§3.9).

**Testing**
22. An **Android emulator** is acceptable for the pre-device automated run (§9).
