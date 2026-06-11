# Input Logging File Contract

## Scope

This contract defines local session log file creation and write boundaries for
Input Event Logging.

## Location and Naming

- Directory: `~/Library/Logs/OverlayClockTimer/`.
- Base filename format: `YYYY-MM-DD_HH-MM-SS.log`.
- A new file is created for each logging panel open.
- If the base filename already exists, the app may create a collision-safe
  variant for the same session.

## Session Boundaries

- A session starts when the logging panel opens.
- A session ends when the logging panel closes.
- File writing is active only during an open-panel session.
- Keyboard, mouse, or scroll events after close must not be written to the
  closed file.
- Reopening the panel creates a new session file.

## Record Content

Each log record is one line with exactly two fields:

- Formatted timestamp.
- One tab character.
- Event name.

Example:

```text
00:00:00.000	Command+C
```

Each log record must not contain these key-value fields:

- `order=`.
- `timestamp=`.
- `category=`.
- `type=`.
- `name=`.
- `phase=`.

Each log record must not contain:

- App name.
- Window title.
- Process metadata.
- Text field identifier.
- Mouse coordinates.
- Scroll coordinates or delta magnitudes.
- Clipboard content.
- Network identifiers.

## Preserved Table Rows

- Preserved table rows are in-memory UI history.
- Preserved rows are never copied into a new session log file.
- Only newly captured events during the open session are written.

## Failure Handling

- If the directory cannot be created, file recording becomes unavailable for the
  session.
- If the file cannot be created, file recording becomes unavailable for the
  session.
- If writing fails during a session, the table remains usable and file recording
  status becomes unavailable.
- Failure to write the log file must not keep input capture active after panel
  close.
