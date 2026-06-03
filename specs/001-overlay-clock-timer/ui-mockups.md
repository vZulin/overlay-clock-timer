# UI Mockups: Overlay Clock Timer

## Purpose

This document defines the first implementation-ready UI mockups for the Overlay
Clock Timer macOS app. The companion visual preview is available at
[`mockups/ui-mockups.html`](./mockups/ui-mockups.html).

The visual direction follows `UI_Example.png`: compact, rounded, high-contrast,
large time display, and icon-only controls. The mockups are not final art; they
are the layout and interaction contract for implementation.

## Mockup Inventory

| Screen | State | Purpose |
|--------|-------|---------|
| Overlay Clock | Dark, default | Primary always-on-top clock display |
| Overlay Clock | Light | Theme contrast and system appearance adaptation |
| Overlay Timer | Idle | Initial timer controls and disabled states |
| Overlay Timer | Running | Active elapsed timer and enabled loop control |
| Overlay Timer | Loop saved | Live timer plus captured loop value |
| Overlay Timer | Paused | Paused value with Start and Reset available |
| Settings Window | Desktop preferences | Separate settings surface for app behavior |

## Overlay Layout

Default frame: `280x160`.

```text
+------------------------------------------------+
| drag region / status label                     |
|                                                |
|                  time display                  |
|                                                |
+-----------+-----------+-----------+------------+
| control   | control   | control   | mode       |
+-----------+-----------+-----------+------------+
```

### Layout Rules

- The top strip is the custom drag region.
- The time display is centered and uses tabular digits.
- The bottom strip contains icon-only controls.
- Timer controls are grouped on the left.
- The mode switch is visually separated on the right.
- Text labels are not used inside timer control buttons; tooltips and
  accessibility labels provide names.
- Disabled controls keep their slot and opacity changes only, so layout does not
  shift.

## Overlay States

### Clock Mode

- Primary display shows `HH:MM:SS.mmm`.
- Bottom controls:
  - Settings
  - Pin or visibility affordance
  - Mode switch
- Clock mode has no destructive action in the overlay.

### Timer Idle

- Primary display shows `00:00:00.000`.
- Start is enabled.
- Loop is disabled.
- Stop/Reset is disabled.
- Mode switch is enabled and separated.

### Timer Running

- Primary display shows live elapsed value.
- Start becomes Pause.
- Loop is enabled.
- Stop/Reset is enabled.
- Mode switch is enabled.

### Timer Loop Saved

- Primary display continues showing live elapsed time.
- Secondary text below the primary display shows the latest captured loop value.
- A small `LOOP` status marker appears in the drag region.
- Underlying timer continues.
- Pressing Loop again replaces the secondary loop value with the new press-time
  value.

### Timer Paused

- Primary display shows the paused elapsed value.
- Start is enabled.
- Loop is disabled.
- Stop/Reset is enabled.
- Mode switch is enabled.

## Settings Window

The settings window is separate from the overlay and uses a quiet macOS utility
layout:

- Sidebar categories:
  - Appearance
  - Timer
  - Shortcuts
  - Startup
  - Visibility
- Main pane uses compact form rows.
- Settings apply immediately where safe.
- The menu-bar status item is always visible; the Visibility pane only toggles
  Dock icon visibility.

## Design Tokens

| Token | Dark Value | Light Value | Notes |
|-------|------------|-------------|-------|
| Overlay radius | 24 px | 24 px | Matches compact floating panel direction |
| Control height | 46 px | 46 px | Stable bottom strip |
| Clock time font | 43 px | 43 px | Default `280x160` frame |
| Timer time font | 34 px | 34 px | Leaves room for the secondary loop value |
| Loop value font | 13 px | 13 px | Secondary captured loop value |
| Time font family | SF Mono fallback | SF Mono fallback | Tabular digits required |
| Accent | `#30d158` | `#007aff` | Success/action contrast |
| Warning accent | `#ff9f0a` | `#bf5a00` | Loop saved marker |
| Background opacity | 90% | 90% | Configurable from 60% through 100%; background only, not text |

## Accessibility Requirements

- Every icon-only button has an accessibility label.
- Every icon-only button has a tooltip.
- Disabled buttons expose disabled state and keep at least 40% visual contrast.
- The time display uses tabular digits to avoid width changes.
- The visible focus ring must fit inside each control slot.
- Minimum supported overlay size must not truncate controls.

## Implementation Notes

- Use SF Symbols in the native app for button icons.
- Use `NSWindow` plus `NSHostingView` for the overlay.
- Keep hit areas stable at all supported overlay sizes.
- Apply opacity to the panel material/background, not to the entire window
  content, so text and icons remain readable.
- Persist frame and size through the preferences store.
