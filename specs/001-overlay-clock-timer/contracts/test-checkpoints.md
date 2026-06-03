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

### 2026-06-03 - Clock Overlay

- Command: `xcodebuild test -scheme OverlayClockTimer -destination 'platform=macOS'`
- Result: PASS with Xcode 26.2 on macOS destination `My Mac`.
- Evidence: App, unit test, and UI test targets built successfully; US1 coverage for injected clock display model dates, borderless `.floating` overlay window configuration, show/hide reuse, frame restore, drag/move frame persistence, off-screen recovery persistence, and visible overlay smoke flow passed with 0 failures.
- Note: The initial sandboxed command failed because Xcode could not write to the default DerivedData location. The same command succeeded after approved elevated execution.

### 2026-06-03 - Timer Mode

- Command: `xcodebuild test -scheme OverlayClockTimer -destination 'platform=macOS'`
- Result: PASS with Xcode 26.2 on macOS destination `My Mac`.
- Evidence: App, unit test, and UI test targets built successfully; US2 coverage for timer start, pause, resume, stop/reset, non-negative elapsed math, Loop capture/replacement, injected monotonic time, live elapsed formatting, button state derivation, Timer mode control enabled states, and secondary latest Loop display passed with 0 failures.

### 2026-06-03 - Mode Switching

- Command: `xcodebuild test -scheme OverlayClockTimer -destination 'platform=macOS'`
- Result: PASS with Xcode 26.2 on macOS destination `My Mac`.
- Evidence: App, unit test, and UI test targets built successfully; US3 coverage for mode-switch action defaults and corrupted stored values, continue/pause/stop-reset/default timer behavior on mode switch, app-level display-mode switching, and mode switch availability/separation in Clock and Timer layouts passed with 0 failures.

### 2026-06-03 - Settings Preferences

- Command: `xcodebuild test -scheme OverlayClockTimer -destination 'platform=macOS'`
- Result: PASS with Xcode 26.2 on macOS destination `My Mac`.
- Evidence: App, unit test, and UI test targets built successfully; US4 coverage for preference persistence and clamping, hotkey conflict rejection and replacement, launch-at-login success/failure consistency, Dock visibility while preserving the menu-bar status item, and opening a separate settings window without hiding the overlay passed with 0 failures.

### 2026-06-03 - Polish Accessibility and Performance

- Command: `xcodebuild test -scheme OverlayClockTimer -destination 'platform=macOS'`
- Result: PASS with Xcode 26.2 on macOS destination `My Mac`.
- Evidence: Added regression coverage for icon-only accessibility labels,
  disabled control states, stable focus target dimensions, and settings
  reachability. Added performance coverage for SC-001 launch-to-readable-overlay
  under 2 seconds, SC-004 60-second timer accuracy within 50 ms, SC-006 live
  theme/opacity/size/font preference application under 1 second, ticker cadence,
  idle ticker cancellation, and primary timer command response under 150 ms.
- Manual visual verification: During the foreground UI automation run, the
  default system appearance overlay and separate settings window were visible
  and readable. Light, dark, and opacity behavior remain covered by live
  preference application tests and the final settings checklist; no truncation or
  unreadable text was observed at the default overlay frame.

### 2026-06-03 - Whitespace Validation

- Command: `git diff --check -- OverlayClockTimer OverlayClockTimerTests OverlayClockTimerUITests specs/001-overlay-clock-timer/tasks.md`
- Result: PASS.
- Evidence: No whitespace errors were reported.

### 2026-06-03 - Final Build

- Command: `xcodebuild build -scheme OverlayClockTimer -destination 'platform=macOS'`
- Result: PASS with Xcode 26.2 on macOS destination `My Mac`.
- Evidence: App target built, signed locally, validated, and registered with
  Launch Services successfully.
- Note: The initial sandboxed command failed because Xcode could not write to
  the default DerivedData location. The same command succeeded after approved
  elevated execution.

### 2026-06-03 - Final Test

- Command: `xcodebuild test -scheme OverlayClockTimer -destination 'platform=macOS'`
- Result: PASS with Xcode 26.2 on macOS destination `My Mac`.
- Evidence: Full unit, performance, and UI automation suite passed with 0
  failures. UI coverage includes overlay launch/show/hide, Timer controls, Loop
  display, mode-switch separation, settings-window reachability, and
  accessibility label/disabled-state regression checks.

### 2026-06-03 - Quickstart Validation

- Validated commands:
  - `xcodebuild build -scheme OverlayClockTimer -destination 'platform=macOS'`
  - `xcodebuild test -scheme OverlayClockTimer -destination 'platform=macOS'`
- Result: PASS.
- Evidence: The completed Xcode project builds and the automated test suite
  launches the app, shows the overlay, opens settings, switches modes, and runs
  Timer controls end to end.
- Follow-up gaps: None recorded.

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
- Launch-at-login failures keep persisted state consistent with system state.
- Settings open in a separate window without hiding the overlay.

### Performance

- Display ticker is capped at display cadence.
- Idle overlay avoids busy-wait behavior.
- SC-001 fresh launch to readable overlay remains under 2 seconds.
- SC-004 60-second timer accuracy remains within 50 ms.
- SC-006 saved or applied appearance changes reach the overlay within 1 second.
- Primary button response remains below 150 ms in test or profiling evidence.
