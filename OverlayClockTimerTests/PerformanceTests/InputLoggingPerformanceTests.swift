import XCTest
@testable import OverlayClockTimer

@MainActor
final class InputLoggingPerformanceTests: XCTestCase {
    func testPanelOpenLatencyStaysUnderTwoHundredMilliseconds() {
        let store = InputEventStore(preferences: OverlayPreferences.defaults)

        let startedAt = Date()
        store.openPanel()
        let elapsed = Date().timeIntervalSince(startedAt)

        XCTAssertTrue(store.isPanelOpen)
        XCTAssertLessThan(elapsed, 0.2)
    }
}
