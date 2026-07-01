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

    func testResetTimerCanDisplayEpochMilliseconds() {
        let store = TimerSessionStore(
            timeFormat: .epochMilliseconds,
            ticker: DisplayTicker(maximumFramesPerSecond: 1)
        )

        XCTAssertEqual(store.elapsedDisplayText, "0000000000000")
        XCTAssertNil(store.latestLoopDisplayText)

        store.apply(timeFormat: .standardMilliseconds)

        XCTAssertEqual(store.elapsedDisplayText, "00:00:00.000")
        XCTAssertNil(store.latestLoopDisplayText)
        XCTAssertTrue(store.canStart)
    }

    func testRunningTimerFormatSwitchDoesNotPauseResetOrRestart() {
        let timeSource = ManualMonotonicTimeSource(now: 20)
        let store = TimerSessionStore(timeSource: timeSource, ticker: DisplayTicker(maximumFramesPerSecond: 1))

        store.start()
        timeSource.advance(by: 1.25)
        store.refresh()

        XCTAssertEqual(store.elapsedDisplayText, "00:00:01.250")

        store.apply(timeFormat: .epochMilliseconds)

        assertRunningSession(store.session, startedAt: 20, accumulatedElapsed: 0)
        XCTAssertEqual(store.elapsedDisplayText, "0000000001250")
        XCTAssertTrue(store.canPause)
        XCTAssertTrue(store.canStopReset)
        XCTAssertTrue(store.canLoop)

        timeSource.advance(by: 0.125)
        store.apply(timeFormat: .standardMilliseconds)

        assertRunningSession(store.session, startedAt: 20, accumulatedElapsed: 0)
        XCTAssertEqual(store.elapsedDisplayText, "00:00:01.375")
    }

    func testPausedTimerFormatSwitchKeepsPausedElapsedValue() {
        let timeSource = ManualMonotonicTimeSource()
        let store = TimerSessionStore(timeSource: timeSource, ticker: DisplayTicker(maximumFramesPerSecond: 1))

        store.start()
        timeSource.advance(by: 2.5)
        store.pause()
        timeSource.advance(by: 10)

        store.apply(timeFormat: .epochMilliseconds)

        XCTAssertTrue(store.session.isPaused)
        XCTAssertEqual(store.elapsedDisplayText, "0000000002500")
        XCTAssertTrue(store.canStart)
        XCTAssertFalse(store.canPause)
        XCTAssertTrue(store.canStopReset)

        timeSource.advance(by: 10)
        store.apply(timeFormat: .standardMilliseconds)

        XCTAssertTrue(store.session.isPaused)
        XCTAssertEqual(store.elapsedDisplayText, "00:00:02.500")
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

    func testLatestLoopReformatsWithoutChangingCapturedElapsedValue() {
        let timeSource = ManualMonotonicTimeSource()
        let store = TimerSessionStore(timeSource: timeSource, ticker: DisplayTicker(maximumFramesPerSecond: 1))

        store.start()
        timeSource.advance(by: 1.25)
        store.loop()
        timeSource.advance(by: 2.125)

        store.apply(timeFormat: .epochMilliseconds)

        XCTAssertTrue(store.session.isRunning)
        XCTAssertEqual(store.latestLoopDisplayText, "0000000001250")
        XCTAssertEqual(store.elapsedDisplayText, "0000000003375")

        store.apply(timeFormat: .standardMilliseconds)

        XCTAssertTrue(store.session.isRunning)
        XCTAssertEqual(store.latestLoopDisplayText, "00:00:01.250")
        XCTAssertEqual(store.elapsedDisplayText, "00:00:03.375")
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

    func testModeSwitchContinueKeepsRunningTimer() {
        let timeSource = ManualMonotonicTimeSource()
        let store = TimerSessionStore(timeSource: timeSource, ticker: DisplayTicker(maximumFramesPerSecond: 1))

        store.start()
        timeSource.advance(by: 1.25)
        store.applyModeSwitchAction(.continue)
        timeSource.advance(by: 0.75)
        store.refresh()

        XCTAssertTrue(store.session.isRunning)
        XCTAssertEqual(store.elapsedDisplayText, "00:00:02.000")
    }

    func testModeSwitchPauseFreezesRunningTimer() {
        let timeSource = ManualMonotonicTimeSource()
        let store = TimerSessionStore(timeSource: timeSource, ticker: DisplayTicker(maximumFramesPerSecond: 1))

        store.start()
        timeSource.advance(by: 1.5)
        store.applyModeSwitchAction(.pause)
        timeSource.advance(by: 10)
        store.refresh()

        XCTAssertTrue(store.session.isPaused)
        XCTAssertEqual(store.elapsedDisplayText, "00:00:01.500")
        XCTAssertTrue(store.canStart)
        XCTAssertFalse(store.canPause)
    }

    func testModeSwitchStopAndResetClearsRunningTimerAndLatestLoop() {
        let timeSource = ManualMonotonicTimeSource()
        let store = TimerSessionStore(timeSource: timeSource, ticker: DisplayTicker(maximumFramesPerSecond: 1))

        store.start()
        timeSource.advance(by: 0.5)
        store.loop()
        store.applyModeSwitchAction(.stopAndReset)

        XCTAssertTrue(store.session.isReset)
        XCTAssertEqual(store.elapsedDisplayText, "00:00:00.000")
        XCTAssertNil(store.latestLoopDisplayText)
        XCTAssertTrue(store.canStart)
        XCTAssertFalse(store.canStopReset)
        XCTAssertFalse(store.canLoop)
    }

    func testDefaultModeSwitchActionStopsAndResetsRunningTimer() {
        let timeSource = ManualMonotonicTimeSource()
        let store = TimerSessionStore(timeSource: timeSource, ticker: DisplayTicker(maximumFramesPerSecond: 1))

        store.start()
        timeSource.advance(by: 0.25)
        store.applyModeSwitchAction(ModeSwitchAction.defaultValue)

        XCTAssertTrue(store.session.isReset)
        XCTAssertEqual(store.elapsedDisplayText, "00:00:00.000")
    }

    func testRepeatedRunningFormatSwitchesKeepSessionContinuousAcrossTrials() {
        for trial in 1...10 {
            let initialNow = TimeInterval(trial * 10)
            let timeSource = ManualMonotonicTimeSource(now: initialNow)
            let store = TimerSessionStore(
                timeSource: timeSource,
                ticker: DisplayTicker(maximumFramesPerSecond: 1)
            )

            store.start()

            for switchIndex in 1...10 {
                timeSource.advance(by: 0.125)
                let nextFormat: TimeFormatPreference = switchIndex.isMultiple(of: 2)
                    ? .standardMilliseconds
                    : .epochMilliseconds

                store.apply(timeFormat: nextFormat)

                assertRunningSession(store.session, startedAt: initialNow, accumulatedElapsed: 0)
                XCTAssertEqual(
                    store.session.elapsed(at: timeSource.now),
                    TimeInterval(switchIndex) * 0.125,
                    accuracy: 0.001,
                    "Trial \(trial), switch \(switchIndex) changed timer continuity."
                )
            }

            store.refresh()

            XCTAssertTrue(store.session.isRunning)
            XCTAssertEqual(store.session.elapsed(at: timeSource.now), 1.25, accuracy: 0.001)
            XCTAssertEqual(store.elapsedDisplayText, "00:00:01.250")
        }
    }

    private func assertRunningSession(
        _ session: TimerSession,
        startedAt: TimeInterval,
        accumulatedElapsed: TimeInterval,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        guard case .running(let actualStartedAt, let actualAccumulatedElapsed, _) = session.state else {
            XCTFail("Expected a running timer session.", file: file, line: line)
            return
        }

        XCTAssertEqual(actualStartedAt, startedAt, accuracy: 0.001, file: file, line: line)
        XCTAssertEqual(actualAccumulatedElapsed, accumulatedElapsed, accuracy: 0.001, file: file, line: line)
    }
}
