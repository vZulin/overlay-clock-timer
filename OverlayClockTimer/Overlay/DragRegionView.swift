import AppKit
import SwiftUI

struct DragRegionView: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        DragRegionNSView()
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}

private final class DragRegionNSView: NSView {
    override func mouseDown(with event: NSEvent) {
        window?.performDrag(with: event)
    }
}
