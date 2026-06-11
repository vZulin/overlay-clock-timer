# Implementation Plan: Input Event Logging

**Branch**: `002-input-event-logging` | **Date**: 2026-06-11 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/002-input-event-logging/spec.md`

## Summary

Add a user-visible input event logging panel to the existing native macOS
Overlay Clock Timer app. The overlay gains an icon-only log toggle immediately
left of the Clock/Timer switch; opening it expands the overlay downward, starts
a new local logging session file, and activates keyboard/mouse event capture.
Closing the panel stops capture and file writes immediately. Visible rows are
newest-first, bounded by a configurable row limit, empty by default on each open,
and optionally preserved in memory only during the current app launch.

The implementation stays Apple-native: Swift 6 mode, SwiftUI views/settings,
AppKit for overlay/window integration, CoreGraphics/AppKit event observation,
Foundation file I/O, UserDefaults preferences, and XCTest/UI tests. No
third-party dependencies are planned.

## Technical Context

**Language/Version**: Swift 6 language mode with Xcode 26.x; use the Swift 6.3 compiler where available in the selected Xcode 26.x toolchain
**Primary Dependencies**: SwiftUI, AppKit, CoreGraphics, Foundation, XCTest; no third-party dependencies
**Storage**: UserDefaults for input logging preferences; in-memory table rows for visible/preserved UI history; local session log files under `~/Library/Logs/OverlayClockTimer/`
**Testing**: XCTest unit/integration tests, Xcode UI tests where practical, `xcodebuild test`
**Target Platform**: macOS Tahoe 26.0+ only
**Project Type**: Native macOS menu-bar app with visible status item and floating overlay window
**Performance Goals**: Open the logging panel and show the table within 200 ms; keep visible table operations bounded to 50 rows; stop event capture and file writes immediately on panel close; avoid sustained CPU usage above the existing idle overlay budget when logging is closed; append log records without blocking overlay interaction
**Constraints**: Logging activates only while the panel is open; no capture while collapsed; no network, sync, telemetry, or server runtime; preserve always-on-top titleless draggable overlay behavior; support light/dark appearance; event table preservation is in-memory only and clears on app quit
**Scale/Scope**: Single-user local desktop diagnostic feature; visible table capped at 5-50 rows; session log files can grow during an open panel session but are local user artifacts

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **macOS-only scope**: PASS. The plan targets macOS Tahoe 26.0+ only and
  rejects web, server, mobile, and cross-platform runtimes.
- **Explicit Apple-native stack**: PASS. Swift 6 mode, Xcode 26.x, SwiftUI,
  AppKit, CoreGraphics, Foundation, UserDefaults, local files, XCTest, and Xcode
  UI tests are named explicitly.
- **Overlay/menu-bar contract**: PASS. The visible status item remains required.
  The existing compact floating overlay remains titleless, draggable, and
  always on top; logging expands downward only while the panel is open.
- **Dependency discipline**: PASS. No third-party dependency is planned.
- **Theme and performance**: PASS. The plan keeps light/dark support, bounded
  table rendering, immediate capture teardown, no busy-wait loops, and local
  file writes off the critical overlay path.
- **Test-first gates**: PASS. Each behavior slice starts with automated tests and
  ends with `xcodebuild test -scheme OverlayClockTimer -destination 'platform=macOS'`.
- **Input logging privacy constraint**: PASS. The feature records user-visible
  input event labels only while the panel is open, with strict limits: visible
  user activation, no background logging, no network, local files only, no
  durable table preservation, no app/window metadata, and no hidden capture.

## Research Summary

Phase 0 decisions are recorded in [research.md](./research.md). No unresolved
clarification markers remain.

Key decisions:

- Use an Apple-native event observer installed only while the logging panel is
  open and removed synchronously on close.
- Model visible table history separately from durable session log files.
- Persist only user preferences; table preservation is in-memory for the current
  app launch.
- Reuse existing time formatting stores for Clock and Timer timestamps.

## Architecture

### Input Logging Domain

- `InputEventRecord`: immutable value representing one captured keyboard or
  mouse event with timestamp, category, name, optional phase, and capture order.
- `InputEventStore`: `@MainActor` observable store for panel state, newest-first
  rows, row-limit trimming, default empty-open behavior, same-launch row
  preservation, and file-recording status.
- `InputEventObserver`: Apple-native event observation adapter. It starts only
  when the panel opens and stops immediately when the panel closes.
- `InputEventNameFormatter`: formats keyboard character keyDown events,
  modifier combinations, and mouse phases into user-facing event names.
- `EventTimestampProvider`: derives a timestamp string from the current display
  mode: Clock uses wall-clock `HH:MM:SS.mmm`; Timer uses the visible timer value
  and `00:00:00.000` when idle or reset.
- `LogSessionWriter`: creates and appends to one local session file for each
  panel open. It never writes preserved rows into a new session file.

### UI Integration

- Extend `OverlayToolbarView` with a logging toggle placed immediately before
  the mode switch in both Clock and Timer layouts.
- Extend `OverlayRootView` to compose the current time/timer display, toolbar,
  and optional `InputEventTableView`.
- The expanded panel grows downward and must not replace the existing drag
  region, primary time display, timer controls, or mode switch.
- The table renders newest-first rows up to the configured row limit. Empty
  default opens render an empty table state.
- `InputEventTableView` uses stable row heights so row count changes do not
  resize individual rows unpredictably.

### Settings Integration

- Extend `OverlayPreferences` with input logging preferences:
  - `eventTableRowLimit`: default `15`, valid range `5...50`.
  - `preserveEventTableBetweenOpens`: default `false`.
- Extend `UserDefaultsPreferencesStore` with typed keys and validation for the
  new settings.
- Add input logging controls to the existing settings window. Do not introduce a
  separate settings window.
- Missing or corrupted persisted row limits use the default `15`; numeric
  persisted values below `5` or above `50` are clamped to the nearest valid
  bound during load/validation.

### File Logging

- Each panel open creates one file under
  `~/Library/Logs/OverlayClockTimer/YYYY-MM-DD_HH-MM-SS.log`.
- If a file with the same timestamp name already exists, the writer must choose
  a collision-safe variant for that session while preserving the requested base
  naming format.
- Each captured event is appended while the panel is open.
- Closing the panel closes the writer and prevents additional writes.
- File creation failure leaves the table usable and exposes a file-recording
  unavailable state.

### Event Capture Semantics

- Keyboard character-producing keyDown events are recorded one-to-one, including
  repeat events.
- Modifier combinations are recorded as one event with canonical modifier order:
  `Control`, `Option`, `Shift`, `Command`, then the key.
- Classification precedence: if a keyDown produces visible text, record it as
  one character-producing keyDown event; otherwise, record modifier shortcuts as
  one canonical combination event.
- Mouse down and mouse up are recorded as distinct event names.
- The feature must not capture or store active app names, window titles, text
  field identifiers, coordinates, clipboard contents, or process metadata.

### Permissions and Failure Handling

- If macOS permissions prevent observing input outside the app, the panel
  remains usable and shows that input events are unavailable until permissions
  allow observation.
- Capture setup failures must not create hidden background retries.
- Capture teardown must be idempotent so rapid open/close cycles do not leave an
  observer running.

## Project Structure

### Documentation (this feature)

```text
specs/002-input-event-logging/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   ├── input-logging-ui-contract.md
│   ├── input-logging-settings-contract.md
│   └── input-logging-file-contract.md
├── checklists/
│   ├── requirements.md
│   └── input-logging.md
└── tasks.md
```

### Source Code (repository root)

```text
OverlayClockTimer/
├── App/
│   └── AppCoordinator.swift
├── InputLogging/
│   ├── EventTimestampProvider.swift
│   ├── InputEventNameFormatter.swift
│   ├── InputEventObserver.swift
│   ├── InputEventRecord.swift
│   ├── InputEventStore.swift
│   └── LogSessionWriter.swift
├── Overlay/
│   ├── OverlayRootView.swift
│   ├── OverlayToolbarView.swift
│   └── InputEventTableView.swift
├── Preferences/
│   ├── OverlayPreferences.swift
│   └── UserDefaultsPreferencesStore.swift
└── Settings/
    ├── InputLoggingSettingsView.swift
    └── SettingsWindowView.swift

OverlayClockTimerTests/
├── InputLoggingTests/
│   ├── EventTimestampProviderTests.swift
│   ├── InputEventNameFormatterTests.swift
│   ├── InputEventObserverTests.swift
│   ├── InputEventStoreTests.swift
│   └── LogSessionWriterTests.swift
├── PreferencesTests/
│   └── PreferencesStoreTests.swift
└── PerformanceTests/
    └── InputLoggingPerformanceTests.swift

OverlayClockTimerUITests/
└── OverlayClockTimerUITests.swift
```

**Structure Decision**: Add a dedicated `InputLogging/` domain folder for
capture, naming, timestamping, table state, and session file writing. Keep UI in
`Overlay/` and preference editing in `Settings/` to preserve existing project
boundaries. Extend existing preference storage rather than creating a parallel
settings subsystem.

## Phase 0: Research

See [research.md](./research.md).

## Phase 1: Design and Contracts

Design artifacts produced:

- [data-model.md](./data-model.md)
- [contracts/input-logging-ui-contract.md](./contracts/input-logging-ui-contract.md)
- [contracts/input-logging-settings-contract.md](./contracts/input-logging-settings-contract.md)
- [contracts/input-logging-file-contract.md](./contracts/input-logging-file-contract.md)
- [quickstart.md](./quickstart.md)

## Constitution Check - Post-Design

- **macOS-only scope**: PASS. Contracts and data model remain macOS-only.
- **Explicit Apple-native stack**: PASS. Design uses existing SwiftUI/AppKit,
  CoreGraphics, Foundation, UserDefaults, local files, and XCTest.
- **Overlay/menu-bar contract**: PASS. Contracts preserve the existing overlay,
  menu-bar status item, mode switch, timer display, drag region, and light/dark
  behavior.
- **Dependency discipline**: PASS. No external dependencies were introduced.
- **Theme and performance**: PASS. Row counts are bounded, preserved rows are
  memory-only, file writes are session-scoped, and logging is inactive while the
  panel is closed.
- **Test-first gates**: PASS. Contracts and quickstart identify test coverage
  and `xcodebuild test` checkpoints.
- **Input logging privacy constraint**: PASS. Contracts limit capture to explicit
  open-panel sessions and prohibit background capture, network transfer, durable
  preserved table rows, and metadata capture beyond event
  category/name/phase/timestamp/order.

## Complexity Tracking

No constitution violations remain after the logging privacy constraint was
expanded to allow explicit, visible, local-only input-event logging with strict
metadata exclusions and open-panel-only capture.
