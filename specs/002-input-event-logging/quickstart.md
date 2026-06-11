# Quickstart: Input Event Logging

## Prerequisites

- macOS Tahoe 26.0 or newer as the deployment target.
- Xcode 26.x with command line tools installed.
- No third-party package manager is required.
- Input monitoring permissions may be required to observe input outside the app.

## Build

```bash
xcodebuild build -scheme OverlayClockTimer -destination 'platform=macOS'
```

## Run Automated Tests

Run this command after every implementation phase. This is the default
development mode: UI input-capture tests launch the app with
`--mock-input-event-capture`, so they do not depend on macOS TCC permissions or
ad-hoc signing stability.

```bash
xcodebuild test -scheme OverlayClockTimer -destination 'platform=macOS'
```

To run only the input-capture UI tests in development mode:

```bash
xcodebuild test \
  -scheme OverlayClockTimer \
  -destination 'platform=macOS' \
  -only-testing:OverlayClockTimerUITests/OverlayClockTimerUITests/testKeyboardLoggingRecordsRowsAndStopsOnClose \
  -only-testing:OverlayClockTimerUITests/OverlayClockTimerUITests/testMouseLoggingRowsAndFileState
```

To run only the visible-refresh SLA coverage:

```bash
xcodebuild test \
  -scheme OverlayClockTimer \
  -destination 'platform=macOS' \
  -only-testing:OverlayClockTimerTests/InputEventStoreTests/testVisibleRowsUpdateBeforeDelayedLogAppendCompletesAndFailureStatusChanges \
  -only-testing:OverlayClockTimerTests/InputLoggingPerformanceTests/testCapturedRowsPublishWithinDisplayRefreshTargetAndPreserveCapturedTimestamp \
  -only-testing:OverlayClockTimerUITests/OverlayClockTimerUITests/testInputLoggingRowsAppearBeforeDelayedFileWritingCanBlockVisibility
```

The UI SLA test uses `--mock-input-event-capture` plus
`--delayed-input-event-log-writing` to prove visible rows are not blocked by a
slow session log append. Strict `<=16 ms` UI timing is opt-in with
`OVERLAY_CLOCK_TIMER_STRICT_UI_REFRESH_SLA=1` because XCUI polling is not a
stable display-refresh timer on every machine.

## Run Real Input Capture UI Tests

Real input capture tests intentionally do not use the mock event source. They
require macOS permissions and a stable build product path. Because this project
uses ad-hoc signing when no `DEVELOPMENT_TEAM` is configured, rebuilding may
change the TCC identity. Prefer `build-for-testing` once, grant permissions to
that exact app path, then run `test-without-building`.

Build once into a stable DerivedData directory:

```bash
DERIVED_DATA="$PWD/build/DerivedData"

xcodebuild build-for-testing \
  -scheme OverlayClockTimer \
  -destination 'platform=macOS' \
  -derivedDataPath "$DERIVED_DATA"
```

Grant permissions in System Settings > Privacy & Security:

- `build/DerivedData/Build/Products/Debug/OverlayClockTimer.app`
  - Accessibility
  - Input Monitoring
- `build/DerivedData/Build/Products/Debug/OverlayClockTimerUITests-Runner.app`
  - Accessibility

Run the real-capture tests without rebuilding:

```bash
OVERLAY_CLOCK_TIMER_REAL_INPUT_CAPTURE_TESTS=1 \
xcodebuild test-without-building \
  -scheme OverlayClockTimer \
  -destination 'platform=macOS' \
  -derivedDataPath "$DERIVED_DATA" \
  -only-testing:OverlayClockTimerUITests/OverlayClockTimerUITests/testKeyboardLoggingRecordsRowsAndStopsOnClose \
  -only-testing:OverlayClockTimerUITests/OverlayClockTimerUITests/testMouseLoggingRowsAndFileState
```

If the panel shows `Capture Unavailable`, remove stale OverlayClockTimer entries
from System Settings and add the exact app paths from `build/DerivedData` again.
Do not rerun `xcodebuild test` for the real-capture check, because it may
rebuild/re-sign the app before launch.

## Manual Review Flow

1. Build and run the `OverlayClockTimer` scheme from Xcode.
2. Show the overlay from the menu-bar status item.
3. Confirm the logging icon appears immediately to the left of the Clock/Timer
   switch.
4. Open the logging panel and confirm the overlay expands downward.
5. Confirm the default table is empty on open.
6. Generate keyboard repeat input and modifier combinations while the panel is
   open.
7. Generate left, right, third, and additional mouse-button down/up events while
   the panel is open.
8. Generate physical scroll-up and scroll-down gestures while the panel is open.
9. Confirm the event table shows only `Time` and `Event` columns.
10. Confirm a newly captured row appears by the next display refresh under
    normal load; on a 60 Hz display the target is `<=16 ms` from in-memory
    record insertion to visible row rendering.
11. Confirm the displayed timestamp remains the captured event time rather than
    the later render time.
12. Confirm mouse rows use `LM ↓`, `LM ↑`, `RM ↓`, `RM ↑`, `3M ↓`, `3M ↑`,
    and numbered additional-button labels such as `4M ↓`, `4M ↑`, `5M ↓`, and
    `5M ↑`.
13. Confirm scroll rows use `SM ↑` and `SM ↓` based on physical gesture
    direction, independent of macOS natural scrolling settings.
14. Close the panel and confirm no additional input is captured or written.
15. Reopen the panel with default settings and confirm the table starts empty.
16. Enable event table preservation in Settings, reopen the panel during the
    same app launch, and confirm visible rows restore without being copied into
    the new log file.

## Settings Review

- Event table row limit defaults to `15`.
- Event table row limit accepts values from `5` through `50`.
- Invalid persisted row limits are repaired to a valid value.
- Event table preservation defaults to disabled.
- Event table preservation persists as a preference, but rows clear on app quit.

## Log Files

- Each panel open creates a file under:

```text
~/Library/Logs/OverlayClockTimer/YYYY-MM-DD_HH-MM-SS.log
```

- Reopening the panel creates a new file.
- Preserved in-memory rows are not written into the new file.
- Each log line contains only the timestamp, one tab character, and the event
  name:

```text
00:00:00.000	Command+C
```

- Log lines must not contain `order=`, `timestamp=`, `category=`, `type=`,
  `name=`, or `phase=`.
- Log files remain local to the Mac.

## Expected Project Layout

```text
OverlayClockTimer/
├── InputLogging/
├── Overlay/
├── Preferences/
└── Settings/

OverlayClockTimerTests/
├── InputLoggingTests/
├── PreferencesTests/
└── PerformanceTests/

OverlayClockTimerUITests/
└── OverlayClockTimerUITests.swift
```

## Final Validation

```bash
xcodebuild build -scheme OverlayClockTimer -destination 'platform=macOS'
xcodebuild test -scheme OverlayClockTimer -destination 'platform=macOS'
```

The final test suite must include a performance or UI-level check that fails if
new rows are stored with correct timestamps but the visible table update is
delayed beyond the display-refresh target.
