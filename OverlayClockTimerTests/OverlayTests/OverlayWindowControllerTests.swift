import AppKit
import XCTest
@testable import OverlayClockTimer

@MainActor
final class OverlayWindowControllerTests: XCTestCase {
    func testCreatesBorderlessFloatingTransparentWindow() throws {
        let store = RecordingOverlayGeometryStore(restoredFrame: CGRect(x: 20, y: 30, width: 280, height: 160))
        let controller = OverlayWindowController(
            geometryStore: store,
            visibleScreenFramesProvider: { [CGRect(x: 0, y: 0, width: 1_000, height: 800)] },
            contentViewProvider: { NSView(frame: CGRect(x: 0, y: 0, width: 280, height: 160)) }
        )

        controller.show()

        let window = try XCTUnwrap(controller.window)
        XCTAssertEqual(window.styleMask, .borderless)
        XCTAssertEqual(window.level, .floating)
        XCTAssertFalse(window.isOpaque)
        XCTAssertEqual(window.backgroundColor, .clear)
        XCTAssertTrue(window.hasShadow)
        XCTAssertTrue(window.collectionBehavior.contains(.canJoinAllSpaces))
        XCTAssertTrue(window.collectionBehavior.contains(.fullScreenAuxiliary))
    }

    func testShowHideMaintainsSingleWindowInstance() {
        let store = RecordingOverlayGeometryStore(restoredFrame: CGRect(x: 20, y: 30, width: 280, height: 160))
        let controller = OverlayWindowController(
            geometryStore: store,
            visibleScreenFramesProvider: { [CGRect(x: 0, y: 0, width: 1_000, height: 800)] },
            contentViewProvider: { NSView(frame: CGRect(x: 0, y: 0, width: 280, height: 160)) }
        )

        controller.show()
        let firstWindow = controller.window
        controller.hide()
        controller.show()

        XCTAssertTrue(controller.isOverlayVisible)
        XCTAssertTrue(firstWindow === controller.window)
    }

    func testShowRestoresSavedFrame() throws {
        let frame = CGRect(x: 120, y: 140, width: 300, height: 180)
        let store = RecordingOverlayGeometryStore(restoredFrame: frame)
        let controller = OverlayWindowController(
            geometryStore: store,
            visibleScreenFramesProvider: { [CGRect(x: 0, y: 0, width: 1_000, height: 800)] },
            contentViewProvider: { NSView(frame: frame) }
        )

        controller.show()

        XCTAssertEqual(try XCTUnwrap(controller.window).frame, frame)
        XCTAssertEqual(store.lastVisibleScreenFrames, [CGRect(x: 0, y: 0, width: 1_000, height: 800)])
        XCTAssertEqual(store.lastDefaultSize, OverlayPreferences.defaultWindowSize)
    }

    func testMovingWindowPersistsFrame() throws {
        let initialFrame = CGRect(x: 20, y: 30, width: 280, height: 160)
        let movedFrame = CGRect(x: 200, y: 220, width: 280, height: 160)
        let store = RecordingOverlayGeometryStore(restoredFrame: initialFrame)
        let controller = OverlayWindowController(
            geometryStore: store,
            visibleScreenFramesProvider: { [CGRect(x: 0, y: 0, width: 1_000, height: 800)] },
            contentViewProvider: { NSView(frame: initialFrame) }
        )

        controller.show()
        try XCTUnwrap(controller.window).setFrame(movedFrame, display: false)
        controller.windowDidMove(Notification(name: NSWindow.didMoveNotification))

        XCTAssertEqual(store.savedFrames.last, movedFrame)
    }
}

private final class RecordingOverlayGeometryStore: OverlayGeometryStoring {
    private let restoredFrame: CGRect
    private(set) var lastVisibleScreenFrames: [CGRect] = []
    private(set) var lastDefaultSize: CGSize?
    private(set) var savedFrames: [CGRect] = []

    init(restoredFrame: CGRect) {
        self.restoredFrame = restoredFrame
    }

    func save(frame: CGRect) {
        savedFrames.append(frame)
    }

    func restoreFrame(visibleScreenFrames: [CGRect], defaultSize: CGSize) -> CGRect {
        lastVisibleScreenFrames = visibleScreenFrames
        lastDefaultSize = defaultSize
        return restoredFrame
    }
}
