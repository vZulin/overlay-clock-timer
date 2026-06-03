#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCHEME="${SCHEME:-OverlayClockTimer}"
DESTINATION="${DESTINATION:-platform=macOS}"
DIST_DIR="${DIST_DIR:-$ROOT_DIR/dist}"
DERIVED_DATA_PATH="${DERIVED_DATA_PATH:-$DIST_DIR/TestDerivedData}"

cd "$ROOT_DIR"
mkdir -p "$DIST_DIR"

echo "Running tests for scheme '$SCHEME' on '$DESTINATION'..."
xcodebuild test \
  -scheme "$SCHEME" \
  -destination "$DESTINATION" \
  -derivedDataPath "$DERIVED_DATA_PATH" \
  "$@"
