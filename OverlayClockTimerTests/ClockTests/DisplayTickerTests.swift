import XCTest
@testable import OverlayClockTimer

final class DisplayTickerTests: XCTestCase {
    func testDisplayCadenceIsCappedAtSixtyHertz() {
        let ticker = DisplayTicker(maximumFramesPerSecond: 120)

        XCTAssertEqual(ticker.framesPerSecond, 60)
        XCTAssertEqual(ticker.interval, 1.0 / 60.0, accuracy: 0.000_001)
    }

    func testDisplayCadenceHasLowerBound() {
        let ticker = DisplayTicker(maximumFramesPerSecond: 0)

        XCTAssertEqual(ticker.framesPerSecond, 1)
        XCTAssertEqual(ticker.interval, 1.0, accuracy: 0.000_001)
    }

    func testStopCancelsFutureTicks() {
        let ticker = DisplayTicker(maximumFramesPerSecond: 60)
        let queue = DispatchQueue(label: "DisplayTickerTests.queue")
        let lock = NSLock()
        var ticks = 0
        let didTick = expectation(description: "Ticker produced at least one tick")

        ticker.start(on: queue) {
            lock.withLock {
                ticks += 1
                if ticks == 1 {
                    didTick.fulfill()
                }
            }
        }

        wait(for: [didTick], timeout: 1)
        ticker.stop()
        let ticksAfterStop = lock.withLock { ticks }

        Thread.sleep(forTimeInterval: 0.05)

        XCTAssertFalse(ticker.isRunning)
        XCTAssertEqual(lock.withLock { ticks }, ticksAfterStop)
    }
}
