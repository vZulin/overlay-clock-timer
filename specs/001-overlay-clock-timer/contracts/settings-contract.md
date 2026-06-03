# Settings Contract

## Scope

This contract defines the separate settings window behavior and preference
persistence requirements.

## Settings Window

- Settings must open in a window separate from the overlay.
- Opening settings must not hide, move, or reset the overlay.
- Settings must always be reachable from the visible menu-bar status item.
- Dock visibility changes must not affect status-item reachability.

## Theme Settings

- Supported values: `system`, `light`, `dark`.
- Default value: `system`.
- Applying theme changes must update overlay appearance without restart.

## Overlay Appearance Settings

- Opacity must be configurable from 60% through 100%.
- Window size must be configurable within `220x124` and `520x300`.
- Timer font size must be configurable while preserving readable layout.
- Invalid persisted values must be clamped or reset to defaults.

## Hotkey Settings

- Configurable commands:
  - Start
  - Pause
  - Stop/Reset
  - Loop
  - Mode switch
- A command may have at most one active binding.
- Two active commands may not share the same binding.
- Conflicting input must be rejected or explicitly replace the previous binding.
- Hotkeys dispatch to the same command handlers as overlay buttons.

## Mode Switch Behavior Setting

- Supported values:
  - Continue timer
  - Pause timer
  - Stop and reset timer
- Default value: Stop and reset timer.
- Changes must affect the next mode switch without restart.

## Launch at Login

- Setting must reflect actual registration state after enable or disable.
- If registration fails, persisted preference must not claim success.

## Status Item and Dock Visibility

- User may configure Dock icon visibility.
- The menu-bar status item is required and must not be user-hideable.
- If persisted legacy data attempts to hide the status item, restore status-item
  visibility on load.

## Persistence

- Preferences must persist across app relaunches.
- Preferences are local to the Mac.
- Corrupted or unsupported values must fall back to safe defaults.
