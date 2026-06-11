import AppKit
import SwiftUI

protocol OverlayGeometryStoring: AnyObject {
    func save(frame: CGRect)
    func restoreFrame(visibleScreenFrames: [CGRect], defaultSize: CGSize) -> CGRect
}

extension OverlayGeometryStore: OverlayGeometryStoring {}

@MainActor
final class OverlayWindowController: NSObject, NSWindowDelegate {
    static let windowTitle = "Overlay Clock Timer Overlay"

    private let geometryStore: OverlayGeometryStoring
    private let visibleScreenFramesProvider: () -> [CGRect]
    private let contentViewProvider: () -> NSView
    private var defaultSize: CGSize

    private(set) var window: NSWindow?

    init(
        geometryStore: OverlayGeometryStoring = OverlayGeometryStore(),
        visibleScreenFramesProvider: @escaping () -> [CGRect] = {
            NSScreen.screens.map(\.visibleFrame)
        },
        defaultSize: CGSize = OverlayPreferences.defaultWindowSize,
        contentViewProvider: @escaping () -> NSView
    ) {
        self.geometryStore = geometryStore
        self.visibleScreenFramesProvider = visibleScreenFramesProvider
        self.defaultSize = defaultSize
        self.contentViewProvider = contentViewProvider
    }

    var isOverlayVisible: Bool {
        window?.isVisible == true
    }

    func show(defaultSize: CGSize? = nil) {
        if let defaultSize {
            self.defaultSize = defaultSize
        }

        let overlayWindow = window ?? makeWindow()
        let restoredFrame = geometryStore.restoreFrame(
            visibleScreenFrames: visibleScreenFramesProvider(),
            defaultSize: self.defaultSize
        )

        overlayWindow.setFrame(restoredFrame, display: true)
        overlayWindow.orderFrontRegardless()
    }

    func hide() {
        window?.orderOut(nil)
    }

    func persistCurrentFrame() {
        guard let window else {
            return
        }

        geometryStore.save(frame: window.frame)
    }

    func apply(preferences: OverlayPreferences) {
        apply(preferences: preferences, isLoggingPanelOpen: false)
    }

    func apply(preferences: OverlayPreferences, isLoggingPanelOpen: Bool) {
        defaultSize = preferences.windowSize
        guard let window else {
            return
        }

        window.minSize = OverlayPreferences.minimumWindowSize
        window.maxSize = isLoggingPanelOpen
            ? OverlayMetrics.maximumExpandedSize
            : OverlayPreferences.maximumWindowSize

        let targetSize = targetWindowSize(
            preferences: preferences,
            isLoggingPanelOpen: isLoggingPanelOpen
        )

        guard window.frame.size != targetSize else {
            return
        }

        var frame = window.frame
        let maxY = frame.maxY
        frame.size = targetSize
        frame.origin.y = maxY - targetSize.height
        window.setFrame(frame, display: true)
        if !isLoggingPanelOpen {
            geometryStore.save(frame: frame)
        }
    }

    func windowDidMove(_ notification: Notification) {
        persistCurrentFrame()
    }

    func windowDidEndLiveResize(_ notification: Notification) {
        persistCurrentFrame()
    }

    func windowWillClose(_ notification: Notification) {
        persistCurrentFrame()
    }

    private func makeWindow() -> NSWindow {
        let frame = geometryStore.restoreFrame(
            visibleScreenFrames: visibleScreenFramesProvider(),
            defaultSize: defaultSize
        )
        let overlayWindow = OverlayPanelWindow(
            contentRect: frame,
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )
        let contentView = contentViewProvider()
        contentView.frame = CGRect(origin: .zero, size: frame.size)

        overlayWindow.title = Self.windowTitle
        overlayWindow.level = .floating
        overlayWindow.isOpaque = false
        overlayWindow.backgroundColor = .clear
        overlayWindow.hasShadow = true
        overlayWindow.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        overlayWindow.minSize = OverlayPreferences.minimumWindowSize
        overlayWindow.maxSize = OverlayMetrics.maximumExpandedSize
        overlayWindow.isReleasedWhenClosed = false
        overlayWindow.contentView = contentView
        overlayWindow.delegate = self

        window = overlayWindow
        return overlayWindow
    }

    private func targetWindowSize(
        preferences: OverlayPreferences,
        isLoggingPanelOpen: Bool
    ) -> CGSize {
        guard isLoggingPanelOpen else {
            return preferences.windowSize
        }

        return CGSize(
            width: preferences.windowSize.width,
            height: min(
                preferences.windowSize.height + OverlayMetrics.inputLoggingExpandedHeightDelta,
                OverlayMetrics.maximumExpandedSize.height
            )
        )
    }
}

private final class OverlayPanelWindow: NSWindow {
    override var canBecomeKey: Bool {
        true
    }
}
