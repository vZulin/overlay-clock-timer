import CoreGraphics
import XCTest
@testable import OverlayClockTimer

final class OverlayGeometryStoreTests: XCTestCase {
    private var userDefaults: UserDefaults!
    private var suiteName: String!

    override func setUp() {
        super.setUp()
        suiteName = "OverlayGeometryStoreTests.\(UUID().uuidString)"
        userDefaults = UserDefaults(suiteName: suiteName)
        userDefaults.removePersistentDomain(forName: suiteName)
    }

    override func tearDown() {
        userDefaults.removePersistentDomain(forName: suiteName)
        userDefaults = nil
        suiteName = nil
        super.tearDown()
    }

    func testSaveAndRestoreFrame() {
        let store = OverlayGeometryStore(userDefaults: userDefaults)
        let frame = CGRect(x: 100, y: 120, width: 280, height: 160)

        store.save(frame: frame)

        let restored = store.restoreFrame(
            visibleScreenFrames: [CGRect(x: 0, y: 0, width: 1_000, height: 800)]
        )
        XCTAssertEqual(restored, frame)
    }

    func testOffScreenRestorePersistsRecoveredFrame() {
        let store = OverlayGeometryStore(userDefaults: userDefaults)
        let offScreen = CGRect(x: 2_000, y: 2_000, width: 280, height: 160)
        let screen = CGRect(x: 0, y: 0, width: 1_000, height: 800)

        store.save(frame: offScreen)
        let restored = store.restoreFrame(visibleScreenFrames: [screen])

        XCTAssertEqual(restored, CGRect(x: 360, y: 320, width: 280, height: 160))
        XCTAssertEqual(
            store.restoreFrame(visibleScreenFrames: [screen]),
            CGRect(x: 360, y: 320, width: 280, height: 160)
        )
    }

    func testDefaultCollapsedSizeAndCompactToolbarMetricsStayWithinContract() {
        XCTAssertEqual(OverlayMetrics.defaultSize, CGSize(width: 280, height: 160))
        XCTAssertEqual(OverlayPreferences.defaultWindowSize, OverlayMetrics.defaultSize)
        XCTAssertEqual(OverlayMetrics.controlButtonSize, 32)

        let timerToolbarWidth =
            OverlayMetrics.horizontalPadding * 2
            + OverlayMetrics.controlButtonSize * 6
            + OverlayMetrics.compactToolbarSpacing * 5

        XCTAssertLessThanOrEqual(timerToolbarWidth, OverlayMetrics.defaultSize.width)
    }
}
