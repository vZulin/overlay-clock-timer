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

    func testFormatsResetDurationAsEpochMilliseconds() {
        XCTAssertEqual(
            DurationFormatter().string(from: 0, timeFormat: .epochMilliseconds),
            "0000000000000"
        )
    }

    func testFormatsElapsedDurationAsLeftZeroPaddedEpochMilliseconds() {
        XCTAssertEqual(
            DurationFormatter().string(from: 12.345, timeFormat: .epochMilliseconds),
            "0000000012345"
        )
    }

    func testEpochMillisecondsKeepThirteenCharactersForShortDurations() {
        let timestamp = DurationFormatter().string(from: 1.234, timeFormat: .epochMilliseconds)

        XCTAssertEqual(timestamp, "0000000001234")
        XCTAssertEqual(timestamp.count, 13)
        XCTAssertTrue(timestamp.allSatisfy(\.isNumber))
    }

    func testNegativeDurationsClampToZeroInEpochMilliseconds() {
        XCTAssertEqual(
            DurationFormatter().string(from: -1.5, timeFormat: .epochMilliseconds),
            "0000000000000"
        )
    }

    func testPreservesStandardMillisecondsFormatWhenExplicitlySelected() {
        XCTAssertEqual(
            DurationFormatter().string(from: 1.234, timeFormat: .standardMilliseconds),
            "00:00:01.234"
        )
    }
}
