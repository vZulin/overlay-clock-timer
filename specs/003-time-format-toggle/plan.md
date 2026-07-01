# Implementation Plan: Time Format Toggle

**Branch**: `003-time-format-toggle` | **Date**: 2026-07-01 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/003-time-format-toggle/spec.md`

## Summary

Add a display-only time format preference that switches the overlay between the
existing `HH:mm:ss.SSS` format and epoch milliseconds. Clock mode uses true
13-digit Unix epoch milliseconds. Timer mode uses a 13-digit, left-zero-padded
elapsed milliseconds value from zero because the timer is a duration, not an
absolute wall-clock timestamp.

The implementation will extend the existing formatter, preference, overlay, and
input logging paths without changing timer state semantics, log file session
ownership, or the overlay default size. The new icon-only `Epoch Toggle` control
will fit in the existing toolbar by tightening timer-mode control spacing and
button metrics while preserving accessibility labels, tooltips, light/dark
readability, and UI test identifiers.

## Technical Context

**Language/Version**: Swift 6 language mode with Xcode 26.x; use the Swift 6.3 compiler where available in the selected Xcode 26.x toolchain
**Primary Dependencies**: SwiftUI, AppKit, Foundation, XCTest; no third-party dependencies
**Storage**: UserDefaults for the selected time format preference; existing local input log files remain under `~/Library/Logs/OverlayClockTimer/`
**Testing**: XCTest unit/integration tests, Xcode UI tests, `xcodebuild build`, and `xcodebuild test`
**Target Platform**: macOS Tahoe 26.0+
**Project Type**: Native macOS menu-bar app with floating overlay window
**Performance Goals**: Format switching visible in under 1 second; timer remains within the existing 50 ms accuracy target after 60 seconds and at least 10 format switches; no busy-wait loops; no extra input logging work while the panel is closed; default overlay size remains 280x160 px
**Constraints**: macOS-only, always-on-top compact overlay, custom drag region, no default size increase, light/dark theme support, local-only preferences and logs, display-only format switching, no rewrite of previously captured input event rows or log lines
**Scale/Scope**: Single-user local desktop utility; one persisted time format preference; existing Clock, Timer, Loop, and Input Logging behavior stays in scope

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- macOS-only scope: PASS. The plan targets macOS Tahoe 26.0+ only and does not
  introduce iOS, web, server, or cross-platform runtime requirements.
- Explicit Apple-native stack: PASS. Swift 6, SwiftUI, AppKit, Foundation,
  XCTest, Xcode 26.x, and `xcodebuild` are named. No third-party dependency is
  introduced.
- Overlay/menu-bar contract: PASS. The menu-bar status item and separate
  floating overlay remain intact; the overlay stays compact, always-on-top,
  titleless, and draggable through the existing drag region.
- Dependency discipline: PASS. Apple-native formatters, SwiftUI controls,
  UserDefaults, and XCTest cover the feature.
- Theme and performance: PASS. The plan preserves adaptive styling, avoids
  busy-wait loops, keeps the existing timer source, and defines measurable
  format-switch and timer-accuracy targets.
- Test-first gates: PASS. Unit, integration, and UI automation coverage are
  planned before implementation, with documented `xcodebuild` checkpoints that
  must pass after each implementation phase.

## Project Structure

### Documentation (this feature)

```text
specs/003-time-format-toggle/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   ├── test-checkpoints.md
│   ├── time-format-display-contract.md
│   ├── time-format-logging-contract.md
│   └── time-format-ui-contract.md
└── tasks.md
```

### Source Code (repository root)

```text
OverlayClockTimer/
├── App/
│   └── AppCoordinator.swift
├── Clock/
│   ├── ClockDisplayModel.swift
│   └── ClockFormatter.swift
├── DesignSystem/
│   ├── OverlayMetrics.swift
│   └── SymbolButtonStyle.swift
├── InputLogging/
│   └── EventTimestampProvider.swift
├── Overlay/
│   ├── OverlayRootView.swift
│   └── OverlayToolbarView.swift
├── Preferences/
│   ├── OverlayPreferences.swift
│   └── UserDefaultsPreferencesStore.swift
└── Timer/
    ├── DurationFormatter.swift
    └── TimerSessionStore.swift

OverlayClockTimerTests/
├── ClockTests/
├── InputLoggingTests/
├── OverlayTests/
├── PreferencesTests/
├── TimerTests/
└── PerformanceTests/

OverlayClockTimerUITests/
└── OverlayClockTimerUITests.swift
```

**Structure Decision**: Keep the feature inside the existing app, formatter,
preferences, overlay, timer, and input logging folders. Add no target, package,
or external module. Add test coverage in the existing XCTest and UI test
targets.

## Design Notes

- Add a canonical `TimeFormatPreference` with two values:
  `standardMilliseconds` and `epochMilliseconds`.
- Add a formatter surface that can format both wall-clock `Date` values and
  elapsed `TimeInterval` values for the selected time format.
- Clock epoch output is a 13-digit decimal integer representing milliseconds
  since the Unix epoch.
- Timer epoch output is a 13-digit, left-zero-padded decimal integer
  representing elapsed milliseconds from zero.
- Millisecond conversion uses non-negative integer milliseconds and must not
  round a duration into the future.
- The selected format is stored in the existing `OverlayPreferences` and
  `UserDefaultsPreferencesStore` path.
- Format switching refreshes visible Clock, Timer, and latest Loop text without
  changing timer session state.
- `EventTimestampProvider` formats timestamps at capture time using the active
  display mode and selected time format.
- `InputEventRecord.timestamp` remains an immutable string so old rows and old
  log lines are not reformatted after a later preference change.
- Add an icon-only `Epoch Toggle` control in both Clock and Timer toolbars with
  stable accessibility identifiers: `clock.timeFormatToggle` and
  `timer.timeFormatToggle`.
- Compact toolbar metrics only inside the existing overlay footprint. The plan
  permits tighter spacing and button size adjustments, but not an increase to
  the default collapsed overlay width or height.
- UI tests must cover control presence, reversible switching, timed Clock
  switching, timer continuity, active logging timestamp changes, unchanged old
  log rows, and no default-size growth.
- The `Epoch Toggle` icon must complete macOS design review and sketch acceptance
  before implementation changes are made in `OverlayToolbarView`.

## Phase 0: Research

Research is complete in [research.md](./research.md). Design decisions include:

- Use epoch milliseconds, not seconds plus a fractional millisecond suffix.
- Use elapsed milliseconds for Timer mode because the timer is a duration.
- Persist time format as an existing local overlay preference.
- Store formatted timestamps on input event records at capture time.
- Tighten the toolbar layout without increasing default overlay dimensions.

No unresolved clarification items remain.

## Phase 1: Design & Contracts

Design outputs produced by this planning pass:

- [data-model.md](./data-model.md): defines `TimeFormatPreference`,
  `TimeFormatter`, `FormattedTimeValue`, `FormatToggleControl`, and the
  timestamp preservation rule for logging.
- [contracts/time-format-display-contract.md](./contracts/time-format-display-contract.md):
  defines Clock, Timer, Loop, and preference format behavior.
- [contracts/time-format-ui-contract.md](./contracts/time-format-ui-contract.md):
  defines toolbar placement, icon behavior, accessibility, layout, and UI test
  identifiers.
- [contracts/time-format-logging-contract.md](./contracts/time-format-logging-contract.md):
  defines input logging timestamp behavior before and after format switches.
- [contracts/test-checkpoints.md](./contracts/test-checkpoints.md): defines
  unit, integration, UI, build, and full-suite checkpoints that must pass.
- [quickstart.md](./quickstart.md): documents build, targeted tests, UI tests,
  full regression tests, and manual review.

## Phase 2 Planning Notes

Implementation tasks generated later by `/speckit.tasks` must include the
following test-first checkpoints:

1. Add failing formatter and preference unit tests for epoch milliseconds,
   invalid preference fallback, and persistence.
2. Add failing Clock and Timer store tests proving format switching is
   display-only, completes visibly in under 1 second for Clock mode, and does not
   pause, reset, or restart the timer.
3. Add failing looped Timer reliability tests for 10 running format-switch
   trials.
4. Add failing input logging tests proving new records use the current format,
   existing rows/log lines remain unchanged, log file names remain unchanged, and
   10 looped logging trials preserve mixed-format history correctly.
5. Add failing UI tests for the new toggle in Clock mode, Timer mode, expanded
   logging state, default-size layout, and light/dark opacity checks at 60%, 90%,
   and 100%.
6. Complete the macOS design review and accepted sketch checkpoint before icon
   implementation.
7. Implement production changes only after the targeted tests fail for the
   intended reason.
8. Run targeted tests after each story implementation.
9. Run `xcodebuild test -scheme OverlayClockTimer -destination 'platform=macOS'`
   before the feature is considered complete.
10. Run `xcodebuild build -scheme OverlayClockTimer -destination 'platform=macOS'`
   for the final build checkpoint.

## Post-Design Constitution Check

- macOS-only scope: PASS.
- Apple-native stack and dependency discipline: PASS.
- Overlay/menu-bar contract: PASS. The default overlay size remains fixed and
  the new control fits through toolbar compaction.
- Theme and performance: PASS. The plan uses existing refresh lifecycles and
  avoids new background work.
- Test-first gates: PASS. Formatter, preference, timer, logging, UI, build, and
  full-suite checkpoints are documented.
- Privacy/local-only constraints: PASS. The feature only changes timestamp
  formatting and does not add telemetry, network sync, or new durable history.

## Complexity Tracking

No constitution violations.
