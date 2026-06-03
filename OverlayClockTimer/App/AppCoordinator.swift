import AppKit
import SwiftUI

@MainActor
final class AppCoordinator: ObservableObject {
    @Published private(set) var isOverlayVisible: Bool
    @Published private(set) var isSettingsPresented: Bool
    @Published private(set) var displayMode: DisplayMode

    let clockDisplayModel: ClockDisplayModel

    private let preferencesStore: PreferencesStore
    private let geometryStore: OverlayGeometryStoring

    private lazy var overlayWindowController: OverlayWindowController = {
        OverlayWindowController(geometryStore: geometryStore) { [weak self] in
            guard let self else {
                return NSView(frame: CGRect(origin: .zero, size: OverlayPreferences.defaultWindowSize))
            }

            return NSHostingView(
                rootView: OverlayRootView(
                    coordinator: self,
                    clockDisplayModel: clockDisplayModel,
                    preferences: preferencesStore.preferences
                )
            )
        }
    }()

    init(
        isOverlayVisible: Bool = false,
        isSettingsPresented: Bool = false,
        displayMode: DisplayMode = .clock,
        launchOverlayOnStart: Bool = false,
        preferencesStore: PreferencesStore = UserDefaultsPreferencesStore(),
        geometryStore: OverlayGeometryStoring = OverlayGeometryStore(),
        clockDisplayModel: ClockDisplayModel = ClockDisplayModel()
    ) {
        self.preferencesStore = preferencesStore
        self.geometryStore = geometryStore
        self.clockDisplayModel = clockDisplayModel
        self.isOverlayVisible = false
        self.isSettingsPresented = isSettingsPresented
        self.displayMode = preferencesStore.preferences.lastDisplayMode ?? displayMode

        if isOverlayVisible || launchOverlayOnStart {
            Task { @MainActor [weak self] in
                self?.showOverlay()
            }
        }
    }

    func showOverlay() {
        isOverlayVisible = true
        clockDisplayModel.start()
        overlayWindowController.show()
    }

    func hideOverlay() {
        isOverlayVisible = false
        clockDisplayModel.stop()
        overlayWindowController.hide()
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
        var preferences = preferencesStore.preferences
        preferences.lastDisplayMode = mode
        preferencesStore.save(preferences)
    }

    func quit() {
        NSApplication.shared.terminate(nil)
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
            quit()
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
