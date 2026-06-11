# Test Checkpoints: Input Event Logging

## Phase 1: Setup

- Date: 2026-06-11 14:11 +0200
- Command: `xcodebuild test -scheme OverlayClockTimer -destination 'platform=macOS'`
- Result: Passed
- Output marker: `** TEST SUCCEEDED **`
- Result bundle: `/Users/Vladimir.Zulin/Library/Developer/Xcode/DerivedData/OverlayClockTimer-axoodzlmxznwhobrfzhbcxdvgyeo/Logs/Test/Test-OverlayClockTimer-2026.06.11_14-10-08-+0200.xcresult`
- Scope: Phase 1 setup checkpoint after registering input logging source and test placeholders in the Xcode project.

## Phase 2: Foundation

- Date: 2026-06-11 14:21 +0200
- Command: `xcodebuild test -scheme OverlayClockTimer -destination 'platform=macOS'`
- Result: Passed
- Output marker: `** TEST SUCCEEDED **`
- Result bundle: `/Users/Vladimir.Zulin/Library/Developer/Xcode/DerivedData/OverlayClockTimer-axoodzlmxznwhobrfzhbcxdvgyeo/Logs/Test/Test-OverlayClockTimer-2026.06.11_14-20-20-+0200.xcresult`
- Scope: Phase 2 foundation checkpoint after adding input logging preferences, records, timestamp provider, and session log writer.

## Phase 3: User Story 1

- Date: 2026-06-11 14:39 +0200
- Command: `xcodebuild test -scheme OverlayClockTimer -destination 'platform=macOS'`
- Result: Passed
- Output marker: `** TEST SUCCEEDED **`
- Result bundle: `/Users/Vladimir.Zulin/Library/Developer/Xcode/DerivedData/OverlayClockTimer-axoodzlmxznwhobrfzhbcxdvgyeo/Logs/Test/Test-OverlayClockTimer-2026.06.11_14-38-31-+0200.xcresult`
- Scope: Phase 3 US1 checkpoint after adding the logging toggle, expanded event table, input logging settings, default empty reopen behavior, same-launch preservation, and overlay expansion wiring.

## Phase 4: User Story 2

- Date: 2026-06-11 17:12 +0200
- Command: `xcodebuild test -scheme OverlayClockTimer -destination 'platform=macOS'`
- Result: Passed
- Output marker: `** TEST SUCCEEDED **`
- Result bundle: `/Users/Vladimir.Zulin/Library/Developer/Xcode/DerivedData/OverlayClockTimer-axoodzlmxznwhobrfzhbcxdvgyeo/Logs/Test/Test-OverlayClockTimer-2026.06.11_17-10-37-+0200.xcresult`
- Scope: Phase 4 US2 checkpoint after adding the default development input-capture test mode. The keyboard UI test launches with `--mock-input-event-capture` by default and fails if capture is unavailable or the expected keyboard row does not appear. Real input-capture coverage remains available as an explicit manual mode with `OVERLAY_CLOCK_TIMER_REAL_INPUT_CAPTURE_TESTS=1` and `xcodebuild test-without-building`.

## Phase 5: User Story 3

- Date: 2026-06-11 17:12 +0200
- Command: `xcodebuild test -scheme OverlayClockTimer -destination 'platform=macOS'`
- Result: Passed
- Output marker: `** TEST SUCCEEDED **`
- Result bundle: `/Users/Vladimir.Zulin/Library/Developer/Xcode/DerivedData/OverlayClockTimer-axoodzlmxznwhobrfzhbcxdvgyeo/Logs/Test/Test-OverlayClockTimer-2026.06.11_17-10-37-+0200.xcresult`
- Scope: Phase 5 US3 checkpoint after adding mouse down/up capture, session file integration, preserved-row file exclusion, and the default development input-capture test mode. The mouse UI test launches with `--mock-input-event-capture` by default and fails if capture/file recording is unavailable or the expected mouse rows do not appear. Real input-capture coverage remains available as an explicit manual mode with `OVERLAY_CLOCK_TIMER_REAL_INPUT_CAPTURE_TESTS=1` and `xcodebuild test-without-building`.

## Phase 6: Whitespace

- Date: 2026-06-11 17:14 +0200
- Command: `git diff --check -- OverlayClockTimer OverlayClockTimerTests OverlayClockTimerUITests OverlayClockTimer.xcodeproj specs/002-input-event-logging/tasks.md specs/002-input-event-logging/contracts/test-checkpoints.md specs/002-input-event-logging/quickstart.md`
- Result: Passed
- Output marker: no whitespace errors
- Scope: Phase 6 whitespace checkpoint after updating input-capture test modes, quickstart guidance, and checkpoint metadata.

## Phase 6: Build

- Date: 2026-06-11 17:14 +0200
- Command: `xcodebuild build -scheme OverlayClockTimer -destination 'platform=macOS'`
- Result: Passed
- Output marker: `** BUILD SUCCEEDED **`
- App bundle: `/Users/Vladimir.Zulin/Library/Developer/Xcode/DerivedData/OverlayClockTimer-axoodzlmxznwhobrfzhbcxdvgyeo/Build/Products/Debug/OverlayClockTimer.app`
- Scope: Phase 6 build checkpoint for a fresh debug app bundle intended for manual validation.

## Phase 6: Post-Format Whitespace

- Date: 2026-06-11 18:30 +0200
- Command: `git diff --check -- OverlayClockTimer OverlayClockTimerTests OverlayClockTimerUITests OverlayClockTimer.xcodeproj specs/002-input-event-logging/tasks.md`
- Result: Passed
- Output marker: no whitespace errors
- Scope: Phase 6 post-format checkpoint after two-column table output, compact mouse and scroll labels, and tab-separated session log output.

## Phase 6: Post-Format Build

- Date: 2026-06-11 18:31 +0200
- Command: `xcodebuild build -scheme OverlayClockTimer -destination 'platform=macOS'`
- Result: Passed
- Output marker: `** BUILD SUCCEEDED **`
- App bundle: `/Users/Vladimir.Zulin/Library/Developer/Xcode/DerivedData/OverlayClockTimer-axoodzlmxznwhobrfzhbcxdvgyeo/Build/Products/Debug/OverlayClockTimer.app`
- Scope: Phase 6 post-format build checkpoint after compact event labels, scroll capture, two-column table output, and minimal session log lines.

## Phase 6: Final Test

- Date: 2026-06-11 18:33 +0200
- Command: `xcodebuild test -scheme OverlayClockTimer -destination 'platform=macOS'`
- Result: Passed
- Output marker: `** TEST SUCCEEDED **`
- Result bundle: `/Users/Vladimir.Zulin/Library/Developer/Xcode/DerivedData/OverlayClockTimer-axoodzlmxznwhobrfzhbcxdvgyeo/Logs/Test/Test-OverlayClockTimer-2026.06.11_18-31-49-+0200.xcresult`
- Scope: Final Phase 6 checkpoint after compact event labels, physical scroll gesture labels, two-column table output, minimal session log lines, and full unit/UI regression coverage.
