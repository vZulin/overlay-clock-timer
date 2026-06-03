import AppKit
import SwiftUI

@MainActor
final class AppCoordinator: ObservableObject {
    @Published private(set) var isOverlayVisible: Bool
    @Published private(set) var isSettingsPresented: Bool
    @Published private(set) var displayMode: DisplayMode

    init(
        isOverlayVisible: Bool = false,
        isSettingsPresented: Bool = false,
        displayMode: DisplayMode = .clock
    ) {
        self.isOverlayVisible = isOverlayVisible
        self.isSettingsPresented = isSettingsPresented
        self.displayMode = displayMode
    }

    func showOverlay() {
        isOverlayVisible = true
    }

    func hideOverlay() {
        isOverlayVisible = false
    }

    func toggleOverlayVisibility() {
        isOverlayVisible.toggle()
    }

    func presentSettings() {
        isSettingsPresented = true
    }

    func dismissSettings() {
        isSettingsPresented = false
    }

    func switchDisplayMode(to mode: DisplayMode) {
        displayMode = mode
    }

    func handle(_ command: AppCommand) {
        switch command {
        case .showOverlay:
            showOverlay()
        case .hideOverlay:
            hideOverlay()
        case .toggleOverlay:
            toggleOverlayVisibility()
        case .presentSettings:
            presentSettings()
        case .switchMode(let mode):
            switchDisplayMode(to: mode)
        case .quit:
            NSApplication.shared.terminate(nil)
        }
    }
}

enum AppCommand: Equatable {
    case showOverlay
    case hideOverlay
    case toggleOverlay
    case presentSettings
    case switchMode(DisplayMode)
    case quit
}
