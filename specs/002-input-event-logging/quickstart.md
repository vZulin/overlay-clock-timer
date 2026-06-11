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

Run this command after every implementation phase:

```bash
xcodebuild test -scheme OverlayClockTimer -destination 'platform=macOS'
```

## Manual Review Flow

1. Build and run the `OverlayClockTimer` scheme from Xcode.
2. Show the overlay from the menu-bar status item.
3. Confirm the logging icon appears immediately to the left of the Clock/Timer
   switch.
4. Open the logging panel and confirm the overlay expands downward.
5. Confirm the default table is empty on open.
6. Generate keyboard repeat input and modifier combinations while the panel is
   open.
7. Generate mouse down and mouse up events while the panel is open.
8. Close the panel and confirm no additional input is captured or written.
9. Reopen the panel with default settings and confirm the table starts empty.
10. Enable event table preservation in Settings, reopen the panel during the
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
