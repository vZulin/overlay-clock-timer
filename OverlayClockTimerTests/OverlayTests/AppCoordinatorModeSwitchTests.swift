import XCTest
@testable import OverlayClockTimer

@MainActor
final class AppCoordinatorModeSwitchTests: XCTestCase {
    func testSwitchDisplayModeAppliesDefaultStopAndResetAction() {
        let timeSource = ManualMonotonicTimeSource()
        let timerSessionStore = TimerSessionStore(
            timeSource: timeSource,
            ticker: DisplayTicker(maximumFramesPerSecond: 1)
        )
        let preferencesStore = InMemoryPreferencesStore()
        let coordinator = AppCoordinator(
            displayMode: .timer,
            preferencesStore: preferencesStore,
            timerSessionStore: timerSessionStore
        )

        timerSessionStore.start()
        timeSource.advance(by: 1.25)
        timerSessionStore.loop()

        coordinator.switchDisplayMode(to: .clock)

        XCTAssertEqual(coordinator.displayMode, .clock)
        XCTAssertTrue(timerSessionStore.session.isReset)
        XCTAssertEqual(timerSessionStore.elapsedDisplayText, "00:00:00.000")
        XCTAssertNil(timerSessionStore.latestLoopDisplayText)
        XCTAssertEqual(preferencesStore.preferences.lastDisplayMode, .clock)
    }

    func testSwitchDisplayModeCanKeepTimerRunning() {
        let timeSource = ManualMonotonicTimeSource()
        let timerSessionStore = TimerSessionStore(
            timeSource: timeSource,
            ticker: DisplayTicker(maximumFramesPerSecond: 1)
        )
        let preferencesStore = InMemoryPreferencesStore(
            preferences: preferences(timerOnModeSwitch: .continue)
        )
        let coordinator = AppCoordinator(
            displayMode: .timer,
            preferencesStore: preferencesStore,
            timerSessionStore: timerSessionStore
        )

        timerSessionStore.start()
        timeSource.advance(by: 0.75)
        coordinator.switchDisplayMode(to: .clock)
        timeSource.advance(by: 0.25)
        timerSessionStore.refresh()

        XCTAssertEqual(coordinator.displayMode, .clock)
        XCTAssertTrue(timerSessionStore.session.isRunning)
        XCTAssertEqual(timerSessionStore.elapsedDisplayText, "00:00:01.000")
    }

    func testSwitchDisplayModeCanPauseRunningTimer() {
        let timeSource = ManualMonotonicTimeSource()
        let timerSessionStore = TimerSessionStore(
            timeSource: timeSource,
            ticker: DisplayTicker(maximumFramesPerSecond: 1)
        )
        let preferencesStore = InMemoryPreferencesStore(
            preferences: preferences(timerOnModeSwitch: .pause)
        )
        let coordinator = AppCoordinator(
            displayMode: .timer,
            preferencesStore: preferencesStore,
            timerSessionStore: timerSessionStore
        )

        timerSessionStore.start()
        timeSource.advance(by: 1.5)
        coordinator.switchDisplayMode(to: .clock)
        timeSource.advance(by: 10)
        timerSessionStore.refresh()

        XCTAssertEqual(coordinator.displayMode, .clock)
        XCTAssertTrue(timerSessionStore.session.isPaused)
        XCTAssertEqual(timerSessionStore.elapsedDisplayText, "00:00:01.500")
    }

    func testSwitchingToCurrentDisplayModeDoesNotApplyTimerAction() {
        let timeSource = ManualMonotonicTimeSource()
        let timerSessionStore = TimerSessionStore(
            timeSource: timeSource,
            ticker: DisplayTicker(maximumFramesPerSecond: 1)
        )
        let preferencesStore = InMemoryPreferencesStore()
        let coordinator = AppCoordinator(
            displayMode: .timer,
            preferencesStore: preferencesStore,
            timerSessionStore: timerSessionStore
        )

        timerSessionStore.start()
        timeSource.advance(by: 1)
        coordinator.switchDisplayMode(to: .timer)

        XCTAssertTrue(timerSessionStore.session.isRunning)
        XCTAssertEqual(preferencesStore.saveCount, 0)
    }

    private func preferences(timerOnModeSwitch: ModeSwitchAction) -> OverlayPreferences {
        var preferences = OverlayPreferences.defaults
        preferences.timerOnModeSwitch = timerOnModeSwitch
        return preferences
    }
}

private final class InMemoryPreferencesStore: PreferencesStore {
    private(set) var preferences: OverlayPreferences
    private(set) var saveCount = 0

    init(preferences: OverlayPreferences = OverlayPreferences.defaults) {
        self.preferences = preferences
    }

    func load() -> OverlayPreferences {
        preferences
    }

    func save(_ preferences: OverlayPreferences) {
        saveCount += 1
        self.preferences = preferences.validated()
    }
}
