import XCTest
@testable import OverlayClockTimer

final class ClockFormatterTests: XCTestCase {
    func testFormatsFixedPOSIXTimeWithMilliseconds() {
        let formatter = ClockFormatter(timeZone: TimeZone(secondsFromGMT: 0)!)
        let date = Date(timeIntervalSince1970: 3_723.456)

        XCTAssertEqual(formatter.string(from: date), "01:02:03.456")
    }

    func testUsesTwentyFourHourFormat() {
        let formatter = ClockFormatter(timeZone: TimeZone(secondsFromGMT: 0)!)
        let date = Date(timeIntervalSince1970: 45_296.789)

        XCTAssertEqual(formatter.string(from: date), "12:34:56.789")
    }

    func testFormatsWallClockDateAsEpochMilliseconds() {
        let formatter = ClockFormatter(timeZone: TimeZone(secondsFromGMT: 0)!)
        let date = Date(timeIntervalSince1970: 1_782_918_314.123)

        let timestamp = formatter.string(from: date, timeFormat: .epochMilliseconds)

        XCTAssertEqual(timestamp, "1782918314123")
        XCTAssertEqual(timestamp.count, 13)
        XCTAssertTrue(timestamp.allSatisfy(\.isNumber))
    }

    func testPreservesStandardMillisecondsFormatWhenExplicitlySelected() {
        let formatter = ClockFormatter(timeZone: TimeZone(secondsFromGMT: 0)!)
        let date = Date(timeIntervalSince1970: 1_782_918_314.123)

        XCTAssertEqual(
            formatter.string(from: date, timeFormat: .standardMilliseconds),
            "15:05:14.123"
        )
    }
}
