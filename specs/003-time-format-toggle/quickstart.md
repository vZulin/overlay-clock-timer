# Quickstart: Time Format Toggle

## Prerequisites

- macOS Tahoe 26.0 or newer as the deployment target.
- Xcode 26.x with command line tools installed.
- No third-party package manager is required.

## Build

```bash
xcodebuild build -scheme OverlayClockTimer -destination 'platform=macOS'
```

## Run Automated Tests

Run the full test suite after each implementation phase:

```bash
xcodebuild test -scheme OverlayClockTimer -destination 'platform=macOS'
```

Run formatter, timer, preference, and logging tests while implementing the
domain behavior:

```bash
xcodebuild test \
  -scheme OverlayClockTimer \
  -destination 'platform=macOS' \
  -only-testing:OverlayClockTimerTests/ClockTests \
  -only-testing:OverlayClockTimerTests/TimerTests \
  -only-testing:OverlayClockTimerTests/PreferencesTests \
  -only-testing:OverlayClockTimerTests/InputLoggingTests
```

Run UI automation after toolbar, overlay layout, accessibility, or icon changes:

```bash
xcodebuild test \
  -scheme OverlayClockTimer \
  -destination 'platform=macOS' \
  -only-testing:OverlayClockTimerUITests/OverlayClockTimerUITests
```

## Manual Review Flow

1. Build and run the `OverlayClockTimer` scheme from Xcode.
2. Show the overlay from the menu-bar status item.
3. Confirm Clock mode starts in `HH:mm:ss.SSS` when no saved preference exists.
4. Press the time format toggle.
5. Confirm Clock mode changes to a 13-digit epoch milliseconds value.
6. Press the toggle again and confirm Clock mode returns to `HH:mm:ss.SSS`.
7. Switch to Timer mode.
8. Confirm reset Timer shows `00:00:00.000` in standard format.
9. Switch to epoch milliseconds and confirm reset Timer shows
   `0000000000000`.
10. Start the timer and switch formats repeatedly while it runs.
11. Confirm the timer never pauses, resets, or jumps backward except for normal
    formatting precision boundaries.
12. Press Loop, switch formats, and confirm the latest loop value reformats
    without changing the captured elapsed moment.
13. Open input logging, capture at least one event in standard format, switch to
    epoch milliseconds, and capture another event.
14. Confirm old visible rows keep their original timestamp strings while new
    rows use the updated format.
15. Inspect the active session log file and confirm existing lines were not
    rewritten.
16. Confirm the default collapsed overlay size did not increase.
17. Confirm Timer mode controls do not overlap at default size.
18. Repeat visual review in light and dark appearance at 60%, 90%, and 100%
    background opacity.

## Final Manual/UI Results

- Date: 2026-07-01.
- Clock examples remain 13-digit epoch milliseconds with no decimal separator.
- Timer examples remain 13-digit left-zero-padded elapsed milliseconds.
- Mixed-format logging examples preserve old timestamp strings and append new
  rows in the active format.
- Opacity review is recorded in `contracts/test-checkpoints.md` for 60%, 90%,
  and 100% background opacity in light and dark appearance.
- Final Phase 7 command results are recorded in
  `contracts/test-checkpoints.md`.

## Expected Examples

Clock mode in epoch milliseconds:

```text
1782918314123
```

Timer reset in epoch milliseconds:

```text
0000000000000
```

Timer elapsed value after 12.345 seconds in epoch milliseconds:

```text
0000000012345
```

Mixed-format log file after switching format during one session:

```text
12:34:56.789	Command+C
1782918314123	Command+V
```

## Final Validation

```bash
git diff --check -- OverlayClockTimer OverlayClockTimerTests OverlayClockTimerUITests OverlayClockTimer.xcodeproj specs/003-time-format-toggle
xcodebuild build -scheme OverlayClockTimer -destination 'platform=macOS'
xcodebuild test -scheme OverlayClockTimer -destination 'platform=macOS'
```
