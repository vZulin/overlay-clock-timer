import XCTest
@testable import OverlayClockTimer

@MainActor
final class EventTimestampProviderTests: XCTestCase {
    func testClockModeUsesClockDisplayTextWithMilliseconds() {
        let clockSource = ManualWallClockTimeSource(now: Date(timeIntervalSince1970: 45_296.789))
        let clockDisplayModel = ClockDisplayModel(
            timeSource: clockSource,
            formatter: ClockFormatter(timeZone: TimeZone(secondsFromGMT: 0)!),
            ticker: DisplayTicker(maximumFramesPerSecond: 1)
        )
        let provider = EventTimestampProvider(
            clockDisplayModel: clockDisplayModel,
            timerSessionStore: TimerSessionStore(ticker: DisplayTicker(maximumFramesPerSecond: 1))
        )

        XCTAssertEqual(provider.timestamp(for: .clock), "12:34:56.789")
    }

    func testTimerModeUsesCurrentTimerDisplayText() {
        let timerSource = ManualMonotonicTimeSource()
        let timerSessionStore = TimerSessionStore(
            timeSource: timerSource,
            ticker: DisplayTicker(maximumFramesPerSecond: 1)
        )
        timerSessionStore.start()
        timerSource.advance(by: 62.345)
        timerSessionStore.refresh()
        let provider = EventTimestampProvider(
            clockDisplayModel: ClockDisplayModel(ticker: DisplayTicker(maximumFramesPerSecond: 1)),
            timerSessionStore: timerSessionStore
        )

        XCTAssertEqual(provider.timestamp(for: .timer), "00:01:02.345")
    }

    func testTimerModeUsesZeroWhenTimerHasNotStarted() {
        let provider = EventTimestampProvider(
            clockDisplayModel: ClockDisplayModel(ticker: DisplayTicker(maximumFramesPerSecond: 1)),
            timerSessionStore: TimerSessionStore(ticker: DisplayTicker(maximumFramesPerSecond: 1))
        )

        XCTAssertEqual(provider.timestamp(for: .timer), "00:00:00.000")
    }
}
