# Paattufy

An offline-first Android music player for a personal library: user-defined **Groups**
(static and smart), a deque-based **queue** with suggestion top-up, time-synced
**lyrics**, output-device awareness, and a **download hub** driven by a JSON catalogue
hosted in a GitHub repo.

Design docs: [`docs/01-abstract-plan.md`](docs/01-abstract-plan.md) (product & layout) and
[`docs/02-technical-plan.md`](docs/02-technical-plan.md) (architecture).

## Run

```bash
flutter pub get
dart run build_runner build      # Drift code generation
flutter run -d <android-device>  # Android 16 (API 36) only
```

The catalogue URLs default to the GitHub repo in `lib/core/constants.dart` and are
editable in Settings → Lyrics / Download hub.

## Test

```bash
scripts/test_all.sh              # analyze + unit + widget + integration (needs an emulator)
SKIP_INTEGRATION=1 scripts/test_all.sh   # everything that runs on the host
```

Unit/widget tests run against a generated fixture library (`test/fixtures/`, regenerate
with `dart run test/fixtures/generate_fixtures.dart`), an in-memory Drift database, a fake
audio engine and fake HTTP — never real music.

## Layout

```
lib/core/            entities, Drift schema, settings, theming, shared widgets
lib/features/        library · groups · queue · playback · lyrics · suggestions ·
                     download_hub · visualizer · settings · onboarding · ...
packages/paattufy_native/   Kotlin plugin: MediaStore, audio decode, output routes,
                     visualizer, icon switch, tag editor (TagLib), intents
android/app/         manifest, launcher-icon aliases, home-screen widgets, QS tile
integration_test/    end-to-end walk-through for an emulator
```

## Notes

- The library is **read-only**: no code path deletes or rewrites audio. Tag edits change
  metadata only.
- All-files access is requested (sidecar `.lrc`, download folder, tag writes).
- The YAMNet model (`assets/models/yamnet.tflite`, Apache-2.0, ≈4 MB, TF Hub
  `lite-model/yamnet/classification/tflite/1`) is bundled. That build exposes the 521
  AudioSet class scores (no 1024-d embedding), which are projected to 64-d; if the file
  is removed, Mood-mode falls back to the heuristic audio features alone.
