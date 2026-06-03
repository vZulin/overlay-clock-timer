#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_NAME="${APP_NAME:-OverlayClockTimer}"
SCHEME="${SCHEME:-OverlayClockTimer}"
CONFIGURATION="${CONFIGURATION:-Release}"
DESTINATION="${DESTINATION:-platform=macOS}"
ARCHS_VALUE="${ARCHS_VALUE:-arm64 x86_64}"
DIST_DIR="${DIST_DIR:-$ROOT_DIR/dist}"
DERIVED_DATA_PATH="${DERIVED_DATA_PATH:-$DIST_DIR/DerivedData}"
CREATE_DMG="${CREATE_DMG:-1}"

cd "$ROOT_DIR"
mkdir -p "$DIST_DIR"

echo "Building '$SCHEME' $CONFIGURATION for '$DESTINATION'..."
xcodebuild build \
  -scheme "$SCHEME" \
  -configuration "$CONFIGURATION" \
  -destination "$DESTINATION" \
  -derivedDataPath "$DERIVED_DATA_PATH" \
  ARCHS="$ARCHS_VALUE" \
  ONLY_ACTIVE_ARCH=NO \
  "$@"

BUILT_APP="$DERIVED_DATA_PATH/Build/Products/$CONFIGURATION/$APP_NAME.app"
OUTPUT_APP="$DIST_DIR/$APP_NAME.app"

if [[ ! -d "$BUILT_APP" ]]; then
  echo "Expected app bundle was not produced: $BUILT_APP" >&2
  exit 1
fi

echo "Copying app bundle to $OUTPUT_APP..."
ditto "$BUILT_APP" "$OUTPUT_APP"

VERSION="$(/usr/libexec/PlistBuddy -c 'Print CFBundleShortVersionString' "$OUTPUT_APP/Contents/Info.plist")"
MIN_OS="$(/usr/libexec/PlistBuddy -c 'Print LSMinimumSystemVersion' "$OUTPUT_APP/Contents/Info.plist")"
ARCHS_BUILT="$(lipo -archs "$OUTPUT_APP/Contents/MacOS/$APP_NAME")"
PACKAGE_BASENAME="$APP_NAME-$VERSION-macOS$MIN_OS-universal"
ZIP_PATH="$DIST_DIR/$PACKAGE_BASENAME.zip"
DMG_PATH="$DIST_DIR/$PACKAGE_BASENAME.dmg"

echo "Verifying app signature..."
codesign --verify --deep --strict --verbose=2 "$OUTPUT_APP"

echo "Creating ZIP package at $ZIP_PATH..."
ditto -c -k --keepParent "$OUTPUT_APP" "$ZIP_PATH"

if [[ "$CREATE_DMG" == "1" ]] && command -v hdiutil >/dev/null 2>&1; then
  echo "Creating DMG package at $DMG_PATH..."
  if ! hdiutil create -volname "$APP_NAME" -srcfolder "$OUTPUT_APP" -ov -format UDZO "$DMG_PATH"; then
    echo "Warning: DMG creation failed. ZIP package is still available." >&2
  fi
fi

echo "Build artifacts:"
echo "  App: $OUTPUT_APP"
echo "  ZIP: $ZIP_PATH"
if [[ -f "$DMG_PATH" ]]; then
  echo "  DMG: $DMG_PATH"
fi
echo "  Architectures: $ARCHS_BUILT"
