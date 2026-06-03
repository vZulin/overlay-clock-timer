---

description: "Task list template for feature implementation"
---

# Tasks: [FEATURE NAME]

**Input**: Design documents from `/specs/[###-feature-name]/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/

**Tests**: Automated tests are MANDATORY for every development stage. Include test
tasks before implementation tasks and include a test-run checkpoint after each phase.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- **macOS app target**: `[AppName]/`
- **Unit/integration tests**: `[AppName]Tests/`
- **UI automation tests**: `[AppName]UITests/`
- Paths shown below assume the native macOS project structure selected in plan.md

<!-- 
  ============================================================================
  IMPORTANT: The tasks below are SAMPLE TASKS for illustration purposes only.
  
  The /speckit.tasks command MUST replace these with actual tasks based on:
  - User stories from spec.md (with their priorities P1, P2, P3...)
  - Feature requirements from plan.md
  - Entities from data-model.md
  - Endpoints from contracts/
  
  Tasks MUST be organized by user story so each story can be:
  - Implemented independently
  - Tested independently
  - Delivered as an MVP increment
  
  DO NOT keep these sample tasks in the generated tasks.md file.
  ============================================================================
-->

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [ ] T001 Create macOS app project structure per implementation plan
- [ ] T002 Initialize Swift/AppKit/SwiftUI project with XCTest targets and no unapproved dependencies
- [ ] T003 [P] Configure formatting, linting, and build/test commands
- [ ] T004 Run initial automated test command and record the passing checkpoint

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

Examples of foundational tasks (adjust based on your project):

- [ ] T005 [P] Create injectable time source and scheduler abstractions in [AppName]/Clock/
- [ ] T006 [P] Create timer state model and deterministic test helpers in [AppName]/Timer/
- [ ] T007 [P] Create menu-bar app shell and status item owner in [AppName]/App/
- [ ] T008 Create floating overlay window controller with titleless draggable configuration in [AppName]/Overlay/
- [ ] T009 Configure adaptive light/dark design primitives in [AppName]/DesignSystem/
- [ ] T010 Add automated tests for foundational clock/timer/window behavior
- [ ] T011 Run automated test command and record the passing checkpoint

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - [Title] (Priority: P1) 🎯 MVP

**Goal**: [Brief description of what this story delivers]

**Independent Test**: [How to verify this story works on its own]

### Tests for User Story 1 (MANDATORY)

> **NOTE: Write these tests FIRST, ensure they FAIL before implementation**

- [ ] T012 [P] [US1] Unit test for [clock/timer behavior] in [AppName]Tests/[Area]Tests/[Name]Tests.swift
- [ ] T013 [P] [US1] Integration/UI test for [user journey] in [AppName]Tests/ or [AppName]UITests/

### Implementation for User Story 1

- [ ] T014 [P] [US1] Create or update domain model in [AppName]/[Area]/[Name].swift
- [ ] T015 [P] [US1] Create or update SwiftUI view/model adapter in [AppName]/[Area]/[Name]View.swift
- [ ] T016 [US1] Implement [feature behavior] in [AppName]/[Area]/[Name].swift
- [ ] T017 [US1] Integrate [feature behavior] with menu-bar or overlay owner
- [ ] T018 [US1] Add edge-case handling for invalid timer states, scheduler cancellation, or window state
- [ ] T019 [US1] Run automated test command and record the passing checkpoint

**Checkpoint**: At this point, User Story 1 should be fully functional and testable independently

---

## Phase 4: User Story 2 - [Title] (Priority: P2)

**Goal**: [Brief description of what this story delivers]

**Independent Test**: [How to verify this story works on its own]

### Tests for User Story 2 (MANDATORY)

- [ ] T020 [P] [US2] Unit test for [clock/timer behavior] in [AppName]Tests/[Area]Tests/[Name]Tests.swift
- [ ] T021 [P] [US2] Integration/UI test for [user journey] in [AppName]Tests/ or [AppName]UITests/

### Implementation for User Story 2

- [ ] T022 [P] [US2] Create or update domain model in [AppName]/[Area]/[Name].swift
- [ ] T023 [US2] Implement [feature behavior] in [AppName]/[Area]/[Name].swift
- [ ] T024 [US2] Integrate with User Story 1 components without breaking independent testability
- [ ] T025 [US2] Run automated test command and record the passing checkpoint

**Checkpoint**: At this point, User Stories 1 AND 2 should both work independently

---

## Phase 5: User Story 3 - [Title] (Priority: P3)

**Goal**: [Brief description of what this story delivers]

**Independent Test**: [How to verify this story works on its own]

### Tests for User Story 3 (MANDATORY)

- [ ] T026 [P] [US3] Unit test for [clock/timer behavior] in [AppName]Tests/[Area]Tests/[Name]Tests.swift
- [ ] T027 [P] [US3] Integration/UI test for [user journey] in [AppName]Tests/ or [AppName]UITests/

### Implementation for User Story 3

- [ ] T028 [P] [US3] Create or update domain model in [AppName]/[Area]/[Name].swift
- [ ] T029 [US3] Implement [feature behavior] in [AppName]/[Area]/[Name].swift
- [ ] T030 [US3] Run automated test command and record the passing checkpoint

**Checkpoint**: All user stories should now be independently functional

---

[Add more user story phases as needed, following the same pattern]

---

## Phase N: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [ ] TXXX [P] Documentation updates in docs/
- [ ] TXXX Code cleanup and refactoring
- [ ] TXXX Performance optimization across all stories
- [ ] TXXX [P] Additional regression and performance tests in [AppName]Tests/
- [ ] TXXX Security hardening
- [ ] TXXX Run quickstart.md validation
- [ ] TXXX Run final automated test command and record the passing checkpoint

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3+)**: All depend on Foundational phase completion
  - User stories can then proceed in parallel (if staffed)
  - Or sequentially in priority order (P1 → P2 → P3)
- **Polish (Final Phase)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 2 (P2)**: Can start after Foundational (Phase 2) - May integrate with US1 but should be independently testable
- **User Story 3 (P3)**: Can start after Foundational (Phase 2) - May integrate with US1/US2 but should be independently testable

### Within Each User Story

- Tests MUST be written and FAIL for the intended reason before implementation
- Domain models before services or adapters
- Services/adapters before UI integration
- Core implementation before integration
- Story complete before moving to next priority

### Parallel Opportunities

- All Setup tasks marked [P] can run in parallel
- All Foundational tasks marked [P] can run in parallel (within Phase 2)
- Once Foundational phase completes, all user stories can start in parallel (if team capacity allows)
- All tests for a user story marked [P] can run in parallel
- Models within a story marked [P] can run in parallel
- Different user stories can be worked on in parallel by different team members

---

## Parallel Example: User Story 1

```bash
# Launch all tests for User Story 1 together:
Task: "Unit test for [clock/timer behavior] in [AppName]Tests/[Area]Tests/[Name]Tests.swift"
Task: "Integration/UI test for [user journey] in [AppName]Tests/ or [AppName]UITests/"

# Launch independent implementation tasks for User Story 1 together:
Task: "Create or update domain model in [AppName]/[Area]/[Name].swift"
Task: "Create or update SwiftUI view/model adapter in [AppName]/[Area]/[Name]View.swift"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL - blocks all stories)
3. Complete Phase 3: User Story 1
4. **STOP and VALIDATE**: Test User Story 1 independently
5. Deploy/demo if ready

### Incremental Delivery

1. Complete Setup + Foundational → Foundation ready
2. Add User Story 1 → Test independently → Deploy/Demo (MVP!)
3. Add User Story 2 → Test independently → Deploy/Demo
4. Add User Story 3 → Test independently → Deploy/Demo
5. Each story adds value without breaking previous stories

### Parallel Team Strategy

With multiple developers:

1. Team completes Setup + Foundational together
2. Once Foundational is done:
   - Developer A: User Story 1
   - Developer B: User Story 2
   - Developer C: User Story 3
3. Stories complete and integrate independently

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Each user story should be independently completable and testable
- Verify tests fail before implementing
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- Avoid: vague tasks, same file conflicts, cross-story dependencies that break independence
