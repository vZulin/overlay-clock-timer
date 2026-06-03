# Feature Specification: Overlay Clock Timer

**Feature Branch**: `001-overlay-clock-timer`
**Created**: 2026-06-03
**Status**: Draft
**Input**: User description: "Create a small native macOS application named
Overlay Clock Timer with a floating always-on-top clock/timer overlay, menu-bar
presence, separate settings window, configurable controls, appearance, launch,
visibility, sizing, font, opacity, and explicit technology stack selection."

## Clarifications

### Session 2026-06-03

- Q: Which OS, Xcode, and Swift baseline should the feature target? → A:
  Target macOS Tahoe 26 with Xcode 26.x; use Swift 6 language mode with the
  Swift 6.3 compiler when available in the selected Xcode 26.x toolchain.
- Q: How should the updated UI mockups affect Loop behavior across artifacts? → A:
  The mockups define Loop as a live main timer plus a secondary latest loop
  value; spec, contracts, research, quickstart, checkpoints, data model, and
  plan must stay synchronized with that behavior.
- Q: How should app visibility settings respect the constitution's visible
  status item requirement? → A: The menu-bar status item remains visible; only
  Dock icon visibility is configurable.
- Q: How should "normal app switching" be scoped for always-on-top validation? → A:
  Validate 10 checks within one desktop Space across Finder, a browser, and a
  text editor or document app.
- Q: How should the primary timer flow preserve state in SC-005? → A: Pause
  preserves elapsed time and the latest loop value, resumed Start continues from
  accumulated elapsed time, and only Stop/Reset clears elapsed and loop state.
- Q: How should readability be validated for light and dark appearances? → A:
  Manual review must pass at 60%, 90%, and 100% background opacity, with readable
  time text, readable icon controls, and visibly distinct disabled controls.
- Q: How should locale affect clock and timer display formatting? → A: Use a
  fixed locale-independent 24-hour numeric display, `HH:MM:SS.mmm`, backed by
  deterministic formatter tests.
- Q: What privacy and security scope applies to global hotkeys and preferences? → A:
  Preferences and hotkey bindings stay local only, no telemetry is collected, no
  data is synced or sent over the network, and global hotkeys only dispatch
  configured app commands.

## Constitutional Scope *(mandatory)*

- **Target Platform**: macOS Tahoe 26.0+ only.
- **Application Model**: Native menu-bar app with a visible status item and a
  separate floating overlay window.
- **Overlay Contract**: Compact default size near 280x160 px, always-on-top window
  level, titleless draggable behavior, and custom drag area remain required.
- **Technology Boundary**: The selected stack is Xcode 26.x, Swift 6 language
  mode, the Swift 6.3 compiler where available in the selected Xcode 26.x
  toolchain, SwiftUI for view composition, AppKit for the floating window and
  menu-bar integration, Foundation for time and persistence primitives,
  ServiceManagement for launch-at-login support, Apple-native hotkey handling,
  and XCTest for automated tests. No third-party dependencies are in scope for
  the initial implementation.
- **Quality Boundary**: Every user story must include automated tests and a
  documented command that passes after the story is implemented.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - View Current Time Overlay (Priority: P1)

As a macOS user, I want a compact floating overlay that shows the current system
time with millisecond precision so I can keep precise time visible above normal
windows.

**Why this priority**: This is the core product value and validates the overlay,
menu-bar presence, time formatting, dragging, theme support, and low-resource
behavior.

**Independent Test**: Launch the app, show the overlay from the menu bar, verify
the overlay stays above normal windows, can be dragged, and displays current time
as `HH:MM:SS.mmm`.

**Acceptance Scenarios**:

1. **Given** the app is running, **When** the user opens the menu-bar status
   item and selects show overlay, **Then** the overlay appears as a compact
   titleless panel above normal application windows.
2. **Given** the overlay is visible in Clock mode, **When** time passes, **Then**
   the displayed value uses `HH:MM:SS.mmm` and remains based on current system
   time.
3. **Given** the overlay is visible, **When** the user drags the custom drag
   area, **Then** the overlay moves freely without exposing a standard title bar.
4. **Given** the system appearance changes, **When** the overlay is visible,
   **Then** the overlay adapts to light or dark appearance without losing
   readability.

---

### User Story 2 - Run and Control Timer (Priority: P2)

As a user, I want to switch to Timer mode and control elapsed time with familiar
media-style icon buttons so I can start, pause, loop, and reset timing without
leaving the overlay.

**Why this priority**: Timer mode is the second primary mode and requires the
most precise state behavior.

**Independent Test**: Switch to Timer mode, exercise Start, Pause, Loop, and
Stop/Reset, and verify each button state and displayed time follows the expected
state transitions.

**Acceptance Scenarios**:

1. **Given** Timer mode is selected and no timer has run, **When** the overlay is
   displayed, **Then** Start, Loop, and Stop/Reset are visible as media-style
   icon controls, Loop is disabled, and Stop/Reset is disabled.
2. **Given** Timer mode is selected, **When** the user presses Start, **Then**
   elapsed time starts from `00:00:00.000`, the displayed value advances with
   millisecond precision, and Start changes to Pause.
3. **Given** the timer is running, **When** the user presses Loop, **Then** the
   main timer continues showing live elapsed time and the loop press time is
   saved as a secondary value below the main timer.
4. **Given** a loop value is visible while the underlying timer is running,
   **When** the user presses Loop again, **Then** the secondary loop value is
   replaced with the new press-time value without resetting or pausing the main
   timer.
5. **Given** the timer is running, **When** the user presses Pause, **Then** the
   counter stops advancing, the current time remains visible, and Pause changes
   back to Start.
6. **Given** the timer has been started and is not reset, **When** the user
   presses Stop/Reset, **Then** the timer stops and resets to `00:00:00.000`.

---

### User Story 3 - Switch Modes Safely (Priority: P3)

As a user, I want a mode switch that is separate from timer controls and always
available so I can move between Clock and Timer without accidental timer state
changes.

**Why this priority**: Mode switching connects the two primary modes and must
protect running timer state.

**Independent Test**: Configure each timer-on-mode-switch behavior, start a
timer, switch mode, and verify the configured behavior is applied.

**Acceptance Scenarios**:

1. **Given** the overlay is visible, **When** the user switches between Clock
   and Timer, **Then** the mode switch remains available and visually separate
   from Start, Pause, Loop, and Stop/Reset.
2. **Given** the timer is running and the mode-switch setting is "continue",
   **When** the user switches modes, **Then** the timer continues counting in
   the background.
3. **Given** the timer is running and the mode-switch setting is "pause", **When**
   the user switches modes, **Then** the timer pauses and keeps its current value.
4. **Given** the timer is running and the mode-switch setting is "stop and
   reset", **When** the user switches modes, **Then** the timer stops and resets
   to `00:00:00.000`.
5. **Given** the user has not changed settings, **When** the user switches modes
   while the timer is running, **Then** the default action is stop and reset.

---

### User Story 4 - Configure App Preferences (Priority: P4)

As a user, I want a separate settings window so I can configure appearance,
shortcuts, timer mode-switch behavior, startup behavior, Dock visibility, size,
font, and opacity without changing the overlay directly.

**Why this priority**: Preferences make the app practical for long-running daily
use, but the clock and timer can deliver value before every preference is
available.

**Independent Test**: Open settings separately from the overlay, change each
preference category, and verify the overlay or app behavior reflects the saved
preference while the menu-bar status item remains visible.

**Acceptance Scenarios**:

1. **Given** the app is running, **When** the user opens Settings from the
   menu-bar status item, **Then** a separate settings window appears and the
   overlay remains independent.
2. **Given** the settings window is open, **When** the user changes theme,
   overlay size, timer font size, or opacity, **Then** the overlay applies the
   saved setting without requiring an app restart.
3. **Given** the settings window is open, **When** the user configures hotkeys
   for timer controls and mode switching, **Then** each configured hotkey invokes
   the same behavior as the corresponding button while the app is running.
4. **Given** the settings window is open, **When** the user enables launch at
   login, **Then** the app starts automatically on the next login.
5. **Given** the settings window is open, **When** the user changes Dock
   visibility, **Then** the Dock icon visibility updates while the menu-bar
   status item remains visible as the reliable access path.

### Edge Cases

- The user pauses immediately after pressing Start; the timer must show a stable
  non-negative elapsed value and the controls must settle into the paused state.
- The user presses Loop repeatedly while the timer runs; each press must update
  the secondary loop value without resetting, hiding, or pausing the main timer.
- The user presses Stop/Reset while a loop value is displayed; the saved loop
  value must clear and the timer must show `00:00:00.000`.
- The system clock changes while Clock mode is visible; Clock mode must reflect
  the new system time without corrupting Timer mode elapsed time.
- The overlay is dragged near screen edges or across displays; it must remain
  recoverable and usable.
- Persisted visibility data contains a legacy hidden menu-bar value; the app
  must ignore or correct it so the status item remains visible.
- A configured hotkey conflicts with an existing binding; the settings window
  must reject or clearly replace the conflicting binding.
- The opacity is set to the minimum supported 60%; the overlay controls and time
  display must remain readable, and disabled controls must stay visibly distinct.
- Launch-at-login registration fails or is denied by macOS; the stored
  preference must not claim launch-at-login is enabled unless registration is
  actually active.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The app MUST run only on macOS Tahoe 26.0+ as a native local
  desktop utility.
- **FR-002**: The app MUST provide a visible menu-bar status item with actions
  to show the overlay, hide the overlay, open settings, and quit the app.
- **FR-003**: The app MUST provide a separate settings window that is not part of
  the overlay.
- **FR-004**: The overlay MUST be compact by default, near 280x160 px, and allow
  user-configurable size within 220x124 px through 520x300 px.
- **FR-005**: The overlay MUST stay above normal application windows while
  visible.
- **FR-006**: The overlay MUST be freely draggable without a standard title bar
  and with a custom drag area.
- **FR-007**: The overlay MUST provide Clock mode and Timer mode.
- **FR-008**: Clock mode MUST display current system time in the fixed
  locale-independent 24-hour numeric `HH:MM:SS.mmm` format.
- **FR-009**: Timer mode MUST display elapsed time in the fixed
  locale-independent 24-hour numeric `HH:MM:SS.mmm` format.
- **FR-010**: Timer elapsed time MUST be calculated with millisecond precision;
  the visible refresh cadence may follow display and system scheduling limits,
  but displayed values must be based on accurate elapsed time whenever rendered.
- **FR-011**: Timer mode MUST show media-player-style icon controls for Start,
  Pause, Stop/Reset, Loop, and mode switching, with stable control slots,
  tooltips, accessibility labels, and visible disabled states.
- **FR-012**: Start MUST be available before the timer runs and MUST change to
  Pause after the timer starts.
- **FR-013**: Pause MUST stop elapsed display advancement, keep the current
  value visible, and change back to Start.
- **FR-014**: Stop/Reset MUST be enabled only after the timer has started and
  before it has been reset.
- **FR-015**: Stop/Reset MUST stop the timer and reset the displayed value to
  `00:00:00.000`.
- **FR-016**: Loop MUST be enabled only while the timer is running.
- **FR-017**: Loop MUST capture the press-time elapsed value as a secondary UI
  value while the main timer continues displaying live elapsed time.
- **FR-018**: Mode switching MUST always be available and visually separated
  from timer controls.
- **FR-019**: The app MUST support three timer actions when switching modes
  during a running timer: continue, pause, and stop/reset.
- **FR-020**: The default timer action when switching modes during a running
  timer MUST be stop/reset.
- **FR-021**: The settings window MUST allow theme selection with at least system
  default, light, and dark options.
- **FR-022**: The app MUST use the system appearance by default.
- **FR-023**: The settings window MUST allow hotkey configuration for every
  overlay control: Start, Pause, Stop/Reset, Loop, and mode switching.
- **FR-024**: The settings window MUST allow enabling or disabling launch at
  login, and failed registration changes MUST leave the stored preference
  consistent with the actual macOS registration state.
- **FR-025**: The settings window MUST allow configuring Dock icon visibility.
  Menu-bar status item visibility MUST NOT be user-configurable and MUST remain
  enabled while the app is running.
- **FR-026**: The settings window MUST allow configuring overlay size, timer font
  size, and overlay background opacity from 60% through 100%.
- **FR-027**: User preferences MUST persist across app relaunches.
- **FR-028**: The overlay visual style MUST follow the `UI_Example.png`
  direction: minimalist, rounded, compact, high-contrast, large time display,
  and icon-only controls similar to media-player controls.
- **FR-029**: The app MUST include automated tests for clock formatting, timer
  state transitions, loop capture values, mode-switch actions, preference
  persistence, the status-item invariant, the Dock visibility setting, and
  overlay show/hide behavior where automation is practical.
- **FR-030**: Expected automated test results MUST NOT be changed to match
  incorrect app behavior.

### Key Entities

- **DisplayMode**: The current overlay mode, either Clock or Timer.
- **TimerSession**: Timer state containing elapsed time, running/paused/reset
  status, and whether a latest loop value exists.
- **LoopCapture**: A captured elapsed time value shown as secondary UI content
  while the main timer continues.
- **OverlayPreferences**: User-configurable overlay size, timer font size,
  background opacity, theme, and Dock visibility setting.
- **HotkeyBinding**: A saved keyboard shortcut mapped to one overlay control.
- **ModeSwitchAction**: The selected timer behavior when switching modes during a
  running timer: continue, pause, or stop/reset.
- **AppVisibilityPreference**: Saved Dock visibility choice plus the invariant
  that the menu-bar status item remains visible.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: From a fresh launch, a user can show the overlay and read current
  time in under 2 seconds.
- **SC-002**: In 10 out of 10 checks within one desktop Space across Finder, a
  browser, and a text editor or document app, the visible overlay remains above
  each standard application window after app activation or window focus changes.
- **SC-003**: Timer Start, Pause, Loop, and Stop/Reset complete their visible
  state changes within 150 ms of user input.
- **SC-004**: A 60-second timer run reports elapsed time within 50 ms of real
  elapsed time at the end of the run.
- **SC-005**: Users can complete the primary timer flow, Start -> Loop -> Pause
  -> Start -> Stop/Reset without opening settings; Pause preserves elapsed time
  and the latest loop value, resumed Start continues from accumulated elapsed
  time, and only Stop/Reset clears elapsed and loop state.
- **SC-006**: Theme, opacity, overlay size, and timer font size changes are
  reflected in the overlay within 1 second after saving or applying the setting.
- **SC-007**: The app remains usable in both light and dark appearances; manual
  visual review must confirm readable time text, readable icon controls, and
  visibly distinct disabled controls at 60%, 90%, and 100% background opacity.
- **SC-008**: Automated tests cover every user story and pass after each
  implementation stage.

## Assumptions

- Hotkeys are intended to work while the app is running, even when the overlay is
  not focused, unless macOS permissions or conflicts prevent a specific binding.
- Clock and timer display strings use the fixed `HH:MM:SS.mmm` format and do
  not follow user locale or 12-hour clock preferences in v1.
- The initial timer mode is an elapsed stopwatch-style timer that counts upward
  from `00:00:00.000`.
- Loop stores the latest captured elapsed value as secondary UI content, not a
  list of stored laps.
- Repeated Loop presses replace the visible captured value while the main timer
  keeps showing live elapsed time.
- User preferences are local to the Mac and do not require network sync or any
  server runtime.
- The app does not collect telemetry, does not sync preferences, does not send
  preference or hotkey data over the network, and does not store secrets in v1.
- Global hotkeys are limited to dispatching configured app commands and must not
  capture or log unrelated keyboard input.
- The menu-bar status item is always visible while the app is running; the Dock
  icon is optional and user-configurable.
