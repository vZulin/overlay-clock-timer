import XCTest

final class OverlayClockTimerUITests: XCTestCase {
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
        XCTAssertTrue(modeSwitch.exists)
        XCTAssertTrue(modeSwitch.isEnabled)

        loggingToggle.click()
        XCTAssertFalse(panel.waitForExistence(timeout: 1))

        loggingToggle.click()
        XCTAssertTrue(panel.waitForExistence(timeout: 2))
        XCTAssertTrue(app.descendants(matching: .any)["inputLogging.emptyState"].exists)
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

        XCTAssertTrue(
            app.descendants(matching: .any)["inputLogging.eventName.mouse-down"]
                .waitForExistence(timeout: 2)
        )
        XCTAssertTrue(
            app.descendants(matching: .any)["inputLogging.eventName.mouse-up"]
                .waitForExistence(timeout: 2)
        )
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
