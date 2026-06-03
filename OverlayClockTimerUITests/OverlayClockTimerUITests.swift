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
}
