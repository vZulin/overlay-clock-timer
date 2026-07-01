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

    func testClockModeFormatsEpochMillisecondsAtCaptureTime() {
        let clockSource = ManualWallClockTimeSource(now: Date(timeIntervalSince1970: 1_782_918_314.000))
        let clockDisplayModel = ClockDisplayModel(
            timeSource: clockSource,
            formatter: ClockFormatter(timeZone: TimeZone(secondsFromGMT: 0)!),
            ticker: DisplayTicker(maximumFramesPerSecond: 1)
        )
        let provider = EventTimestampProvider(
            clockDisplayModel: clockDisplayModel,
            timerSessionStore: TimerSessionStore(ticker: DisplayTicker(maximumFramesPerSecond: 1))
        )

        clockSource.now = Date(timeIntervalSince1970: 1_782_918_314.123)

        XCTAssertEqual(
            provider.timestamp(for: .clock, timeFormat: .epochMilliseconds),
            "1782918314123"
        )
        XCTAssertEqual(clockDisplayModel.displayText, "15:05:14.000")
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

    func testTimerModeFormatsEpochMillisecondsAtCaptureTime() {
        let timerSource = ManualMonotonicTimeSource()
        let timerSessionStore = TimerSessionStore(
            timeSource: timerSource,
            ticker: DisplayTicker(maximumFramesPerSecond: 1)
        )
        timerSessionStore.start()
        timerSource.advance(by: 12.345)
        let provider = EventTimestampProvider(
            clockDisplayModel: ClockDisplayModel(ticker: DisplayTicker(maximumFramesPerSecond: 1)),
            timerSessionStore: timerSessionStore
        )

        XCTAssertEqual(
            provider.timestamp(for: .timer, timeFormat: .epochMilliseconds),
            "0000000012345"
        )
        XCTAssertEqual(timerSessionStore.elapsedDisplayText, "00:00:00.000")
    }

    func testTimerModeUsesZeroWhenTimerHasNotStarted() {
        let provider = EventTimestampProvider(
            clockDisplayModel: ClockDisplayModel(ticker: DisplayTicker(maximumFramesPerSecond: 1)),
            timerSessionStore: TimerSessionStore(ticker: DisplayTicker(maximumFramesPerSecond: 1))
        )

        XCTAssertEqual(provider.timestamp(for: .timer), "00:00:00.000")
    }
}
