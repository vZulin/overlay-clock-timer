# Time Format UI Contract

## Scope

This contract defines overlay toolbar, icon, accessibility, and layout behavior
for the time format toggle.

## Toolbar Placement

- The time format toggle is icon-only.
- Clock mode contains a `clock.timeFormatToggle` button.
- Timer mode contains a `timer.timeFormatToggle` button.
- The toggle remains visible when the input logging panel is expanded.
- The toggle must not replace or hide:
  - Settings
  - Hide Overlay
  - Start/Pause
  - Stop/Reset
  - Loop
  - Input Logging
  - Clock/Timer Mode Switch

## Icon Contract

- The icon follows the `Epoch Toggle` direction.
- The glyph is compact, monoline, and native-feeling.
- The glyph combines:
  - a clock or time cue,
  - a numeric timestamp cue,
  - a reversible conversion cue.
- The icon adapts to light and dark appearance using the existing toolbar color
  treatment.
- The icon remains legible at compact toolbar button sizes.

## Icon Design Acceptance

- Before implementation, the `Epoch Toggle` icon must complete a macOS design
  review against the existing toolbar control style.
- The accepted sketch must define the clock cue, numeric timestamp cue,
  reversible conversion cue, compact button bounds, and light/dark rendering
  expectations.
- Implementation in `OverlayToolbarView` must follow the accepted sketch unless
  the deviation is recorded in this contract before coding.

### Accepted Epoch Toggle Sketch

- Review date: 2026-07-01.
- Review basis: macOS toolbar icon guidance, existing overlay button treatment,
  compact timer toolbar constraints, light/dark adaptive foreground rendering,
  and the fixed 280x160 default collapsed overlay size.
- Button bounds: 32x32 pt toolbar button, 8 pt corner radius, no visible text
  label, with the existing active/disabled/background treatment preserved.
- Glyph bounds: 18x18 pt optical drawing area centered inside the button.
- Clock cue: a small monoline clock ring on the leading side with two rounded
  hands.
- Numeric timestamp cue: three trailing monoline digit-row strokes suggesting a
  compact epoch-milliseconds value without spelling out "Unix" or adding a text
  label.
- Reversible conversion cue: a rounded diagonal connector with a small arrow
  head from the clock cue toward the timestamp strokes.
- Stroke style: 1.4-1.6 pt rounded caps and joins, using the same adaptive
  foreground color as the existing SF Symbol toolbar icons.
- Light/dark rendering: no hard-coded icon colors; the glyph inherits the
  toolbar token color and opacity used for enabled and disabled controls.
- Acceptance: accepted for implementation in `OverlayToolbarView` with compact
  metrics centralized in `OverlayMetrics`.

## Accessibility Contract

- The button has a tooltip.
- The button has an accessibility label.
- The label describes the target action, not only the current state.
- Suggested labels:
  - `Switch to Epoch Milliseconds`
  - `Switch to Standard Time Format`
- UI tests identify the button by stable accessibility identifiers:
  - `clock.timeFormatToggle`
  - `timer.timeFormatToggle`

## Layout Contract

- Default collapsed overlay size remains 280x160 px.
- Timer mode controls fit without increasing default overlay width or height.
- Control compaction may reduce toolbar spacing and button size, but controls
  must remain readable, distinguishable, and clickable.
- No control may overlap another control.
- Time display text must not overlap the toolbar.
- The mode switch remains visually distinct from timer controls.
- The input logging toggle remains immediately left of the mode switch unless
  a tighter grouping is required; if grouping changes, UI tests must still prove
  the logging toggle and mode switch remain separate and usable.

## UI Test Requirements

- Verify Clock mode toggle exists, is enabled, and switches display format.
- Verify Timer mode toggle exists, is enabled, and switches display format.
- Verify Timer mode controls remain visible and do not overlap at default size.
- Verify expanded input logging state keeps the toggle visible and usable.
- Verify light and dark appearance keep the icon readable at 60%, 90%, and 100%
  background opacity.
