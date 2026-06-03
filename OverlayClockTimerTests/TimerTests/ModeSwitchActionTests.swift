import XCTest
@testable import OverlayClockTimer

final class ModeSwitchActionTests: XCTestCase {
    func testDefaultActionStopsAndResetsTimer() {
        XCTAssertEqual(ModeSwitchAction.defaultValue, .stopAndReset)
    }

    func testStoredValuesRoundTrip() {
        XCTAssertEqual(ModeSwitchAction(storedValue: "continue"), .continue)
        XCTAssertEqual(ModeSwitchAction(storedValue: "pause"), .pause)
        XCTAssertEqual(ModeSwitchAction(storedValue: "stopAndReset"), .stopAndReset)
    }

    func testCorruptedStoredValueFallsBackToStopAndReset() {
        XCTAssertEqual(ModeSwitchAction(storedValue: "invalid"), .stopAndReset)
        XCTAssertEqual(ModeSwitchAction(storedValue: nil), .stopAndReset)
    }
}
