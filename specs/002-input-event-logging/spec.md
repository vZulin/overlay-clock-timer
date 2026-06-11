# Feature Specification: Input Event Logging

**Feature Branch**: `002-input-event-logging`
**Created**: 2026-06-10
**Status**: Draft
**Input**: User description: "Add Input Event Logging with an overlay logging
toggle, expandable recent event table, keyboard keyDown repeat logging, modifier
combination logging, mouse down and mouse up logging, mode-specific timestamps,
and per-panel-session log files."

## Clarifications

### Session 2026-06-11

- Q: What configurable range should the event table row limit support? → A:
  Default 15 rows, configurable from 5 through 50 rows in the settings window.
- Q: How long should the optional preserved event table survive? → A: Preserve
  rows only between panel openings during the current app launch; clear them
  when the app quits.

## Constitutional Scope *(mandatory)*

- **Target Platform**: macOS Tahoe 26.0+ only.
- **Application Model**: Native menu-bar app with a visible status item and a
  separate floating overlay window.
- **Overlay Contract**: The collapsed overlay remains compact, always-on-top,
  titleless, draggable, and compatible with the existing Clock/Timer controls.
  When input logging is opened, the overlay expands downward only for the log
  panel and returns to the collapsed size when logging is closed.
- **Technology Boundary**: The implementation plan must stay within the
  Apple-native stack selected for the base overlay feature and must justify any
  third-party dependency exception.
- **Quality Boundary**: Every user story must include automated tests and a
  documented command that passes after the story is implemented.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Open and Review Recent Input Events (Priority: P1)

As a user, I want an icon-only logging control in the overlay that opens a
compact recent-events panel so I can inspect the latest input activity without
leaving the Clock/Timer overlay.

**Why this priority**: This is the visible entry point for the feature and
enforces the privacy rule that logging is active only while the panel is open.

**Independent Test**: Launch the app, show the overlay, press the logging icon,
verify the panel expands downward with a recent-events table, press the icon
again, verify the panel collapses and logging stops, then reopen it with default
settings and verify the table starts empty.

**Acceptance Scenarios**:

1. **Given** the overlay is visible and collapsed, **When** the user presses the
   logging icon to the left of the Clock/Timer switch, **Then** the overlay
   expands downward and shows a table for the latest input events.
2. **Given** the logging panel is open, **When** the user presses the logging
   icon again, **Then** the panel collapses and no further input events are
   captured or written for that session.
3. **Given** the logging panel is open, **When** new input events arrive, **Then**
   the newest event is always shown as the first row and the visible row count
   does not exceed the configured event table row limit.
4. **Given** the logging panel is open, **When** the user switches between Clock
   and Timer, **Then** the logging control remains left of the Clock/Timer
   switch and the table remains usable.
5. **Given** the settings window is open, **When** the user changes the event
   table row limit, **Then** the logging panel uses the saved limit without
   changing whether logging is currently active.
6. **Given** the preserve table setting is disabled, **When** the user closes
   and reopens the logging panel, **Then** the table starts empty even though a
   new session log file is created.
7. **Given** the preserve table setting is enabled and the app has not quit,
   **When** the user closes and reopens the logging panel, **Then** the table
   restores the previously visible rows up to the configured row limit.

---

### User Story 2 - Log Keyboard Events Precisely (Priority: P2)

As a user, I want keyboard activity to be recorded at the same granularity as
the characters or combinations produced so repeated keys and shortcuts are clear
in the event history.

**Why this priority**: Keyboard repeat and shortcut behavior is the most
important clarified requirement and the easiest place to lose diagnostic value
by coalescing events incorrectly.

**Independent Test**: Open the logging panel, generate repeated character input
and modifier combinations in another editable context, and verify the table and
log file contain the exact event count and event names.

**Acceptance Scenarios**:

1. **Given** the logging panel is open, **When** the user holds the `S` key and
   an editor receives five `s` characters, **Then** five separate keyboard
   records appear with different millisecond timestamps.
2. **Given** the logging panel is open, **When** the user presses `Command+C`,
   **Then** one keyboard record appears with the combination name `Command+C`.
3. **Given** the logging panel is open, **When** the user presses
   `Option+Shift+K`, **Then** one keyboard record appears with the combination
   name `Option+Shift+K`.
4. **Given** the logging panel is closed, **When** the user generates character
   input or modifier combinations, **Then** no keyboard records are added to the
   table or current log file.

---

### User Story 3 - Log Mouse Events and Persist the Session (Priority: P3)

As a user, I want mouse down and mouse up activity to be recorded separately and
written to a local session log file while the logging panel is open.

**Why this priority**: Mouse press boundaries and durable session logs complete
the diagnostic workflow after the visible panel and keyboard semantics exist.

**Independent Test**: Open the logging panel, verify a new log file is created,
perform mouse down and mouse up actions, and verify both the table and log file
contain separate records while no writes occur after the panel closes.

**Acceptance Scenarios**:

1. **Given** the logging panel is closed, **When** the user opens it, **Then** a
   new log file is created under
   `~/Library/Logs/OverlayClockTimer/YYYY-MM-DD_HH-MM-SS.log`.
2. **Given** the logging panel is open, **When** the user performs a mouse down
   followed by mouse up, **Then** two separate records appear with precise
   timestamps and event names `Mouse Down` and `Mouse Up`.
3. **Given** the logging panel is open and more events occur than the configured
   row limit allows, **When** the table refreshes, **Then** only the newest
   configured number of records remain visible while the session log file keeps
   the records captured during the open session.
4. **Given** the logging panel has been closed, **When** additional keyboard or
   mouse events occur, **Then** no additional rows appear and no additional
   lines are written to the closed session log file.
5. **Given** the preserve table setting is enabled and the panel is reopened,
   **When** the new session log file starts, **Then** preserved in-memory rows
   remain visible but are not rewritten into the new session log file.

### Edge Cases

- The user opens and closes the logging panel rapidly; each open session creates
  at most one log file, and closing stops capture and file writes immediately.
- The user opens the logging panel with default settings after a previous panel
  session; the table starts empty while a new log file is created.
- The user enables preserved table rows, closes the panel, and quits the app
  before reopening; the next app launch starts with an empty event table.
- The user holds a key long enough to generate a burst of repeat keyDown events;
  each character-producing keyDown remains a separate record and older visible
  rows are discarded only after the configured event table row limit is
  exceeded.
- The stored event table row limit is missing, corrupted, below 5, or above 50;
  missing or corrupted values use the default `15`, numeric values below `5` are
  clamped to `5`, and numeric values above `50` are clamped to `50` before
  rendering the logging panel.
- A modifier combination produces no printable character; it is still recorded
  once as a named combination while the panel is open.
- The timer is not started when the overlay is in Timer mode; event timestamps
  use `00:00:00.000`.
- The user resets or pauses the timer while logging is open; subsequent Timer
  mode event timestamps reflect the current visible timer value at the moment of
  each event.
- The system clock changes while logging is open in Clock mode; subsequent
  Clock mode event timestamps reflect the updated system time.
- The log directory or file cannot be created; the app keeps the panel usable,
  clearly indicates that file recording is unavailable for the session, and does
  not claim that a log file exists.
- macOS input-monitoring permissions prevent observing external app input; the
  panel clearly indicates that input events are unavailable until permissions
  allow observation, and the app does not silently capture data outside the
  stated open-panel window.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The overlay MUST add an icon-only logging toggle immediately to
  the left of the Clock/Timer switch.
- **FR-002**: The logging toggle MUST use a minimalist list-style SF Symbol,
  with `list.bullet.rectangle` as the intended baseline symbol unless the target
  macOS symbol catalog requires an equivalent list/log symbol.
- **FR-003**: Pressing the logging toggle MUST expand the overlay downward and
  show the input-event table; pressing it again MUST collapse the panel.
- **FR-004**: Input event logging MUST be active only while the logging panel is
  open.
- **FR-005**: Closing the logging panel MUST stop input capture and file writes
  immediately.
- **FR-006**: The logging table MUST show the newest input-event records up to
  the configured event table row limit, with the newest record as the first row.
- **FR-007**: The event table row limit MUST be configurable in the settings
  window, default to 15 rows, and allow saved values from 5 through 50 rows.
- **FR-008**: When a captured event would exceed the configured visible row
  limit, the oldest visible row MUST be removed automatically.
- **FR-009**: The settings window MUST allow enabling or disabling event table
  preservation between logging panel openings.
- **FR-010**: Event table preservation MUST be disabled by default.
- **FR-011**: When event table preservation is disabled, each logging panel open
  MUST start with an empty visible table.
- **FR-012**: When event table preservation is enabled, reopening the logging
  panel during the same app launch MUST restore the previously visible rows up
  to the configured row limit.
- **FR-013**: Preserved table rows MUST clear when the app quits and MUST NOT be
  restored on the next app launch.
- **FR-014**: Opening the logging panel MUST create a new log file at
  `~/Library/Logs/OverlayClockTimer/YYYY-MM-DD_HH-MM-SS.log`.
- **FR-015**: Reopening the logging panel after it was closed MUST start a new
  logging session and create a new log file.
- **FR-016**: Preserved in-memory table rows MUST NOT be written into a newly
  created session log file.
- **FR-017**: The app MUST write event records to the session log file only
  while the logging panel is open.
- **FR-018**: Keyboard logging MUST record every character-producing keyDown as a
  separate event, including repeat events.
- **FR-019**: If holding `S` causes five `s` characters to appear in an editor,
  the app MUST create five separate keyboard records with distinct millisecond
  timestamps.
- **FR-020**: Keyboard combinations with modifiers MUST be logged as a single
  event using a readable combination name, such as `Command+C` or
  `Option+Shift+K`. If a keyDown event both includes modifiers and produces
  visible text, including Shift- or Option-modified characters, it MUST be
  treated as one character-producing keyDown record; non-character modifier
  shortcuts MUST be treated as one readable combination event.
- **FR-021**: Mouse logging MUST record `Mouse Down` and `Mouse Up` as separate
  events with their own timestamps.
- **FR-022**: In Clock mode, each event timestamp MUST use real system time in
  `HH:MM:SS.mmm` format.
- **FR-023**: In Timer mode, each event timestamp MUST use the current visible
  timer value in the existing timer display format, with `00:00:00.000` when the
  timer has not started or has been reset.
- **FR-024**: Each input-event record MUST include timestamp, input category,
  event name, and event phase when applicable.
- **FR-025**: The expanded logging UI MUST preserve the overlay's always-on-top,
  titleless, draggable behavior, light/dark readability, icon accessibility
  labels, and tooltips.
- **FR-026**: The app MUST NOT capture, display, or write keyboard or mouse
  events before the logging panel opens, after it closes, or during normal
  overlay use with the panel collapsed.
- **FR-027**: If the app cannot create the session log file, it MUST continue to
  show captured in-memory table rows while the panel is open and must clearly
  indicate that file recording is unavailable for that session.
- **FR-028**: The app MUST keep input-event logs local to the user's Mac and
  MUST NOT send, sync, or upload event records.
- **FR-029**: Automated tests MUST cover panel open/close behavior, default empty
  table behavior, optional same-launch table preservation, table ordering and
  trimming at default, minimum, and maximum row limits, keyboard repeats,
  keyboard combinations, mouse down/up records, Clock timestamps, Timer
  timestamps, file-session creation, and the no-logging-while-closed invariant.
- **FR-030**: Expected automated test results MUST NOT be changed to match
  incorrect app behavior.

### Key Entities

- **LoggingPanelState**: Whether the logging panel is open or closed, including
  the current session status and any file-recording availability message.
- **LoggingPreferences**: Saved input logging preferences, including the event
  table row limit with default, minimum, and maximum bounds, plus whether visible
  table rows are preserved between panel openings during the current app launch.
- **InputEventRecord**: A captured input event with timestamp, category, event
  name, optional phase, and capture order.
- **KeyboardInputEvent**: A keyboard record representing either one
  character-producing keyDown or one modifier combination.
- **MouseInputEvent**: A mouse record representing either `Mouse Down` or
  `Mouse Up`.
- **LogSessionFile**: The local file created for one open-panel logging session.
- **EventTimestampContext**: The mode-specific source used to format a record's
  timestamp as Clock time or Timer value.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: From a visible collapsed overlay with default settings, a user can
  open the logging panel and see an empty event table within 200 ms.
- **SC-002**: In 10 out of 10 repeat-key trials where holding `S` produces five
  `s` characters, the table and session log contain five separate keyboard
  records with distinct millisecond timestamps.
- **SC-003**: In 10 out of 10 modifier-combination trials, each combination is
  recorded as exactly one keyboard event with a readable combination name.
- **SC-004**: In 10 out of 10 mouse click trials, `Mouse Down` and `Mouse Up`
  appear as separate records in chronological capture order and reverse visible
  table order.
- **SC-005**: After one more event than the configured row limit is captured,
  the visible table contains exactly the configured number of rows and the
  newest event is the first row.
- **SC-006**: After the logging panel closes, 10 subsequent keyboard or mouse
  events produce zero new table rows and zero new writes to the closed session
  log file.
- **SC-007**: With event table preservation enabled, reopening the logging panel
  during the same app launch restores the previously visible rows in 10 out of
  10 trials without writing those rows into the new session log file.
- **SC-008**: Clock mode and Timer mode timestamps match their required formats
  in 100% of automated timestamp-format test cases.
- **SC-009**: Automated tests cover every user story and pass after the feature
  is implemented.

## Assumptions

- Input Event Logging is a user-visible diagnostic feature for the current Mac
  user, not a background monitoring feature.
- Input observation covers events observable to the app while the panel is open,
  including foreground app input when macOS permissions allow it.
- Generated log files are local diagnostic artifacts and are not automatically
  deleted by this feature.
- Preserved table rows are in-memory UI history for the current app launch only,
  not durable event storage.
- Timer-mode event timestamps follow the existing timer display width because
  the reset and idle value is specified as `00:00:00.000`.
- The event table row limit is configured through the existing settings window;
  this feature does not add a separate settings window.
