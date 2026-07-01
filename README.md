# Overlay Clock Timer

Overlay Clock Timer is a native macOS menu-bar utility with a compact
always-on-top clock and elapsed timer overlay. It is built with SwiftUI for the
interface, AppKit for macOS window and menu-bar integration, and XCTest for
automated coverage.

## Features

- Floating titleless overlay window that stays above normal app windows.
- Clock mode with fixed 24-hour `HH:MM:SS.mmm` formatting.
- Timer mode with Start, Pause, Loop, Stop/Reset, and mode switching controls.
- Latest Loop capture shown separately while the main timer continues running.
- Separate settings window for appearance, timer behavior, hotkeys, startup,
  and Dock visibility.
- Menu-bar status item remains available while the app is running.
- Local-only preferences and hotkey bindings; no telemetry or network sync.

## Requirements

- macOS Tahoe 26.0 or newer.
- Xcode 26.x with command line tools installed.
- Swift 6 language mode; Xcode 26.5 or newer is recommended when Swift 6.3 is
  required by the selected toolchain.
- No third-party dependencies.

## Project Layout

```text
OverlayClockTimer.xcodeproj/
OverlayClockTimer/
OverlayClockTimerTests/
OverlayClockTimerUITests/
scripts/
specs/001-overlay-clock-timer/
```

## Development

Open the project in Xcode:

```bash
open OverlayClockTimer.xcodeproj
```

Build from the command line:

```bash
xcodebuild build -scheme OverlayClockTimer -destination 'platform=macOS'
```

Run the full test suite:

```bash
./scripts/test.sh
```

The script uses these defaults:

- `SCHEME=OverlayClockTimer`
- `DESTINATION=platform=macOS`
- `DERIVED_DATA_PATH=dist/TestDerivedData`

Additional `xcodebuild test` arguments can be passed after the script name.

## Release Build

Create a portable release build:

```bash
./scripts/build-release.sh
```

The script builds a universal Release app for `arm64 x86_64`, verifies the app
signature, copies the app bundle into `dist/`, and creates a ZIP package.

Expected outputs:

```text
dist/OverlayClockTimer.app
dist/OverlayClockTimer-1.0-macOS26.0-universal.zip
```

DMG creation is best-effort and can be disabled:

```bash
CREATE_DMG=0 ./scripts/build-release.sh
```

## macOS Sequoia 15 Build

Create a custom universal Release build with `LSMinimumSystemVersion` set to
`15.0`:

```bash
./scripts/build-release-macos15.sh
```

Expected outputs:

```text
dist/macos-sequoia-15/OverlayClockTimer.app
dist/macos-sequoia-15/OverlayClockTimer-1.0-macOS15.0-universal.zip
```

DMG creation follows the same best-effort behavior as the default release
script and can be disabled:

```bash
CREATE_DMG=0 ./scripts/build-release-macos15.sh
```

## CI Pipeline

Run tests and build the release artifact:

```bash
./scripts/ci.sh
```

This runs `scripts/test.sh` and then `scripts/build-release.sh`. DMG creation is
disabled by default in the CI script because `hdiutil` can fail in restricted
automation environments.

## Testing a Prebuilt App

Run the test workflow against an already built app bundle:

```bash
./scripts/test-built-app.sh
```

By default, the script:

- verifies `dist/OverlayClockTimer.app`;
- builds only XCTest bundles and the `.xctestrun` file;
- patches the UI test target to launch the prebuilt app;
- runs `xcodebuild test-without-building`.

UI tests validate the prebuilt app bundle. App-hosted unit and performance tests
continue to use the XCTest test-host build because injecting those bundles into
the release app would require mutating or re-signing the release artifact.

Useful variants:

```bash
UI_ONLY=1 ./scripts/test-built-app.sh
APP_PATH=/path/to/OverlayClockTimer.app ./scripts/test-built-app.sh
```

## Configuration

Most scripts support environment overrides:

```bash
SCHEME=OverlayClockTimer DESTINATION='platform=macOS' ./scripts/test.sh
DIST_DIR=/tmp/OverlayClockTimer ./scripts/build-release.sh
```

Generated build outputs are written under `dist/`, which is intentionally
ignored by Git.

## Manual Smoke Test

After creating a release build:

1. Launch `dist/OverlayClockTimer.app`.
2. Confirm the overlay appears on launch.
3. Switch between Clock and Timer modes.
4. Start, pause, loop, and reset the timer.
5. Open Settings and change appearance, size, opacity, Dock visibility, and
   timer mode-switch behavior.
6. Quit from the menu-bar status item.

## Troubleshooting

- If `xcodebuild test` fails with Xcode service or CoreSimulator permission
  errors in a sandboxed environment, rerun it in a normal terminal session.
- If a copied app does not open on another Mac, confirm the target Mac is running
  macOS Tahoe 26.0 or newer.
- If SSH pushes to GitHub fail, ensure the correct private key is loaded with
  `ssh-add` and that `ssh -T git@github.com` authenticates successfully.
