<!--
Sync Impact Report
Version change: 1.1.0 -> 2.0.0
Modified principles:
- III. Floating Overlay and Menu Bar Contract (explicit alternate millisecond
  display formats allowed when user-selected)
Added sections:
- None
Removed sections:
- None
Templates requiring updates:
- ✅ .specify/templates/plan-template.md (updated overlay contract wording)
- ✅ .specify/templates/spec-template.md (updated constitutional scope wording)
- ✅ .specify/templates/tasks-template.md (checked; no update required)
- ✅ .specify/templates/commands/*.md (not present in this repository)
- ✅ Runtime guidance docs (AGENTS.md checked; no update required)
Follow-up TODOs:
- None
-->

# Overlay Clock Timer Constitution

## Core Principles

### I. macOS-Only Native Product
The application MUST target macOS only. Plans, specs, tasks, code, and tests MUST NOT
introduce iOS, iPadOS, web, cross-platform desktop, or server runtime requirements.
All user-facing behavior MUST be designed around macOS desktop conventions.

Rationale: the product depends on macOS-native window levels, menu bar integration,
theme behavior, and event handling.

### II. Apple-Native Stack and Minimal Dependencies
Every implementation plan MUST explicitly select the technology stack before design
work starts. The default stack is Swift, SwiftUI for view composition, AppKit for
`NSWindow` and menu bar integration, Foundation/Swift Concurrency where needed, and
XCTest for automated tests. Third-party dependencies MUST NOT be added unless the plan
documents the concrete limitation in Apple frameworks, the dependency cost, and a
removal strategy.

Rationale: a small always-on overlay has strict footprint and reliability constraints;
unnecessary dependencies increase launch time, maintenance cost, and integration risk.

### III. Floating Overlay and Menu Bar Contract
The product MUST run as a menu-bar application with a visible status item and a
separate floating overlay window. The overlay MUST default to a compact footprint near
280x160 px, use `NSWindow.Level.floating` or `NSWindow.Level.statusBar`, remain
draggable without a standard title bar, and provide a custom drag area. The overlay
MUST display current time with millisecond precision, MUST support `HH:mm:ss.SSS` as
the default visible clock format, and MAY provide explicit user-selected alternate
millisecond display formats such as epoch milliseconds. Alternate display formats
MUST remain display-only and MUST NOT change clock source, timer state, logging
ownership, or overlay window behavior. The overlay MUST provide a timer mode.

Rationale: these behaviors define the product identity and must remain stable across
features.

### IV. Test-First Delivery Gates
Every development stage MUST include automated tests appropriate to the changed
behavior. Tests MUST be written before implementation when behavior is new or changed,
and the test suite MUST fail for the intended reason before production code is updated.
Expected test results MUST NOT be changed to match incorrect implementation behavior.
After each stage, the documented automated test command MUST run and pass before work
continues.

Rationale: timer and clock behavior is easy to regress through scheduler, formatting,
and window-state changes; tests are the primary guardrail.

### V. Performance, Theme, and Maintainability
The application MUST avoid busy-wait loops, unbounded timers, unnecessary background
work, and avoidable memory retention. Refresh cadence MUST be documented and justified
when milliseconds are visible. The UI MUST support light and dark appearance through
system colors or explicit adaptive assets. Code MUST be structured into testable units
with injected time sources, isolated timer state, and small UI adapters. Comments MUST
explain non-obvious platform behavior or design decisions.

Rationale: an always-on overlay runs for long sessions and must remain cheap, readable,
and predictable.

## Technical Constraints

- Target platform MUST be macOS only.
- Feature plans MUST name the Swift version, minimum macOS version, Xcode requirement,
  Apple frameworks, test framework, and any build tooling.
- The overlay window MUST be titleless or visually titleless, draggable through a
  custom region, always on top, and sized for a compact default around 280x160 px.
- The overlay clock MUST support `HH:mm:ss.SSS` as the default visible format and MAY
  support explicit alternate millisecond formats, including epoch milliseconds, when
  a feature spec defines display-only state behavior and regression tests.
- The application MUST expose menu-bar controls for showing, hiding, and quitting the
  app at minimum.
- Light and dark appearances MUST be verified by automated tests where feasible and by
  documented manual checks where AppKit rendering makes automation impractical.
- Timer and clock logic MUST be testable without waiting for real wall-clock time.
- Logging, if added, MUST be low-volume. Input-event logging MAY include user-visible
  input event labels only when explicitly activated by opening the logging panel, MUST
  stop immediately when the panel closes, MUST remain local-only, MUST NOT run in the
  background, and MUST NOT include app names, window titles, coordinates, clipboard
  content, text field identifiers, process metadata, network identifiers, or hidden
  durable history.

## Development Workflow and Quality Gates

- Specifications MUST keep macOS-only scope explicit and include independently testable
  user scenarios.
- Plans MUST pass the Constitution Check before research and after design.
- Tasks MUST include automated test tasks for each user story and a test-run checkpoint
  after each phase.
- Implementation MUST keep domain logic separate from AppKit/SwiftUI adapters wherever
  practical.
- Changes that alter clock formatting, timer transitions, window behavior, menu-bar
  behavior, theme behavior, or performance characteristics MUST include regression
  tests.
- Any constitution violation MUST be recorded in Complexity Tracking with a concrete
  reason, rejected simpler alternative, and removal or mitigation plan.

## Governance

This constitution supersedes conflicting project templates, generated plans, generated
tasks, and ad hoc implementation preferences. Amendments require an explicit update to
this file, a Sync Impact Report, and synchronization of affected templates. Versioning
uses semantic versioning:

- MAJOR: removes or redefines an existing principle or weakens a mandatory gate.
- MINOR: adds a principle, section, or materially expands governance requirements.
- PATCH: clarifies wording without changing obligations.

All feature plans MUST include a Constitution Check. All reviews MUST verify compliance
with the macOS-only scope, stack declaration, overlay/menu-bar contract, dependency
policy, testing gates, performance constraints, and theme support. Work MUST NOT proceed
past a stage checkpoint while required automated tests are failing.

**Version**: 2.0.0 | **Ratified**: 2026-06-03 | **Last Amended**: 2026-07-01
