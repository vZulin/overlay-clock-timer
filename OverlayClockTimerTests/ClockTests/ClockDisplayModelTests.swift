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
}
