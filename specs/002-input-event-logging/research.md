# Research: Input Event Logging

## Decision: Use Apple-Native Event Observation Scoped to Panel Visibility

Use an Apple-native event observation adapter that is installed only when the
logging panel opens and removed immediately when the panel closes.

**Rationale**: The specification requires keyboard and mouse events only while
the logging panel is open. Scoping observer lifetime to panel state is the
clearest way to satisfy the no-background-logging invariant and keep idle CPU at
the existing overlay budget.

**Alternatives considered**:

- Always-on observer with filtering: rejected because it violates the privacy
  model and increases idle work.
- App-local SwiftUI event handling only: rejected because the feature needs to
  observe input generated in other editable contexts when macOS permissions
  allow it.
- Third-party input monitoring library: rejected by the no-dependency policy and
  unnecessary for the required event classes.

## Decision: Represent Visible Table History Separately From Session Log Files

Keep visible/preserved table rows in memory and create a separate local file for
each panel-open logging session.

**Rationale**: The spec requires a new file on every open, default empty table
behavior, optional same-launch visible row preservation, and no rewrite of
preserved rows into a new session file. Separate models prevent accidental
coupling between UI history and durable file content.

**Alternatives considered**:

- Use the log file as the table source: rejected because default reopen behavior
  must show an empty table and optional preservation must be in-memory only.
- Persist table rows in UserDefaults: rejected because preserved rows must clear
  on app quit and should not become durable event storage.

## Decision: Persist Only Input Logging Preferences

Store `eventTableRowLimit` and `preserveEventTableBetweenOpens` in the existing
preferences model and UserDefaults store.

**Rationale**: The settings are user preferences and should persist across app
launches. The existing settings architecture already validates and persists
bounded values, making it the correct integration point.

**Alternatives considered**:

- Store preferences in a separate file: rejected because it duplicates existing
  preference infrastructure.
- Treat settings as session-only: rejected because the user explicitly wants the
  row count and preservation setting configurable in Settings.

## Decision: Clamp Invalid Row Limits to the Nearest Valid Bound

Clamp loaded row limits to `5...50`, with default `15` when the value is
missing.

**Rationale**: The spec already defines a bounded preference and requires safe
handling of invalid persisted values. Clamping preserves user intent better than
resetting a near-valid value while keeping the UI bounded.

**Alternatives considered**:

- Always reset invalid values to 15: rejected because values just outside the
  valid range can be repaired without discarding intent.
- Reject loading preferences entirely: rejected because one invalid setting
  should not corrupt unrelated overlay preferences.

## Decision: Use Canonical Event Names With Limited Data Capture

Record keyboard character names and modifier combinations, plus mouse phase
names, but do not record app names, window titles, coordinates, clipboard
content, text field identifiers, or process metadata.

**Rationale**: The feature needs diagnostic event names and repeat granularity,
but constitution privacy constraints require minimizing captured local data.
Limiting the record shape keeps logs useful while reducing unnecessary
sensitive context.

**Alternatives considered**:

- Record full event metadata: rejected as unnecessary and higher privacy risk.
- Hash or redact all keyboard values: rejected because the spec requires visible
  character repeat evidence such as five `s` records.

## Decision: Reuse Existing Clock and Timer Display Sources for Timestamps

Use the existing wall-clock formatter for Clock mode and the existing timer
display value for Timer mode timestamps.

**Rationale**: The feature requires mode-specific timestamps that match what the
user sees. Reusing existing formatting rules avoids divergence between the
overlay display and log records.

**Alternatives considered**:

- Use wall-clock timestamps for every event: rejected because Timer mode must
  use the current timer value.
- Recompute timer duration from wall-clock dates: rejected because the base timer
  model uses monotonic elapsed time to avoid system clock changes.

## Decision: Treat Permission Failure as a Visible Session State

If macOS permissions prevent observing external input, keep the panel usable,
show that input capture is unavailable, and avoid hidden retry loops.

**Rationale**: Permission failure is expected on macOS and must not be silent.
Making it an explicit panel state preserves user trust and testability.

**Alternatives considered**:

- Fail panel opening: rejected because file failure and permission failure
  should not make the overlay unusable.
- Poll for permission changes in the background: rejected because it adds
  background work and weakens the no-background-logging boundary.
