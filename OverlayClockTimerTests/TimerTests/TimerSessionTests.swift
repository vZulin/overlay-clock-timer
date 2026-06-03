import XCTest
@testable import OverlayClockTimer

final class TimerSessionTests: XCTestCase {
    func testStartPauseResumeAndStopResetTransitions() {
        var session = TimerSession()

        session.start(at: 10)
        XCTAssertTrue(session.isRunning)
        XCTAssertEqual(session.elapsed(at: 12.5), 2.5, accuracy: 0.000_001)

        session.pause(at: 12.5)
        XCTAssertTrue(session.isPaused)
        XCTAssertEqual(session.elapsed(at: 30), 2.5, accuracy: 0.000_001)

        session.start(at: 40)
        XCTAssertTrue(session.isRunning)
        XCTAssertEqual(session.elapsed(at: 41.25), 3.75, accuracy: 0.000_001)

        session.stopReset()
        XCTAssertTrue(session.isReset)
        XCTAssertEqual(session.elapsed(at: 100), 0, accuracy: 0.000_001)
        XCTAssertNil(session.latestLoop)
    }

    func testElapsedNeverBecomesNegativeWhenClockMovesBackwards() {
        var session = TimerSession()

        session.start(at: 10)

        XCTAssertEqual(session.elapsed(at: 8), 0, accuracy: 0.000_001)
    }

    func testLoopCaptureIsSecondaryAndMainTimerKeepsRunning() throws {
        var session = TimerSession()

        session.start(at: 0)
        session.loop(at: 1.25)

        let latestLoop = try XCTUnwrap(session.latestLoop)
        XCTAssertEqual(latestLoop.capturedElapsed, 1.25, accuracy: 0.000_001)
        XCTAssertEqual(latestLoop.capturedAt, 1.25, accuracy: 0.000_001)
        XCTAssertEqual(session.elapsed(at: 3.5), 3.5, accuracy: 0.000_001)
    }

    func testRepeatedLoopReplacesLatestLoop() throws {
        var session = TimerSession()

        session.start(at: 0)
        session.loop(at: 1)
        session.loop(at: 2.5)

        let latestLoop = try XCTUnwrap(session.latestLoop)
        XCTAssertEqual(latestLoop.capturedElapsed, 2.5, accuracy: 0.000_001)
        XCTAssertEqual(latestLoop.capturedAt, 2.5, accuracy: 0.000_001)
    }

    func testLoopIsIgnoredWhenTimerIsNotRunning() {
        var session = TimerSession()

        session.loop(at: 1)

        XCTAssertNil(session.latestLoop)
    }
}
