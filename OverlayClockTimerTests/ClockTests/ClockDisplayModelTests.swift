import XCTest
@testable import OverlayClockTimer

@MainActor
final class ClockDisplayModelTests: XCTestCase {
    func testInitialDisplayUsesInjectedWallClockDate() {
        let source = ManualWallClockTimeSource(now: Date(timeIntervalSince1970: 3_723.456))
        let model = ClockDisplayModel(
            timeSource: source,
            formatter: ClockFormatter(timeZone: TimeZone(secondsFromGMT: 0)!),
            ticker: DisplayTicker()
        )

        XCTAssertEqual(model.displayText, "01:02:03.456")
    }

    func testRefreshUsesLatestInjectedWallClockDate() {
        let source = ManualWallClockTimeSource(now: Date(timeIntervalSince1970: 3_723.456))
        let model = ClockDisplayModel(
            timeSource: source,
            formatter: ClockFormatter(timeZone: TimeZone(secondsFromGMT: 0)!),
            ticker: DisplayTicker()
        )

        source.now = Date(timeIntervalSince1970: 45_296.789)
        model.refresh()

        XCTAssertEqual(model.displayText, "12:34:56.789")
    }

    func testApplyingEpochFormatRefreshesDisplayWithoutChangingTimeSource() {
        let date = Date(timeIntervalSince1970: 1_782_918_314.123)
        let source = ManualWallClockTimeSource(now: date)
        let model = ClockDisplayModel(
            timeSource: source,
            formatter: ClockFormatter(timeZone: TimeZone(secondsFromGMT: 0)!),
            ticker: DisplayTicker()
        )

        model.apply(timeFormat: .epochMilliseconds)

        XCTAssertEqual(source.now, date)
        XCTAssertEqual(model.displayText, "1782918314123")
    }

    func testApplyingStandardFormatRefreshesDisplayWithoutChangingTimeSource() {
        let date = Date(timeIntervalSince1970: 1_782_918_314.123)
        let source = ManualWallClockTimeSource(now: date)
        let model = ClockDisplayModel(
            timeSource: source,
            formatter: ClockFormatter(timeZone: TimeZone(secondsFromGMT: 0)!),
            ticker: DisplayTicker()
        )

        model.apply(timeFormat: .epochMilliseconds)
        model.apply(timeFormat: .standardMilliseconds)

        XCTAssertEqual(source.now, date)
        XCTAssertEqual(model.displayText, "15:05:14.123")
    }

    func testRefreshUsesCurrentTimeFormatWithLatestWallClockDate() {
        let source = ManualWallClockTimeSource(now: Date(timeIntervalSince1970: 1_782_918_314.123))
        let model = ClockDisplayModel(
            timeSource: source,
            formatter: ClockFormatter(timeZone: TimeZone(secondsFromGMT: 0)!),
            ticker: DisplayTicker()
        )

        model.apply(timeFormat: .epochMilliseconds)
        source.now = Date(timeIntervalSince1970: 1_782_918_315.987)
        model.refresh()

        XCTAssertEqual(model.displayText, "1782918315987")
    }
}
