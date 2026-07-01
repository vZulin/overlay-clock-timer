import XCTest

final class OverlayClockTimerUITests: XCTestCase {
    private let standardTimePattern = #"^\d{2}:\d{2}:\d{2}\.\d{3}$"#
    private let epochMillisecondsPattern = #"^\d{13}$"#

    func testUITestBundleLoads() {
        XCTAssertTrue(true)
    }

    @MainActor
    func testDefaultLaunchShowsReadableOverlay() {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing"]
        app.launch()

        let overlayWindow = app.windows["Overlay Clock Timer Overlay"]
        XCTAssertTrue(overlayWindow.waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["clock.display"].exists)
    }

    @MainActor
    func testClockFormatToggleSwitchesDisplayAndPersistsAcrossRelaunch() {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing", "--show-overlay-on-launch"]
        app.launch()

        let overlayWindow = app.windows["Overlay Clock Timer Overlay"]
        XCTAssertTrue(overlayWindow.waitForExistence(timeout: 5))

        let standardText = waitForClockDisplay(app, matchingRegex: standardTimePattern)
        let toggle = app.buttons["clock.timeFormatToggle"]
        assertAccessibleButton(toggle, label: "Switch to Epoch Milliseconds")

        toggle.click()

        let epochText = waitForClockDisplay(app, matchingRegex: epochMillisecondsPattern)
        XCTAssertNotEqual(epochText, standardText)
        assertAccessibleButton(toggle, label: "Switch to Standard Time Format")

        app.terminate()
        app.launchArguments = [
            "--ui-testing",
            "--show-overlay-on-launch",
            "--preserve-ui-testing-preferences"
        ]
        app.launch()

        XCTAssertTrue(app.windows["Overlay Clock Timer Overlay"].waitForExistence(timeout: 5))
        _ = waitForClockDisplay(app, matchingRegex: epochMillisecondsPattern)
        assertAccessibleButton(
            app.buttons["clock.timeFormatToggle"],
            label: "Switch to Standard Time Format"
        )
    }

    @MainActor
    func testClockFormatToggleUpdatesVisibleDisplayWithinOneSecond() {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing", "--show-overlay-on-launch"]
        app.launch()

        let overlayWindow = app.windows["Overlay Clock Timer Overlay"]
        XCTAssertTrue(overlayWindow.waitForExistence(timeout: 5))
        _ = waitForClockDisplay(app, matchingRegex: standardTimePattern)

        let display = app.staticTexts["clock.display"]
        let toggle = app.buttons["clock.timeFormatToggle"]
        assertAccessibleButton(toggle, label: "Switch to Epoch Milliseconds")

        toggle.click()
        let startedAt = Date()
        _ = waitForClockDisplayValue(display, matchingRegex: epochMillisecondsPattern, timeout: 1)

        XCTAssertLessThanOrEqual(Date().timeIntervalSince(startedAt), 1)
    }

    @MainActor
    func testMenuBarShowHideAndVisibleOverlaySmokeFlow() {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing", "--show-overlay-on-launch"]
        app.launch()

        let overlayWindow = app.windows["Overlay Clock Timer Overlay"]
        XCTAssertTrue(overlayWindow.waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["clock.display"].exists)

        let hideButton = app.buttons["clock.hideOverlay"]
        XCTAssertTrue(hideButton.exists)
        hideButton.click()

        XCTAssertFalse(overlayWindow.waitForExistence(timeout: 1))
    }

    @MainActor
    func testTimerModeControlsAndLatestLoopText() {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing", "--show-overlay-on-launch"]
        app.launch()

        let overlayWindow = app.windows["Overlay Clock Timer Overlay"]
        XCTAssertTrue(overlayWindow.waitForExistence(timeout: 5))

        app.buttons["clock.switchMode"].click()

        let timerDisplay = app.staticTexts["timer.display"]
        XCTAssertTrue(timerDisplay.waitForExistence(timeout: 2))

        let startButton = app.buttons["timer.start"]
        let stopResetButton = app.buttons["timer.stopReset"]
        let loopButton = app.buttons["timer.loop"]

        XCTAssertTrue(startButton.isEnabled)
        XCTAssertFalse(stopResetButton.isEnabled)
        XCTAssertFalse(loopButton.isEnabled)

        startButton.click()

        let pauseButton = app.buttons["timer.pause"]
        XCTAssertTrue(pauseButton.waitForExistence(timeout: 2))
        XCTAssertTrue(pauseButton.isEnabled)
        XCTAssertTrue(stopResetButton.isEnabled)
        XCTAssertTrue(loopButton.isEnabled)

        loopButton.click()

        let latestLoopText = app.staticTexts["timer.latestLoop"]
        XCTAssertTrue(latestLoopText.waitForExistence(timeout: 2))

        pauseButton.click()
        XCTAssertFalse(loopButton.isEnabled)
        XCTAssertTrue(stopResetButton.isEnabled)

        stopResetButton.click()
        XCTAssertTrue(app.buttons["timer.start"].waitForExistence(timeout: 2))
        XCTAssertFalse(stopResetButton.isEnabled)
        XCTAssertFalse(latestLoopText.exists)
    }

    @MainActor
    func testTimerFormatToggleSwitchesDisplayWithoutDisablingTimerControls() {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing", "--show-overlay-on-launch"]
        app.launch()

        let overlayWindow = app.windows["Overlay Clock Timer Overlay"]
        XCTAssertTrue(overlayWindow.waitForExistence(timeout: 5))

        app.buttons["clock.switchMode"].click()

        let timerDisplay = app.staticTexts["timer.display"]
        XCTAssertTrue(timerDisplay.waitForExistence(timeout: 2))

        let startButton = app.buttons["timer.start"]
        let stopResetButton = app.buttons["timer.stopReset"]
        let loopButton = app.buttons["timer.loop"]
        let toggle = app.buttons["timer.timeFormatToggle"]

        XCTAssertTrue(startButton.isEnabled)
        XCTAssertFalse(stopResetButton.isEnabled)
        XCTAssertFalse(loopButton.isEnabled)
        assertAccessibleButton(toggle, label: "Switch to Epoch Milliseconds")

        toggle.click()

        XCTAssertEqual(waitForTimerDisplay(app, matchingRegex: epochMillisecondsPattern), "0000000000000")
        XCTAssertTrue(startButton.isEnabled)
        XCTAssertFalse(stopResetButton.isEnabled)
        XCTAssertFalse(loopButton.isEnabled)
        assertAccessibleButton(toggle, label: "Switch to Standard Time Format")

        startButton.click()

        let pauseButton = app.buttons["timer.pause"]
        XCTAssertTrue(pauseButton.waitForExistence(timeout: 2))
        XCTAssertTrue(pauseButton.isEnabled)
        XCTAssertTrue(stopResetButton.isEnabled)
        XCTAssertTrue(loopButton.isEnabled)
        _ = waitForTimerDisplay(app, matchingRegex: epochMillisecondsPattern)

        toggle.click()

        _ = waitForTimerDisplay(app, matchingRegex: standardTimePattern)
        XCTAssertTrue(pauseButton.isEnabled)
        XCTAssertTrue(stopResetButton.isEnabled)
        XCTAssertTrue(loopButton.isEnabled)
        assertAccessibleButton(toggle, label: "Switch to Epoch Milliseconds")
    }

    @MainActor
    func testTimerToolbarControlsAndFormatToggleDoNotOverlapAtDefaultSize() {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing", "--show-overlay-on-launch"]
        app.launch()

        let overlayWindow = app.windows["Overlay Clock Timer Overlay"]
        XCTAssertTrue(overlayWindow.waitForExistence(timeout: 5))

        app.buttons["clock.switchMode"].click()

        let controls = timerToolbarControls(app)
        XCTAssertTrue(controls.start.waitForExistence(timeout: 2))

        assertCompactToolbarButton(controls.stopReset, label: "Stop and Reset", isEnabled: false)
        assertCompactToolbarButton(controls.start, label: "Start")
        assertCompactToolbarButton(controls.loop, label: "Loop", isEnabled: false)
        assertCompactToolbarButton(controls.formatToggle, label: "Switch to Epoch Milliseconds")
        assertCompactToolbarButton(controls.inputLogging, label: "Show Input Event Log")
        assertCompactToolbarButton(controls.modeSwitch, label: "Switch to Clock Mode")
        assertToolbarControlsDoNotOverlap(
            [
                controls.stopReset,
                controls.start,
                controls.loop,
                controls.formatToggle,
                controls.inputLogging,
                controls.modeSwitch
            ],
            inside: overlayWindow
        )
    }

    @MainActor
    func testModeSwitchKeepsDisplayAndToolbarSlotsStable() {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing", "--show-overlay-on-launch"]
        app.launch()

        let overlayWindow = app.windows["Overlay Clock Timer Overlay"]
        XCTAssertTrue(overlayWindow.waitForExistence(timeout: 5))
        let clockDisplay = app.staticTexts["clock.display"]
        XCTAssertTrue(clockDisplay.waitForExistence(timeout: 2))

        let clockDisplayMidY = clockDisplay.frame.midY
        let clockHideMinX = app.buttons["clock.hideOverlay"].frame.minX
        let clockFormatMinX = app.buttons["clock.timeFormatToggle"].frame.minX
        let clockLoggingMinX = app.buttons["clock.inputLoggingToggle"].frame.minX
        let clockModeMinX = app.buttons["clock.switchMode"].frame.minX
        let clockLoggingToModeGap =
            app.buttons["clock.switchMode"].frame.minX
            - app.buttons["clock.inputLoggingToggle"].frame.maxX

        app.buttons["clock.switchMode"].click()

        let timerDisplay = app.staticTexts["timer.display"]
        XCTAssertTrue(timerDisplay.waitForExistence(timeout: 2))
        let timerStart = app.buttons["timer.start"]
        XCTAssertTrue(timerStart.waitForExistence(timeout: 2))

        XCTAssertEqual(timerDisplay.frame.midY, clockDisplayMidY, accuracy: 1.5)
        XCTAssertEqual(timerStart.frame.minX, clockHideMinX, accuracy: 1.5)
        XCTAssertEqual(app.buttons["timer.timeFormatToggle"].frame.minX, clockFormatMinX, accuracy: 1.5)
        XCTAssertEqual(app.buttons["timer.inputLoggingToggle"].frame.minX, clockLoggingMinX, accuracy: 1.5)
        XCTAssertEqual(app.buttons["timer.switchMode"].frame.minX, clockModeMinX, accuracy: 1.5)

        let timerLoggingToModeGap =
            app.buttons["timer.switchMode"].frame.minX
            - app.buttons["timer.inputLoggingToggle"].frame.maxX
        XCTAssertEqual(timerLoggingToModeGap, clockLoggingToModeGap, accuracy: 1.5)
    }

    @MainActor
    func testInputLoggingExpansionKeepsCollapsedHeaderFramesStable() {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing", "--show-overlay-on-launch"]
        app.launch()

        let overlayWindow = app.windows["Overlay Clock Timer Overlay"]
        XCTAssertTrue(overlayWindow.waitForExistence(timeout: 5))
        let clockDisplay = app.staticTexts["clock.display"]
        XCTAssertTrue(clockDisplay.waitForExistence(timeout: 2))
        let loggingToggle = app.buttons["clock.inputLoggingToggle"]

        let displayFrame = clockDisplay.frame
        let hideFrame = app.buttons["clock.hideOverlay"].frame
        let formatFrame = app.buttons["clock.timeFormatToggle"].frame
        let loggingFrame = loggingToggle.frame
        let modeFrame = app.buttons["clock.switchMode"].frame

        loggingToggle.click()

        let panel = app.descendants(matching: .any)["inputLogging.panel"]
        XCTAssertTrue(panel.waitForExistence(timeout: 2))

        XCTAssertEqual(clockDisplay.frame.midY, displayFrame.midY, accuracy: 1.5)
        XCTAssertEqual(app.buttons["clock.hideOverlay"].frame.midY, hideFrame.midY, accuracy: 1.5)
        XCTAssertEqual(app.buttons["clock.timeFormatToggle"].frame.midY, formatFrame.midY, accuracy: 1.5)
        XCTAssertEqual(app.buttons["clock.inputLoggingToggle"].frame.midY, loggingFrame.midY, accuracy: 1.5)
        XCTAssertEqual(app.buttons["clock.switchMode"].frame.midY, modeFrame.midY, accuracy: 1.5)
        XCTAssertEqual(app.buttons["clock.hideOverlay"].frame.minX, hideFrame.minX, accuracy: 1.5)
        XCTAssertEqual(app.buttons["clock.timeFormatToggle"].frame.minX, formatFrame.minX, accuracy: 1.5)
        XCTAssertEqual(app.buttons["clock.inputLoggingToggle"].frame.minX, loggingFrame.minX, accuracy: 1.5)
        XCTAssertEqual(app.buttons["clock.switchMode"].frame.minX, modeFrame.minX, accuracy: 1.5)
    }

    @MainActor
    func testFormatToggleRemainsVisibleWhenInputLoggingIsExpanded() {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing", "--show-overlay-on-launch"]
        app.launch()

        let overlayWindow = app.windows["Overlay Clock Timer Overlay"]
        XCTAssertTrue(overlayWindow.waitForExistence(timeout: 5))

        app.buttons["clock.switchMode"].click()

        let inputLoggingToggle = app.buttons["timer.inputLoggingToggle"]
        XCTAssertTrue(inputLoggingToggle.waitForExistence(timeout: 2))
        inputLoggingToggle.click()

        let panel = app.descendants(matching: .any)["inputLogging.panel"]
        XCTAssertTrue(panel.waitForExistence(timeout: 2))

        let controls = timerToolbarControls(app)
        assertCompactToolbarButton(controls.formatToggle, label: "Switch to Epoch Milliseconds")
        assertCompactToolbarButton(controls.inputLogging, label: "Hide Input Event Log")
        assertCompactToolbarButton(controls.modeSwitch, label: "Switch to Clock Mode")
        assertToolbarControlsDoNotOverlap(
            [
                controls.stopReset,
                controls.start,
                controls.loop,
                controls.formatToggle,
                controls.inputLogging,
                controls.modeSwitch
            ],
            inside: overlayWindow
        )
    }

    @MainActor
    func testEpochToggleAndCompactedControlsInLightAndDarkAppearancesAtOpacityLevels() {
        let cases: [(theme: String, opacity: String)] = [
            ("light", "0.60"),
            ("light", "0.90"),
            ("light", "1.00"),
            ("dark", "0.60"),
            ("dark", "0.90"),
            ("dark", "1.00")
        ]

        for testCase in cases {
            let app = XCUIApplication()
            app.launchArguments = [
                "--ui-testing",
                "--show-overlay-on-launch",
                "--ui-testing-theme=\(testCase.theme)",
                "--ui-testing-background-opacity=\(testCase.opacity)"
            ]
            if testCase.theme == "dark" {
                app.launchEnvironment["AppleInterfaceStyle"] = "Dark"
            }
            app.launch()

            let overlayWindow = app.windows["Overlay Clock Timer Overlay"]
            XCTAssertTrue(
                overlayWindow.waitForExistence(timeout: 5),
                "Overlay did not appear for \(testCase.theme) at \(testCase.opacity) opacity."
            )

            assertCompactToolbarButton(
                app.buttons["clock.timeFormatToggle"],
                label: "Switch to Epoch Milliseconds"
            )
            assertCompactToolbarButton(app.buttons["clock.settings"], label: "Settings")
            assertCompactToolbarButton(app.buttons["clock.hideOverlay"], label: "Hide Overlay")

            app.buttons["clock.switchMode"].click()

            let controls = timerToolbarControls(app)
            XCTAssertTrue(controls.start.waitForExistence(timeout: 2))
            assertCompactToolbarButton(controls.formatToggle, label: "Switch to Epoch Milliseconds")
            assertToolbarControlsDoNotOverlap(
                [
                    controls.stopReset,
                    controls.start,
                    controls.loop,
                    controls.formatToggle,
                    controls.inputLogging,
                    controls.modeSwitch
                ],
                inside: overlayWindow
            )

            app.terminate()
        }
    }

    @MainActor
    func testModeSwitchIsAlwaysAvailableAndSeparateFromTimerControls() {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing", "--show-overlay-on-launch"]
        app.launch()

        let overlayWindow = app.windows["Overlay Clock Timer Overlay"]
        XCTAssertTrue(overlayWindow.waitForExistence(timeout: 5))

        let clockModeSwitch = app.buttons["clock.switchMode"]
        XCTAssertTrue(clockModeSwitch.exists)
        XCTAssertTrue(clockModeSwitch.isEnabled)

        clockModeSwitch.click()

        let timerModeSwitch = app.buttons["timer.switchMode"]
        let startButton = app.buttons["timer.start"]
        let stopResetButton = app.buttons["timer.stopReset"]
        let loopButton = app.buttons["timer.loop"]

        XCTAssertTrue(timerModeSwitch.waitForExistence(timeout: 2))
        XCTAssertTrue(timerModeSwitch.isEnabled)
        XCTAssertGreaterThan(timerModeSwitch.frame.minX, loopButton.frame.maxX + 12)

        startButton.click()

        let pauseButton = app.buttons["timer.pause"]
        XCTAssertTrue(pauseButton.waitForExistence(timeout: 2))
        XCTAssertTrue(timerModeSwitch.isEnabled)
        XCTAssertGreaterThan(timerModeSwitch.frame.minX, loopButton.frame.maxX + 12)

        pauseButton.click()
        XCTAssertTrue(timerModeSwitch.isEnabled)
        XCTAssertGreaterThan(timerModeSwitch.frame.minX, loopButton.frame.maxX + 12)

        stopResetButton.click()
        XCTAssertTrue(timerModeSwitch.isEnabled)
        XCTAssertGreaterThan(timerModeSwitch.frame.minX, loopButton.frame.maxX + 12)
    }

    @MainActor
    func testInputLoggingToggleOpensClosesPanelAndPreservesModeSwitch() {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing", "--show-overlay-on-launch"]
        app.launch()

        let overlayWindow = app.windows["Overlay Clock Timer Overlay"]
        XCTAssertTrue(overlayWindow.waitForExistence(timeout: 5))

        let loggingToggle = app.buttons["clock.inputLoggingToggle"]
        let modeSwitch = app.buttons["clock.switchMode"]
        XCTAssertTrue(loggingToggle.exists)
        XCTAssertTrue(modeSwitch.exists)
        XCTAssertLessThan(loggingToggle.frame.maxX, modeSwitch.frame.minX)

        loggingToggle.click()

        let panel = app.descendants(matching: .any)["inputLogging.panel"]
        XCTAssertTrue(panel.waitForExistence(timeout: 2))
        XCTAssertTrue(app.descendants(matching: .any)["inputLogging.emptyState"].exists)
        let eventTable = app.outlines["inputLogging.eventTable"]
        XCTAssertGreaterThanOrEqual(
            eventTable.frame.height,
            400
        )
        XCTAssertTrue(modeSwitch.exists)
        XCTAssertTrue(modeSwitch.isEnabled)

        loggingToggle.click()
        XCTAssertFalse(panel.waitForExistence(timeout: 1))

        loggingToggle.click()
        XCTAssertTrue(panel.waitForExistence(timeout: 2))
        XCTAssertTrue(app.descendants(matching: .any)["inputLogging.emptyState"].exists)
    }

    @MainActor
    func testInputLoggingPanelAccessibilityStatesAndDarkAppearanceSmoke() {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing", "--show-overlay-on-launch"]
        app.launchEnvironment["AppleInterfaceStyle"] = "Dark"
        app.launch()

        let overlayWindow = app.windows["Overlay Clock Timer Overlay"]
        XCTAssertTrue(overlayWindow.waitForExistence(timeout: 5))

        let loggingToggle = app.buttons["clock.inputLoggingToggle"]
        assertAccessibleButton(loggingToggle, label: "Show Input Event Log")
        loggingToggle.click()

        let panel = app.descendants(matching: .any)["inputLogging.panel"]
        XCTAssertTrue(panel.waitForExistence(timeout: 2))
        XCTAssertTrue(app.descendants(matching: .any)["inputLogging.emptyState"].exists)
        XCTAssertTrue(
            app.staticTexts["Capture Active"].exists
                || app.staticTexts["Capture Unavailable"].exists
                || app.staticTexts["Capture Inactive"].exists
        )
        XCTAssertTrue(
            app.staticTexts["File Active"].exists
                || app.staticTexts["File Unavailable"].exists
                || app.staticTexts["File Inactive"].exists
        )
        XCTAssertTrue(app.staticTexts["0/15"].exists)
    }

    @MainActor
    func testInputLoggingTableShowsOnlyTimeAndEventColumns() {
        let app = XCUIApplication()
        app.launchArguments = inputCaptureTestLaunchArguments()
        app.launch()

        let overlayWindow = app.windows["Overlay Clock Timer Overlay"]
        XCTAssertTrue(overlayWindow.waitForExistence(timeout: 5))

        app.buttons["clock.inputLoggingToggle"].click()

        let panel = app.descendants(matching: .any)["inputLogging.panel"]
        XCTAssertTrue(panel.waitForExistence(timeout: 2))

        let table = app.outlines
            .matching(NSPredicate(format: "label CONTAINS %@", "Input Event Table"))
            .firstMatch
        XCTAssertTrue(table.exists)
        XCTAssertTrue(table.label.contains("Time"))
        XCTAssertTrue(table.label.contains("Event"))
        XCTAssertFalse(table.label.contains("Type"))
        XCTAssertFalse(table.label.contains("Category"))
        XCTAssertFalse(table.label.contains("Phase"))
    }

    @MainActor
    func testInputLoggingRowsPreserveOldTimestampAndUseNewFormatAfterSwitch() {
        let app = XCUIApplication()
        app.launchArguments = inputCaptureTestLaunchArguments()
            + ["--preserve-input-event-table-between-opens"]
        app.launch()

        let overlayWindow = app.windows["Overlay Clock Timer Overlay"]
        XCTAssertTrue(overlayWindow.waitForExistence(timeout: 5))

        let loggingToggle = app.buttons["clock.inputLoggingToggle"]
        loggingToggle.click()

        let panel = app.descendants(matching: .any)["inputLogging.panel"]
        XCTAssertTrue(panel.waitForExistence(timeout: 2))
        guard requireCaptureActive(app) else {
            return
        }

        let firstTimestamp = waitForInputLoggingTimestamp(
            app,
            captureOrder: 1,
            matchingRegex: standardTimePattern
        )

        loggingToggle.click()
        XCTAssertFalse(panel.waitForExistence(timeout: 1))

        let formatToggle = app.buttons["clock.timeFormatToggle"]
        formatToggle.click()
        assertAccessibleButton(formatToggle, label: "Switch to Standard Time Format")

        loggingToggle.click()
        XCTAssertTrue(panel.waitForExistence(timeout: 2))
        guard requireCaptureActive(app) else {
            return
        }

        let epochTimestamp = waitForInputLoggingTimestamp(
            app,
            captureOrder: 14,
            matchingRegex: epochMillisecondsPattern
        )
        let preservedFirstTimestamp = waitForInputLoggingTimestamp(
            app,
            captureOrder: 1,
            matchingRegex: standardTimePattern
        )

        XCTAssertEqual(preservedFirstTimestamp, firstTimestamp)
        XCTAssertNotEqual(epochTimestamp, firstTimestamp)
    }

    @MainActor
    func testInputLoggingToggleIsLeftOfTimerModeSwitch() {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing", "--show-overlay-on-launch"]
        app.launch()

        let overlayWindow = app.windows["Overlay Clock Timer Overlay"]
        XCTAssertTrue(overlayWindow.waitForExistence(timeout: 5))

        app.buttons["clock.switchMode"].click()

        let loggingToggle = app.buttons["timer.inputLoggingToggle"]
        let modeSwitch = app.buttons["timer.switchMode"]
        XCTAssertTrue(loggingToggle.waitForExistence(timeout: 2))
        XCTAssertTrue(modeSwitch.exists)
        XCTAssertLessThan(loggingToggle.frame.maxX, modeSwitch.frame.minX)
    }

    @MainActor
    func testKeyboardLoggingRecordsRowsAndStopsOnClose() {
        let app = XCUIApplication()
        app.launchArguments = inputCaptureTestLaunchArguments()
        app.launch()

        let overlayWindow = app.windows["Overlay Clock Timer Overlay"]
        XCTAssertTrue(overlayWindow.waitForExistence(timeout: 5))

        let loggingToggle = app.buttons["clock.inputLoggingToggle"]
        loggingToggle.click()

        let panel = app.descendants(matching: .any)["inputLogging.panel"]
        XCTAssertTrue(panel.waitForExistence(timeout: 2))

        guard requireCaptureActive(app) else {
            return
        }

        overlayWindow.click()
        overlayWindow.typeKey("s", modifierFlags: [])

        XCTAssertTrue(
            app.descendants(matching: .any)["inputLogging.eventName.s"]
                .waitForExistence(timeout: 2)
        )

        loggingToggle.click()
        XCTAssertFalse(panel.waitForExistence(timeout: 1))
    }

    @MainActor
    func testMouseLoggingRowsAndFileState() {
        let app = XCUIApplication()
        app.launchArguments = inputCaptureTestLaunchArguments()
        app.launch()

        let overlayWindow = app.windows["Overlay Clock Timer Overlay"]
        XCTAssertTrue(overlayWindow.waitForExistence(timeout: 5))

        let loggingToggle = app.buttons["clock.inputLoggingToggle"]
        loggingToggle.click()

        let panel = app.descendants(matching: .any)["inputLogging.panel"]
        XCTAssertTrue(panel.waitForExistence(timeout: 2))

        let fileActive = app.staticTexts["File Active"]
        let fileUnavailable = app.staticTexts["File Unavailable"]
        guard fileActive.exists else {
            XCTFail(
                fileUnavailable.exists
                    ? "File recording is unavailable; this test cannot verify persisted mouse events."
                    : "File recording did not become active."
            )
            return
        }
        guard requireCaptureActive(app) else {
            return
        }

        overlayWindow.click()

        XCTAssertTrue(app.descendants(matching: .any)["inputLogging.eventName.lm-down"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.descendants(matching: .any)["inputLogging.eventName.lm-up"].waitForExistence(timeout: 2))
    }

    @MainActor
    func testCompactMouseAndScrollRowsUseStableAccessibilityIdentifiers() {
        let app = XCUIApplication()
        app.launchArguments = inputCaptureTestLaunchArguments()
        app.launch()

        let overlayWindow = app.windows["Overlay Clock Timer Overlay"]
        XCTAssertTrue(overlayWindow.waitForExistence(timeout: 5))

        app.buttons["clock.inputLoggingToggle"].click()

        let panel = app.descendants(matching: .any)["inputLogging.panel"]
        XCTAssertTrue(panel.waitForExistence(timeout: 2))

        guard requireCaptureActive(app) else {
            return
        }

        let expectedIdentifiers = [
            "inputLogging.eventName.lm-down",
            "inputLogging.eventName.lm-up",
            "inputLogging.eventName.rm-down",
            "inputLogging.eventName.rm-up",
            "inputLogging.eventName.3m-down",
            "inputLogging.eventName.3m-up",
            "inputLogging.eventName.4m-down",
            "inputLogging.eventName.4m-up",
            "inputLogging.eventName.5m-down",
            "inputLogging.eventName.5m-up",
            "inputLogging.eventName.sm-up",
            "inputLogging.eventName.sm-down"
        ]

        for identifier in expectedIdentifiers {
            XCTAssertTrue(
                app.descendants(matching: .any)[identifier].waitForExistence(timeout: 2),
                "Missing row identifier: \(identifier)"
            )
        }
    }

    @MainActor
    func testInputLoggingRowsAppearBeforeDelayedFileWritingCanBlockVisibility() {
        let app = XCUIApplication()
        app.launchArguments = inputCaptureTestLaunchArguments()
            + ["--delayed-input-event-log-writing"]
        app.launch()

        let overlayWindow = app.windows["Overlay Clock Timer Overlay"]
        XCTAssertTrue(overlayWindow.waitForExistence(timeout: 5))

        let loggingToggle = app.buttons["clock.inputLoggingToggle"]
        let panel = app.descendants(matching: .any)["inputLogging.panel"]
        let row = app.descendants(matching: .any)["inputLogging.eventName.s"]
        let enforceStrictDisplayRefreshTarget =
            ProcessInfo.processInfo.environment["OVERLAY_CLOCK_TIMER_STRICT_UI_REFRESH_SLA"] == "1"
        var rowAppearanceDurations: [TimeInterval] = []

        for trial in 1...10 {
            loggingToggle.click()
            XCTAssertTrue(panel.waitForExistence(timeout: 2), "Panel did not open in trial \(trial).")
            guard requireCaptureActive(app) else {
                return
            }

            let startedAt = Date()
            XCTAssertTrue(
                row.waitForExistence(timeout: 0.5),
                "Input row did not appear before the delayed file writer could block visibility in trial \(trial)."
            )
            let elapsed = Date().timeIntervalSince(startedAt)
            rowAppearanceDurations.append(elapsed)

            if enforceStrictDisplayRefreshTarget {
                XCTAssertLessThanOrEqual(elapsed, 0.016, "Trial \(trial) exceeded the display-refresh target.")
            }

            loggingToggle.click()
            XCTAssertFalse(panel.waitForExistence(timeout: 1), "Panel did not close in trial \(trial).")
        }

        XCTAssertEqual(rowAppearanceDurations.count, 10)
    }

    @MainActor
    func testSettingsWindowOpensSeparatelyWithoutHidingOverlay() {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing", "--show-overlay-on-launch"]
        app.launch()

        let overlayWindow = app.windows["Overlay Clock Timer Overlay"]
        XCTAssertTrue(overlayWindow.waitForExistence(timeout: 5))

        app.buttons["clock.settings"].click()

        let settingsWindow = app.windows["Overlay Clock Timer Settings"]
        XCTAssertTrue(settingsWindow.waitForExistence(timeout: 5))
        XCTAssertTrue(overlayWindow.exists)
        XCTAssertTrue(settingsWindow.staticTexts["settings.appearance.title"].exists)
    }

    @MainActor
    func testAccessibilityLabelsDisabledStatesFocusTargetsAndSettingsReachability() {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing", "--show-overlay-on-launch"]
        app.launch()

        let overlayWindow = app.windows["Overlay Clock Timer Overlay"]
        XCTAssertTrue(overlayWindow.waitForExistence(timeout: 5))

        assertAccessibleButton(app.buttons["clock.settings"], label: "Settings")
        assertAccessibleButton(app.buttons["clock.hideOverlay"], label: "Hide Overlay")
        assertAccessibleButton(app.buttons["clock.inputLoggingToggle"], label: "Show Input Event Log")
        assertAccessibleButton(app.buttons["clock.switchMode"], label: "Switch to Timer Mode")

        app.buttons["clock.switchMode"].click()

        let startButton = app.buttons["timer.start"]
        let stopResetButton = app.buttons["timer.stopReset"]
        let loopButton = app.buttons["timer.loop"]
        let switchModeButton = app.buttons["timer.switchMode"]

        XCTAssertTrue(startButton.waitForExistence(timeout: 2))
        assertAccessibleButton(startButton, label: "Start")
        assertAccessibleButton(stopResetButton, label: "Stop and Reset", isEnabled: false)
        assertAccessibleButton(loopButton, label: "Loop", isEnabled: false)
        assertAccessibleButton(switchModeButton, label: "Switch to Clock Mode")

        startButton.click()

        let pauseButton = app.buttons["timer.pause"]
        XCTAssertTrue(pauseButton.waitForExistence(timeout: 2))
        assertAccessibleButton(pauseButton, label: "Pause")
        XCTAssertTrue(stopResetButton.isEnabled)
        XCTAssertTrue(loopButton.isEnabled)

        switchModeButton.click()
        app.buttons["clock.settings"].click()

        let settingsWindow = app.windows["Overlay Clock Timer Settings"]
        XCTAssertTrue(settingsWindow.waitForExistence(timeout: 5))
        XCTAssertTrue(settingsWindow.staticTexts["settings.appearance.title"].exists)
        XCTAssertTrue(overlayWindow.exists)
    }

    @MainActor
    private func assertAccessibleButton(
        _ button: XCUIElement,
        label: String,
        isEnabled: Bool = true,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertTrue(button.exists, file: file, line: line)
        XCTAssertEqual(button.label, label, file: file, line: line)
        XCTAssertEqual(button.isEnabled, isEnabled, file: file, line: line)
        XCTAssertGreaterThanOrEqual(button.frame.width, 32, file: file, line: line)
        XCTAssertGreaterThanOrEqual(button.frame.height, 32, file: file, line: line)
    }

    @MainActor
    private func assertCompactToolbarButton(
        _ button: XCUIElement,
        label: String,
        isEnabled: Bool = true,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertTrue(button.exists, file: file, line: line)
        XCTAssertEqual(button.label, label, file: file, line: line)
        XCTAssertEqual(button.isEnabled, isEnabled, file: file, line: line)
        XCTAssertGreaterThanOrEqual(button.frame.width, 28, file: file, line: line)
        XCTAssertGreaterThanOrEqual(button.frame.height, 28, file: file, line: line)
        XCTAssertLessThanOrEqual(button.frame.width, 34, file: file, line: line)
        XCTAssertLessThanOrEqual(button.frame.height, 34, file: file, line: line)
    }

    @MainActor
    private func assertToolbarControlsDoNotOverlap(
        _ controls: [XCUIElement],
        inside container: XCUIElement,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let containerFrame = container.frame
        for control in controls {
            XCTAssertTrue(control.exists, file: file, line: line)
            XCTAssertGreaterThanOrEqual(control.frame.minX, containerFrame.minX - 1, file: file, line: line)
            XCTAssertGreaterThanOrEqual(control.frame.minY, containerFrame.minY - 1, file: file, line: line)
            XCTAssertLessThanOrEqual(control.frame.maxX, containerFrame.maxX + 1, file: file, line: line)
            XCTAssertLessThanOrEqual(control.frame.maxY, containerFrame.maxY + 1, file: file, line: line)
        }

        let orderedControls = controls.sorted { $0.frame.minX < $1.frame.minX }
        for index in 0..<(orderedControls.count - 1) {
            XCTAssertLessThanOrEqual(
                orderedControls[index].frame.maxX,
                orderedControls[index + 1].frame.minX + 0.5,
                file: file,
                line: line
            )
        }
    }

    @MainActor
    private func timerToolbarControls(_ app: XCUIApplication) -> (
        stopReset: XCUIElement,
        start: XCUIElement,
        loop: XCUIElement,
        formatToggle: XCUIElement,
        inputLogging: XCUIElement,
        modeSwitch: XCUIElement
    ) {
        (
            stopReset: app.buttons["timer.stopReset"],
            start: app.buttons["timer.start"],
            loop: app.buttons["timer.loop"],
            formatToggle: app.buttons["timer.timeFormatToggle"],
            inputLogging: app.buttons["timer.inputLoggingToggle"],
            modeSwitch: app.buttons["timer.switchMode"]
        )
    }

    @MainActor
    private func waitForClockDisplay(
        _ app: XCUIApplication,
        matchingRegex pattern: String,
        timeout: TimeInterval = 2,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> String {
        let display = app.staticTexts["clock.display"]
        XCTAssertTrue(display.waitForExistence(timeout: timeout), file: file, line: line)

        return waitForClockDisplayValue(
            display,
            matchingRegex: pattern,
            timeout: timeout,
            file: file,
            line: line
        )
    }

    @MainActor
    private func waitForClockDisplayValue(
        _ display: XCUIElement,
        matchingRegex pattern: String,
        timeout: TimeInterval,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> String {
        let deadline = Date().addingTimeInterval(timeout)
        var latestText = clockDisplayText(display)

        while Date() < deadline {
            latestText = clockDisplayText(display)
            if latestText.range(of: pattern, options: .regularExpression) != nil {
                return latestText
            }

            RunLoop.current.run(until: Date().addingTimeInterval(0.05))
        }

        XCTFail("Clock display did not match \(pattern). Last value: \(latestText)", file: file, line: line)
        return latestText
    }

    @MainActor
    private func clockDisplayText(_ display: XCUIElement) -> String {
        (display.value as? String) ?? display.label
    }

    @MainActor
    private func waitForTimerDisplay(
        _ app: XCUIApplication,
        matchingRegex pattern: String,
        timeout: TimeInterval = 2,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> String {
        let display = app.staticTexts["timer.display"]
        XCTAssertTrue(display.waitForExistence(timeout: timeout), file: file, line: line)

        return waitForTimerDisplayValue(
            display,
            matchingRegex: pattern,
            timeout: timeout,
            file: file,
            line: line
        )
    }

    @MainActor
    private func waitForTimerDisplayValue(
        _ display: XCUIElement,
        matchingRegex pattern: String,
        timeout: TimeInterval,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> String {
        let deadline = Date().addingTimeInterval(timeout)
        var latestText = timerDisplayText(display)

        while Date() < deadline {
            latestText = timerDisplayText(display)
            if latestText.range(of: pattern, options: .regularExpression) != nil {
                return latestText
            }

            RunLoop.current.run(until: Date().addingTimeInterval(0.05))
        }

        XCTFail("Timer display did not match \(pattern). Last value: \(latestText)", file: file, line: line)
        return latestText
    }

    @MainActor
    private func timerDisplayText(_ display: XCUIElement) -> String {
        (display.value as? String) ?? display.label
    }

    @MainActor
    private func waitForInputLoggingTimestamp(
        _ app: XCUIApplication,
        captureOrder: UInt64,
        matchingRegex pattern: String,
        timeout: TimeInterval = 2,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> String {
        let timestamp = app.staticTexts["inputLogging.eventTimestamp.\(captureOrder)"]
        XCTAssertTrue(timestamp.waitForExistence(timeout: timeout), file: file, line: line)

        let deadline = Date().addingTimeInterval(timeout)
        var latestText = inputLoggingTimestampText(timestamp)
        while Date() < deadline {
            latestText = inputLoggingTimestampText(timestamp)
            if latestText.range(of: pattern, options: .regularExpression) != nil {
                return latestText
            }

            RunLoop.current.run(until: Date().addingTimeInterval(0.05))
        }

        XCTFail(
            "Input logging timestamp \(captureOrder) did not match \(pattern). Last value: \(latestText)",
            file: file,
            line: line
        )
        return latestText
    }

    @MainActor
    private func inputLoggingTimestampText(_ timestamp: XCUIElement) -> String {
        (timestamp.value as? String) ?? timestamp.label
    }

    private func inputCaptureTestLaunchArguments() -> [String] {
        var arguments = ["--ui-testing", "--show-overlay-on-launch"]
        if ProcessInfo.processInfo.environment["OVERLAY_CLOCK_TIMER_REAL_INPUT_CAPTURE_TESTS"] != "1" {
            arguments.append("--mock-input-event-capture")
        }
        return arguments
    }

    @MainActor
    private func requireCaptureActive(
        _ app: XCUIApplication,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> Bool {
        let captureActive = app.staticTexts["Capture Active"]
        let captureUnavailable = app.staticTexts["Capture Unavailable"]
        guard captureActive.exists else {
            XCTFail(
                captureUnavailable.exists
                ? "Capture is unavailable; grant Input Monitoring/Accessibility permission before running real capture UI tests."
                : "Capture did not become active.",
                file: file,
                line: line
            )
            return false
        }
        return true
    }

}
