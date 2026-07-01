# Tasks: Time Format Toggle

**Input**: Design documents from `/specs/003-time-format-toggle/`
**Prerequisites**: [plan.md](./plan.md), [spec.md](./spec.md), [research.md](./research.md), [data-model.md](./data-model.md), [contracts/](./contracts/), [quickstart.md](./quickstart.md)

**Tests**: Automated tests are mandatory. Write tests before implementation,
confirm they fail for the intended reason, then implement and run the documented
test checkpoint.

**Organization**: Tasks are grouped by user story to keep each story
independently implementable and testable.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel because it touches different files and has no
  dependency on incomplete tasks.
- **[Story]**: User story label for story phases only.
- Every task includes an exact file path.

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Confirm the feature baseline and prepare checkpoint tracking before
behavior changes.

- [X] T001 Review time format requirements and checkpoint commands in specs/003-time-format-toggle/plan.md
- [X] T002 Review display, UI, logging, and test contracts in specs/003-time-format-toggle/contracts/time-format-display-contract.md, specs/003-time-format-toggle/contracts/time-format-ui-contract.md, specs/003-time-format-toggle/contracts/time-format-logging-contract.md, and specs/003-time-format-toggle/contracts/test-checkpoints.md
- [X] T003 Run `xcodebuild test -scheme OverlayClockTimer -destination 'platform=macOS'` and record the baseline result in specs/003-time-format-toggle/contracts/test-checkpoints.md

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Add shared preference and formatter behavior required by every user
story.

**Critical**: No user story work should begin until this phase is complete.

### Tests First

- [X] T004 [P] Add failing `TimeFormatPreference` default, invalid fallback, validation, and persistence tests in OverlayClockTimerTests/PreferencesTests/PreferencesStoreTests.swift
- [X] T005 [P] Add failing Clock epoch milliseconds tests for 13-digit wall-clock formatting and standard format preservation in OverlayClockTimerTests/ClockTests/ClockFormatterTests.swift
- [X] T006 [P] Add failing Timer epoch milliseconds tests for reset, elapsed, left-zero padding, and negative clamp behavior in OverlayClockTimerTests/TimerTests/DurationFormatterTests.swift

### Implementation

- [X] T007 Add `TimeFormatPreference` to `OverlayPreferences`, defaults, and validation in OverlayClockTimer/Preferences/OverlayPreferences.swift
- [X] T008 Persist `TimeFormatPreference` with invalid-value fallback in OverlayClockTimer/Preferences/UserDefaultsPreferencesStore.swift
- [X] T009 Extend wall-clock formatting for `HH:mm:ss.SSS` and 13-digit epoch milliseconds in OverlayClockTimer/Clock/ClockFormatter.swift
- [X] T010 Extend duration formatting for `HH:mm:ss.SSS` and 13-digit left-zero-padded elapsed milliseconds in OverlayClockTimer/Timer/DurationFormatter.swift
- [X] T011 Run targeted formatter and preference tests and record the passing checkpoint in specs/003-time-format-toggle/contracts/test-checkpoints.md

**Checkpoint**: Shared format preference and formatter behavior are ready.

---

## Phase 3: User Story 1 - Switch Clock Display Format (Priority: P1) MVP

**Goal**: A user can switch Clock mode between `HH:mm:ss.SSS` and 13-digit
epoch milliseconds from the overlay.

**Independent Test**: Launch in Clock mode, press the format toggle, verify
13-digit epoch milliseconds, press again, verify `HH:mm:ss.SSS`, and relaunch
with the saved format preference.

### Tests for User Story 1

- [X] T012 [P] [US1] Add failing ClockDisplayModel tests for live format changes without changing the time source in OverlayClockTimerTests/ClockTests/ClockDisplayModelTests.swift
- [X] T013 [P] [US1] Add failing AppCoordinator tests for toggling and persisting `TimeFormatPreference` in OverlayClockTimerTests/OverlayTests/AppCoordinatorModeSwitchTests.swift
- [X] T014 [P] [US1] Add failing UI test for `clock.timeFormatToggle` switching Clock display formats in OverlayClockTimerUITests/OverlayClockTimerUITests.swift
- [X] T015 [US1] Add failing timed UI assertion that `clock.timeFormatToggle` updates the visible Clock display within 1 second in OverlayClockTimerUITests/OverlayClockTimerUITests.swift

### Implementation for User Story 1

- [X] T016 [US1] Add format update support to ClockDisplayModel in OverlayClockTimer/Clock/ClockDisplayModel.swift
- [X] T017 [US1] Add `toggleTimeFormat()` and live Clock refresh integration to AppCoordinator in OverlayClockTimer/App/AppCoordinator.swift
- [X] T018 [US1] Add the Clock-mode time format toggle button with identifier `clock.timeFormatToggle` in OverlayClockTimer/Overlay/OverlayToolbarView.swift
- [X] T019 [US1] Ensure Clock display scaling handles 13-digit epoch milliseconds at default size in OverlayClockTimer/Overlay/OverlayRootView.swift
- [X] T020 [US1] Run Clock, preferences, overlay coordinator, and UI tests for US1 and record the passing checkpoint in specs/003-time-format-toggle/contracts/test-checkpoints.md

**Checkpoint**: User Story 1 is fully functional and independently testable.

---

## Phase 4: User Story 2 - Switch Timer Display Without Interrupting Timing (Priority: P2)

**Goal**: A user can switch Timer mode format while reset, running, paused, or
showing a latest loop value without changing timer state.

**Independent Test**: Start the timer, switch formats at least 10 times while it
runs, verify the timer continues within the existing 50 ms accuracy target, then
verify paused and latest loop values reformat without state changes.

### Tests for User Story 2

- [X] T021 [P] [US2] Add failing TimerSessionStore tests for reset epoch display, running format switches, paused format switches, and latest loop reformatting in OverlayClockTimerTests/TimerTests/TimerSessionStoreTests.swift
- [X] T022 [P] [US2] Add failing timer accuracy regression coverage for at least 10 format switches during a 60-second run in OverlayClockTimerTests/PerformanceTests/TimerAccuracyPerformanceTests.swift
- [X] T023 [US2] Add failing looped TimerSessionStore reliability test for 10 consecutive running format-switch trials without pause, reset, or restart in OverlayClockTimerTests/TimerTests/TimerSessionStoreTests.swift
- [X] T024 [P] [US2] Add failing UI test for `timer.timeFormatToggle` switching Timer display formats without disabling timer controls in OverlayClockTimerUITests/OverlayClockTimerUITests.swift

### Implementation for User Story 2

- [X] T025 [US2] Add format update support for elapsed and latest loop display text in OverlayClockTimer/Timer/TimerSessionStore.swift
- [X] T026 [US2] Integrate Timer format refresh into AppCoordinator preference updates in OverlayClockTimer/App/AppCoordinator.swift
- [X] T027 [US2] Add the Timer-mode time format toggle button with identifier `timer.timeFormatToggle` in OverlayClockTimer/Overlay/OverlayToolbarView.swift
- [X] T028 [US2] Ensure Timer and latest loop text scale for 13-digit elapsed milliseconds in OverlayClockTimer/Overlay/OverlayRootView.swift
- [X] T029 [US2] Run Timer, performance, coordinator, and UI tests for US2 and record the passing checkpoint in specs/003-time-format-toggle/contracts/test-checkpoints.md

**Checkpoint**: User Stories 1 and 2 both work independently.

---

## Phase 5: User Story 3 - Log Input Events With the Active Time Format (Priority: P3)

**Goal**: New input logging rows and session log lines use the active display
format while previously captured rows and existing log lines remain unchanged.

**Independent Test**: Open logging, capture events in standard format, switch to
epoch milliseconds, capture more events, and verify visible rows plus log file
lines preserve mixed formats exactly as captured.

### Tests for User Story 3

- [X] T030 [P] [US3] Add failing EventTimestampProvider tests for Clock and Timer epoch milliseconds timestamps in OverlayClockTimerTests/InputLoggingTests/EventTimestampProviderTests.swift
- [X] T031 [P] [US3] Add failing InputEventStore tests proving existing visible and preserved rows keep original timestamp strings after format switches in OverlayClockTimerTests/InputLoggingTests/InputEventStoreTests.swift
- [X] T032 [P] [US3] Add failing LogSessionWriter test proving existing log lines are not rewritten and mixed timestamp formats append correctly in OverlayClockTimerTests/InputLoggingTests/LogSessionWriterTests.swift
- [X] T033 [US3] Add failing LogSessionWriter filename invariant test proving format switches do not change session log file names in OverlayClockTimerTests/InputLoggingTests/LogSessionWriterTests.swift
- [X] T034 [P] [US3] Add failing looped input logging reliability test for 10 before/after format-switch trials preserving old rows and old log lines in OverlayClockTimerTests/InputLoggingTests/InputLoggingFormatSwitchReliabilityTests.swift
- [X] T035 [P] [US3] Add failing UI test for input logging rows before and after a format switch in OverlayClockTimerUITests/OverlayClockTimerUITests.swift

### Implementation for User Story 3

- [X] T036 [US3] Update EventTimestampProvider to format capture-time timestamps from display mode and `TimeFormatPreference` in OverlayClockTimer/InputLogging/EventTimestampProvider.swift
- [X] T037 [US3] Pass the active time format into input event recording callbacks in OverlayClockTimer/App/AppCoordinator.swift
- [X] T038 [US3] Preserve immutable timestamp strings for visible and preserved rows after format changes in OverlayClockTimer/InputLogging/InputEventStore.swift
- [X] T039 [US3] Verify session log append behavior keeps existing lines untouched and preserves session file naming in OverlayClockTimer/InputLogging/LogSessionWriter.swift
- [X] T040 [US3] Run InputLogging and UI tests for US3 and record the passing checkpoint in specs/003-time-format-toggle/contracts/test-checkpoints.md

**Checkpoint**: User Stories 1, 2, and 3 work independently and together.

---

## Phase 6: User Story 4 - Fit the New Toggle in the Existing Overlay (Priority: P4)

**Goal**: The new toggle uses a native-feeling icon and fits in Clock, Timer,
and expanded logging layouts without increasing the default overlay size.

**Independent Test**: At default overlay size, verify Clock mode, Timer mode,
and expanded input logging state show the new toggle, all existing controls, and
no overlap in light and dark appearances.

### Tests for User Story 4

- [X] T041 [US4] Add failing UI layout test proving Timer controls and `timer.timeFormatToggle` do not overlap at default size in OverlayClockTimerUITests/OverlayClockTimerUITests.swift
- [X] T042 [US4] Add failing UI test proving the format toggle remains visible when input logging is expanded in OverlayClockTimerUITests/OverlayClockTimerUITests.swift
- [X] T043 [US4] Add failing light and dark appearance smoke tests for the Epoch Toggle icon and compacted controls in OverlayClockTimerUITests/OverlayClockTimerUITests.swift
- [X] T044 [US4] Add manual/UI checkpoint for Epoch Toggle readability at 60%, 90%, and 100% background opacity in specs/003-time-format-toggle/contracts/test-checkpoints.md
- [X] T045 [P] [US4] Add failing overlay metrics regression test for unchanged default collapsed size in OverlayClockTimerTests/OverlayTests/OverlayGeometryStoreTests.swift

### Implementation for User Story 4

- [X] T046 [US4] Complete macOS design review and record the accepted `Epoch Toggle` sketch constraints in specs/003-time-format-toggle/contracts/time-format-ui-contract.md
- [X] T047 [US4] Implement the `Epoch Toggle` monoline icon direction inside OverlayToolbarView without adding text labels in OverlayClockTimer/Overlay/OverlayToolbarView.swift
- [X] T048 [US4] Compact toolbar spacing and button metrics without changing default overlay size in OverlayClockTimer/DesignSystem/OverlayMetrics.swift
- [X] T049 [US4] Preserve button readability, disabled states, active states, tooltips, and accessibility labels after compaction in OverlayClockTimer/Overlay/OverlayToolbarView.swift
- [X] T050 [US4] Verify expanded logging layout keeps toolbar controls accessible in OverlayClockTimer/Overlay/OverlayRootView.swift
- [X] T051 [US4] Run UI tests and overlay tests for US4 and record the passing checkpoint in specs/003-time-format-toggle/contracts/test-checkpoints.md

**Checkpoint**: All user stories are independently functional with the compact
overlay contract preserved.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Final validation, documentation updates, and cleanup across all
stories.

- [X] T052 [P] Update manual validation examples and final results in specs/003-time-format-toggle/quickstart.md
- [X] T053 [P] Update checkpoint results after final targeted and full test runs in specs/003-time-format-toggle/contracts/test-checkpoints.md
- [X] T054 [P] Review generated feature docs for stale terminology such as fractional Unix seconds in specs/003-time-format-toggle/spec.md
- [X] T055 Run `git diff --check -- OverlayClockTimer OverlayClockTimerTests OverlayClockTimerUITests OverlayClockTimer.xcodeproj specs/003-time-format-toggle` and record the result in specs/003-time-format-toggle/contracts/test-checkpoints.md
- [X] T056 Run `xcodebuild build -scheme OverlayClockTimer -destination 'platform=macOS'` and record the result in specs/003-time-format-toggle/contracts/test-checkpoints.md
- [X] T057 Run `xcodebuild test -scheme OverlayClockTimer -destination 'platform=macOS'` and record the result in specs/003-time-format-toggle/contracts/test-checkpoints.md

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 Setup**: No dependencies.
- **Phase 2 Foundational**: Depends on Phase 1; blocks all user stories.
- **Phase 3 US1**: Depends on Phase 2; MVP.
- **Phase 4 US2**: Depends on Phase 2 and uses shared toggle/preference paths;
  can be implemented after US1 or in parallel if file conflicts are coordinated.
- **Phase 5 US3**: Depends on Phase 2; can be implemented after US1/US2 format
  APIs exist.
- **Phase 6 US4**: Depends on visible toggle work from US1/US2.
- **Phase 7 Polish**: Depends on selected user stories being complete.

### User Story Dependencies

- **US1 (P1)**: MVP and no dependency on other stories after Foundation.
- **US2 (P2)**: Uses Foundation and the same toggle action; coordinate
  `AppCoordinator` and `OverlayToolbarView` edits with US1.
- **US3 (P3)**: Uses Foundation and the selected format state; depends on the
  active format being available to input logging.
- **US4 (P4)**: Finalizes UI fit and icon quality after the toggle exists in
  Clock and Timer modes.

### Within Each User Story

- Write tests first and verify they fail for the intended reason.
- Implement domain or formatter changes before UI integration.
- Integrate UI controls before UI layout polish.
- Run targeted tests before moving to the next story.
- Record checkpoint results in `contracts/test-checkpoints.md`.

---

## Parallel Execution Examples

### User Story 1

```text
Task: "Add failing ClockDisplayModel tests in OverlayClockTimerTests/ClockTests/ClockDisplayModelTests.swift"
Task: "Add failing AppCoordinator tests in OverlayClockTimerTests/OverlayTests/AppCoordinatorModeSwitchTests.swift"
Task: "Add failing UI test in OverlayClockTimerUITests/OverlayClockTimerUITests.swift"
```

### User Story 2

```text
Task: "Add failing TimerSessionStore tests in OverlayClockTimerTests/TimerTests/TimerSessionStoreTests.swift"
Task: "Add failing timer accuracy regression in OverlayClockTimerTests/PerformanceTests/TimerAccuracyPerformanceTests.swift"
Task: "Add failing UI test in OverlayClockTimerUITests/OverlayClockTimerUITests.swift"
```

### User Story 3

```text
Task: "Add failing EventTimestampProvider tests in OverlayClockTimerTests/InputLoggingTests/EventTimestampProviderTests.swift"
Task: "Add failing InputEventStore tests in OverlayClockTimerTests/InputLoggingTests/InputEventStoreTests.swift"
Task: "Add failing LogSessionWriter tests in OverlayClockTimerTests/InputLoggingTests/LogSessionWriterTests.swift"
```

### User Story 4

```text
Task: "Add failing UI layout test in OverlayClockTimerUITests/OverlayClockTimerUITests.swift"
Task: "Add failing overlay metrics regression in OverlayClockTimerTests/OverlayTests/OverlayGeometryStoreTests.swift"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1 setup.
2. Complete Phase 2 shared formatter and preference foundation.
3. Complete Phase 3 Clock display toggle.
4. Stop and validate US1 independently with targeted unit and UI tests.

### Incremental Delivery

1. Add Foundation and US1 for a usable Clock toggle MVP.
2. Add US2 for Timer continuity and latest Loop formatting.
3. Add US3 for input logging timestamp correctness.
4. Add US4 for final compact layout, icon quality, and UI polish.
5. Run final build and full test suite.

### Parallel Team Strategy

After Phase 2, tests for US1, US2, US3, and US4 can be written in parallel.
Implementation should coordinate edits to `AppCoordinator.swift`,
`OverlayToolbarView.swift`, and `OverlayRootView.swift` because those files are
shared integration points.

---

## Notes

- [P] tasks are parallelizable only when they touch different files or are
  independent test additions.
- Story labels map directly to user stories in [spec.md](./spec.md).
- Do not change expected tests to match incorrect behavior.
- Do not increase the default collapsed overlay size.
- Do not reformat existing input event rows or existing session log lines.
- Do not add third-party dependencies.
