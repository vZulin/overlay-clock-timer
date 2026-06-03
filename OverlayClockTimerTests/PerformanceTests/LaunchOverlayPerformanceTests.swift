import AppKit
import XCTest
@testable import OverlayClockTimer

@MainActor
final class LaunchOverlayPerformanceTests: XCTestCase {
    func testFreshLaunchToReadableOverlayStaysUnderTwoSeconds() {
        let preferencesStore = PerformancePreferencesStore()
        let geometryStore = PerformanceGeometryStore(
            restoredFrame: CGRect(x: 120, y: 120, width: 280, height: 160)
        )
        let coordinator = AppCoordinator(
            preferencesStore: preferencesStore,
            geometryStore: geometryStore,
            clockDisplayModel: ClockDisplayModel(
                timeSource: ManualWallClockTimeSource(now: Date(timeIntervalSince1970: 3_723.456)),
                formatter: ClockFormatter(timeZone: TimeZone(secondsFromGMT: 0)!),
                ticker: DisplayTicker(maximumFramesPerSecond: 1)
            ),
            timerSessionStore: TimerSessionStore(ticker: DisplayTicker(maximumFramesPerSecond: 1))
        )

        let startedAt = Date()
        coordinator.showOverlay()
        let elapsed = Date().timeIntervalSince(startedAt)

        XCTAssertTrue(coordinator.isOverlayVisible)
        XCTAssertEqual(coordinator.clockDisplayModel.displayText, "01:02:03.456")
        XCTAssertLessThan(elapsed, 2.0)

        coordinator.hideOverlay()
    }
}

private final class PerformancePreferencesStore: PreferencesStore {
    private(set) var preferences: OverlayPreferences

    init(preferences: OverlayPreferences = OverlayPreferences.defaults) {
        self.preferences = preferences
    }

    func load() -> OverlayPreferences {
        preferences
    }

    func save(_ preferences: OverlayPreferences) {
        self.preferences = preferences.validated()
    }
}

private final class PerformanceGeometryStore: OverlayGeometryStoring {
    private let restoredFrame: CGRect
    private(set) var savedFrames: [CGRect] = []

    init(restoredFrame: CGRect) {
        self.restoredFrame = restoredFrame
    }

    func save(frame: CGRect) {
        savedFrames.append(frame)
    }

    func restoreFrame(visibleScreenFrames: [CGRect], defaultSize: CGSize) -> CGRect {
        restoredFrame
    }
}
