# Tasks: Input Event Logging

**Input**: Design documents from `/specs/002-input-event-logging/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/

**Tests**: Automated tests are MANDATORY for every development stage. Write test
tasks before implementation tasks and include a test-run checkpoint after each
phase.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1, US2, US3)
- Include exact file paths in descriptions

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Create feature folders and register new source/test files in the Xcode project.

- [X] T001 Create `OverlayClockTimer/InputLogging/`, `OverlayClockTimerTests/InputLoggingTests/`, and `OverlayClockTimerTests/PerformanceTests/` directories
- [X] T002 Create empty app Swift files at `OverlayClockTimer/InputLogging/EventTimestampProvider.swift`, `OverlayClockTimer/InputLogging/InputEventNameFormatter.swift`, `OverlayClockTimer/InputLogging/InputEventObserver.swift`, `OverlayClockTimer/InputLogging/InputEventRecord.swift`, `OverlayClockTimer/InputLogging/InputEventStore.swift`, `OverlayClockTimer/InputLogging/LogSessionWriter.swift`, `OverlayClockTimer/Overlay/InputEventTableView.swift`, and `OverlayClockTimer/Settings/InputLoggingSettingsView.swift`
- [X] T003 Create empty test Swift files at `OverlayClockTimerTests/InputLoggingTests/EventTimestampProviderTests.swift`, `OverlayClockTimerTests/InputLoggingTests/InputEventNameFormatterTests.swift`, `OverlayClockTimerTests/InputLoggingTests/InputEventObserverTests.swift`, `OverlayClockTimerTests/InputLoggingTests/InputEventRecordTests.swift`, `OverlayClockTimerTests/InputLoggingTests/InputEventStoreTests.swift`, `OverlayClockTimerTests/InputLoggingTests/LogSessionWriterTests.swift`, and `OverlayClockTimerTests/PerformanceTests/InputLoggingPerformanceTests.swift`
- [X] T004 Add file references and source/test build entries for the files created by T002 and T003 in `OverlayClockTimer.xcodeproj/project.pbxproj`
- [X] T005 Run `xcodebuild test -scheme OverlayClockTimer -destination 'platform=macOS'` and record the setup checkpoint in `specs/002-input-event-logging/contracts/test-checkpoints.md`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Shared models, preference schema, timestamp formatting, and file infrastructure required by all user stories.

**CRITICAL**: No user story work can begin until this phase is complete.

### Tests for Foundation (MANDATORY)

- [X] T006 [P] Add `LoggingPreferences` default, clamp, persistence, and corrupted-value tests to `OverlayClockTimerTests/PreferencesTests/PreferencesStoreTests.swift`
- [X] T007 [P] Add input event record ordering and privacy-shape tests in `OverlayClockTimerTests/InputLoggingTests/InputEventRecordTests.swift`
- [X] T008 [P] Add Clock/Timer timestamp context tests in `OverlayClockTimerTests/InputLoggingTests/EventTimestampProviderTests.swift`
- [X] T009 [P] Add log session file naming, collision, append, close, and failure tests in `OverlayClockTimerTests/InputLoggingTests/LogSessionWriterTests.swift`

### Implementation for Foundation

- [X] T010 [P] Implement the initial `InputEventRecord` and capture-order value types in `OverlayClockTimer/InputLogging/InputEventRecord.swift`
- [X] T011 [P] Implement `EventTimestampProvider` using `ClockDisplayModel` and `TimerSessionStore` display values in `OverlayClockTimer/InputLogging/EventTimestampProvider.swift`
- [X] T012 [P] Implement `LogSessionWriter` with session file creation, collision-safe names, append, close, and failure status in `OverlayClockTimer/InputLogging/LogSessionWriter.swift`
- [X] T013 Extend `OverlayPreferences` with `eventTableRowLimit` and `preserveEventTableBetweenOpens` defaults and validation in `OverlayClockTimer/Preferences/OverlayPreferences.swift`
- [X] T014 Extend `UserDefaultsPreferencesStore` keys, load, save, and validation for input logging preferences in `OverlayClockTimer/Preferences/UserDefaultsPreferencesStore.swift`
- [X] T015 Run `xcodebuild test -scheme OverlayClockTimer -destination 'platform=macOS'` and record the foundation checkpoint in `specs/002-input-event-logging/contracts/test-checkpoints.md`

**Checkpoint**: Foundation ready - user story implementation can now begin.

---

## Phase 3: User Story 1 - Open and Review Recent Input Events (Priority: P1) MVP

**Goal**: Add the visible logging toggle, expandable table panel, row-limit settings, default empty reopen behavior, and optional same-launch table preservation.

**Independent Test**: Launch the app, show the overlay, press the logging icon, verify the panel expands downward with an event table, press the icon again, verify logging state closes, then reopen with default settings and verify the table starts empty.

### Tests for User Story 1 (MANDATORY)

- [X] T016 [P] [US1] Add `InputEventStore` panel open/close, newest-first rows, row trimming, default empty reopen, and same-launch preservation tests in `OverlayClockTimerTests/InputLoggingTests/InputEventStoreTests.swift`
- [X] T017 [P] [US1] Add input logging settings UI preference binding tests in `OverlayClockTimerTests/PreferencesTests/PreferencesStoreTests.swift`
- [X] T018 [P] [US1] Add overlay UI automation for logging toggle placement, panel open/close, mode switch availability, and default empty reopen in `OverlayClockTimerUITests/OverlayClockTimerUITests.swift`
- [X] T019 [P] [US1] Add panel open latency performance coverage for SC-001 in `OverlayClockTimerTests/PerformanceTests/InputLoggingPerformanceTests.swift`

### Implementation for User Story 1

- [X] T020 [P] [US1] Implement `InputEventStore` panel state, row trimming, default empty open, same-launch preservation, and file/capture status fields in `OverlayClockTimer/InputLogging/InputEventStore.swift`
- [X] T021 [P] [US1] Implement the expanded newest-first event table, empty state, unavailable states, and accessibility labels in `OverlayClockTimer/Overlay/InputEventTableView.swift`
- [X] T022 [P] [US1] Implement `InputLoggingSettingsView` with row limit and preservation controls in `OverlayClockTimer/Settings/InputLoggingSettingsView.swift`
- [X] T023 [US1] Add the Input Logging settings section to the existing settings window in `OverlayClockTimer/Settings/SettingsWindowView.swift`
- [X] T024 [US1] Add the logging toggle immediately left of the mode switch in both toolbar layouts in `OverlayClockTimer/Overlay/OverlayToolbarView.swift`
- [X] T025 [US1] Integrate `InputEventStore` and `InputEventTableView` into the overlay layout expansion in `OverlayClockTimer/Overlay/OverlayRootView.swift`
- [X] T026 [US1] Wire `InputEventStore` ownership, preferences, and app-quit preserved-row clearing through `OverlayClockTimer/App/AppCoordinator.swift`
- [X] T027 [US1] Run `xcodebuild test -scheme OverlayClockTimer -destination 'platform=macOS'` and record the US1 checkpoint in `specs/002-input-event-logging/contracts/test-checkpoints.md`

**Checkpoint**: User Story 1 is independently functional and testable as the MVP.

---

## Phase 4: User Story 2 - Log Keyboard Events Precisely (Priority: P2)

**Goal**: Record keyboard character-producing keyDown events one-to-one, including repeats, and record modifier combinations as single named events.

**Independent Test**: Open the logging panel, generate repeated `S` input and modifier combinations in another editable context, and verify the table and log file contain the exact event count and names.

### Tests for User Story 2 (MANDATORY)

- [X] T028 [P] [US2] Add keyboard character, repeat keyDown, non-character key, modifier combination naming, and modifier-plus-visible-text precedence tests in `OverlayClockTimerTests/InputLoggingTests/InputEventNameFormatterTests.swift`
- [X] T029 [P] [US2] Add keyboard observer lifecycle and no-capture-while-closed tests in `OverlayClockTimerTests/InputLoggingTests/InputEventObserverTests.swift`
- [X] T030 [P] [US2] Add keyboard record insertion and row trimming tests through `InputEventStore` in `OverlayClockTimerTests/InputLoggingTests/InputEventStoreTests.swift`
- [X] T031 [P] [US2] Add UI automation for visible keyboard rows and no rows after close where automation is practical in `OverlayClockTimerUITests/OverlayClockTimerUITests.swift`

### Implementation for User Story 2

- [X] T032 [P] [US2] Implement keyboard event name formatting with canonical modifier order and modifier-plus-visible-text precedence in `OverlayClockTimer/InputLogging/InputEventNameFormatter.swift`
- [X] T033 [P] [US2] Implement `InputEventObserver` keyboard observation start/stop hooks and injectable event source seam in `OverlayClockTimer/InputLogging/InputEventObserver.swift`
- [X] T034 [US2] Connect keyboard observer events to `InputEventStore` row insertion and `LogSessionWriter` appends in `OverlayClockTimer/InputLogging/InputEventStore.swift`
- [X] T035 [US2] Wire keyboard observer lifecycle to logging panel open/close in `OverlayClockTimer/App/AppCoordinator.swift`
- [X] T036 [US2] Add permission-unavailable state propagation for keyboard capture in `OverlayClockTimer/InputLogging/InputEventObserver.swift` and `OverlayClockTimer/Overlay/InputEventTableView.swift`
- [X] T037 [US2] Run `xcodebuild test -scheme OverlayClockTimer -destination 'platform=macOS'` and record the US2 checkpoint in `specs/002-input-event-logging/contracts/test-checkpoints.md`

**Checkpoint**: User Stories 1 and 2 both work independently.

---

## Phase 5: User Story 3 - Initial Mouse Events and Session Persistence (Priority: P3)

**Goal**: Record initial mouse down/up events, create a new session log file for each panel open, append only open-session events, and keep preserved rows out of new files.

**Independent Test**: Open the logging panel, verify a new log file is created, perform mouse down/up, verify separate table and file records, close the panel, and verify no further writes occur.

**Clarified Scope Note**: The final US3 behavior now requires compact button-specific mouse labels, scroll labels, a two-column table, and tab-separated log lines. Those format changes are tracked in Phase 6 tasks T055-T068.

### Tests for User Story 3 (MANDATORY)

- [X] T038 [P] [US3] Add mouse down/up naming tests in `OverlayClockTimerTests/InputLoggingTests/InputEventNameFormatterTests.swift`
- [X] T039 [P] [US3] Add mouse observer lifecycle, permission-unavailable, and no-capture-while-closed tests in `OverlayClockTimerTests/InputLoggingTests/InputEventObserverTests.swift`
- [X] T040 [P] [US3] Add session log file open, append, close, preserved-row exclusion, and failure status integration tests in `OverlayClockTimerTests/InputLoggingTests/InputEventStoreTests.swift`
- [X] T041 [P] [US3] Add UI automation for mouse rows and file-recording unavailable state where automation is practical in `OverlayClockTimerUITests/OverlayClockTimerUITests.swift`

### Implementation for User Story 3

- [X] T042 [P] [US3] Extend `InputEventNameFormatter` with mouse down/up event names in `OverlayClockTimer/InputLogging/InputEventNameFormatter.swift`
- [X] T043 [P] [US3] Extend `InputEventObserver` with mouse down/up observation using the same open-panel lifecycle in `OverlayClockTimer/InputLogging/InputEventObserver.swift`
- [X] T044 [US3] Integrate `LogSessionWriter` session creation, append, close, and unavailable status with `InputEventStore` in `OverlayClockTimer/InputLogging/InputEventStore.swift`
- [X] T045 [US3] Ensure preserved in-memory rows are restored visibly but never appended to a new session file in `OverlayClockTimer/InputLogging/InputEventStore.swift`
- [X] T046 [US3] Wire mouse observer lifecycle, permission-unavailable state, and file writer teardown to panel close in `OverlayClockTimer/App/AppCoordinator.swift`
- [X] T047 [US3] Run `xcodebuild test -scheme OverlayClockTimer -destination 'platform=macOS'` and record the US3 checkpoint in `specs/002-input-event-logging/contracts/test-checkpoints.md`

**Checkpoint**: All user stories are independently functional.

---

## Phase 6: Clarified Format Revision & Cross-Cutting Concerns

**Purpose**: Bring the completed input logging implementation into alignment with the clarified output format, then complete cross-story validation, privacy hardening, documentation, and final checkpoints.

- [X] T048 [P] Add privacy regression tests proving no app name, window title, coordinates, scroll coordinates, scroll delta magnitudes, clipboard content, text field identifier, process metadata, network identifier, category/type, phase, or log key-value fields are exposed in `OverlayClockTimerTests/InputLoggingTests/InputEventRecordTests.swift`
- [X] T049 [P] Add light/dark readability and accessibility regression coverage for the logging toggle, two-column table rows, compact event labels, empty state, and unavailable states in `OverlayClockTimerUITests/OverlayClockTimerUITests.swift`
- [X] T050 [P] Add maximum row-limit, nonblocking log append, and closed-panel idle observer performance coverage in `OverlayClockTimerTests/PerformanceTests/InputLoggingPerformanceTests.swift`
- [X] T051 Update manual validation guidance for input logging in `specs/002-input-event-logging/quickstart.md`
- [X] T052 Run requirements checklist review and record any remaining issues in `specs/002-input-event-logging/checklists/input-logging.md`
- [X] T053 Run pre-format-revision `git diff --check -- OverlayClockTimer OverlayClockTimerTests OverlayClockTimerUITests OverlayClockTimer.xcodeproj specs/002-input-event-logging/tasks.md` and record the historical whitespace checkpoint in `specs/002-input-event-logging/contracts/test-checkpoints.md`
- [X] T054 Run pre-format-revision `xcodebuild build -scheme OverlayClockTimer -destination 'platform=macOS'` and record the historical build checkpoint in `specs/002-input-event-logging/contracts/test-checkpoints.md`
- [X] T055 [P] [US1] Add UI automation proving the input event table shows exactly `Time` and `Event` columns and no `Type`, `Category`, or `Phase` columns in `OverlayClockTimerUITests/OverlayClockTimerUITests.swift`
- [X] T056 [P] [US3] Add compact mouse-button label tests for `LM ↓`, `LM ↑`, `RM ↓`, `RM ↑`, `3M ↓`, `3M ↑`, `4M ↓`, `4M ↑`, `5M ↓`, and `5M ↑` in `OverlayClockTimerTests/InputLoggingTests/InputEventNameFormatterTests.swift`
- [X] T057 [P] [US3] Add compact scroll label tests for `SM ↑` and `SM ↓` in `OverlayClockTimerTests/InputLoggingTests/InputEventNameFormatterTests.swift`
- [X] T058 [P] [US3] Add observer lifecycle tests for right, third, additional mouse buttons, scroll up/down, and no scroll capture while closed in `OverlayClockTimerTests/InputLoggingTests/InputEventObserverTests.swift`
- [X] T059 [P] [US3] Add store and writer tests proving session log lines are `<timestamp><TAB><event name>` only and exclude `order=`, `timestamp=`, `category=`, `type=`, `name=`, and `phase=` in `OverlayClockTimerTests/InputLoggingTests/InputEventStoreTests.swift` and `OverlayClockTimerTests/InputLoggingTests/LogSessionWriterTests.swift`
- [X] T060 [P] [US3] Add UI automation for compact mouse-button rows and compact scroll rows in `OverlayClockTimerUITests/OverlayClockTimerUITests.swift`
- [X] T061 [P] Update `InputEventRecord` to expose `timestamp` and `eventName` as the public record projection while keeping capture order internal for sorting in `OverlayClockTimer/InputLogging/InputEventRecord.swift`
- [X] T062 [P] [US3] Update `InputEventNameFormatter` to emit compact mouse-button and scroll event labels in `OverlayClockTimer/InputLogging/InputEventNameFormatter.swift`
- [X] T063 [P] [US3] Extend `InputEventObserver` source event mapping for right, third, additional mouse buttons, and scroll up/down events in `OverlayClockTimer/InputLogging/InputEventObserver.swift`
- [X] T064 [US3] Update `InputEventStore` and `LogSessionWriter` to write exactly `timestamp`, one tab character, and `eventName` per log line in `OverlayClockTimer/InputLogging/InputEventStore.swift` and `OverlayClockTimer/InputLogging/LogSessionWriter.swift`
- [X] T065 [US1] Update `InputEventTableView` to render only `Time` and `Event` columns and remove `Type`, `Category`, and `Phase` UI output in `OverlayClockTimer/Overlay/InputEventTableView.swift`
- [X] T066 [US3] Update mock input capture fixtures for compact mouse-button and scroll events in `OverlayClockTimer/InputLogging/InputEventObserver.swift` and `OverlayClockTimer/App/OverlayClockTimerApp.swift`
- [X] T067 [US1] Update UI test accessibility identifiers and assertions for the two-column table shape in `OverlayClockTimerUITests/OverlayClockTimerUITests.swift`
- [X] T068 [US3] Update UI test accessibility identifiers and assertions for compact mouse-button and scroll event names in `OverlayClockTimerUITests/OverlayClockTimerUITests.swift`
- [X] T069 Run post-format-revision `git diff --check -- OverlayClockTimer OverlayClockTimerTests OverlayClockTimerUITests OverlayClockTimer.xcodeproj specs/002-input-event-logging/tasks.md` after T055-T068 and record the whitespace checkpoint in `specs/002-input-event-logging/contracts/test-checkpoints.md`
- [X] T070 Run post-format-revision `xcodebuild build -scheme OverlayClockTimer -destination 'platform=macOS'` after T055-T069 and record the build checkpoint in `specs/002-input-event-logging/contracts/test-checkpoints.md`
- [X] T071 Run format-revision final `xcodebuild test -scheme OverlayClockTimer -destination 'platform=macOS'` after T055-T070 and record the Phase 6 checkpoint in `specs/002-input-event-logging/contracts/test-checkpoints.md`

---

## Phase 7: Visible Table Refresh SLA Revision

**Purpose**: Bring the completed implementation into alignment with FR-033 and SC-012: captured events update the in-memory table model immediately, render by the next display refresh, and do not wait for file writes, debounce intervals, timer ticks, or batch refreshes.

**Clarified Scope Note**: The timestamp remains the captured event time. The new work is about when the row becomes visible, not about changing timestamp formatting.

### Tests for Visible Table Refresh SLA (MANDATORY)

- [ ] T072 [P] [US1] Add a store regression test proving `visibleRows` is updated before a deliberately delayed `LogSessionWriting.append(_:)` completes and before file status changes in `OverlayClockTimerTests/InputLoggingTests/InputEventStoreTests.swift`
- [ ] T073 [P] [US1] Add SC-012 performance coverage that runs 10 mock visible-capture trials and measures event injection to published newest `visibleRows` entry within `<=16 ms`, while preserving the captured timestamp, in `OverlayClockTimerTests/PerformanceTests/InputLoggingPerformanceTests.swift`
- [ ] T074 [P] [US1] Add UI automation with mock input capture that measures event injection to row existence in 10 trials, verifies the row appears within the display-refresh target where UI automation timing is stable, and proves delayed file writing cannot block row visibility in `OverlayClockTimerUITests/OverlayClockTimerUITests.swift`

### Implementation for Visible Table Refresh SLA

- [ ] T075 [US1] Refactor `InputEventStore` so `recordKeyboardEvent(_:timestamp:)`, `recordMouseEvent(_:timestamp:)`, and `recordScrollEvent(_:timestamp:)` mutate and publish `visibleRows` before scheduling any session log append in `OverlayClockTimer/InputLogging/InputEventStore.swift`
- [ ] T076 [US1] Move session log append work off the visible-row update path while preserving append failure reporting, session scoping, and close semantics that prevent pending writes from writing to a closed session in `OverlayClockTimer/InputLogging/InputEventStore.swift` and `OverlayClockTimer/InputLogging/LogSessionWriter.swift`
- [ ] T077 [US1] Verify `InputEventTableView` reads directly from `InputEventStore.visibleRows` without debounce, timer batching, or a secondary cached row source in `OverlayClockTimer/Overlay/InputEventTableView.swift`
- [ ] T078 [US1] Add or update mock launch/test wiring for delayed file writing used by the SLA UI test in `OverlayClockTimer/App/OverlayClockTimerApp.swift` and `OverlayClockTimer/App/AppCoordinator.swift`
- [ ] T079 Update manual validation and checkpoint notes for the visible table refresh SLA in `specs/002-input-event-logging/quickstart.md` and `specs/002-input-event-logging/contracts/test-checkpoints.md`
- [ ] T080 Run `git diff --check -- OverlayClockTimer OverlayClockTimerTests OverlayClockTimerUITests OverlayClockTimer.xcodeproj specs/002-input-event-logging/tasks.md specs/002-input-event-logging/quickstart.md specs/002-input-event-logging/contracts/test-checkpoints.md` after T072-T079 and record the whitespace checkpoint in `specs/002-input-event-logging/contracts/test-checkpoints.md`
- [ ] T081 Run final `xcodebuild test -scheme OverlayClockTimer -destination 'platform=macOS'` after T072-T080 and record the visible-refresh SLA checkpoint in `specs/002-input-event-logging/contracts/test-checkpoints.md`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies.
- **Foundational (Phase 2)**: Depends on Setup completion and blocks all user stories.
- **User Story 1 (Phase 3)**: Depends on Foundation; MVP scope.
- **User Story 2 (Phase 4)**: Depends on Foundation and uses US1 panel/store integration.
- **User Story 3 (Phase 5)**: Depends on Foundation and uses US1 panel/store integration; can share observer work with US2 if implemented in parallel.
- **Clarified Format Revision & Polish (Phase 6)**: Depends on selected user stories being complete and must run before the format-revision checkpoint because the feature specification changed the public table/log format after the initial US3 implementation.
- **Visible Table Refresh SLA Revision (Phase 7)**: Depends on Phase 6 and must run before final completion because the feature specification now requires immediate in-memory insertion and visible rendering by the next display refresh.

### User Story Dependencies

- **US1 (P1)**: Required first for the visible panel, settings, row storage, open/close lifecycle, and final visible-refresh SLA tasks T072-T081.
- **US2 (P2)**: Requires the US1 store/panel lifecycle to display and persist keyboard rows.
- **US3 (P3)**: Requires the US1 store/panel lifecycle and foundational file writer; the initial mouse/session behavior is complete, but final US3 acceptance now depends on T056-T064, T066, and T068 for compact mouse-button labels, scroll labels, and tab-separated log output.

### Within Each User Story

- Tests MUST be written and fail for the intended reason before implementation.
- Domain models and stores before UI integration.
- Event formatting before observer-to-store integration.
- Observer lifecycle before AppCoordinator wiring.
- Checkpoint command must pass before moving to the next story.

---

## Parallel Opportunities

- T006, T007, T008, and T009 can run in parallel after setup.
- T010, T011, and T012 can run in parallel after corresponding tests exist.
- T016, T017, T018, and T019 can run in parallel.
- T020, T021, and T022 can run in parallel before US1 integration tasks T023-T026.
- T028, T029, T030, and T031 can run in parallel.
- T032 and T033 can run in parallel before US2 integration tasks T034-T036.
- T038, T039, T040, and T041 can run in parallel.
- T042 and T043 can run in parallel before US3 integration tasks T044-T046.
- T048, T049, T050, T055, T056, T057, T058, T059, and T060 can run in parallel during clarified format revision because they update different test files or independent test scopes.
- T061, T062, and T063 can run in parallel after their corresponding tests exist.
- T065 can run after T055; T064 can run after T059; T066 can run after T062-T063.
- T067 and T068 can run after T065-T066.
- T069, T070, and T071 must run sequentially after T055-T068 are complete.
- T072, T073, and T074 can run in parallel because they target different test files.
- T075 and T076 must run after T072-T073 fail for the intended reason.
- T077 and T078 can run after T074 fails for the intended reason.
- T079, T080, and T081 must run sequentially after T075-T078 are complete.

## Parallel Example: User Story 1

```bash
Task: "T016 [US1] Add InputEventStore panel lifecycle tests in OverlayClockTimerTests/InputLoggingTests/InputEventStoreTests.swift"
Task: "T017 [US1] Add input logging settings UI preference binding tests in OverlayClockTimerTests/PreferencesTests/PreferencesStoreTests.swift"
Task: "T018 [US1] Add overlay UI automation in OverlayClockTimerUITests/OverlayClockTimerUITests.swift"
Task: "T019 [US1] Add panel open latency performance coverage in OverlayClockTimerTests/PerformanceTests/InputLoggingPerformanceTests.swift"
```

## Parallel Example: User Story 2

```bash
Task: "T028 [US2] Add keyboard event name formatter tests in OverlayClockTimerTests/InputLoggingTests/InputEventNameFormatterTests.swift"
Task: "T029 [US2] Add keyboard observer lifecycle tests in OverlayClockTimerTests/InputLoggingTests/InputEventObserverTests.swift"
Task: "T030 [US2] Add keyboard record insertion tests in OverlayClockTimerTests/InputLoggingTests/InputEventStoreTests.swift"
Task: "T031 [US2] Add keyboard logging UI automation in OverlayClockTimerUITests/OverlayClockTimerUITests.swift"
```

## Parallel Example: User Story 3

```bash
Task: "T038 [US3] Add mouse naming tests in OverlayClockTimerTests/InputLoggingTests/InputEventNameFormatterTests.swift"
Task: "T039 [US3] Add mouse observer lifecycle, permission-unavailable, and no-capture-while-closed tests in OverlayClockTimerTests/InputLoggingTests/InputEventObserverTests.swift"
Task: "T040 [US3] Add session file integration tests in OverlayClockTimerTests/InputLoggingTests/InputEventStoreTests.swift"
Task: "T041 [US3] Add mouse logging UI automation in OverlayClockTimerUITests/OverlayClockTimerUITests.swift"
```

## Parallel Example: Clarified Format Revision

```bash
Task: "T055 [US1] Add two-column table UI automation in OverlayClockTimerUITests/OverlayClockTimerUITests.swift"
Task: "T056 [US3] Add compact mouse-button label tests in OverlayClockTimerTests/InputLoggingTests/InputEventNameFormatterTests.swift"
Task: "T057 [US3] Add compact scroll label tests in OverlayClockTimerTests/InputLoggingTests/InputEventNameFormatterTests.swift"
Task: "T058 [US3] Add observer lifecycle tests for mouse buttons and scroll in OverlayClockTimerTests/InputLoggingTests/InputEventObserverTests.swift"
Task: "T059 [US3] Add tab-separated log line tests in OverlayClockTimerTests/InputLoggingTests/InputEventStoreTests.swift and OverlayClockTimerTests/InputLoggingTests/LogSessionWriterTests.swift"
```

## Parallel Example: Visible Table Refresh SLA

```bash
Task: "T072 [US1] Add store regression for UI-first visibleRows publication in OverlayClockTimerTests/InputLoggingTests/InputEventStoreTests.swift"
Task: "T073 [US1] Add SC-012 performance coverage in OverlayClockTimerTests/PerformanceTests/InputLoggingPerformanceTests.swift"
Task: "T074 [US1] Add delayed-file UI automation in OverlayClockTimerUITests/OverlayClockTimerUITests.swift"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1 setup and Phase 2 foundation.
2. Complete Phase 3 US1 for the visible toggle, panel, settings, row limit, and
   default empty reopen behavior.
3. Stop and validate with `xcodebuild test -scheme OverlayClockTimer -destination 'platform=macOS'`.

### Incremental Delivery

1. Foundation: models, preferences, timestamp provider, and file writer.
2. US1: visible panel and settings lifecycle.
3. US2: keyboard capture and naming semantics.
4. US3: mouse capture and session file integration.
5. Clarified format revision: two-column table, compact mouse-button labels,
   scroll labels, and tab-separated log output.
6. Visible table refresh SLA revision: UI-first row publication, delayed-file
   regression coverage, and final visible-refresh checkpoint.
7. Polish: privacy, accessibility, performance, quickstart, and final build/test.

### Privacy Guardrails

- Keep observer lifetime tied to the open panel.
- Do not introduce telemetry, network writes, or sync.
- Do not store app names, window titles, coordinates, clipboard content, text
  field identifiers, process metadata, or network identifiers.
- Do not display or write category/type, phase, order, or key-value log fields.
- Keep preserved table rows in memory only and clear them when the app quits.
