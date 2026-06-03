# Overlay UI Contract

## Scope

This contract defines externally visible overlay behavior for Clock mode, Timer
mode, mode switching, draggable behavior, always-on-top behavior, and persisted
window geometry.

## Overlay Window Contract

- Default visible size: approximately `280x160`.
- Minimum visible size: `220x124`.
- Maximum visible size: `520x300`.
- Window must be visually titleless.
- Window must remain above normal application windows while visible.
- Window must be draggable through the dedicated drag region.
- Window controls must remain clickable and must not start a drag gesture.
- Window position must persist after drag and restore on next launch.
- If restored position is off-screen, the overlay must recover to a visible
  default position.

## Clock Mode Contract

- Display format: `HH:MM:SS.mmm`.
- Display source: current system wall-clock time.
- Display must refresh smoothly at display cadence while visible.
- System clock changes must be reflected in Clock mode.
- Timer elapsed state must not be changed by system clock changes.

## Timer Mode Contract

### Idle or Reset

- Display value: `00:00:00.000`.
- Start: enabled.
- Pause: not visible; Start is visible instead.
- Loop: visible but disabled.
- Stop/Reset: visible but disabled.
- Mode switch: enabled and visually separate from timer controls.

### Running

- Main display value: live elapsed duration.
- Secondary loop value: hidden until Loop captures a value.
- Start: replaced by Pause.
- Pause: enabled.
- Loop: enabled.
- Stop/Reset: enabled.
- Mode switch: enabled and visually separate from timer controls.

### Paused

- Display value: paused elapsed duration.
- Start: enabled.
- Pause: not visible; Start is visible instead.
- Loop: disabled.
- Stop/Reset: enabled.
- Mode switch: enabled and visually separate from timer controls.

### Loop Saved Value

- First Loop press while running captures elapsed time into a secondary line
  below the main timer.
- The main timer continues showing live elapsed time while the secondary loop
  value is visible.
- Repeated Loop presses replace the secondary loop value with the new press-time
  elapsed value.
- Stop/Reset clears the secondary loop value.
- Pause preserves the secondary loop value until Start or Stop/Reset changes
  state.

## Mode Switch Contract

- Mode switch is always available.
- Mode switch does not share visual grouping with Start, Pause, Loop, and
  Stop/Reset.
- If timer is running:
  - `continue`: timer remains running.
  - `pause`: timer pauses and keeps current elapsed value.
  - `stopAndReset`: timer resets to `00:00:00.000`.
- Default mode-switch action: `stopAndReset`.

## Accessibility Contract

- Every icon-only control must have an accessibility label and tooltip.
- Disabled controls must expose disabled state.
- Time display must use tabular digits.
- Text and icon contrast must remain readable in light and dark appearances.

## Visual Contract

- Visual direction follows `UI_Example.png`: compact, rounded, minimalist,
  high-contrast, large time display, and bottom icon-only controls.
- Background opacity is configurable from 60% through 100% and affects the panel
  background, not text opacity.
- Timer controls are grouped; mode switch is visually separated.
