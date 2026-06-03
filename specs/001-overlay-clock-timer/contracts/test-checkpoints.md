# Test Checkpoint Contract

## Scope

Every implementation phase must include automated tests before implementation
and must end with a passing test command. Expected test results must not be
changed to match incorrect behavior.

## Required Command

```bash
xcodebuild test -scheme OverlayClockTimer -destination 'platform=macOS'
```

## Checkpoint Log

### 2026-06-03 - Setup

- Command: `xcodebuild test -scheme OverlayClockTimer -destination 'platform=macOS'`
- Result: PASS with Xcode 26.2 on macOS destination `My Mac`.
- Evidence: App, unit test, and UI test targets built successfully; `OverlayClockTimerTests.testProjectBootstrapBuilds()` and `OverlayClockTimerUITests.testUITestBundleLoads()` passed with 0 failures.
- Note: The initial sandboxed run failed because Xcode could not write to the default DerivedData location. The same command succeeded after approved elevated execution.

### 2026-06-03 - Foundation

- Command: `xcodebuild test -scheme OverlayClockTimer -destination 'platform=macOS'`
- Result: PASS with Xcode 26.2 on macOS destination `My Mac`.
- Evidence: App, unit test, and UI test targets built successfully; foundation coverage for time sources, clock formatting, elapsed duration formatting, display ticker cadence/cancellation, preference defaults/clamping/corruption handling/status-item invariant/Dock persistence, and visible-screen frame recovery passed with 0 failures.

## Phase Checkpoints

### Setup

- App target exists.
- Unit test target exists.
- UI test target exists.
- Test command runs successfully.

### Clock Overlay

- Clock formatter outputs `HH:mm:ss.SSS`.
- Overlay show/hide command is testable.
- Window frame persistence is testable.
- Theme adaptation has automated or documented manual verification.

### Timer Mode

- Start transitions to running.
- Pause transitions to paused.
- Stop/Reset transitions to reset.
- Loop captures a secondary elapsed value without hiding the live timer.
- Timer elapsed calculation uses injected monotonic time.

### Mode Switching

- Continue keeps timer running.
- Pause pauses timer.
- Stop and reset clears timer.
- Default action is stop and reset.

### Settings

- Preferences persist across store reload.
- Invalid values are clamped or reset.
- Menu-bar status item visibility remains enabled while Dock icon visibility is
  configurable.
- Hotkey conflicts are rejected or replaced explicitly.

### Performance

- Display ticker is capped at display cadence.
- Idle overlay avoids busy-wait behavior.
- SC-001 fresh launch to readable overlay remains under 2 seconds.
- SC-004 60-second timer accuracy remains within 50 ms.
- SC-006 saved or applied appearance changes reach the overlay within 1 second.
- Primary button response remains below 150 ms in test or profiling evidence.
