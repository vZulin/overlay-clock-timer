# Test Checkpoints: Time Format Toggle

## Required Commands

Run the full test suite after each completed implementation phase:

```bash
xcodebuild test -scheme OverlayClockTimer -destination 'platform=macOS'
```

Run the UI test target when toolbar, overlay layout, or accessibility changes:

```bash
xcodebuild test \
  -scheme OverlayClockTimer \
  -destination 'platform=macOS' \
  -only-testing:OverlayClockTimerUITests
```

Run the final build checkpoint before completion:

```bash
xcodebuild build -scheme OverlayClockTimer -destination 'platform=macOS'
```

## Phase 1 Setup Baseline

- Date: 2026-07-01
- Command:
  `xcodebuild test -scheme OverlayClockTimer -destination 'platform=macOS'`
- Result: PASS. `xcodebuild` reported `** TEST SUCCEEDED **`.
- UI test summary: 15 tests, 0 failures.
- Result bundle:
  `/Users/Vladimir.Zulin/Library/Developer/Xcode/DerivedData/OverlayClockTimer-axoodzlmxznwhobrfzhbcxdvgyeo/Logs/Test/Test-OverlayClockTimer-2026.07.01_18-43-29-+0200.xcresult`

## Phase 1: Formatter and Preference Tests

- Add unit tests before production code for:
  - Clock epoch milliseconds formatting.
  - Timer epoch milliseconds formatting.
  - Standard format preservation.
  - Negative duration clamping.
  - Invalid persisted preference fallback.
  - Preference persistence across store load/save.
- Expected pre-implementation result: targeted tests fail because the format
  preference and epoch formatter do not exist yet.
- Required post-implementation result: targeted tests pass.

Suggested command:

```bash
xcodebuild test \
  -scheme OverlayClockTimer \
  -destination 'platform=macOS' \
  -only-testing:OverlayClockTimerTests/ClockTests \
  -only-testing:OverlayClockTimerTests/TimerTests \
  -only-testing:OverlayClockTimerTests/PreferencesTests
```

### Phase 2 Foundational Result

- Date: 2026-07-01
- Pre-implementation command:
  `xcodebuild test -scheme OverlayClockTimer -destination 'platform=macOS' -only-testing:OverlayClockTimerTests/ClockTests -only-testing:OverlayClockTimerTests/TimerTests -only-testing:OverlayClockTimerTests/PreferencesTests`
- Pre-implementation result: FAIL as expected. `xcodebuild` reported missing
  `timeFormat` formatter APIs and unresolved `TimeFormatPreference` members.
- Pre-implementation result bundle:
  `/Users/Vladimir.Zulin/Library/Developer/Xcode/DerivedData/OverlayClockTimer-axoodzlmxznwhobrfzhbcxdvgyeo/Logs/Test/Test-OverlayClockTimer-2026.07.01_18-50-10-+0200.xcresult`
- Post-implementation command:
  `xcodebuild test -scheme OverlayClockTimer -destination 'platform=macOS' -only-testing:OverlayClockTimerTests/ClockTests -only-testing:OverlayClockTimerTests/TimerTests -only-testing:OverlayClockTimerTests/PreferencesTests`
- Post-implementation result: PASS. `xcodebuild` reported
  `** TEST SUCCEEDED **`.
- Post-implementation result bundle:
  `/Users/Vladimir.Zulin/Library/Developer/Xcode/DerivedData/OverlayClockTimer-axoodzlmxznwhobrfzhbcxdvgyeo/Logs/Test/Test-OverlayClockTimer-2026.07.01_18-52-20-+0200.xcresult`

### Phase 3 US1 Clock Toggle Result

- Date: 2026-07-01
- Pre-implementation command:
  `xcodebuild test -scheme OverlayClockTimer -destination 'platform=macOS' -only-testing:OverlayClockTimerTests/ClockTests -only-testing:OverlayClockTimerTests/PreferencesTests -only-testing:OverlayClockTimerTests/OverlayTests/AppCoordinatorModeSwitchTests -only-testing:OverlayClockTimerUITests/OverlayClockTimerUITests/testClockFormatToggleSwitchesDisplayAndPersistsAcrossRelaunch -only-testing:OverlayClockTimerUITests/OverlayClockTimerUITests/testClockFormatToggleUpdatesVisibleDisplayWithinOneSecond`
- Pre-implementation result: FAIL as expected. `xcodebuild` reported missing
  `ClockDisplayModel.apply(timeFormat:)` support before production changes.
- Pre-implementation result bundle:
  `/Users/Vladimir.Zulin/Library/Developer/Xcode/DerivedData/OverlayClockTimer-axoodzlmxznwhobrfzhbcxdvgyeo/Logs/Test/Test-OverlayClockTimer-2026.07.01_18-55-46-+0200.xcresult`
- Post-implementation command:
  `xcodebuild test -scheme OverlayClockTimer -destination 'platform=macOS' -only-testing:OverlayClockTimerTests/ClockTests -only-testing:OverlayClockTimerTests/PreferencesTests -only-testing:OverlayClockTimerTests/OverlayTests/AppCoordinatorModeSwitchTests -only-testing:OverlayClockTimerUITests/OverlayClockTimerUITests/testClockFormatToggleSwitchesDisplayAndPersistsAcrossRelaunch -only-testing:OverlayClockTimerUITests/OverlayClockTimerUITests/testClockFormatToggleUpdatesVisibleDisplayWithinOneSecond`
- Post-implementation result: PASS. `xcodebuild` reported
  `** TEST SUCCEEDED **`.
- UI test summary: 2 selected UI tests, 0 failures.
- Post-implementation result bundle:
  `/Users/Vladimir.Zulin/Library/Developer/Xcode/DerivedData/OverlayClockTimer-axoodzlmxznwhobrfzhbcxdvgyeo/Logs/Test/Test-OverlayClockTimer-2026.07.01_18-58-04-+0200.xcresult`

### Phase 4 US2 Timer Toggle Result

- Date: 2026-07-01
- Pre-implementation command:
  `xcodebuild test -scheme OverlayClockTimer -destination 'platform=macOS' -only-testing:OverlayClockTimerTests/TimerTests -only-testing:OverlayClockTimerTests/PerformanceTests/TimerAccuracyPerformanceTests -only-testing:OverlayClockTimerTests/OverlayTests/AppCoordinatorModeSwitchTests -only-testing:OverlayClockTimerUITests/OverlayClockTimerUITests/testTimerFormatToggleSwitchesDisplayWithoutDisablingTimerControls`
- Pre-implementation result: FAIL as expected. `xcodebuild` reported missing
  `TimerSessionStore.apply(timeFormat:)` support before production changes.
- Pre-implementation result bundle:
  `/Users/Vladimir.Zulin/Library/Developer/Xcode/DerivedData/OverlayClockTimer-axoodzlmxznwhobrfzhbcxdvgyeo/Logs/Test/Test-OverlayClockTimer-2026.07.01_19-03-58-+0200.xcresult`
- Post-implementation command:
  `xcodebuild test -scheme OverlayClockTimer -destination 'platform=macOS' -only-testing:OverlayClockTimerTests/TimerSessionStoreTests -only-testing:OverlayClockTimerTests/TimerAccuracyPerformanceTests -only-testing:OverlayClockTimerTests/AppCoordinatorModeSwitchTests -only-testing:OverlayClockTimerUITests/OverlayClockTimerUITests/testTimerFormatToggleSwitchesDisplayWithoutDisablingTimerControls`
- Post-implementation result: PASS. `xcodebuild` reported
  `** TEST SUCCEEDED **`.
- Post-implementation summary: 22 selected unit tests and 1 selected UI test,
  0 failures.
- Post-implementation result bundle:
  `/Users/Vladimir.Zulin/Library/Developer/Xcode/DerivedData/OverlayClockTimer-axoodzlmxznwhobrfzhbcxdvgyeo/Logs/Test/Test-OverlayClockTimer-2026.07.01_19-05-53-+0200.xcresult`
- Additional Timer toolbar regression command:
  `xcodebuild test -scheme OverlayClockTimer -destination 'platform=macOS' -only-testing:OverlayClockTimerUITests/OverlayClockTimerUITests/testTimerModeControlsAndLatestLoopText -only-testing:OverlayClockTimerUITests/OverlayClockTimerUITests/testModeSwitchIsAlwaysAvailableAndSeparateFromTimerControls -only-testing:OverlayClockTimerUITests/OverlayClockTimerUITests/testInputLoggingToggleIsLeftOfTimerModeSwitch -only-testing:OverlayClockTimerUITests/OverlayClockTimerUITests/testAccessibilityLabelsDisabledStatesFocusTargetsAndSettingsReachability`
- Additional Timer toolbar regression result: PASS. 4 selected UI tests,
  0 failures.
- Additional Timer toolbar regression result bundle:
  `/Users/Vladimir.Zulin/Library/Developer/Xcode/DerivedData/OverlayClockTimer-axoodzlmxznwhobrfzhbcxdvgyeo/Logs/Test/Test-OverlayClockTimer-2026.07.01_19-06-21-+0200.xcresult`

## Phase 2: Clock and Timer Store Tests

- Add unit/integration tests before production code for:
  - Clock display refresh after format changes.
  - Clock display format switching completes visibly in under 1 second.
  - Timer reset display as `0000000000000`.
  - Running timer continues across at least 10 format switches.
  - Running timer format switching passes 10 consecutive reliability trials
    without pause, reset, or restart.
  - Paused timer remains paused after a format switch.
  - Latest loop value is reformatted without changing captured elapsed value.
- Required post-implementation result: targeted tests pass.

Suggested command:

```bash
xcodebuild test \
  -scheme OverlayClockTimer \
  -destination 'platform=macOS' \
  -only-testing:OverlayClockTimerTests/ClockTests \
  -only-testing:OverlayClockTimerTests/TimerTests \
  -only-testing:OverlayClockTimerTests/PerformanceTests/TimerAccuracyPerformanceTests
```

## Phase 3: Input Logging Tests

- Add input logging tests before production code for:
  - New Clock-mode rows use current format.
  - New Timer-mode rows use current format.
  - Existing rows remain unchanged after format switches.
  - Existing session log lines remain unchanged after format switches.
  - Session log file names remain unchanged after format switches.
  - Preserved rows retain original timestamp strings.
  - Ten consecutive logging trials preserve old rows and old log lines while new
    rows and appended lines use the updated format.
- Required post-implementation result: targeted tests pass.

Suggested command:

```bash
xcodebuild test \
  -scheme OverlayClockTimer \
  -destination 'platform=macOS' \
  -only-testing:OverlayClockTimerTests/InputLoggingTests
```

### Phase 5 US3 Input Logging Result

- Date: 2026-07-01
- Pre-implementation command:
  `xcodebuild test -scheme OverlayClockTimer -destination 'platform=macOS' -only-testing:OverlayClockTimerTests/InputLoggingTests -only-testing:OverlayClockTimerUITests/OverlayClockTimerUITests/testInputLoggingRowsPreserveOldTimestampAndUseNewFormatAfterSwitch`
- Pre-implementation result: FAIL as expected. `xcodebuild` reported missing
  `EventTimestampProvider.timestamp(for:timeFormat:)` support before production
  changes.
- Pre-implementation result bundle:
  `/Users/Vladimir.Zulin/Library/Developer/Xcode/DerivedData/OverlayClockTimer-axoodzlmxznwhobrfzhbcxdvgyeo/Logs/Test/Test-OverlayClockTimer-2026.07.01_19-13-14-+0200.xcresult`
- Post-implementation command:
  `xcodebuild test -scheme OverlayClockTimer -destination 'platform=macOS' -only-testing:OverlayClockTimerTests/EventTimestampProviderTests -only-testing:OverlayClockTimerTests/InputEventStoreTests -only-testing:OverlayClockTimerTests/LogSessionWriterTests -only-testing:OverlayClockTimerTests/InputLoggingFormatSwitchReliabilityTests -only-testing:OverlayClockTimerUITests/OverlayClockTimerUITests/testInputLoggingRowsPreserveOldTimestampAndUseNewFormatAfterSwitch`
- Post-implementation result: PASS. `xcodebuild` reported
  `** TEST SUCCEEDED **`.
- Post-implementation summary: selected input logging unit/integration tests and
  1 selected UI test, 0 failures.
- Post-implementation result bundle:
  `/Users/Vladimir.Zulin/Library/Developer/Xcode/DerivedData/OverlayClockTimer-axoodzlmxznwhobrfzhbcxdvgyeo/Logs/Test/Test-OverlayClockTimer-2026.07.01_19-16-28-+0200.xcresult`

## Phase 4: UI Tests

- Add UI tests before production code for:
  - `clock.timeFormatToggle` exists, is enabled, and switches Clock display.
  - `clock.timeFormatToggle` switches the visible Clock display in under
    1 second.
  - `timer.timeFormatToggle` exists, is enabled, and switches Timer display.
  - Timer controls and the new toggle fit without increasing default overlay
    size.
  - Expanded input logging panel keeps the toggle visible.
  - Light and dark appearance keep the icon and compacted controls readable at
    60%, 90%, and 100% background opacity.
- Complete and record a macOS design review plus accepted `Epoch Toggle` sketch
  before implementing the icon.
- Required post-implementation result: UI tests pass.

Suggested command:

```bash
xcodebuild test \
  -scheme OverlayClockTimer \
  -destination 'platform=macOS' \
  -only-testing:OverlayClockTimerUITests/OverlayClockTimerUITests
```

### Phase 6 US4 Compact Overlay Result

- Date: 2026-07-01
- Pre-implementation command:
  `xcodebuild test -scheme OverlayClockTimer -destination 'platform=macOS' -only-testing:OverlayClockTimerTests/OverlayGeometryStoreTests/testDefaultCollapsedSizeAndCompactToolbarMetricsStayWithinContract -only-testing:OverlayClockTimerUITests/OverlayClockTimerUITests/testTimerToolbarControlsAndFormatToggleDoNotOverlapAtDefaultSize -only-testing:OverlayClockTimerUITests/OverlayClockTimerUITests/testFormatToggleRemainsVisibleWhenInputLoggingIsExpanded -only-testing:OverlayClockTimerUITests/OverlayClockTimerUITests/testEpochToggleAndCompactedControlsInLightAndDarkAppearancesAtOpacityLevels`
- Pre-implementation result: FAIL as expected. `xcodebuild` reported missing
  `OverlayMetrics.compactToolbarSpacing` before compact toolbar metrics and the
  accepted icon implementation were added.
- Pre-implementation result bundle:
  `/Users/Vladimir.Zulin/Library/Developer/Xcode/DerivedData/OverlayClockTimer-axoodzlmxznwhobrfzhbcxdvgyeo/Logs/Test/Test-OverlayClockTimer-2026.07.01_19-21-22-+0200.xcresult`
- Post-implementation compact UI command:
  `xcodebuild test -scheme OverlayClockTimer -destination 'platform=macOS' -only-testing:OverlayClockTimerTests/OverlayGeometryStoreTests/testDefaultCollapsedSizeAndCompactToolbarMetricsStayWithinContract -only-testing:OverlayClockTimerUITests/OverlayClockTimerUITests/testTimerToolbarControlsAndFormatToggleDoNotOverlapAtDefaultSize -only-testing:OverlayClockTimerUITests/OverlayClockTimerUITests/testFormatToggleRemainsVisibleWhenInputLoggingIsExpanded -only-testing:OverlayClockTimerUITests/OverlayClockTimerUITests/testEpochToggleAndCompactedControlsInLightAndDarkAppearancesAtOpacityLevels`
- Post-implementation compact UI result: PASS. `xcodebuild` reported
  `** TEST SUCCEEDED **`.
- Post-implementation compact UI result bundle:
  `/Users/Vladimir.Zulin/Library/Developer/Xcode/DerivedData/OverlayClockTimer-axoodzlmxznwhobrfzhbcxdvgyeo/Logs/Test/Test-OverlayClockTimer-2026.07.01_19-22-26-+0200.xcresult`
- Expanded overlay/UI regression command:
  `xcodebuild test -scheme OverlayClockTimer -destination 'platform=macOS' -only-testing:OverlayClockTimerTests/OverlayGeometryStoreTests -only-testing:OverlayClockTimerTests/OverlayWindowControllerTests -only-testing:OverlayClockTimerTests/AppCoordinatorModeSwitchTests -only-testing:OverlayClockTimerUITests/OverlayClockTimerUITests/testTimerModeControlsAndLatestLoopText -only-testing:OverlayClockTimerUITests/OverlayClockTimerUITests/testModeSwitchIsAlwaysAvailableAndSeparateFromTimerControls -only-testing:OverlayClockTimerUITests/OverlayClockTimerUITests/testInputLoggingToggleIsLeftOfTimerModeSwitch -only-testing:OverlayClockTimerUITests/OverlayClockTimerUITests/testAccessibilityLabelsDisabledStatesFocusTargetsAndSettingsReachability -only-testing:OverlayClockTimerUITests/OverlayClockTimerUITests/testTimerToolbarControlsAndFormatToggleDoNotOverlapAtDefaultSize -only-testing:OverlayClockTimerUITests/OverlayClockTimerUITests/testFormatToggleRemainsVisibleWhenInputLoggingIsExpanded -only-testing:OverlayClockTimerUITests/OverlayClockTimerUITests/testEpochToggleAndCompactedControlsInLightAndDarkAppearancesAtOpacityLevels`
- Expanded overlay/UI regression result: PASS. `xcodebuild` reported
  `** TEST SUCCEEDED **`.
- Expanded overlay/UI regression summary: 7 selected UI tests, overlay geometry,
  overlay window, and app coordinator tests, 0 failures.
- Expanded overlay/UI regression result bundle:
  `/Users/Vladimir.Zulin/Library/Developer/Xcode/DerivedData/OverlayClockTimer-axoodzlmxznwhobrfzhbcxdvgyeo/Logs/Test/Test-OverlayClockTimer-2026.07.01_19-23-43-+0200.xcresult`

#### Epoch Toggle Opacity Checkpoint

- 60% opacity: PASS in light and dark appearance via
  `testEpochToggleAndCompactedControlsInLightAndDarkAppearancesAtOpacityLevels`.
- 90% opacity: PASS in light and dark appearance via
  `testEpochToggleAndCompactedControlsInLightAndDarkAppearancesAtOpacityLevels`.
- 100% opacity: PASS in light and dark appearance via
  `testEpochToggleAndCompactedControlsInLightAndDarkAppearancesAtOpacityLevels`.
- Readability criteria: the icon-only toggle remains present, enabled, compact
  (28-34 pt accessibility frame), non-overlapping with adjacent controls, and
  uses the same adaptive toolbar foreground treatment in all checked cases.

## Final Validation

- Date: 2026-07-01.
- Documentation review: PASS. Generated feature docs were reviewed for stale
  terminology. `spec.md` consistently defines the alternate format as epoch
  milliseconds: 13 decimal digits with no decimal separator. The only remaining
  fractional Unix seconds reference is in `research.md` as a rejected
  alternative, which is intentional.
- Manual/UI review examples: PASS. `quickstart.md` records final epoch
  milliseconds examples, timer elapsed milliseconds examples, mixed-format log
  examples, and the opacity checkpoint location.
- `git diff --check -- OverlayClockTimer OverlayClockTimerTests OverlayClockTimerUITests OverlayClockTimer.xcodeproj specs/003-time-format-toggle`
  result: PASS. Command exited 0 with no whitespace error output.
- `xcodebuild build -scheme OverlayClockTimer -destination 'platform=macOS'`
  result: PASS. `xcodebuild` reported `** BUILD SUCCEEDED **`.
- `xcodebuild test -scheme OverlayClockTimer -destination 'platform=macOS'`
  result: PASS. `xcodebuild` reported `** TEST SUCCEEDED **`.
- Full-suite UI summary: 22 UI tests, 0 failures.
- Full-suite result bundle:
  `/Users/Vladimir.Zulin/Library/Developer/Xcode/DerivedData/OverlayClockTimer-axoodzlmxznwhobrfzhbcxdvgyeo/Logs/Test/Test-OverlayClockTimer-2026.07.01_19-31-26-+0200.xcresult`
- Expected automated test results were not changed to match incorrect behavior.
