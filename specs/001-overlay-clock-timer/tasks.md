# Tasks: Overlay Clock Timer

**Input**: Design documents from `/specs/001-overlay-clock-timer/`
**Prerequisites**: `specs/001-overlay-clock-timer/plan.md`, `specs/001-overlay-clock-timer/spec.md`, `specs/001-overlay-clock-timer/research.md`, `specs/001-overlay-clock-timer/data-model.md`, `specs/001-overlay-clock-timer/contracts/`, `specs/001-overlay-clock-timer/quickstart.md`, `specs/001-overlay-clock-timer/ui-mockups.md`

**Tests**: Automated tests are mandatory for every development stage. Write behavior tests before implementation tasks, confirm they fail for the intended reason, then run the required checkpoint command after each phase:

```bash
xcodebuild test -scheme OverlayClockTimer -destination 'platform=macOS'
```

**Organization**: Tasks are grouped by user story to keep each increment independently implementable and testable.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel because it touches different files and does not depend on incomplete tasks.
- **[Story]**: User-story label for story phases only.
- Every task includes an exact project path.

## Path Conventions

- **App target**: `OverlayClockTimer/`
- **Unit/integration tests**: `OverlayClockTimerTests/`
- **UI automation tests**: `OverlayClockTimerUITests/`
- **Project file**: `OverlayClockTimer.xcodeproj/project.pbxproj`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Create the native macOS project shell, targets, schemes, and baseline test command.

- [X] T001 Create `OverlayClockTimer.xcodeproj/project.pbxproj` with macOS app, unit test, and UI test targets for macOS Tahoe 26.0+, Xcode 26.x, Swift 6 language mode, and no third-party dependencies
- [X] T002 Configure the `OverlayClockTimer` scheme and shared test action in `OverlayClockTimer.xcodeproj/xcshareddata/xcschemes/OverlayClockTimer.xcscheme`
- [X] T003 [P] Create source directory structure under `OverlayClockTimer/App/`, `OverlayClockTimer/Overlay/`, `OverlayClockTimer/Clock/`, `OverlayClockTimer/Timer/`, `OverlayClockTimer/Settings/`, `OverlayClockTimer/Preferences/`, `OverlayClockTimer/Hotkeys/`, `OverlayClockTimer/DesignSystem/`, and `OverlayClockTimer/Support/`
- [X] T004 [P] Create test directory structure under `OverlayClockTimerTests/ClockTests/`, `OverlayClockTimerTests/TimerTests/`, `OverlayClockTimerTests/PreferencesTests/`, `OverlayClockTimerTests/OverlayTests/`, `OverlayClockTimerTests/PerformanceTests/`, and `OverlayClockTimerUITests/`
- [X] T005 [P] Create resource catalog `OverlayClockTimer/Resources/Assets.xcassets` and add `UI_Example.png` as a design reference resource entry if the app target needs bundled reference assets
- [X] T006 Run `xcodebuild test -scheme OverlayClockTimer -destination 'platform=macOS'` for `OverlayClockTimer.xcodeproj` and record the setup checkpoint in `specs/001-overlay-clock-timer/contracts/test-checkpoints.md`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Build deterministic time, formatting, preferences, geometry, ticker, and design-system primitives used by all stories.

**Critical**: No user-story implementation should begin until this phase is complete.

### Tests for Foundation (MANDATORY)

- [X] T007 [P] Add injectable time source tests in `OverlayClockTimerTests/ClockTests/TimeSourceTests.swift`
- [X] T008 [P] Add fixed `HH:mm:ss.SSS` clock formatter tests in `OverlayClockTimerTests/ClockTests/ClockFormatterTests.swift`
- [X] T009 [P] Add elapsed duration formatter tests for `HH:mm:ss.SSS` and hour rollover in `OverlayClockTimerTests/TimerTests/DurationFormatterTests.swift`
- [X] T010 [P] Add display cadence and cancellation tests in `OverlayClockTimerTests/ClockTests/DisplayTickerTests.swift`
- [X] T011 [P] Add preference default, clamping, corrupted-value, status-item invariant, and Dock visibility tests in `OverlayClockTimerTests/PreferencesTests/PreferencesStoreTests.swift`
- [X] T012 [P] Add visible-screen recovery tests in `OverlayClockTimerTests/PreferencesTests/ScreenFrameValidatorTests.swift`

### Implementation for Foundation

- [X] T013 Create SwiftUI app entry point scaffold in `OverlayClockTimer/App/OverlayClockTimerApp.swift`
- [X] T014 Create main coordinator scaffold for overlay visibility, settings presentation, display mode, and command routing in `OverlayClockTimer/App/AppCoordinator.swift`
- [X] T015 [P] Implement injectable wall-clock and monotonic time abstractions in `OverlayClockTimer/Clock/TimeSource.swift`
- [X] T016 [P] Implement cached POSIX `DateFormatter` clock formatting in `OverlayClockTimer/Clock/ClockFormatter.swift`
- [X] T017 [P] Implement exact elapsed duration formatting in `OverlayClockTimer/Timer/DurationFormatter.swift`
- [X] T018 [P] Implement display-cadence ticker capped at 60 Hz in `OverlayClockTimer/Clock/DisplayTicker.swift`
- [X] T019 [P] Implement typed overlay preference model, Dock visibility setting, and defaults in `OverlayClockTimer/Preferences/OverlayPreferences.swift`
- [X] T020 [P] Implement hotkey binding model and conflict identity in `OverlayClockTimer/Preferences/HotkeyBinding.swift`
- [X] T021 Implement preference loading, validation, clamping, and persistence in `OverlayClockTimer/Preferences/PreferencesStore.swift` and `OverlayClockTimer/Preferences/UserDefaultsPreferencesStore.swift`
- [X] T022 [P] Implement visible screen frame validation in `OverlayClockTimer/Support/ScreenFrameValidator.swift`
- [X] T023 [P] Implement overlay size, font, control, and opacity metrics in `OverlayClockTimer/DesignSystem/OverlayMetrics.swift`
- [X] T024 [P] Implement adaptive system/light/dark theme tokens in `OverlayClockTimer/DesignSystem/OverlayTheme.swift`
- [X] T025 [P] Implement reusable icon-only control styling in `OverlayClockTimer/DesignSystem/SymbolButtonStyle.swift`
- [X] T026 Implement window frame persistence and off-screen recovery storage in `OverlayClockTimer/Overlay/OverlayGeometryStore.swift`
- [X] T027 Run `xcodebuild test -scheme OverlayClockTimer -destination 'platform=macOS'` for `OverlayClockTimer.xcodeproj` and record the foundation checkpoint in `specs/001-overlay-clock-timer/contracts/test-checkpoints.md`

**Checkpoint**: Foundation is ready; user stories can start from deterministic, tested primitives.

---

## Phase 3: User Story 1 - View Current Time Overlay (Priority: P1) [MVP]

**Goal**: Show a compact, titleless, draggable, always-on-top overlay from the menu bar with current system time in `HH:MM:SS.mmm`.

**Independent Test**: Launch the app, show the overlay from the menu bar, verify `.floating` window behavior, drag persistence, light/dark readability, and current time display format.

### Tests for User Story 1 (MANDATORY)

- [X] T028 [P] [US1] Add clock display model tests with injected wall-clock dates in `OverlayClockTimerTests/ClockTests/ClockDisplayModelTests.swift`
- [X] T029 [P] [US1] Add overlay window level, borderless style, show/hide, and frame-restore tests in `OverlayClockTimerTests/OverlayTests/OverlayWindowControllerTests.swift`
- [X] T030 [P] [US1] Add overlay frame persistence tests for drag saves and off-screen restore in `OverlayClockTimerTests/OverlayTests/OverlayGeometryStoreTests.swift`
- [X] T031 [P] [US1] Add UI automation for menu-bar show/hide and visible overlay smoke flow in `OverlayClockTimerUITests/OverlayClockTimerUITests.swift`

### Implementation for User Story 1

- [X] T032 [P] [US1] Implement current-time display model using `ClockFormatter` and `DisplayTicker` in `OverlayClockTimer/Clock/ClockDisplayModel.swift`
- [X] T033 [US1] Implement borderless floating `NSWindow` ownership, `.floating` level, transparent background, shadow, and frame restore in `OverlayClockTimer/Overlay/OverlayWindowController.swift`
- [X] T034 [P] [US1] Implement AppKit-backed custom drag region using `window.performDrag(with:)` in `OverlayClockTimer/Overlay/DragRegionView.swift`
- [X] T035 [P] [US1] Implement menu-bar content with Show Overlay, Hide Overlay, Settings, and Quit actions in `OverlayClockTimer/App/MenuBarContentView.swift`
- [X] T036 [US1] Implement Clock-mode overlay layout with large tabular time display and bottom controls in `OverlayClockTimer/Overlay/OverlayRootView.swift`
- [X] T037 [US1] Wire `MenuBarExtra`, overlay controller creation, and show/hide commands through `OverlayClockTimer/App/OverlayClockTimerApp.swift` and `OverlayClockTimer/App/AppCoordinator.swift`
- [X] T038 [US1] Persist overlay position after drag and restore validated frames through `OverlayClockTimer/Overlay/OverlayWindowController.swift` and `OverlayClockTimer/Overlay/OverlayGeometryStore.swift`
- [X] T039 [US1] Apply theme, opacity, radius, and sizing metrics to Clock-mode overlay content in `OverlayClockTimer/Overlay/OverlayRootView.swift` and `OverlayClockTimer/DesignSystem/OverlayTheme.swift`
- [X] T040 [US1] Add accessibility labels and tooltips for Clock-mode icon controls in `OverlayClockTimer/Overlay/OverlayRootView.swift`
- [X] T041 [US1] Run `xcodebuild test -scheme OverlayClockTimer -destination 'platform=macOS'` for `OverlayClockTimer.xcodeproj` and record the US1 checkpoint in `specs/001-overlay-clock-timer/contracts/test-checkpoints.md`

**Checkpoint**: US1 is independently functional as the MVP.

---

## Phase 4: User Story 2 - Run and Control Timer (Priority: P2)

**Goal**: Provide Timer mode with Start, Pause, Stop/Reset, Loop, and a live primary elapsed display plus secondary latest loop value.

**Independent Test**: Switch to Timer mode, exercise all timer controls, verify button enabled states, elapsed values, pause behavior, reset behavior, and Loop capture without replacing the live timer.

### Tests for User Story 2 (MANDATORY)

- [X] T042 [P] [US2] Add timer start, pause, resume, stop/reset, and non-negative elapsed tests in `OverlayClockTimerTests/TimerTests/TimerSessionTests.swift`
- [X] T043 [P] [US2] Add Loop capture tests proving `latestLoop` is secondary, repeated Loop replaces it, and the main timer keeps running in `OverlayClockTimerTests/TimerTests/TimerSessionTests.swift`
- [X] T044 [P] [US2] Add timer store tests for injected monotonic time, live elapsed display, and button state derivation in `OverlayClockTimerTests/TimerTests/TimerSessionStoreTests.swift`
- [X] T045 [P] [US2] Add UI automation for Timer mode Start, Pause, Stop/Reset, Loop enabled states, and secondary Loop text in `OverlayClockTimerUITests/OverlayClockTimerUITests.swift`

### Implementation for User Story 2

- [X] T046 [P] [US2] Implement elapsed stopwatch state machine with `latestLoop` in `OverlayClockTimer/Timer/TimerSession.swift`
- [X] T047 [US2] Implement observable timer store, command methods, injected monotonic time source, and display state derivation in `OverlayClockTimer/Timer/TimerSessionStore.swift`
- [X] T048 [P] [US2] Implement media-player-style icon controls and stable disabled slots in `OverlayClockTimer/Overlay/OverlayToolbarView.swift`
- [X] T049 [US2] Extend overlay content for Timer idle, running, paused, and reset layouts in `OverlayClockTimer/Overlay/OverlayRootView.swift`
- [X] T050 [US2] Bind Start/Pause, Stop/Reset, and Loop actions to `TimerSessionStore` from `OverlayClockTimer/Overlay/OverlayToolbarView.swift`
- [X] T051 [US2] Render the latest Loop capture as a secondary line below the live main timer in `OverlayClockTimer/Overlay/OverlayRootView.swift`
- [X] T052 [US2] Clear `latestLoop` on Stop/Reset while preserving it across Pause in `OverlayClockTimer/Timer/TimerSessionStore.swift`
- [X] T053 [US2] Add accessibility labels and tooltips for Start, Pause, Stop/Reset, and Loop controls in `OverlayClockTimer/Overlay/OverlayToolbarView.swift`
- [X] T054 [US2] Run `xcodebuild test -scheme OverlayClockTimer -destination 'platform=macOS'` for `OverlayClockTimer.xcodeproj` and record the US2 checkpoint in `specs/001-overlay-clock-timer/contracts/test-checkpoints.md`

**Checkpoint**: US1 and US2 work independently with deterministic timer tests.

---

## Phase 5: User Story 3 - Switch Modes Safely (Priority: P3)

**Goal**: Keep mode switching always available, visually separate from timer controls, and apply the configured timer behavior when switching modes.

**Independent Test**: Set each mode-switch action, start a timer, switch modes, and verify continue, pause, and stop/reset behavior with default stop/reset.

### Tests for User Story 3 (MANDATORY)

- [X] T055 [P] [US3] Add mode-switch action default and corrupted-value fallback tests in `OverlayClockTimerTests/TimerTests/ModeSwitchActionTests.swift`
- [X] T056 [P] [US3] Add timer store tests for continue, pause, stop/reset, and default behavior on mode switch in `OverlayClockTimerTests/TimerTests/TimerSessionStoreTests.swift`
- [X] T057 [P] [US3] Add UI automation proving the mode switch is always available and visually separate from timer controls in `OverlayClockTimerUITests/OverlayClockTimerUITests.swift`

### Implementation for User Story 3

- [X] T058 [P] [US3] Implement `continue`, `pause`, and `stopAndReset` mode-switch actions in `OverlayClockTimer/Timer/ModeSwitchAction.swift`
- [X] T059 [US3] Apply mode-switch actions to running timer state in `OverlayClockTimer/Timer/TimerSessionStore.swift`
- [X] T060 [US3] Persist default `stopAndReset` timer-on-mode-switch preference in `OverlayClockTimer/Preferences/OverlayPreferences.swift` and `OverlayClockTimer/Preferences/UserDefaultsPreferencesStore.swift`
- [X] T061 [US3] Implement app-level display mode switching through `OverlayClockTimer/App/AppCoordinator.swift`
- [X] T062 [US3] Keep the mode button visually separated from timer controls in `OverlayClockTimer/Overlay/OverlayToolbarView.swift`
- [X] T063 [US3] Keep mode switching available in both Clock and Timer layouts in `OverlayClockTimer/Overlay/OverlayRootView.swift`
- [X] T064 [US3] Run `xcodebuild test -scheme OverlayClockTimer -destination 'platform=macOS'` for `OverlayClockTimer.xcodeproj` and record the US3 checkpoint in `specs/001-overlay-clock-timer/contracts/test-checkpoints.md`

**Checkpoint**: Mode switching is safe and configurable at the model level.

---

## Phase 6: User Story 4 - Configure App Preferences (Priority: P4)

**Goal**: Provide a separate settings window for theme, hotkeys, mode-switch behavior, launch at login, Dock visibility, overlay size, font size, and opacity while keeping the menu-bar status item visible.

**Independent Test**: Open settings from the menu-bar status item, update every preference category, verify persistence and live app behavior, and confirm Dock visibility and invalid hotkey states are handled correctly.

### Tests for User Story 4 (MANDATORY)

- [X] T065 [P] [US4] Add persistence and clamping tests for theme, opacity, size, font, mode-switch action, and display mode in `OverlayClockTimerTests/PreferencesTests/PreferencesStoreTests.swift`
- [X] T066 [P] [US4] Add hotkey uniqueness, reject, and explicit replacement tests in `OverlayClockTimerTests/PreferencesTests/HotkeyBindingTests.swift`
- [X] T067 [P] [US4] Add launch-at-login success and failure consistency tests with a mock service in `OverlayClockTimerTests/PreferencesTests/LaunchAtLoginControllerTests.swift`
- [X] T068 [P] [US4] Add visible status-item invariant and Dock visibility persistence tests in `OverlayClockTimerTests/PreferencesTests/AppVisibilityControllerTests.swift`
- [X] T069 [P] [US4] Add UI automation for opening the separate Settings window without hiding the overlay in `OverlayClockTimerUITests/OverlayClockTimerUITests.swift`

### Implementation for User Story 4

- [X] T070 [US4] Implement the separate settings window shell and sidebar categories in `OverlayClockTimer/Settings/SettingsWindowView.swift`
- [X] T071 [P] [US4] Implement theme, opacity, overlay size, and timer font controls in `OverlayClockTimer/Settings/AppearanceSettingsView.swift`
- [X] T072 [P] [US4] Implement timer-on-mode-switch behavior controls in `OverlayClockTimer/Settings/TimerSettingsView.swift`
- [X] T073 [P] [US4] Implement hotkey capture, conflict display, reject, and explicit replace UI in `OverlayClockTimer/Settings/HotkeySettingsView.swift`
- [X] T074 [P] [US4] Implement launch-at-login controls in `OverlayClockTimer/Settings/StartupSettingsView.swift`
- [X] T075 [P] [US4] Implement Dock visibility controls and status-item invariant messaging in `OverlayClockTimer/Settings/VisibilitySettingsView.swift`
- [X] T076 [US4] Implement ServiceManagement-backed launch-at-login adapter in `OverlayClockTimer/Support/LaunchAtLoginController.swift`
- [X] T077 [US4] Implement Dock activation policy while preserving the visible menu-bar status item in `OverlayClockTimer/App/AppVisibilityController.swift`
- [X] T078 [P] [US4] Implement shared hotkey command definitions for Start, Pause, Stop/Reset, Loop, and mode switch in `OverlayClockTimer/Hotkeys/HotkeyCommand.swift`
- [X] T079 [US4] Implement Apple-native hotkey registration wrapper and command dispatch in `OverlayClockTimer/Hotkeys/HotkeyRegistrar.swift`
- [X] T080 [US4] Add settings scene creation and presentation routing in `OverlayClockTimer/App/OverlayClockTimerApp.swift`
- [X] T081 [US4] Connect the Settings menu item to the settings window through `OverlayClockTimer/App/MenuBarContentView.swift` and `OverlayClockTimer/App/AppCoordinator.swift`
- [X] T082 [US4] Apply live preference updates to overlay frame, opacity, theme, and font through `OverlayClockTimer/Overlay/OverlayWindowController.swift` and `OverlayClockTimer/Overlay/OverlayRootView.swift`
- [X] T083 [US4] Register, unregister, and refresh persisted hotkeys on app launch and preference changes in `OverlayClockTimer/App/AppCoordinator.swift`
- [X] T084 [US4] Run `xcodebuild test -scheme OverlayClockTimer -destination 'platform=macOS'` for `OverlayClockTimer.xcodeproj` and record the US4 checkpoint in `specs/001-overlay-clock-timer/contracts/test-checkpoints.md`

**Checkpoint**: Preferences are separate, persistent, live-applied, and guarded against unrecoverable states.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Strengthen accessibility, performance, documentation, and final validation across all user stories.

- [X] T085 [P] Add accessibility regression coverage for icon labels, disabled states, focus rings, and settings reachability in `OverlayClockTimerUITests/OverlayClockTimerUITests.swift`
- [X] T086 [P] Add SC-001 fresh launch-to-readable-overlay performance threshold tests in `OverlayClockTimerTests/PerformanceTests/LaunchOverlayPerformanceTests.swift`
- [X] T087 [P] Add SC-004 60-second timer accuracy threshold tests with injected monotonic time in `OverlayClockTimerTests/PerformanceTests/TimerAccuracyPerformanceTests.swift`
- [X] T088 [P] Add SC-006 live preference-application latency threshold tests for theme, opacity, size, and font changes in `OverlayClockTimerTests/PerformanceTests/PreferenceApplicationPerformanceTests.swift`
- [X] T089 [P] Add ticker cadence, idle overlay behavior, and primary button response performance tests in `OverlayClockTimerTests/PerformanceTests/OverlayTickerPerformanceTests.swift`
- [X] T090 Tune ticker lifecycle, visibility-based cancellation, and low-CPU idle behavior in `OverlayClockTimer/Clock/DisplayTicker.swift`
- [X] T091 Document final light/dark, opacity, and theme manual verification results in `specs/001-overlay-clock-timer/contracts/test-checkpoints.md`
- [X] T092 [P] Update final build, run, and manual verification notes in `specs/001-overlay-clock-timer/quickstart.md`
- [X] T093 [P] Update implementation notes if final UI differs from the mockup contract in `specs/001-overlay-clock-timer/ui-mockups.md`
- [X] T094 Run whitespace validation with `git diff --check -- OverlayClockTimer OverlayClockTimerTests OverlayClockTimerUITests specs/001-overlay-clock-timer/tasks.md` and record issues in `specs/001-overlay-clock-timer/contracts/test-checkpoints.md`
- [X] T095 Run `xcodebuild build -scheme OverlayClockTimer -destination 'platform=macOS'` for `OverlayClockTimer.xcodeproj` and record the build checkpoint in `specs/001-overlay-clock-timer/contracts/test-checkpoints.md`
- [X] T096 Run final `xcodebuild test -scheme OverlayClockTimer -destination 'platform=macOS'` for `OverlayClockTimer.xcodeproj` and record the final checkpoint in `specs/001-overlay-clock-timer/contracts/test-checkpoints.md`
- [X] T097 Validate `specs/001-overlay-clock-timer/quickstart.md` end to end against the completed `OverlayClockTimer.xcodeproj` and record any follow-up gaps in `specs/001-overlay-clock-timer/contracts/test-checkpoints.md`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 - Setup**: No dependencies.
- **Phase 2 - Foundational**: Depends on Phase 1; blocks all user stories.
- **Phase 3 - US1**: Depends on Phase 2; delivers MVP.
- **Phase 4 - US2**: Depends on Phase 2 and uses overlay shell from US1 for full UI verification, but timer domain tests can be implemented independently after Phase 2.
- **Phase 5 - US3**: Depends on Phase 2 and integrates with timer state from US2 for full runtime behavior.
- **Phase 6 - US4**: Depends on Phase 2 and applies preferences to completed overlay/timer behavior from US1-US3.
- **Phase 7 - Polish**: Depends on completed stories selected for release.

### User Story Dependencies

- **US1 (P1)**: Independent after Foundation; first MVP target.
- **US2 (P2)**: Timer domain can start after Foundation; overlay UI integration is easiest after US1.
- **US3 (P3)**: Requires timer state from US2 for end-to-end mode-switch behavior.
- **US4 (P4)**: Requires preference primitives from Foundation and applies to US1-US3 behavior.

### Within Each User Story

- Write the listed tests first and confirm they fail for the intended reason.
- Implement domain and store behavior before SwiftUI/AppKit integration.
- Keep command routing centralized through `OverlayClockTimer/App/AppCoordinator.swift`.
- Run the checkpoint command before moving to the next story.

---

## Parallel Opportunities

- Setup tasks T003, T004, and T005 can run in parallel after T001/T002 are defined.
- Foundation tests T007-T012 can run in parallel.
- Foundation implementations T015-T020 and T022-T025 can run in parallel because they touch separate files.
- US1 tests T028-T031 can run in parallel.
- US2 tests T042-T045 can run in parallel.
- US3 tests T055-T057 can run in parallel.
- US4 tests T065-T069 and settings subviews T071-T075 can run in parallel.
- Polish tasks T085-T089, T092, and T093 can run in parallel.

---

## Parallel Example: User Story 1

```text
Task: T028 [US1] Add clock display model tests in OverlayClockTimerTests/ClockTests/ClockDisplayModelTests.swift
Task: T029 [US1] Add overlay window tests in OverlayClockTimerTests/OverlayTests/OverlayWindowControllerTests.swift
Task: T030 [US1] Add geometry persistence tests in OverlayClockTimerTests/OverlayTests/OverlayGeometryStoreTests.swift
Task: T031 [US1] Add menu-bar UI smoke flow in OverlayClockTimerUITests/OverlayClockTimerUITests.swift
```

## Parallel Example: User Story 2

```text
Task: T042 [US2] Add timer transition tests in OverlayClockTimerTests/TimerTests/TimerSessionTests.swift
Task: T044 [US2] Add timer store display state tests in OverlayClockTimerTests/TimerTests/TimerSessionStoreTests.swift
Task: T045 [US2] Add timer UI automation in OverlayClockTimerUITests/OverlayClockTimerUITests.swift
```

## Parallel Example: User Story 4

```text
Task: T071 [US4] Implement AppearanceSettingsView in OverlayClockTimer/Settings/AppearanceSettingsView.swift
Task: T072 [US4] Implement TimerSettingsView in OverlayClockTimer/Settings/TimerSettingsView.swift
Task: T073 [US4] Implement HotkeySettingsView in OverlayClockTimer/Settings/HotkeySettingsView.swift
Task: T074 [US4] Implement StartupSettingsView in OverlayClockTimer/Settings/StartupSettingsView.swift
Task: T075 [US4] Implement VisibilitySettingsView in OverlayClockTimer/Settings/VisibilitySettingsView.swift
```

---

## Implementation Strategy

### MVP First (US1 Only)

1. Complete Phase 1: Setup.
2. Complete Phase 2: Foundational.
3. Complete Phase 3: US1 View Current Time Overlay.
4. Stop and validate the menu-bar app, floating overlay, current-time display, dragging, persistence, light/dark readability, and `xcodebuild test`.

### Incremental Delivery

1. Setup + Foundation: project builds, tests run, shared primitives are deterministic.
2. US1: working clock overlay MVP.
3. US2: working timer controls with live timer plus secondary Loop value.
4. US3: safe mode switching with default stop/reset and configurable behavior.
5. US4: separate settings window and persisted preferences.
6. Polish: accessibility, performance, docs, and final validation.

### Validation Rules

- Do not change expected test results to match incorrect behavior.
- Keep the app macOS-only and Apple-native.
- Do not add third-party dependencies unless a later specification explicitly changes the constitution.
- Preserve the `Loop` contract: the main timer remains live, and the captured Loop value is secondary UI content.
