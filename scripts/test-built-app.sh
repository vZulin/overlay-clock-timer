#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_NAME="${APP_NAME:-OverlayClockTimer}"
SCHEME="${SCHEME:-OverlayClockTimer}"
DESTINATION="${DESTINATION:-platform=macOS}"
DIST_DIR="${DIST_DIR:-$ROOT_DIR/dist}"
APP_PATH="${APP_PATH:-$DIST_DIR/$APP_NAME.app}"
DERIVED_DATA_PATH="${DERIVED_DATA_PATH:-$DIST_DIR/PrebuiltAppTestDerivedData}"
BUILD_TEST_BUNDLES="${BUILD_TEST_BUNDLES:-1}"
UI_TEST_TARGET="${UI_TEST_TARGET:-OverlayClockTimerUITests}"
UI_TEST_TARGET_INDEX="${UI_TEST_TARGET_INDEX:-1}"
UI_ONLY="${UI_ONLY:-0}"

if [[ "$APP_PATH" != /* ]]; then
  APP_PATH="$ROOT_DIR/$APP_PATH"
fi

TEST_PRODUCTS_DIR="$DERIVED_DATA_PATH/Build/Products"
PATCHED_XCTESTRUN_PATH="$TEST_PRODUCTS_DIR/$APP_NAME-prebuilt-app.xctestrun"

cd "$ROOT_DIR"
mkdir -p "$DIST_DIR"

if [[ ! -d "$APP_PATH" ]]; then
  echo "Prebuilt app bundle does not exist: $APP_PATH" >&2
  echo "Run scripts/build-release.sh first or pass APP_PATH=/path/to/$APP_NAME.app." >&2
  exit 1
fi

if [[ ! -x "$APP_PATH/Contents/MacOS/$APP_NAME" ]]; then
  echo "Prebuilt app executable is missing or not executable: $APP_PATH/Contents/MacOS/$APP_NAME" >&2
  exit 1
fi

echo "Verifying prebuilt app signature..."
codesign --verify --deep --strict --verbose=2 "$APP_PATH"

if [[ "$BUILD_TEST_BUNDLES" == "1" ]]; then
  echo "Building XCTest bundles for scheme '$SCHEME' on '$DESTINATION'..."
  xcodebuild build-for-testing \
    -scheme "$SCHEME" \
    -destination "$DESTINATION" \
    -derivedDataPath "$DERIVED_DATA_PATH"
fi

XCTESTRUN_PATH="${XCTESTRUN_PATH:-}"
if [[ -z "$XCTESTRUN_PATH" ]]; then
  XCTESTRUN_PATH="$(
    find "$TEST_PRODUCTS_DIR" \
      -maxdepth 1 \
      -type f \
      -name '*.xctestrun' \
      ! -name '*prebuilt*.xctestrun' \
      -print \
      -quit
  )"
fi

if [[ -z "$XCTESTRUN_PATH" || ! -f "$XCTESTRUN_PATH" ]]; then
  echo "No .xctestrun file was found under $TEST_PRODUCTS_DIR." >&2
  echo "Run with BUILD_TEST_BUNDLES=1 or pass XCTESTRUN_PATH=/path/to/file.xctestrun." >&2
  exit 1
fi

cp "$XCTESTRUN_PATH" "$PATCHED_XCTESTRUN_PATH"

ACTUAL_UI_TARGET="$(
  /usr/libexec/PlistBuddy \
    -c "Print :TestConfigurations:0:TestTargets:$UI_TEST_TARGET_INDEX:BlueprintName" \
    "$PATCHED_XCTESTRUN_PATH"
)"

if [[ "$ACTUAL_UI_TARGET" != "$UI_TEST_TARGET" ]]; then
  echo "Expected UI test target '$UI_TEST_TARGET' at index $UI_TEST_TARGET_INDEX, found '$ACTUAL_UI_TARGET'." >&2
  echo "Pass UI_TEST_TARGET_INDEX if the .xctestrun target order changes." >&2
  exit 1
fi

echo "Patching UI test target to launch prebuilt app: $APP_PATH"
plutil \
  -replace "TestConfigurations.0.TestTargets.$UI_TEST_TARGET_INDEX.UITargetAppPath" \
  -string "$APP_PATH" \
  "$PATCHED_XCTESTRUN_PATH"

if [[ "$UI_ONLY" == "1" ]]; then
  echo "Running UI tests against the prebuilt app without rebuilding it..."
  xcodebuild test-without-building \
    -xctestrun "$PATCHED_XCTESTRUN_PATH" \
    -destination "$DESTINATION" \
    "-only-testing:$UI_TEST_TARGET" \
    "$@"
else
  echo "Running the full XCTest suite without rebuilding."
  echo "UI tests target the prebuilt app; app-hosted unit tests use the XCTest test-host build."
  xcodebuild test-without-building \
    -xctestrun "$PATCHED_XCTESTRUN_PATH" \
    -destination "$DESTINATION" \
    "$@"
fi
