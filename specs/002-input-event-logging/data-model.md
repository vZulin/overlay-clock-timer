# Data Model: Input Event Logging

## Entity: LoggingPanelState

Represents whether the logging panel is open and the current status of the
active logging session.

### Fields

- `isOpen`: Boolean indicating whether the panel is expanded.
- `activeSession`: Optional `LogSessionFile` for the current open-panel session.
- `fileRecordingStatus`: `available`, `unavailable(reason)`, or `inactive`.
- `captureStatus`: `inactive`, `active`, or `unavailable(reason)`.
- `visibleRows`: Newest-first list of `InputEventRecord`.
- `preservedRows`: In-memory newest-first list retained only when preservation is
  enabled during the current app launch.

### Validation Rules

- `visibleRows.count` must never exceed `LoggingPreferences.eventTableRowLimit`.
- `preservedRows.count` must never exceed `LoggingPreferences.eventTableRowLimit`.
- `activeSession` is present only while `isOpen` is true and file creation
  succeeded.
- Closing the panel sets `captureStatus` to `inactive` and ends `activeSession`.

### State Transitions

- `closed -> open`: creates a new session file, starts capture, and initializes
  `visibleRows` from either empty state or same-launch preserved rows.
- `open -> closed`: stops capture, closes file writing, and stores visible rows
  in memory only if preservation is enabled.
- `closed -> app quit`: clears `preservedRows`.

## Entity: LoggingPreferences

Saved input logging preferences integrated into the existing overlay
preferences.

### Fields

- `eventTableRowLimit`: Integer row limit.
- `preserveEventTableBetweenOpens`: Boolean.

### Defaults

- `eventTableRowLimit`: `15`.
- `preserveEventTableBetweenOpens`: `false`.

### Validation Rules

- `eventTableRowLimit` must be clamped to `5...50`.
- Missing row limit uses `15`.
- Missing preservation setting uses `false`.
- Preferences persist across app relaunches; preserved table rows do not.

## Entity: InputEventRecord

Immutable representation of one captured keyboard, mouse-button, or scroll
event.

### Fields

- `id`: Stable unique identity for the row.
- `captureOrder`: Monotonic sequence number assigned at capture time for
  internal newest-first sorting.
- `timestamp`: Already formatted mode-specific timestamp string.
- `eventName`: Human-readable event name shown in the table and written to the
  session log file.

### Validation Rules

- `captureOrder` must increase for every captured event in the current app
  launch, but it is not displayed or written to the session log file.
- `timestamp` must match the active display mode's required format.
- `eventName` must not include app name, window title, text field identifier,
  clipboard content, coordinates, or process metadata.
- Visible table rows expose only `timestamp` and `eventName`.
- Session log lines expose only `timestamp`, a tab separator, and `eventName`.

## Entity: KeyboardInputEvent

Specialized input source event before conversion into `InputEventRecord`.

### Fields

- `key`: Character or key identifier.
- `modifiers`: Ordered set of active modifiers.
- `isRepeat`: Boolean for repeat keyDown events.
- `producesCharacter`: Boolean.

### Validation Rules

- Each character-producing keyDown, including repeats, maps to exactly one
  `InputEventRecord`.
- KeyDown events that produce visible text map to character records even when
  modifiers are active.
- Non-character modifier combinations map to exactly one `InputEventRecord`.
- Modifier names use canonical order: `Control`, `Option`, `Shift`, `Command`,
  followed by the key.

## Entity: MouseInputEvent

Specialized input source event before conversion into `InputEventRecord`.

### Fields

- `button`: `left`, `right`, `third`, or `additional`.
- `action`: `down` or `up`.
- `additionalButtonNumber`: Optional integer used when `button` is
  `additional` to format numbered additional-button labels.

### Validation Rules

- Mouse down and mouse up are separate events.
- Left-button events map to `LM ↓` and `LM ↑`.
- Right-button events map to `RM ↓` and `RM ↑`.
- Third-button events map to `3M ↓` and `3M ↑`.
- Additional-button events map to numbered labels such as `4M ↓`, `4M ↑`,
  `5M ↓`, and `5M ↑`.
- Mouse coordinates are not stored.

## Entity: ScrollInputEvent

Specialized input source event before conversion into `InputEventRecord`.

### Fields

- `direction`: Physical gesture direction, `up` or `down`.

### Validation Rules

- Physical upward scroll gesture maps to `SM ↑`.
- Physical downward scroll gesture maps to `SM ↓`.
- Scroll direction is independent of content movement and macOS natural
  scrolling settings.
- Scroll coordinates, delta magnitudes, and target view metadata are not stored.

## Entity: LogSessionFile

Represents the local file for one open-panel logging session.

### Fields

- `url`: File URL under `~/Library/Logs/OverlayClockTimer/`.
- `createdAt`: Wall-clock creation time.
- `status`: `open`, `closed`, or `failed(reason)`.

### Validation Rules

- The base filename format is `YYYY-MM-DD_HH-MM-SS.log`.
- A collision-safe variant may be used if a file already exists for the same
  timestamp.
- A session file receives only events captured after that panel open.
- Preserved in-memory rows are never written into a new session file.
- Closing the panel closes the session file.

## Entity: EventTimestampContext

Represents the mode-specific source used to produce an event timestamp.

### Fields

- `displayMode`: `clock` or `timer`.
- `clockDisplayText`: Current wall-clock text when in Clock mode.
- `timerDisplayText`: Current timer text when in Timer mode.

### Validation Rules

- Clock mode timestamps use `HH:MM:SS.mmm`.
- Timer mode timestamps use the current visible timer value.
- Timer idle/reset timestamps use `00:00:00.000`.

## Relationships

- `LoggingPanelState` owns the active `LogSessionFile` while the panel is open.
- `LoggingPanelState` owns visible and preserved `InputEventRecord` collections.
- `LoggingPreferences` controls `LoggingPanelState` row trimming and preservation
  behavior.
- `KeyboardInputEvent`, `MouseInputEvent`, and `ScrollInputEvent` are converted
  into `InputEventRecord`.
- `EventTimestampContext` formats the timestamp for each `InputEventRecord`.
