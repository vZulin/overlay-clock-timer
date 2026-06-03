import XCTest
@testable import OverlayClockTimer

final class TimeSourceTests: XCTestCase {
    func testManualWallClockReturnsInjectedDateAndCanAdvance() {
        let initialDate = Date(timeIntervalSince1970: 1_800)
        let source = ManualWallClockTimeSource(now: initialDate)

        XCTAssertEqual(source.now, initialDate)

        source.advance(by: 2.5)

        XCTAssertEqual(source.now, initialDate.addingTimeInterval(2.5))
    }

    func testManualMonotonicSourceNeverMovesBelowZero() {
        let source = ManualMonotonicTimeSource(now: 3)

        source.advance(by: -10)

        XCTAssertEqual(source.now, 0)
    }

    func testSystemTimeSourcesProduceValues() {
        XCTAssertNotNil(SystemWallClockTimeSource().now)
        XCTAssertGreaterThanOrEqual(SystemMonotonicTimeSource().now, 0)
    }
}
