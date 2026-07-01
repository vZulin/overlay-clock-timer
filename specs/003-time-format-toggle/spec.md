# Feature Specification: Time Format Toggle

**Feature Branch**: `003-time-format-toggle`
**Created**: 2026-07-01
**Status**: Draft
**Input**: User description: "Add a button that switches displayed time between HH:mm:ss.SSS and Unix timestamp formats. The setting changes display format only. Clock mode, Timer mode, running timer continuity, input logging display, and input log files must use the selected display format for new values. Existing logged rows must remain unchanged after format switches. Add a new macOS-style icon for the toggle and compact Timer-mode controls so the new button fits without increasing the overlay size."

## Clarifications

### Session 2026-07-01

- Q: Which Unix timestamp representation should be used for millisecond
  precision? → A: Use epoch milliseconds: 13 decimal digits with no decimal
  separator.
- Q: May the overlay show user-selected epoch milliseconds instead of the default
  structured clock format? → A: Yes. `HH:mm:ss.SSS` remains the required default
  and supported format; epoch milliseconds may replace the visible clock or timer
  string only after explicit user selection and only as display-only formatting.
- Q: How should coverage gaps from analysis be resolved? → A: Add timed switch
  assertions, looped timer/logging reliability tests, opacity checkpoints, a log
  filename invariant test, and pre-implementation icon review acceptance.

## Constitutional Scope *(mandatory)*

- **Target Platform**: macOS Tahoe 26.0+ only.
- **Application Model**: Native menu-bar app with a visible status item and a
  separate floating overlay window.
- **Overlay Contract**: The collapsed overlay remains compact, always-on-top,
  titleless, draggable, and compatible with the existing Clock, Timer, and input
  logging controls. The default overlay size MUST NOT increase to fit the new
  format toggle.
- **Time Display Contract**: `HH:mm:ss.SSS` remains the default and required
  supported clock format. Epoch milliseconds may replace the visible clock or
  timer string only after explicit user selection and only as display-only
  formatting.
- **Technology Boundary**: Implementation planning must remain within the
  previously selected Apple-native local macOS stack and must justify any
  third-party dependency exception.
- **Quality Boundary**: Every user story must include automated tests and a
  documented command that passes after the story is implemented.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Switch Clock Display Format (Priority: P1)

As a user, I want an icon-only control in the overlay that switches the current
clock display between the existing structured time format and a 13-digit epoch
milliseconds format so I can use whichever representation is more useful without
opening settings.

**Why this priority**: Clock display is the primary overlay use case, and the
format toggle must be immediately visible and reversible.

**Independent Test**: Launch the app in Clock mode, press the format toggle,
verify the visible clock changes from `HH:mm:ss.SSS` to a 13-digit epoch
milliseconds value, press the toggle again, and verify the clock returns to
`HH:mm:ss.SSS` while remaining based on current system time.

**Acceptance Scenarios**:

1. **Given** the overlay is visible in Clock mode using `HH:mm:ss.SSS`, **When**
   the user presses the format toggle, **Then** the clock display changes to the
   current 13-digit epoch milliseconds value.
2. **Given** the overlay is visible in Clock mode using epoch milliseconds
   format, **When** the user presses the format toggle, **Then** the clock
   display changes back to `HH:mm:ss.SSS`.
3. **Given** the system clock changes while Clock mode is visible, **When**
   epoch milliseconds format is selected, **Then** the displayed value reflects
   the updated system time without altering Timer mode state.
4. **Given** the user relaunches the app after selecting a time format, **When**
   the overlay appears again, **Then** the last selected display format is used.

---

### User Story 2 - Switch Timer Display Without Interrupting Timing (Priority: P2)

As a user, I want to switch timer display format while the timer is running so I
can change representation without pausing, resetting, or delaying the timer.

**Why this priority**: The timer already depends on precise continuity; a format
change must remain a display-only operation.

**Independent Test**: Start the timer, switch formats repeatedly while it runs,
and verify the timer continues advancing without pause, reset, or measurable
delay beyond the existing timer accuracy target.

**Acceptance Scenarios**:

1. **Given** Timer mode is selected and the timer is reset, **When** epoch
   milliseconds format is selected, **Then** the timer displays the reset
   elapsed value as `0000000000000`.
2. **Given** the timer is running in `HH:mm:ss.SSS` format, **When** the user
   presses the format toggle, **Then** the timer display changes to a 13-digit
   elapsed milliseconds value and continues counting without pausing.
3. **Given** the timer is running in epoch milliseconds format, **When** the
   user presses the format toggle, **Then** the timer display changes to
   `HH:mm:ss.SSS` and continues counting without pausing.
4. **Given** a latest loop value is visible, **When** the user changes the time
   format, **Then** the main timer and the latest loop value are both shown in
   the selected display format without changing the captured loop value.
5. **Given** the timer is paused, **When** the user changes the time format,
   **Then** the same paused elapsed value is shown in the selected display
   format and the timer remains paused.

---

### User Story 3 - Log Input Events With the Active Time Format (Priority: P3)

As a user with input logging enabled, I want new event timestamps in the visible
table and session log file to use the currently selected display format while
older event rows and older log lines remain exactly as captured.

**Why this priority**: Input logging is durable diagnostic output; changing the
display format must not rewrite history or make logs misleading.

**Independent Test**: Open input logging, capture events in one format, switch
formats, capture more events, and verify the visible table and session log file
contain old rows in the old format and new rows in the new format.

**Acceptance Scenarios**:

1. **Given** input logging is open and `HH:mm:ss.SSS` format is selected,
   **When** an input event is captured, **Then** the visible table row and the
   session log line use `HH:mm:ss.SSS`.
2. **Given** input logging is open and epoch milliseconds format is selected,
   **When** an input event is captured in Clock mode, **Then** the visible table
   row and the session log line use the current 13-digit epoch milliseconds
   value.
3. **Given** input logging is open and epoch milliseconds format is selected,
   **When** an input event is captured in Timer mode, **Then** the visible table
   row and the session log line use the current timer value as a 13-digit
   elapsed milliseconds value.
4. **Given** several rows were captured before a format switch, **When** the
   user switches formats and captures more events, **Then** previously captured
   visible rows remain unchanged and only newly captured rows use the updated
   format.
5. **Given** an active session log file already contains lines in one format,
   **When** the user switches formats and captures more events, **Then** the log
   file appends new lines in the updated format and does not rewrite existing
   lines.
6. **Given** preserved in-memory rows are restored after closing and reopening
   the logging panel during the same app launch, **When** the selected time
   format has changed since those rows were captured, **Then** the restored rows
   keep their original timestamp strings.

---

### User Story 4 - Fit the New Toggle in the Existing Overlay (Priority: P4)

As a user, I want the new format toggle to fit naturally into the existing
compact overlay so the widget remains the same size and the controls remain
clear in Clock mode, Timer mode, and the expanded logging state.

**Why this priority**: The overlay is valuable because it stays compact; adding
a control must not make the widget larger or visually crowded.

**Independent Test**: Inspect the overlay at the default size in Clock mode,
Timer mode, and with input logging expanded, verify the new toggle is visible,
clickable, accessible, and does not overlap existing controls or time text.

**Acceptance Scenarios**:

1. **Given** the overlay is at its default collapsed size in Timer mode, **When**
   all Timer controls and the new format toggle are visible, **Then** every
   control fits without increasing the overlay size or overlapping the timer
   display.
2. **Given** Clock mode is visible, **When** the user reviews the control row,
   **Then** the format toggle appears as an icon-only control with a tooltip and
   accessible label.
3. **Given** Timer mode is visible, **When** the user reviews the control row,
   **Then** Start/Pause, Loop, Stop/Reset, mode switching, input logging, and
   time format controls remain visually distinguishable.
4. **Given** light or dark appearance is active, **When** the user views the new
   icon, **Then** the icon remains readable and matches the existing
   macOS-style monoline control set.

### Edge Cases

- The user toggles the time format rapidly while the timer is running; the
  timer continues from the same elapsed source and the visible value never
  jumps backward except for normal formatting precision boundaries.
- The user toggles the time format while the timer is paused; the paused value
  reformats without starting or resetting the timer.
- The user toggles the time format immediately after pressing Start; the timer
  remains non-negative and continues counting.
- The user toggles the time format while the latest loop value is visible; the
  loop value remains the same captured elapsed moment and is only reformatted.
- The user toggles the time format while input logging is open and events arrive
  close to the toggle action; each event uses the format selected at the moment
  the event record is accepted.
- The stored time format preference is missing, corrupted, or unknown; the app
  falls back to `HH:mm:ss.SSS`.
- The overlay is at its minimum supported size; controls remain usable, and the
  display may use the existing responsive visual rules without hiding the format
  toggle.
- The session log file contains mixed timestamp formats because the user changed
  format during the session; the file remains valid because each line preserves
  the timestamp string captured for that event.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The overlay MUST provide an icon-only time format toggle that
  switches between `HH:mm:ss.SSS` and epoch milliseconds display formats.
- **FR-002**: The selected time format MUST apply to visible Clock mode time,
  visible Timer mode time, the latest visible loop value, newly captured input
  event rows, and newly appended input log lines.
- **FR-003**: The selected time format MUST be a display preference only and
  MUST NOT change clock source, timer elapsed state, timer running state, loop
  capture state, logging enabled state, row ordering, or log session ownership.
- **FR-004**: `HH:mm:ss.SSS` format MUST remain the default when no valid saved
  preference exists.
- **FR-005**: Epoch milliseconds format for Clock mode MUST show current system
  time as a 13-digit decimal integer representing milliseconds since the Unix
  epoch, with no decimal separator.
- **FR-006**: Epoch milliseconds format for Timer mode MUST show elapsed timer
  value as a 13-digit, left-zero-padded decimal integer representing elapsed
  milliseconds from zero, with no decimal separator.
- **FR-007**: Switching the time format while the timer is running MUST NOT
  pause, reset, restart, or otherwise delay the timer.
- **FR-008**: Switching the time format while the timer is paused MUST keep the
  timer paused and reformat the same elapsed value.
- **FR-009**: Switching the time format while a latest loop value is visible MUST
  reformat the displayed loop value without changing the captured elapsed
  moment.
- **FR-010**: Newly captured input event rows MUST store the formatted timestamp
  string produced at capture time so older rows remain unchanged after later
  format switches.
- **FR-011**: Newly appended input log lines MUST use the selected time format
  at the moment the event record is accepted, and existing log lines MUST NOT be
  rewritten after a format switch.
- **FR-012**: Preserved in-memory input event rows MUST keep their original
  timestamp strings when restored during the same app launch.
- **FR-013**: The session log file naming scheme MUST remain unchanged by this
  feature, and automated coverage MUST prove format switching does not change
  session log file names.
- **FR-014**: The selected time format preference MUST persist across app
  relaunches as a local user preference.
- **FR-015**: The format toggle MUST fit in the existing default overlay size in
  Clock mode, Timer mode, and the expanded input logging state.
- **FR-016**: Adding the format toggle MUST NOT increase the overlay default
  collapsed width or height.
- **FR-017**: Timer-mode control spacing MUST become compact enough for the new
  toggle while preserving readable icon buttons, clear disabled states,
  tooltips, and accessible labels.
- **FR-018**: The format toggle icon MUST follow a new `Epoch Toggle` design
  direction: a compact monoline glyph that visually combines clock time,
  numeric timestamp representation, and reversible conversion while matching
  the existing macOS-style icon controls. The icon direction MUST complete a
  macOS design review and sketch acceptance step before implementation.
- **FR-019**: The format toggle MUST expose a tooltip and accessible label that
  clearly identify the action and the currently available target format.
- **FR-020**: The app MUST support light and dark appearance for the new toggle,
  compacted controls, and all affected time displays.
- **FR-021**: Automated tests MUST cover Clock format switching, Timer format
  switching during reset/running/paused states, loop value reformatting, input
  logging before and after format switches, preference fallback and persistence,
  timed Clock switching, looped Timer and logging reliability trials, the log
  filename invariant, and the no-overlay-size-increase invariant where
  automation is practical.
- **FR-022**: Expected automated test results MUST NOT be changed to match
  incorrect app behavior.

### Key Entities

- **TimeFormatPreference**: The user's selected display format, either
  `HH:mm:ss.SSS` or epoch milliseconds format, persisted locally and applied
  across overlay modes and new log records.
- **FormattedTimeValue**: A display string derived from the current clock time,
  timer elapsed value, or captured loop value according to the selected time
  format.
- **FormatToggleControl**: The icon-only overlay control that switches the
  selected time format and communicates the current/target format through
  tooltip and accessibility text.
- **CapturedEventTimestamp**: The timestamp string stored with an input event
  record at capture time, intentionally not reformatted after later preference
  changes.
- **Epoch Toggle Icon**: The new macOS-style monoline icon direction for the
  format toggle, combining clock and numeric timestamp cues in a compact glyph.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: From a visible Clock-mode overlay, a user can switch between
  `HH:mm:ss.SSS` and epoch milliseconds display formats in under 1 second.
- **SC-002**: During a 60-second running timer trial with at least 10 format
  switches, final elapsed time remains within the existing 50 ms timer accuracy
  target.
- **SC-003**: In 10 out of 10 running timer trials, pressing the format toggle
  changes only the displayed format and does not pause, reset, or restart the
  timer.
- **SC-004**: In 10 out of 10 logging trials that capture events before and
  after a format switch, older visible rows and existing log lines remain
  unchanged while newer rows and appended lines use the updated format.
- **SC-005**: In default-size visual checks for Clock mode, Timer mode, and the
  expanded logging state, the overlay size is unchanged and controls do not
  overlap the time display or each other.
- **SC-006**: In light and dark appearance review at 60%, 90%, and 100%
  background opacity, the new icon and compacted controls remain readable,
  distinguishable, and consistent with the existing control style.
- **SC-007**: Automated tests cover every user story and pass after the feature
  is implemented.

## Assumptions

- Epoch milliseconds display uses a 13-digit decimal integer with no decimal
  separator so milliseconds are encoded directly in the timestamp value.
- Timer mode cannot represent a wall-clock Unix epoch timestamp because it is an
  elapsed stopwatch; therefore epoch milliseconds format in Timer mode means a
  13-digit, left-zero-padded elapsed milliseconds value from zero.
- The time format toggle is part of the overlay control row rather than only the
  settings window, because the user requested an in-widget button.
- The selected time format is a local user preference and does not require
  network sync.
- Input log file names continue to use the existing session naming format; only
  event timestamp fields inside log lines follow the selected display format.
- Existing input logging privacy and permission boundaries remain unchanged.
