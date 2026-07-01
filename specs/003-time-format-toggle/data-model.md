# Data Model: Time Format Toggle

## Entity: TimeFormatPreference

Represents the user's selected display format for Clock, Timer, Loop, and new
input logging timestamps.

### Fields

- `rawValue`: Persisted string value.
- `kind`: Either `standardMilliseconds` or `epochMilliseconds`.

### Defaults

- Default value: `standardMilliseconds`.
- Missing, corrupted, or unknown stored values use `standardMilliseconds`.

### Validation Rules

- Only known values are accepted from persistence.
- The value is local to the current Mac and does not require network sync.
- Changing the value must not mutate timer session state, logging session state,
  row ordering, or log file ownership.

### State Transitions

- `standardMilliseconds -> epochMilliseconds`: all live displays refresh using
  epoch milliseconds.
- `epochMilliseconds -> standardMilliseconds`: all live displays refresh using
  `HH:mm:ss.SSS`.
- Any transition while the timer is running keeps the timer running.
- Any transition while the timer is paused keeps the timer paused.

## Entity: TimeFormatter

Formats wall-clock and elapsed time values for the selected
`TimeFormatPreference`.

### Fields

- `timeFormat`: Active `TimeFormatPreference`.
- `timeZone`: Used only for `HH:mm:ss.SSS` wall-clock formatting.

### Validation Rules

- Clock standard format is `HH:mm:ss.SSS`.
- Clock epoch format is a 13-digit decimal integer representing milliseconds
  since the Unix epoch.
- Timer standard format is `HH:mm:ss.SSS`.
- Timer epoch format is a 13-digit, left-zero-padded decimal integer
  representing elapsed milliseconds from zero.
- Negative elapsed values clamp to zero before formatting.
- Millisecond conversion must not round elapsed values into the future.

## Entity: FormattedTimeValue

Represents the string shown in the overlay for Clock, Timer, latest Loop, and
new input event timestamps.

### Fields

- `source`: `clock`, `timerElapsed`, `latestLoop`, or `inputEventTimestamp`.
- `timeFormat`: The format used to produce the string.
- `text`: The immutable display string.

### Validation Rules

- `text` matches the format active when it is produced.
- Live Clock, Timer, and latest Loop values may be reformatted after a format
  switch.
- Captured input event timestamp strings are immutable and are not reformatted
  after a format switch.

## Entity: FormatToggleControl

Represents the icon-only overlay control that switches time format.

### Fields

- `identifier`: `clock.timeFormatToggle` or `timer.timeFormatToggle`.
- `currentFormat`: Active `TimeFormatPreference`.
- `targetFormat`: The format selected by the next activation.
- `accessibilityLabel`: Describes the action and target format.
- `tooltip`: Describes the action and target format.

### Validation Rules

- The control appears in Clock and Timer toolbars.
- The control remains visible when input logging is expanded.
- The control must fit within the default overlay size.
- The control must remain readable in light and dark appearance.
- The control must not replace or hide Start/Pause, Stop/Reset, Loop, input
  logging, or mode switching controls.

## Entity: EpochToggleIcon

Represents the native-style icon direction for the format toggle.

### Fields

- `clockCue`: Visual cue for wall-clock or timer time.
- `numericCue`: Visual cue for timestamp digits.
- `conversionCue`: Visual cue for reversible switching.

### Validation Rules

- The icon is monoline and visually compatible with the existing toolbar
  controls.
- The icon uses adaptive foreground styling.
- The icon must remain legible at compact toolbar sizes.

## Entity: CapturedEventTimestamp

Represents the timestamp string stored on an input event row and written to the
session log line.

### Fields

- `text`: Formatted timestamp string.
- `displayMode`: `clock` or `timer` at capture time.
- `timeFormat`: `standardMilliseconds` or `epochMilliseconds` at capture time.

### Validation Rules

- The timestamp is produced when the event record is accepted.
- Existing rows keep their original timestamp strings after format changes.
- Existing log lines are never rewritten after format changes.
- Clock epoch timestamp strings are 13 digits.
- Timer epoch timestamp strings are 13 digits and left-zero-padded.

## Relationships

- `OverlayPreferences` owns `TimeFormatPreference`.
- `TimeFormatter` reads `TimeFormatPreference` to produce `FormattedTimeValue`.
- `ClockDisplayModel` displays a live `FormattedTimeValue` from wall-clock time.
- `TimerSessionStore` displays live elapsed and latest loop
  `FormattedTimeValue` values from monotonic timer state.
- `FormatToggleControl` changes `TimeFormatPreference`.
- `EventTimestampProvider` creates `CapturedEventTimestamp` values for input
  logging.
- `InputEventRecord` stores the `CapturedEventTimestamp.text` string.
