import XCTest
@testable import OverlayClockTimer

@MainActor
final class TimerSessionStoreTests: XCTestCase {
    func testUsesInjectedMonotonicTimeForLiveElapsedDisplay() {
        let timeSource = ManualMonotonicTimeSource(now: 10)
        let store = TimerSessionStore(timeSource: timeSource, ticker: DisplayTicker(maximumFramesPerSecond: 1))

        store.start()
        timeSource.advance(by: 1.234)
        store.refresh()

        XCTAssertEqual(store.elapsedDisplayText, "00:00:01.234")
    }

    func testDerivesButtonStatesForIdleRunningPausedAndReset() {
        let timeSource = ManualMonotonicTimeSource()
        let store = TimerSessionStore(timeSource: timeSource, ticker: DisplayTicker(maximumFramesPerSecond: 1))

        XCTAssertTrue(store.canStart)
        XCTAssertFalse(store.canPause)
        XCTAssertFalse(store.canStopReset)
        XCTAssertFalse(store.canLoop)

        store.start()
        XCTAssertFalse(store.canStart)
        XCTAssertTrue(store.canPause)
        XCTAssertTrue(store.canStopReset)
        XCTAssertTrue(store.canLoop)

        timeSource.advance(by: 1)
        store.pause()
        XCTAssertTrue(store.canStart)
        XCTAssertFalse(store.canPause)
        XCTAssertTrue(store.canStopReset)
        XCTAssertFalse(store.canLoop)

        store.stopReset()
        XCTAssertTrue(store.canStart)
        XCTAssertFalse(store.canPause)
        XCTAssertFalse(store.canStopReset)
        XCTAssertFalse(store.canLoop)
    }

    func testFormatsLatestLoopAsSecondaryDisplayWhileMainTimerContinues() {
        let timeSource = ManualMonotonicTimeSource()
        let store = TimerSessionStore(timeSource: timeSource, ticker: DisplayTicker(maximumFramesPerSecond: 1))

        store.start()
        timeSource.advance(by: 1.111)
        store.loop()
        timeSource.advance(by: 2.222)
        store.refresh()

        XCTAssertEqual(store.latestLoopDisplayText, "00:00:01.111")
        XCTAssertEqual(store.elapsedDisplayText, "00:00:03.333")
    }

    func testPausePreservesLatestLoopAndStopResetClearsIt() {
        let timeSource = ManualMonotonicTimeSource()
        let store = TimerSessionStore(timeSource: timeSource, ticker: DisplayTicker(maximumFramesPerSecond: 1))

        store.start()
        timeSource.advance(by: 1.5)
        store.loop()
        store.pause()

        XCTAssertEqual(store.latestLoopDisplayText, "00:00:01.500")

        store.stopReset()

        XCTAssertNil(store.latestLoopDisplayText)
        XCTAssertEqual(store.elapsedDisplayText, "00:00:00.000")
    }
}
