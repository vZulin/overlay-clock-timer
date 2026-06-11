# Input Logging UI Contract

## Scope

This contract defines externally visible overlay behavior for the input logging
toggle, expanded event table, table row lifecycle, and accessibility.

## Toolbar Contract

- The logging toggle is icon-only.
- The logging toggle appears immediately to the left of the Clock/Timer mode
  switch in both Clock and Timer modes.
- The baseline symbol is `list.bullet.rectangle` or the closest available
  list/log SF Symbol in the target macOS symbol catalog.
- The toggle has a tooltip and accessibility label.
- The mode switch remains available and visually separated from timer controls.

## Panel Open/Close Contract

- Closed state:
  - The overlay uses its normal collapsed layout.
  - Input capture is inactive.
  - File writing is inactive.
- Open state:
  - The overlay expands downward.
  - A table area appears below the existing primary overlay content.
  - Input capture is active only if permissions allow observation.
  - A new session log file is created or file recording shows unavailable state.
- Closing the panel stops input capture and file writes immediately.
- Rapid repeated open/close must not leave capture or file writing active after
  close.

## Table Contract

- Rows are newest-first.
- Row count must not exceed `eventTableRowLimit`.
- Default row limit is `15`.
- Valid row limit range is `5...50`.
- With preservation disabled, every panel open starts with an empty table.
- With preservation enabled, reopening the panel during the same app launch
  restores the previously visible rows up to the row limit.
- Preserved rows clear when the app quits.
- Preserved rows are visible UI history only and are not written into a new
  session log file.

## Empty and Unavailable States

- Default open with no captured events shows an empty table state.
- File recording unavailable state must be visible when the session file cannot
  be created.
- Input capture unavailable state must be visible when macOS permissions prevent
  observation.
- The panel remains usable when file recording or capture is unavailable.

## Timestamp Contract

- Clock mode rows use current system time in `HH:MM:SS.mmm`.
- Timer mode rows use the current visible timer value.
- Timer idle/reset rows use `00:00:00.000`.
- Timestamp text must remain readable in light and dark appearance.

## Accessibility and Visual Contract

- The logging toggle, table, rows, and unavailable states must have accessible
  labels.
- Row text must remain readable in light and dark appearance.
- The expanded panel must not make existing time, timer, or mode controls
  inaccessible.
- The overlay remains titleless, draggable through the drag region, and
  always-on-top while expanded.
