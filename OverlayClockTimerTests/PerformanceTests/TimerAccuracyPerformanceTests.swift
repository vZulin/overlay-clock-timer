import XCTest
@testable import OverlayClockTimer

@MainActor
final class TimerAccuracyPerformanceTests: XCTestCase {
    func testInjectedSixtySecondTimerStaysWithinFiftyMilliseconds() {
        let timeSource = ManualMonotonicTimeSource(now: 10)
        let store = TimerSessionStore(
            timeSource: timeSource,
            ticker: DisplayTicker(maximumFramesPerSecond: 1)
        )

        store.start()
        timeSource.advance(by: 60)
        store.refresh()

        XCTAssertEqual(store.elapsedDisplayText, "00:01:00.000")
        XCTAssertEqual(store.session.elapsed(at: timeSource.now), 60, accuracy: 0.050)
    }
}
