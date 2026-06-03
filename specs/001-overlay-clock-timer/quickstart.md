# Quickstart: Overlay Clock Timer

## Prerequisites

- macOS Tahoe 26.0 or newer as the deployment target.
- Xcode 26.x with command line tools installed.
- Xcode 26.5 or newer is recommended when the project needs the Swift 6.3
  compiler bundled with the toolchain.
- No third-party package manager is required.

## Open the Project

```bash
open OverlayClockTimer.xcodeproj
```

## Build

```bash
xcodebuild build -scheme OverlayClockTimer -destination 'platform=macOS'
```

## Run Automated Tests

Run this command after every implementation phase:

```bash
xcodebuild test -scheme OverlayClockTimer -destination 'platform=macOS'
```

## Run the App

1. Build and run the `OverlayClockTimer` scheme from Xcode.
2. Confirm the menu-bar status item appears.
3. Use the menu-bar status item to show the overlay.
4. Confirm the overlay appears above normal application windows.
5. Drag the overlay by its drag region and verify position persists after
   relaunch.

## Manual Verification Checklist

Use this checklist after a successful final build and test run:

```bash
xcodebuild build -scheme OverlayClockTimer -destination 'platform=macOS'
xcodebuild test -scheme OverlayClockTimer -destination 'platform=macOS'
```

### Clock Mode

- Display format is `HH:MM:SS.mmm`.
- Display updates smoothly.
- The overlay remains readable in light and dark appearance.
- The overlay can be hidden and shown from the menu-bar status item.

### Timer Mode

- Start begins elapsed count-up from `00:00:00.000`.
- Start changes to Pause while running.
- Pause freezes the displayed value.
- Stop/Reset resets to `00:00:00.000`.
- Loop is enabled only while running.
- Loop saves a secondary elapsed value while the main timer keeps showing live
  elapsed time.
- Pressing Loop again replaces the secondary loop value.

### Mode Switching

- Mode switch is always available.
- Mode switch is visually separate from timer controls.
- Default behavior while timer is running is stop and reset.
- Continue and pause mode-switch settings behave as configured.

### Settings

- Settings open in a separate window.
- Theme selection supports system, light, and dark.
- Opacity, overlay size, and timer font size apply without restart.
- Launch at login can be enabled and disabled.
- The menu-bar status item remains visible; Dock icon visibility can be toggled.
- Hotkey conflicts are rejected or explicitly replaced.

## Expected Project Layout

```text
OverlayClockTimer.xcodeproj/
OverlayClockTimer/
OverlayClockTimerTests/
OverlayClockTimerUITests/
```

## Notes for Implementation

- Timer mode is an elapsed count-up timer in v1.
- DateFormatter is used for current system time only.
- Elapsed timer display uses a custom duration formatter.
- Timer math must use an injected monotonic time source for deterministic tests.
- Final validation includes accessibility regression coverage for icon-only
  controls, deterministic timer accuracy coverage, live preference application
  latency coverage, and full app/UI tests through the `OverlayClockTimer` scheme.
- Final validation on 2026-06-03 with Xcode 26.2 passed the documented build and
  test commands against the completed Xcode project.
