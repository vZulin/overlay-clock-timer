# Research: Overlay Clock Timer

## Decision: SwiftUI app lifecycle with AppKit overlay bridge

**Decision**: Use a SwiftUI `App` entry point and SwiftUI views for menu content,
overlay content, and settings, with an AppKit `OverlayWindowController` for the
floating `NSWindow`.

**Rationale**: SwiftUI keeps the UI compact and testable, while AppKit is required
for precise macOS window behavior such as titleless windows, window levels,
custom dragging, and frame persistence.

**Alternatives considered**:

- Pure AppKit: more control but more boilerplate and slower iteration.
- Electron or cross-platform UI: rejected by macOS-only constitution and resource
  budget.
- Pure SwiftUI window scene for overlay: rejected because it does not provide
  enough reliable control over the floating, titleless overlay contract.

## Decision: macOS Tahoe 26.0+ deployment target

**Decision**: Target macOS Tahoe 26.0+ for the initial implementation.

**Rationale**: The user explicitly requested macOS Tahoe 26. Targeting Tahoe
keeps the implementation aligned with the intended current macOS SDK and avoids
compatibility branches for older macOS releases.

**Alternatives considered**:

- macOS 14.0+: rejected because it no longer matches the requested target.
- Older macOS support: rejected because it increases compatibility validation
  surface and conflicts with the macOS Tahoe 26 requirement.

## Decision: Xcode 26.x with Swift 6 language mode

**Decision**: Use Xcode 26.x, Swift 6 language mode, and the Swift 6.3 compiler
where available in the selected Xcode 26.x toolchain.

**Rationale**: Xcode exposes Swift language mode as Swift 6, while the bundled
compiler version can be Swift 6.3 in current Xcode 26.x toolchains. This keeps
the project on the modern concurrency and diagnostics baseline without inventing
a non-existent "Swift 6.3 language mode" setting.

**Alternatives considered**:

- Swift 5.10 with Xcode 16.x: rejected as stale for macOS Tahoe 26 and Xcode
  26.x.
- Swift 6.0 with Xcode 16.x: rejected because it does not match the requested
  Xcode 26/macOS Tahoe 26 baseline.
- Future Swift snapshots: rejected for v1 because they reduce reproducibility.

## Decision: No third-party dependencies

**Decision**: Use only Apple frameworks in v1.

**Rationale**: The feature is small and depends mainly on system window, menu,
time, preferences, and test APIs. Extra dependencies would increase launch time,
review cost, and maintenance risk without solving a hard problem.

**Alternatives considered**:

- Third-party hotkey packages: convenient, but unnecessary for v1 and conflicts
  with the dependency policy.
- Third-party settings or UI packages: rejected because SwiftUI is sufficient.

## Decision: `NSWindow.Level.floating` default with `.statusBar` fallback

**Decision**: Use `.floating` as the default always-on-top level. Keep
`.statusBar` as an implementation fallback if verification shows `.floating`
does not satisfy normal overlay acceptance tests.

**Rationale**: `.floating` is less intrusive and satisfies the product contract
for normal application windows. `.statusBar` is more aggressive and should not be
the default unless tests prove it is required.

**Alternatives considered**:

- Always use `.statusBar`: stronger visibility, but risks covering system UI and
  feeling too invasive.
- Normal window level: rejected because it violates the overlay requirement.

## Decision: Custom drag region using `window.performDrag(with:)`

**Decision**: Implement a dedicated drag region with an AppKit-backed view that
forwards mouse-down events to the hosting window's native drag behavior.

**Rationale**: The overlay has buttons. Making the whole background movable
risks conflicts between button clicks and window dragging. A dedicated drag
region is predictable and testable.

**Alternatives considered**:

- `isMovableByWindowBackground = true`: simpler, but too coarse for an
  interactive overlay.
- Manual frame mutation during mouse drag: more code and easier to get wrong
  across displays.

## Decision: Borderless overlay window style

**Decision**: Use a manually owned `NSWindow` with `.borderless` style, clear
background, shadow, and a SwiftUI/AppKit custom drag region.

**Rationale**: A borderless window removes the standard title bar entirely and
keeps hit testing predictable for a compact overlay with custom controls.

**Alternatives considered**:

- Transparent title bar with full-size content view: viable, but keeps more
  title-bar semantics than this compact overlay needs.
- Standard titled window: rejected because it violates the overlay visual
  contract.

## Decision: Display cadence capped at 60 Hz

**Decision**: Use a display ticker capped at 60 Hz for visible clock/timer
updates. Every render uses accurate current time or elapsed time.

**Rationale**: A 1 ms UI redraw loop would waste resources and is not guaranteed
by normal display hardware or macOS scheduling. Accuracy belongs in the time
calculation; rendering should follow display cadence.

**Alternatives considered**:

- 1 ms `Timer`: rejected because it increases CPU usage without guaranteeing
  visible 1 ms updates.
- 1 Hz updates: too coarse for millisecond display.
- Adaptive cadence: acceptable later, but 60 Hz is the simplest v1 target.

## Decision: DateFormatter for clock, custom formatter for elapsed timer

**Decision**: Use a cached `DateFormatter` for Clock mode with
`HH:mm:ss.SSS`. Use a custom `DurationFormatter` for Timer mode.

**Rationale**: DateFormatter formats calendar dates and is correct for current
system time. Timer mode formats elapsed duration; a custom formatter avoids
timezone and date rollover problems.

**Alternatives considered**:

- DateFormatter for elapsed timer: rejected because it treats elapsed values as
  dates.
- Swift duration formatting: viable for display text, but custom formatting is
  easier to test for the exact `HH:mm:ss.SSS` contract.

## Decision: Monotonic time source for timer math

**Decision**: Timer elapsed time uses an injected monotonic time source. Clock
mode uses system wall-clock time.

**Rationale**: A user or network time update can change the system clock while a
timer is running. The elapsed timer must continue correctly through that event.
Injection keeps tests deterministic.

**Alternatives considered**:

- `Date()` subtraction for elapsed timer: rejected because wall-clock changes
  can corrupt elapsed time.
- Real waiting in tests: rejected because it makes tests slow and flaky.

## Decision: Loop as secondary captured elapsed value

**Decision**: In running state, pressing Loop stores the current elapsed value
as secondary UI content below the main timer. The main timer always continues to
show live elapsed time. Repeated Loop presses replace the secondary value.

**Rationale**: The user must keep seeing the live timer after pressing Loop. A
secondary latest-loop line preserves the captured value without hiding the main
timer and without adding a lap list to the compact overlay.

**Alternatives considered**:

- Replacing the main timer with the captured value: rejected because users lose
  the live elapsed value.
- Toggle between captured and live display: rejected because it adds cognitive
  overhead and can still hide the live timer.
- Lap list: useful, but out of scope for the compact overlay.

## Decision: UserDefaults for preferences and window frame

**Decision**: Persist settings, last overlay frame, and selected timer behavior
with typed UserDefaults keys.

**Rationale**: Preferences are local, small, and do not require sync or complex
schema migration in v1.

**Alternatives considered**:

- Files: unnecessary complexity for small preference values.
- Core Data or SwiftData: rejected as excessive for v1.

## Decision: Visible status item with optional Dock icon

**Decision**: Keep the menu-bar status item visible for the lifetime of the app.
Expose Dock icon visibility as the only configurable app-presence setting.

**Rationale**: The constitution requires a visible status item, and the status
item is the stable recovery path for showing the overlay, opening settings, and
quitting. Allowing status-item hiding would create an avoidable unrecoverable
state unless the constitution were amended.

**Alternatives considered**:

- Configurable menu-bar and Dock visibility: rejected because it conflicts with
  the visible status-item requirement.
- Dock-only recovery path: rejected because the app is defined as a menu-bar app
  and Dock visibility is optional.
- Amend the constitution: rejected because the requested behavior can be
  satisfied without weakening the menu-bar contract.

## Decision: Apple-native hotkey registration wrapper

**Decision**: Create a `HotkeyRegistrar` abstraction around Apple-native global
hotkey handling.

**Rationale**: The app needs no dependency for a small set of global shortcuts,
and a wrapper keeps future replacement possible if a macOS API constraint is
discovered during implementation.

**Alternatives considered**:

- Third-party hotkey library: rejected by dependency policy.
- Local-only shortcuts: simpler, but weaker than the user requirement.
- Event taps: powerful, but may require broader permissions and more careful
  privacy handling.

## Decision: Launch-at-login via ServiceManagement

**Decision**: Use ServiceManagement for the launch-at-login setting.

**Rationale**: It is the Apple-native path for login item management and avoids
custom launch agent files.

**Alternatives considered**:

- Manual LaunchAgent plist: more fragile and less user-friendly.
- No startup support in v1: rejected by the specification.

## Decision: UI contracts for application behavior

**Decision**: Create contracts for overlay controls, settings, and test
checkpoints instead of network API contracts.

**Rationale**: This app has no server API. The public behavior is user-facing UI
state, persisted preferences, and test gates.

**Alternatives considered**:

- Skip contracts: rejected because UI behavior has enough stateful rules to
benefit from explicit contracts.
