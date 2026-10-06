#!/usr/bin/env bash
# Paattufy local test runner (AP §1: personal build, no CI service).
# Static analysis, unit + widget tests, then the emulator integration test.
set -euo pipefail

cd "$(dirname "$0")/.."

echo "==> flutter analyze"
flutter analyze

echo "==> flutter test (unit + widget)"
flutter test

if [[ "${SKIP_INTEGRATION:-0}" == "1" ]]; then
  echo "==> integration tests skipped (SKIP_INTEGRATION=1)"
else
  DEVICE="${DEVICE:-emulator-5554}"
  ADB="${ADB:-adb}"
  AUDIO_DIR="${AUDIO_DIR:-}"   # optional: folder of <artist>/<song>.wav to push as the test library

  echo "==> preparing $DEVICE (clear data, grant permissions)"
  "$ADB" -s "$DEVICE" shell pm clear com.paattufy.music >/dev/null 2>&1 || true
  if [[ -n "$AUDIO_DIR" ]]; then
    "$ADB" -s "$DEVICE" push "$AUDIO_DIR/." /sdcard/Music/ >/dev/null
    "$ADB" -s "$DEVICE" shell am broadcast -a android.intent.action.MEDIA_SCANNER_SCAN_FILE -d file:///sdcard/Music >/dev/null
  fi

  echo "==> flutter test integration_test"
  # Permissions can only be granted once the package is installed, so install first.
  flutter build apk --debug >/dev/null
  "$ADB" -s "$DEVICE" install -r build/app/outputs/flutter-apk/app-debug.apk >/dev/null
  for p in READ_MEDIA_AUDIO POST_NOTIFICATIONS BLUETOOTH_CONNECT; do
    "$ADB" -s "$DEVICE" shell pm grant com.paattufy.music "android.permission.$p"
  done
  "$ADB" -s "$DEVICE" shell appops set com.paattufy.music MANAGE_EXTERNAL_STORAGE allow
  flutter test integration_test -d "$DEVICE" || {
    echo "!! integration tests need a running emulator/device (DEVICE=$DEVICE) with the fixture audio pushed" >&2
    exit 1
  }
fi

echo "==> all green"
