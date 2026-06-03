# Implementation Plan: Overlay Clock Timer

**Branch**: `001-overlay-clock-timer` | **Date**: 2026-06-03 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/001-overlay-clock-timer/spec.md`

## Summary

Build a small native macOS Tahoe 26 menu-bar app with a visible status item and
a separate floating overlay window for clock and elapsed timer modes. The app
uses Xcode 26.x, Swift 6 language mode, the Swift 6.3 compiler where available
in the selected Xcode 26.x toolchain, SwiftUI for composition, AppKit for
precise window behavior, Foundation for clock and preference primitives,
ServiceManagement for launch-at-login, and XCTest for test-first delivery. The
overlay is always on top, titleless, draggable through a custom drag region,
persists size/position/preferences with UserDefaults, and uses a compact
KeyCastr-like visual direction based on `UI_Example.png`.

## Technology Stack Decision

### Option A: Xcode 26.x + Swift 6 mode + AppKit window bridge (selected)

- **Stack**: macOS Tahoe 26.0+ target, Xcode 26.x toolchain, Swift 6 language
  mode, Swift 6.3 compiler where available in the selected Xcode 26.x toolchain,
  SwiftUI, AppKit, Foundation, ServiceManagement, XCTest.
- **Strengths**: Native UI, no third-party dependencies, direct access to
  `NSWindow` levels and titleless behavior, SwiftUI settings and overlay views
  remain testable through view models.
- **Trade-offs**: Requires a small AppKit bridge for the overlay window and
  hotkey registration instead of a pure SwiftUI implementation.

### Option B: Swift 5.10 + Xcode 16.x

- **Strengths**: Mature and conservative for older macOS targets.
- **Trade-offs**: Stale for a macOS Tahoe 26 target, lacks the intended Xcode 26
  SDK baseline, and creates avoidable migration work to Swift 6 strict
  concurrency.

### Option C: Swift 6.0 + Xcode 16.x

- **Strengths**: Moves to Swift 6 language mode earlier than Swift 5.10.
- **Trade-offs**: Still tied to the older Xcode 16 generation and does not match
  the requested Xcode 26/macOS Tahoe 26 baseline.

### Option D: Pure AppKit with `NSStatusItem`

- **Strengths**: Maximum control over menu-bar and window behavior.
- **Trade-offs**: More boilerplate and slower UI iteration; settings and adaptive
  layout require more manual code than SwiftUI.

### Option E: Electron, Catalyst, or another cross-platform stack

- **Strengths**: Familiar web UI tooling for some teams.
- **Trade-offs**: Violates the macOS-only native constitution, adds unnecessary
  runtime cost, weakens AppKit window-level control, and increases memory usage.

**Recommendation**: Use Option A. It satisfies the constitution with the fewest
moving parts: SwiftUI for views and settings, AppKit only where macOS window and
menu behavior require it, and no external dependencies. Swift 5.10 is no longer
selected because it was an older conservative baseline from the previous plan.
Swift 6.0 is also not the target because the project now explicitly targets
Xcode 26 and macOS Tahoe 26; use Swift 6 language mode with the newest Swift
compiler bundled in the selected Xcode 26.x toolchain, currently Swift 6.3 in
the latest Xcode 26.x releases.

## Technical Context

**Language/Version**: Swift 6 language mode with Xcode 26.x; use the Swift 6.3 compiler where available in the selected Xcode 26.x toolchain
**Primary Dependencies**: SwiftUI, AppKit, Foundation, ServiceManagement, XCTest; no third-party dependencies
**Storage**: UserDefaults for preferences, Dock visibility, window frame, mode, and timer-on-mode-switch action
**Testing**: XCTest unit/integration tests, Xcode UI tests where practical, `xcodebuild test`
**Target Platform**: macOS Tahoe 26.0+ only
**Project Type**: Native macOS menu-bar app with visible status item and floating overlay window
**Performance Goals**: Show overlay within 2 seconds of launch; keep visible updates at display cadence up to 60 Hz; keep timer input response under 150 ms; keep a 60-second timer within 50 ms of real elapsed time; apply theme, opacity, size, and timer font changes within 1 second; avoid sustained CPU usage above 2% on an idle overlay; keep memory below 80 MB for the running app
**Constraints**: Always-on-top compact overlay, custom drag region, light/dark theme support, low resource usage, no busy-wait loops, test-first checkpoints
**Scale/Scope**: Single-user local desktop utility with no server runtime and no network sync

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **macOS-only scope**: PASS. The plan targets macOS Tahoe 26.0+ only and
  rejects web, server, mobile, and cross-platform runtimes.
- **Explicit Apple-native stack**: PASS. Swift, SwiftUI, AppKit, Foundation,
  ServiceManagement, UserDefaults, Xcode 26.x, and XCTest are named explicitly.
- **Overlay/menu-bar contract**: PASS. The app includes a required visible
  menu-bar status item plus a separate compact floating overlay near 280x160 px,
  titleless draggable behavior, custom drag area, clock mode, and timer mode.
- **Dependency discipline**: PASS. No third-party dependencies are planned.
- **Theme and performance**: PASS. System/light/dark theme options, opacity,
  display-cadence refresh, monotonic timer math, and CPU constraints are planned.
- **Test-first gates**: PASS. Every implementation phase must start with failing
  behavior tests and end with a passing documented test command.

## Architecture

### Application Composition

- `OverlayClockTimerApp`: SwiftUI `App` entry point. Owns top-level scenes:
  `MenuBarExtra`, settings window, and app command wiring.
- `AppCoordinator`: `@MainActor` observable object that coordinates overlay
  visibility, active mode, settings presentation, Dock visibility, the required
  status item, and app lifecycle.
- `OverlayWindowController`: AppKit owner for the floating overlay `NSWindow`.
  Creates, shows, hides, orders front, persists frame, and applies window-level
  and appearance settings.
- `OverlayRootView`: SwiftUI root rendered inside `NSHostingView`. Contains the
  time display, timer controls, mode switch, and drag region.
- `ClockDisplayModel`: Produces formatted current system time using a cached
  fixed-format DateFormatter.
- `TimerSessionStore`: Owns elapsed timer state transitions and exposes the live
  elapsed display plus optional latest loop value to SwiftUI.
- `PreferencesStore`: Loads, validates, publishes, and persists preferences using
  UserDefaults.
- `HotkeyRegistrar`: Registers Apple-native global shortcuts and dispatches them
  to the same commands used by overlay buttons.

### Menu Bar and Settings

- The visible menu-bar status item exposes Show Overlay, Hide Overlay, Settings,
  and Quit.
- Settings are a separate SwiftUI `WindowGroup` with a stable window identifier.
- The menu-bar status item is required by the constitution and is not
  user-hideable.
- Dock visibility is the only configurable app-presence setting and is applied
  through app activation policy updates without hiding the status item.
- Launch at login is applied through ServiceManagement.

### Overlay Window

- Create an `NSWindow` manually in `OverlayWindowController`.
- Use a visually titleless window:
  - `styleMask`: `.borderless`
  - `isOpaque = false`
  - `backgroundColor = .clear`
  - `hasShadow = true`
  - `collectionBehavior` includes joining spaces and full-screen auxiliary
    behavior where supported.
- Apply always-on-top with `window.level = .floating` by default.
- Keep `.statusBar` as a documented fallback only if verification shows
  `.floating` does not satisfy the acceptance scenario for target spaces.
- Persist the final window frame after user drag/resize and restore it on launch.

### Draggable Without Title Bar

Use a dedicated SwiftUI-visible drag region backed by an AppKit view:

1. `DragRegionView` is an `NSViewRepresentable`.
2. The backing `NSView` handles `mouseDown(with:)`.
3. It calls `window?.performDrag(with: event)` so macOS performs native window
   dragging.
4. Timer control hit areas are excluded from the drag region, preventing button
   clicks from starting a window drag.

This is preferable to making the entire window movable by background because the
overlay contains icon buttons and mode controls.

### Time Display

- Clock mode uses a cached `DateFormatter` configured with:
  - `locale = Locale(identifier: "en_US_POSIX")`
  - `dateFormat = "HH:mm:ss.SSS"`
- User-facing text remains `HH:MM:SS.mmm`, but implementation uses lowercase
  `mm` for minutes and uppercase `SSS` for milliseconds because DateFormatter
  format symbols are case-sensitive.
- A `DisplayTicker` publishes refresh events at display cadence, capped at 60 Hz.
- The display may not redraw every 1 ms; instead, every render formats the latest
  accurate time. This avoids busy-wait loops and unnecessary CPU load.

### Timer Mode

The specification describes an elapsed count-up timer, not a countdown timer.
V1 implements stopwatch-style elapsed time from `00:00:00.000`.

- Timer math uses a monotonic time source, not wall-clock `Date`, so system clock
  changes do not corrupt elapsed time.
- `TimerSession` state:
  - `idle`
  - `running(startedAt, accumulatedBeforeStart, latestLoop?)`
  - `paused(accumulatedElapsed, latestLoop?)`
  - `reset`
- Start transitions from `idle`, `paused`, or `reset` into `running`.
- Pause freezes accumulated elapsed and preserves the display value.
- Stop/Reset clears accumulated elapsed and the latest loop value.
- Loop is enabled only in `running`.
- Loop records the current elapsed value as secondary UI content below the main
  timer while the main timer continues showing live elapsed time. Repeated Loop
  presses replace that secondary value. This keeps the compact one-line primary
  display accurate without adding a lap list.
- Elapsed formatting uses a custom `DurationFormatter` for `HH:mm:ss.SSS`.
  DateFormatter is intentionally not used for elapsed durations because it
  formats calendar dates and introduces timezone/day-rollover concerns.

### State Handling

- `DisplayMode`: `clock` or `timer`.
- `ModeSwitchAction`: `continue`, `pause`, `stopAndReset`; default
  `stopAndReset`.
- Switching mode while the timer runs delegates to `TimerSessionStore`:
  - `continue`: preserve `running`.
  - `pause`: transition to `paused`.
  - `stopAndReset`: transition to `reset`.
- Overlay view state is derived from stores. Buttons do not own timer state.

### Persistence

Persist these values with typed UserDefaults keys:

- Overlay frame: `overlay.frame.x`, `overlay.frame.y`, `overlay.frame.width`,
  `overlay.frame.height`.
- Theme: `system`, `light`, `dark`; default `system`.
- Background opacity: bounded decimal range from `0.60` through `1.00`, default
  `0.90`, applied only to the panel background.
- Window size: bounded width/height, default near `280x160`.
- Timer font size: bounded value, default derived from overlay height.
- Last display mode: optional convenience restore.
- Timer-on-mode-switch action: default `stopAndReset`.
- Dock visibility flag; the menu-bar status item remains visible and is not
  persisted as a user-configurable preference.
- Launch-at-login flag.
- Hotkey bindings for Start, Pause, Stop/Reset, Loop, and mode switch.

Restore window position defensively: if the saved frame is outside all visible
screens, center the overlay on the primary display and overwrite the saved frame.

## Overlay Design Mockups

Detailed UI mockups are maintained in [ui-mockups.md](./ui-mockups.md), with a
standalone visual preview at [mockups/ui-mockups.html](./mockups/ui-mockups.html).

### Clock Mode

```text
+------------------------------------------------+
|  drag region                                   |
|                                                |
|              14:11:23.482                      |
|                                                |
+----------------+----------------+----------------+
| settings       | pin            | mode           |
+----------------+----------------+----------------+
```

### Timer Mode - Running

```text
+------------------------------------------------+
|  drag region                         TIMER     |
|                                                |
|              00:00:12.842                      |
|                                                |
+-----------+-----------+-----------+------------+
| reset     | pause     | loop      | mode       |
+-----------+-----------+-----------+------------+
```

### Timer Mode - Running With Loop Value

```text
+------------------------------------------------+
|  drag region                         LOOP      |
|              00:00:12.842                      |
|             Loop 00:00:08.311                  |
+-----------+-----------+-----------+------------+
| reset     | pause     | loop      | mode       |
+-----------+-----------+-----------+------------+
```

### Timer Mode - Idle or Reset

```text
+------------------------------------------------+
|  drag region                         TIMER     |
|                                                |
|              00:00:00.000                      |
|                                                |
+-----------+-----------+-----------+------------+
| reset*    | start     | loop*     | mode       |
+-----------+-----------+-----------+------------+

* disabled visual state
```

### Visual Rules

- Default overlay size: `280x160`.
- Minimum size: `220x124`.
- Maximum size: `520x300`.
- Large monospaced time display with tabular digits.
- Icon-only bottom controls with tooltips and accessibility labels.
- Timer controls are grouped; mode switch is visually separated by spacing or a
  divider.
- Use adaptive materials/colors for system, light, and dark appearance.
- Opacity applies to the overlay background, not directly to text opacity, so
  readability remains stable.

## Project Structure

### Documentation (this feature)

```text
specs/001-overlay-clock-timer/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   ├── overlay-ui-contract.md
│   ├── settings-contract.md
│   └── test-checkpoints.md
└── tasks.md
```

### Source Code (repository root)

```text
OverlayClockTimer.xcodeproj/

OverlayClockTimer/
├── App/
│   ├── OverlayClockTimerApp.swift
│   ├── AppCoordinator.swift
│   ├── MenuBarContentView.swift
│   └── AppVisibilityController.swift
├── Overlay/
│   ├── OverlayWindowController.swift
│   ├── OverlayRootView.swift
│   ├── OverlayToolbarView.swift
│   ├── DragRegionView.swift
│   └── OverlayGeometryStore.swift
├── Clock/
│   ├── ClockDisplayModel.swift
│   ├── ClockFormatter.swift
│   ├── DisplayTicker.swift
│   └── TimeSource.swift
├── Timer/
│   ├── TimerSession.swift
│   ├── TimerSessionStore.swift
│   ├── DurationFormatter.swift
│   └── ModeSwitchAction.swift
├── Settings/
│   ├── SettingsWindowView.swift
│   ├── AppearanceSettingsView.swift
│   ├── HotkeySettingsView.swift
│   ├── TimerSettingsView.swift
│   ├── StartupSettingsView.swift
│   └── VisibilitySettingsView.swift
├── Preferences/
│   ├── PreferencesStore.swift
│   ├── UserDefaultsPreferencesStore.swift
│   ├── OverlayPreferences.swift
│   └── HotkeyBinding.swift
├── Hotkeys/
│   ├── HotkeyRegistrar.swift
│   └── HotkeyCommand.swift
├── DesignSystem/
│   ├── OverlayTheme.swift
│   ├── OverlayMetrics.swift
│   └── SymbolButtonStyle.swift
└── Support/
    ├── LaunchAtLoginController.swift
    └── ScreenFrameValidator.swift

OverlayClockTimerTests/
├── ClockTests/
│   ├── ClockFormatterTests.swift
│   └── DisplayTickerTests.swift
├── TimerTests/
│   ├── TimerSessionTests.swift
│   ├── TimerSessionStoreTests.swift
│   └── DurationFormatterTests.swift
├── PreferencesTests/
│   ├── PreferencesStoreTests.swift
│   └── ScreenFrameValidatorTests.swift
├── OverlayTests/
│   ├── OverlayWindowControllerTests.swift
│   └── OverlayGeometryStoreTests.swift
└── PerformanceTests/
    ├── LaunchOverlayPerformanceTests.swift
    ├── TimerAccuracyPerformanceTests.swift
    ├── PreferenceApplicationPerformanceTests.swift
    └── OverlayTickerPerformanceTests.swift

OverlayClockTimerUITests/
└── OverlayClockTimerUITests.swift
```

**Structure Decision**: Use one native macOS app target plus unit and UI test
targets. Keep timer and formatter logic independent from SwiftUI/AppKit so tests
can run deterministically without waiting for real wall-clock time.

## Test Strategy

- Unit tests first for `ClockFormatter`, `DurationFormatter`, `TimerSession`, and
  `PreferencesStore`.
- AppKit integration tests for window level, frame persistence, and recovery
  from off-screen saved frames where automation is practical.
- UI tests for menu-bar show/hide, settings window launch, and primary timer flow
  where Xcode UI testing can target the app reliably.
- Performance tests for SC-001 launch-to-readable-overlay latency, SC-004
  60-second timer accuracy, SC-006 live preference-application latency, ticker
  cadence, idle overlay CPU-sensitive paths, and primary button response.
- Required checkpoint command after every implementation phase:

```bash
xcodebuild test -scheme OverlayClockTimer -destination 'platform=macOS'
```

## Post-Design Constitution Check

- **macOS-only scope**: PASS. Generated design artifacts target only native
  macOS app behavior.
- **Explicit Apple-native stack**: PASS. `research.md`, this plan, and
  `AGENTS.md` name Xcode 26.x, Swift 6 language mode, Swift 6.3 compiler where
  available, SwiftUI, AppKit, Foundation, ServiceManagement, UserDefaults, and
  XCTest.
- **Overlay/menu-bar contract**: PASS. `overlay-ui-contract.md` and
  `settings-contract.md` cover the floating overlay, required visible status
  item, menu-bar behavior, draggable region, mode controls, Dock visibility, and
  window persistence.
- **Dependency discipline**: PASS. Research rejects third-party dependencies for
  v1.
- **Theme and performance**: PASS. Design contracts cover light/dark appearance,
  opacity, display cadence, timer accuracy, and busy-wait avoidance.
- **Test-first gates**: PASS. `test-checkpoints.md` defines required test
  checkpoints and the recurring `xcodebuild test` command.

## Complexity Tracking

No constitution violations are planned.
