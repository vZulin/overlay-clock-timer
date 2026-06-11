# Input Logging Settings Contract

## Scope

This contract defines settings and persistence requirements for input logging
preferences.

## Settings Surface

- Input logging settings live in the existing settings window.
- No separate settings window is introduced for input logging.
- Opening settings must not start input capture.
- Changing settings must not change whether logging is currently active.

## Event Table Row Limit

- Preference key intent: visible event table row limit.
- Default value: `15`.
- Minimum value: `5`.
- Maximum value: `50`.
- Missing persisted value uses `15`.
- Persisted values below `5` are clamped to `5`.
- Persisted values above `50` are clamped to `50`.
- The row limit applies to visible rows and preserved in-memory rows, not to
  session log file line count.

## Event Table Preservation

- Preference key intent: preserve visible table rows between panel openings.
- Default value: disabled.
- When disabled, opening the panel starts with an empty visible table.
- When enabled, visible rows are preserved only during the current app launch.
- Preserved rows clear when the app quits.
- Preserved rows are not persisted in UserDefaults.
- Preserved rows are not written into new session log files.

## Persistence

- `eventTableRowLimit` persists across app relaunches.
- `preserveEventTableBetweenOpens` persists across app relaunches.
- The row records themselves do not persist across app relaunches.
- Preferences are local to the Mac and are not synced or uploaded.

## Validation Coverage

- Requirements must cover default values.
- Requirements must cover valid minimum and maximum values.
- Requirements must cover corrupted or out-of-range persisted values.
- Requirements must cover changing settings while the logging panel is open.
