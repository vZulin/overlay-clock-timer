import XCTest
@testable import OverlayClockTimer

@MainActor
final class OverlayTickerPerformanceTests: XCTestCase {
    func testTickerUsesDisplayCadenceAndCoalescingLeeway() {
        let ticker = DisplayTicker(maximumFramesPerSecond: 240)

        XCTAssertEqual(ticker.framesPerSecond, 60)
        XCTAssertEqual(ticker.interval, 1.0 / 60.0, accuracy: 0.000_001)
        XCTAssertGreaterThanOrEqual(ticker.leeway, 0.001)
    }

    func testTimerStoreKeepsTickerStoppedWhileIdlePausedAndReset() {
        let ticker = DisplayTicker(maximumFramesPerSecond: 60)
        let timeSource = ManualMonotonicTimeSource()
        let store = TimerSessionStore(timeSource: timeSource, ticker: ticker)

        XCTAssertFalse(ticker.isRunning)

        store.start()
        XCTAssertTrue(ticker.isRunning)

        timeSource.advance(by: 1)
        store.pause()
        XCTAssertFalse(ticker.isRunning)

        store.start()
        XCTAssertTrue(ticker.isRunning)

        store.stopReset()
        XCTAssertFalse(ticker.isRunning)
    }

    func testPrimaryTimerCommandsCompleteWithinResponseBudget() {
        let timeSource = ManualMonotonicTimeSource()
        let store = TimerSessionStore(
            timeSource: timeSource,
            ticker: DisplayTicker(maximumFramesPerSecond: 60)
        )

        let startedAt = Date()
        store.start()
        timeSource.advance(by: 0.25)
        store.loop()
        store.pause()
        store.stopReset()
        let elapsed = Date().timeIntervalSince(startedAt)

        XCTAssertLessThan(elapsed, 0.150)
    }
}
