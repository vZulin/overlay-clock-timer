import XCTest

final class OverlayClockTimerUITests: XCTestCase {
    func testUITestBundleLoads() {
        XCTAssertTrue(true)
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
}
