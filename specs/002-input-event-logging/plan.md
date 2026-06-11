# Implementation Plan: Input Event Logging

**Branch**: `002-input-event-logging` | **Date**: 2026-06-11 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/002-input-event-logging/spec.md`

**Note**: This plan was updated after clarification changed the visible table and
session log format to expose only `Time` and `Event`.

## Summary

Add input event logging to the existing macOS menu-bar overlay. The overlay gets
an icon-only logging toggle that opens a downward-expanded recent-events panel,
starts scoped input capture, and creates one local session log file per panel
open. Rows are newest-first and show only two user-facing fields: `Time` and
`Event`. Log lines use the same minimal shape:
`<timestamp><TAB><event name>`.

Keyboard events keep existing character and modifier-combination semantics.
Mouse input is normalized into compact labels for left, right, third, and
numbered additional buttons: `LM ↓`, `LM ↑`, `RM ↓`, `RM ↑`, `3M ↓`, `3M ↑`,
and labels such as `4M ↓`, `4M ↑`, `5M ↓`, and `5M ↑`. Scroll direction is
normalized as `SM ↑` and `SM ↓`. Internal capture order may still exist for
stable sorting, but order, category/type, and phase are not displayed or written
to session log files.

## Technical Context

**Language/Version**: Swift 6 language mode with Xcode 26.x; use the Swift 6.3 compiler where available in the selected Xcode 26.x toolchain
**Primary Dependencies**: SwiftUI, AppKit, CoreGraphics, Foundation, XCTest; no third-party dependencies
**Storage**: UserDefaults for input logging preferences; in-memory table rows for visible/preserved UI history; local session log files under `~/Library/Logs/OverlayClockTimer/`
**Testing**: XCTest unit/integration tests, Xcode UI tests where practical, `xcodebuild test`
**Target Platform**: macOS Tahoe 26.0+
**Project Type**: Native macOS menu-bar app with floating overlay window
**Performance Goals**: Panel open and empty table visible within 200 ms; input formatting and log append must not block overlay controls; no input observers while panel is closed; no busy-wait loops
**Constraints**: Always-on-top compact overlay, custom drag region, light/dark theme support, local-only logs, no background input logging, no app/window/process/coordinate/clipboard/text-field/network metadata
**Scale/Scope**: Single-user local desktop utility; visible row limit defaults to 15 and clamps to 5...50; session log line count is unbounded by the visible row limit

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- macOS-only scope: PASS. The plan targets macOS Tahoe 26.0+ only and does not
  introduce iOS, web, server, or cross-platform runtime requirements.
- Explicit Apple-native stack: PASS. Swift 6, SwiftUI, AppKit, CoreGraphics,
  Foundation, XCTest, Xcode 26.x, and `xcodebuild` are named. No third-party
  dependencies are introduced.
- Overlay/menu-bar contract: PASS. The existing menu-bar status item and
  separate floating overlay remain intact; the logging panel expands downward
  from the overlay and collapses back to the compact Clock/Timer surface.
- Dependency discipline: PASS. Apple-native event observation and file writing
  cover the requirement; no dependency exception is needed.
- Theme and performance: PASS. The panel uses existing adaptive overlay styling,
  scoped observers, no busy-wait loops, and measurable panel-open latency.
- Test-first gates: PASS. Unit, integration, and UI automation coverage are
  planned for every changed behavior, with `xcodebuild test` checkpoints.

## Project Structure

### Documentation (this feature)

```text
specs/002-input-event-logging/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   ├── input-logging-file-contract.md
│   ├── input-logging-settings-contract.md
│   ├── input-logging-ui-contract.md
│   └── test-checkpoints.md
└── tasks.md
```

### Source Code (repository root)

```text
OverlayClockTimer/
├── App/
│   ├── AppCoordinator.swift
│   └── OverlayClockTimerApp.swift
├── InputLogging/
│   ├── EventTimestampProvider.swift
│   ├── InputEventNameFormatter.swift
│   ├── InputEventObserver.swift
│   ├── InputEventRecord.swift
│   ├── InputEventStore.swift
│   └── LogSessionWriter.swift
├── Overlay/
│   ├── InputEventTableView.swift
│   ├── OverlayRootView.swift
│   └── OverlayToolbarView.swift
├── Preferences/
└── Settings/

OverlayClockTimerTests/
├── InputLoggingTests/
├── PreferencesTests/
└── PerformanceTests/

OverlayClockTimerUITests/
└── OverlayClockTimerUITests.swift
```

**Structure Decision**: Keep input logging domain and adapters under
`OverlayClockTimer/InputLogging/`, integrate UI through existing `Overlay/` and
`Settings/` views, and keep tests in the existing XCTest and UI test targets.
No new target, package, or external module is required.

## Design Notes

- `InputEventRecord` remains the single table/log row model, but public output
  uses only `timestamp` and `eventName`.
- `captureOrder` is internal and exists only for deterministic newest-first row
  ordering and tests.
- Category/type/phase may be represented internally only if useful for adapter
  implementation, but they must not be visible table columns or session log
  fields.
- `InputEventNameFormatter` owns canonical user-facing names for keyboard,
  mouse-button, and scroll events.
- `LogSessionWriter` writes exactly one line per event:
  `<timestamp><TAB><event name>\n`.
- AppKit event observation is scoped to the logging panel open state and is
  removed immediately on close.
- UI tests use a mock capture source by default for development stability. Real
  input-capture tests are explicit and require macOS TCC permissions plus
  `test-without-building`.

## Phase 0: Research

Research is complete in [research.md](./research.md). The format clarification
adds two design decisions:

- User-facing and file output use a minimal record projection: timestamp plus
  event name only.
- Mouse buttons and scroll directions are normalized to compact event labels
  before rows are displayed or written.

No unresolved `NEEDS CLARIFICATION` items remain.

## Phase 1: Design & Contracts

Design outputs updated by this planning pass:

- [data-model.md](./data-model.md): revised `InputEventRecord`,
  `MouseInputEvent`, and added scroll direction modeling.
- [contracts/input-logging-ui-contract.md](./contracts/input-logging-ui-contract.md):
  revised table columns and compact event naming expectations.
- [contracts/input-logging-file-contract.md](./contracts/input-logging-file-contract.md):
  revised session line format to `<timestamp><TAB><event name>`.
- [quickstart.md](./quickstart.md): revised manual checks and log-file examples.

## Post-Design Constitution Check

- macOS-only scope: PASS.
- Apple-native stack and dependency discipline: PASS.
- Overlay/menu-bar contract: PASS.
- Privacy and local-only logging: PASS. The new minimal log format removes
  order, category/type, and phase from durable files.
- Theme and performance: PASS.
- Test-first gates: PASS. Existing tasks must be regenerated or updated before
  implementation to cover compact mouse labels, scroll labels, two-column table
  output, and tab-separated log lines.

## Complexity Tracking

No constitution violations.
