# Data Model: Overlay Clock Timer

## Entity: DisplayMode

Represents the active overlay mode.

### Values

- `clock`
- `timer`

### Validation Rules

- Value must always be one of the defined cases.
- Mode switching must be available from every overlay state.

### Relationships

- A mode switch may trigger `ModeSwitchAction` when `TimerSession` is running.
- `OverlayRootView` derives visible controls from `DisplayMode`.

## Entity: TimerSession

Represents elapsed timer state.

### Fields

- `state`: `idle`, `running`, `paused`, or `reset`
- `startedAt`: monotonic instant, present only while running
- `accumulatedElapsed`: duration accumulated before the current running segment
- `latestLoop`: optional `LoopCapture`

### Validation Rules

- Elapsed time must never be negative.
- `startedAt` must exist only in `running`.
- `latestLoop` may exist only when elapsed time has been captured from a
  running session.
- Stop/Reset must clear `startedAt`, `accumulatedElapsed`, and `latestLoop`.

### State Transitions

```text
idle --start--> running
reset --start--> running
running --pause--> paused
paused --start--> running
running --stopReset--> reset
paused --stopReset--> reset
running --loop when no loop value--> running(latestLoop shown below live timer)
running(latestLoop exists) --loop--> running(latestLoop replaced)
```

### Relationships

- Uses `TimeSource` for deterministic elapsed calculation.
- Uses `DurationFormatter` for display.
- Controlled by overlay buttons and hotkey commands.

## Entity: LoopCapture

Represents a display-only captured elapsed time.

### Fields

- `capturedElapsed`: duration at the moment Loop was pressed
- `capturedAt`: monotonic instant for debugging and tests

### Validation Rules

- `capturedElapsed` must be greater than or equal to zero.
- Captured loop display must not replace, pause, or reset the main timer.

### Relationships

- Belongs to `TimerSession`.

## Entity: ModeSwitchAction

Defines timer behavior when a user switches modes while the timer is running.

### Values

- `continue`
- `pause`
- `stopAndReset`

### Validation Rules

- Default value must be `stopAndReset`.
- Stored value must fall back to `stopAndReset` if unknown or corrupted.

### Relationships

- Read by `AppCoordinator` before applying a `DisplayMode` change.
- Persisted by `PreferencesStore`.

## Entity: OverlayPreferences

Represents user-configurable overlay appearance and behavior.

### Fields

- `theme`: `system`, `light`, or `dark`
- `backgroundOpacity`: decimal value applied only to the overlay background
- `windowSize`: width and height
- `timerFontSize`: decimal value
- `lastWindowFrame`: x, y, width, and height
- `lastDisplayMode`: optional `DisplayMode`

### Validation Rules

- `theme` defaults to `system`.
- `backgroundOpacity` defaults to `0.90` and must stay within `0.60...1.00`.
- `windowSize` defaults near `280x160`, with minimum `220x124` and maximum
  `520x300`.
- `timerFontSize` must fit inside the current overlay size.
- `lastWindowFrame` must be validated against visible screens before restore.

### Relationships

- Persisted by `PreferencesStore`.
- Applied by `OverlayWindowController` and `OverlayRootView`.

## Entity: HotkeyBinding

Represents one keyboard shortcut mapped to one overlay command.

### Fields

- `command`: `start`, `pause`, `stopReset`, `loop`, or `switchMode`
- `keyCode`: platform key code
- `modifiers`: modifier flags
- `isEnabled`: boolean

### Validation Rules

- Each command may have at most one active binding.
- Two active commands must not share the same key and modifier combination.
- Conflicting bindings must be rejected or explicitly replaced by the user.

### Relationships

- Persisted by `PreferencesStore`.
- Registered by `HotkeyRegistrar`.
- Dispatches to the same command handlers as overlay buttons.

## Entity: AppVisibilityPreference

Represents optional Dock visibility while preserving the required menu-bar status
item.

### Fields

- `showDockIcon`: boolean
- `statusItemVisible`: always true while the app is running; not a
  user-configurable persisted field

### Validation Rules

- `statusItemVisible` must always resolve to true while the app is running.
- Invalid or legacy persisted values that attempt to hide the status item must
  be ignored or corrected on load.

### Relationships

- Applied by `AppCoordinator`.
- Dock state is delegated to `AppVisibilityController`.

## Entity: LaunchAtLoginPreference

Represents startup behavior.

### Fields

- `isEnabled`: boolean

### Validation Rules

- Failed enable or disable operations must leave the stored value consistent with
  the actual system registration state.

### Relationships

- Applied by `LaunchAtLoginController`.
- Exposed in settings.

## Entity: OverlayGeometry

Represents current overlay frame and screen recovery behavior.

### Fields

- `frame`: x, y, width, and height
- `visibleScreenFrame`: screen frame used for validation

### Validation Rules

- Width and height must respect user preference bounds.
- Restored frame must intersect a visible screen.
- If the frame is outside all screens, reset to a centered default frame.

### Relationships

- Persisted by `OverlayGeometryStore`.
- Applied by `OverlayWindowController`.
