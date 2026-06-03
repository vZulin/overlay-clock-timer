import AppKit
import XCTest
@testable import OverlayClockTimer

@MainActor
final class PreferenceApplicationPerformanceTests: XCTestCase {
    func testLiveAppearancePreferenceChangesApplyUnderOneSecond() throws {
        let preferencesStore = LivePreferencesStore()
        let geometryStore = LivePreferenceGeometryStore(
            restoredFrame: CGRect(x: 80, y: 80, width: 280, height: 160)
        )
        let coordinator = AppCoordinator(
            preferencesStore: preferencesStore,
            geometryStore: geometryStore,
            clockDisplayModel: ClockDisplayModel(ticker: DisplayTicker(maximumFramesPerSecond: 1)),
            timerSessionStore: TimerSessionStore(ticker: DisplayTicker(maximumFramesPerSecond: 1))
        )

        coordinator.showOverlay()

        let startedAt = Date()
        coordinator.updatePreferences { preferences in
            preferences.theme = .dark
            preferences.backgroundOpacity = 0.66
            preferences.windowSize = CGSize(width: 360, height: 210)
            preferences.timerFontSize = 42
        }
        let elapsed = Date().timeIntervalSince(startedAt)

        XCTAssertEqual(coordinator.preferences.theme, .dark)
        XCTAssertEqual(coordinator.preferences.backgroundOpacity, 0.66)
        XCTAssertEqual(coordinator.preferences.windowSize, CGSize(width: 360, height: 210))
        XCTAssertEqual(coordinator.preferences.timerFontSize, 42)
        XCTAssertLessThan(elapsed, 1.0)

        let appliedFrame = try XCTUnwrap(geometryStore.savedFrames.last)
        XCTAssertEqual(appliedFrame.size, CGSize(width: 360, height: 210))

        coordinator.hideOverlay()
    }
}

private final class LivePreferencesStore: PreferencesStore {
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

private final class LivePreferenceGeometryStore: OverlayGeometryStoring {
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
