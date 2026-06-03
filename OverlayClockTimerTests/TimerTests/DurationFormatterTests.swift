import XCTest
@testable import OverlayClockTimer

final class DurationFormatterTests: XCTestCase {
    func testFormatsZeroDuration() {
        XCTAssertEqual(DurationFormatter().string(from: 0), "00:00:00.000")
    }

    func testFormatsMilliseconds() {
        XCTAssertEqual(DurationFormatter().string(from: 1.234), "00:00:01.234")
    }

    func testFormatsHourRolloverWithoutDayWrapping() {
        XCTAssertEqual(DurationFormatter().string(from: 27 * 3_600 + 1.007), "27:00:01.007")
    }

    func testNegativeDurationsClampToZero() {
        XCTAssertEqual(DurationFormatter().string(from: -1.5), "00:00:00.000")
    }
}
