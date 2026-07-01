# Time Format Logging Contract

## Scope

This contract defines how input event timestamps use the selected time format in
visible rows and session log files.

## Capture-Time Timestamp Rule

- Each input event receives a formatted timestamp when the event record is
  accepted.
- The timestamp uses the display mode active at capture time.
- The timestamp uses the time format active at capture time.
- Later format switches do not reformat existing event records.

## Visible Table Contract

- New rows captured in standard format show `HH:mm:ss.SSS`.
- New Clock-mode rows captured in epoch milliseconds format show 13-digit epoch
  milliseconds.
- New Timer-mode rows captured in epoch milliseconds format show 13-digit
  elapsed milliseconds from zero.
- Rows captured before a format switch keep their existing timestamp strings.
- Preserved same-launch rows keep their existing timestamp strings after
  closing and reopening the logging panel.
- Row ordering and trimming behavior remain unchanged.

## Session Log File Contract

- Existing session log file naming remains unchanged:

```text
~/Library/Logs/OverlayClockTimer/YYYY-MM-DD_HH-MM-SS.log
```

- Each appended line keeps the existing shape:

```text
<timestamp><TAB><event name>
```

- New lines use the selected format at the moment the event record is accepted.
- Existing lines are never rewritten after a format switch.
- Mixed timestamp formats are valid within one session file when the user
  switches formats during the session.
- Preserved in-memory rows are not copied into a new session file.

## Privacy Contract

- The feature changes timestamp representation only.
- It does not add app names, window titles, process identifiers, coordinates,
  clipboard content, text field identifiers, telemetry, network sync, or hidden
  durable history.

## Acceptance Checks

- Capture at least one row in standard format, switch format, capture another
  row, and verify both row timestamps remain in their original formats.
- Repeat the same check against the active session log file.
- Repeat the check in Clock mode and Timer mode.
