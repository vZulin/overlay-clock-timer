# Implementation Plan: [FEATURE]

**Branch**: `[###-feature-name]` | **Date**: [DATE] | **Spec**: [link]
**Input**: Feature specification from `/specs/[###-feature-name]/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

[Extract from feature spec: primary requirement + technical approach from research]

## Technical Context

<!--
  ACTION REQUIRED: Replace the content in this section with the technical details
  for the project. The structure here is presented in advisory capacity to guide
  the iteration process.
-->

**Language/Version**: Swift [version] or NEEDS CLARIFICATION
**Primary Dependencies**: SwiftUI, AppKit, Foundation, XCTest; third-party dependencies require Constitution justification
**Storage**: [UserDefaults, files, or N/A]
**Testing**: XCTest for unit/integration tests; UI automation where practical
**Target Platform**: macOS only, minimum version [version] or NEEDS CLARIFICATION
**Project Type**: Native macOS menu-bar app with floating overlay window
**Performance Goals**: [refresh cadence, CPU budget, memory budget, launch-time goal or NEEDS CLARIFICATION]
**Constraints**: Always-on-top compact overlay, custom drag region, light/dark theme support, low resource usage
**Scale/Scope**: Single-user local desktop utility with no server runtime

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- macOS-only scope: plan targets macOS only and rejects iOS, web, server, and
  cross-platform runtime requirements.
- Explicit Apple-native stack: Swift version, minimum macOS version, Xcode
  requirement, Apple frameworks, test framework, and build tooling are named.
- Overlay/menu-bar contract: plan preserves a menu-bar status item plus a
  compact floating overlay near 280x160 px, always-on-top window level, titleless
  draggable behavior, custom drag area, default clock display format support,
  any explicit display-only alternate formats, and timer mode.
- Dependency discipline: no third-party dependency is introduced without a
  documented Apple-framework limitation, cost, and removal strategy.
- Theme and performance: light/dark appearance support, refresh cadence, timer
  lifecycle, CPU/memory goals, and avoidance of busy-wait loops are documented.
- Test-first gates: automated tests are planned for every development stage;
  expected test results are immutable and the test command is documented for
  each checkpoint.

## Project Structure

### Documentation (this feature)

```text
specs/[###-feature]/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)
<!--
  ACTION REQUIRED: Replace the placeholder tree below with the concrete layout
  for this feature. Delete unused options and expand the chosen structure with
  real paths (e.g., apps/admin, packages/something). The delivered plan must
  not include Option labels.
-->

```text
[AppName]/
├── App/                 # App lifecycle, menu-bar status item, app commands
├── Overlay/             # Floating NSWindow/AppKit bridge and SwiftUI overlay views
├── Clock/               # Clock formatting and injected time source
├── Timer/               # Timer state machine and scheduling
├── DesignSystem/        # Adaptive colors, typography, shared UI primitives
└── Support/             # Small shared utilities

[AppName]Tests/
├── ClockTests/
├── TimerTests/
├── OverlayTests/
└── PerformanceTests/

[AppName]UITests/
└── [UI automation tests when practical]
```

**Structure Decision**: [Document the selected structure and reference the real
directories captured above]

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., 4th project] | [current need] | [why 3 projects insufficient] |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient] |
