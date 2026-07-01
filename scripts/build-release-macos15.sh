#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MACOSX_DEPLOYMENT_TARGET_VALUE="${MACOSX_DEPLOYMENT_TARGET_VALUE:-15.0}"

export DIST_DIR="${DIST_DIR:-$ROOT_DIR/dist/macos-sequoia-15}"
export DERIVED_DATA_PATH="${DERIVED_DATA_PATH:-$DIST_DIR/DerivedData}"

exec "$ROOT_DIR/scripts/build-release.sh" \
  MACOSX_DEPLOYMENT_TARGET="$MACOSX_DEPLOYMENT_TARGET_VALUE" \
  "$@"
