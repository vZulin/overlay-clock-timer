# Research: Time Format Toggle

## Decision: Use Epoch Milliseconds for the Alternate Clock Format

Clock mode will display epoch milliseconds as a 13-digit decimal integer with no
decimal separator, such as `1782918314123`.

**Rationale**: The clarification requires milliseconds to be encoded directly in
the timestamp value rather than displayed after a decimal point. This matches
the common epoch-milliseconds convention used by logs and systems that need
millisecond precision.

**Alternatives considered**:

- Unix seconds with a fractional suffix, such as `1782918314.123`: rejected
  because the clarified requirement says 13 characters with no separator.
- Locale-formatted date and time: rejected because the feature is an alternate
  timestamp display, not a localized date display.
- ISO 8601 timestamp: rejected because it is longer and does not match the
  requested epoch-milliseconds representation.

## Decision: Use 13-Digit Elapsed Milliseconds for Timer Mode

Timer mode will display the elapsed timer value as a 13-digit,
left-zero-padded decimal integer representing milliseconds from zero, such as
`0000000012345`.

**Rationale**: The timer is a duration and does not have a calendar date or Unix
epoch anchor. Using elapsed milliseconds keeps the format display-only, preserves
timer semantics, and satisfies the 13-character millisecond representation.

**Alternatives considered**:

- Treat timer elapsed value as a wall-clock Unix epoch timestamp: rejected
  because it would incorrectly imply a real date.
- Display unpadded elapsed milliseconds, such as `12345`: rejected because the
  clarified UI format requires 13 characters.
- Keep timer in `HH:mm:ss.SSS` while Clock uses epoch milliseconds: rejected
  because the spec requires the selected format to apply to Timer mode too.

## Decision: Keep Format Switching Display-Only

The selected time format will change only formatter output. It will not change
clock source, monotonic timer source, timer session state, latest loop capture,
input logging state, row order, or log file session ownership.

**Rationale**: The user explicitly requires a running timer to continue without
pause or delay when the format changes. Keeping the formatter as the only
behavioral boundary minimizes regression risk and keeps the change testable.

**Alternatives considered**:

- Recreate Clock and Timer stores after a format switch: rejected because it
  risks resetting state and restarting ticker lifecycles.
- Pause and resume the timer around format updates: rejected because it violates
  the continuity requirement.

## Decision: Persist Time Format in Existing Overlay Preferences

Store the selected format in the existing preferences model and UserDefaults
store. Missing, corrupted, or unknown values fall back to `HH:mm:ss.SSS`.

**Rationale**: The format is a local UI preference and should survive relaunches.
The existing preferences path already centralizes validation and live overlay
application.

**Alternatives considered**:

- Store format only in memory: rejected because the spec requires relaunch
  persistence.
- Add a separate settings file: rejected because it duplicates existing local
  preference infrastructure.

## Decision: Store Captured Event Timestamps as Immutable Strings

Input logging rows will continue storing the formatted timestamp string produced
when the event record is accepted. Format changes affect only future records.

**Rationale**: The spec requires old visible rows and existing log lines to stay
unchanged. Storing the string, rather than a raw timestamp plus a live formatter,
prevents accidental history rewrites.

**Alternatives considered**:

- Store raw time and reformat table rows on every preference change: rejected
  because old rows must remain unchanged.
- Rewrite active log files after a format switch: rejected because log files
  must preserve original lines exactly.

## Decision: Add a Native-Style Custom Epoch Toggle Icon

Use a compact monoline `Epoch Toggle` glyph in SwiftUI/AppKit styling that
combines a clock cue, numeric timestamp cue, and reversible conversion cue. The
icon must match the existing toolbar button treatment and adapt to light and
dark appearances.

**Rationale**: The existing toolbar uses icon-only controls. A native-feeling
custom glyph avoids adding text labels that would crowd the compact overlay and
keeps the feature discoverable through tooltip and accessibility label.

**Alternatives considered**:

- Use a text button such as `Unix`: rejected because it consumes toolbar width
  and conflicts with the existing icon-only control language.
- Use only a generic `number` symbol: rejected because it does not communicate
  conversion between time formats.
- Increase overlay width to make room: rejected by the fixed default-size
  requirement.

## Decision: Tighten Toolbar Layout Within the Existing Overlay Footprint

Timer mode will fit the new control by reducing toolbar spacing and, if needed,
using slightly smaller toolbar button metrics while preserving minimum
clickability, disabled states, tooltips, and accessibility labels.

**Rationale**: Timer mode currently has the tightest button row. Adjusting
control spacing is the smallest change that satisfies the no-size-increase
constraint.

**Alternatives considered**:

- Hide less-used controls behind a menu: rejected because existing Timer and
  logging controls must remain available.
- Increase default overlay size: rejected by the spec.
- Allow overlap or dynamic wrapping: rejected because it would damage the
  compact overlay and make UI tests brittle.
