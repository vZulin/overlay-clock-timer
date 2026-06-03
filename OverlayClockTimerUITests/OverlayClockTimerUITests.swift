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
}
