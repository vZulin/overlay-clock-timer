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
}
