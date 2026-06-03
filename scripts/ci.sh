#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

"$ROOT_DIR/scripts/test.sh"
CREATE_DMG="${CREATE_DMG:-0}" "$ROOT_DIR/scripts/build-release.sh"
