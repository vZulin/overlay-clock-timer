import AppKit
import SwiftUI

@MainActor
final class AppCoordinator: ObservableObject {
    @Published private(set) var isOverlayVisible: Bool
    @Published private(set) var isSettingsPresented: Bool
    @Published private(set) var displayMode: DisplayMode
    @Published private(set) var preferences: OverlayPreferences

    let clockDisplayModel: ClockDisplayModel
    let timerSessionStore: TimerSessionStore

    private let preferencesStore: PreferencesStore
    private let geometryStore: OverlayGeometryStoring
    private let hotkeyRegistrar: HotkeyRegistrar
    private var settingsWindow: NSWindow?

    private lazy var launchAtLoginControllerStorage = LaunchAtLoginController(
        preferencesStore: preferencesStore
    )
    private lazy var appVisibilityControllerStorage = AppVisibilityController(
        preferencesStore: preferencesStore
    )

    var launchAtLoginController: LaunchAtLoginController {
        launchAtLoginControllerStorage
    }

    var appVisibilityController: AppVisibilityController {
        appVisibilityControllerStorage
    }

    private lazy var overlayWindowController: OverlayWindowController = {
        OverlayWindowController(geometryStore: geometryStore) { [weak self] in
            guard let self else {
                return NSView(frame: CGRect(origin: .zero, size: OverlayPreferences.defaultWindowSize))
            }

            return NSHostingView(
                rootView: OverlayRootView(
                    coordinator: self,
                    clockDisplayModel: clockDisplayModel,
                    timerSessionStore: timerSessionStore
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
        clockDisplayModel: ClockDisplayModel = ClockDisplayModel(),
        timerSessionStore: TimerSessionStore = TimerSessionStore(),
        hotkeyRegistrar: HotkeyRegistrar = HotkeyRegistrar()
    ) {
        self.preferencesStore = preferencesStore
        self.geometryStore = geometryStore
        self.clockDisplayModel = clockDisplayModel
        self.timerSessionStore = timerSessionStore
        self.hotkeyRegistrar = hotkeyRegistrar
        self.preferences = preferencesStore.preferences
        self.isOverlayVisible = false
        self.isSettingsPresented = isSettingsPresented
        self.displayMode = preferencesStore.preferences.lastDisplayMode ?? displayMode
        self.hotkeyRegistrar.commandHandler = { [weak self] command in
            self?.handle(command)
        }
        self.hotkeyRegistrar.refresh(bindings: preferences.hotkeyBindings)

        if isOverlayVisible || launchOverlayOnStart {
            Task { @MainActor [weak self] in
                self?.showOverlay()
            }
        }
    }

    func showOverlay() {
        isOverlayVisible = true
        clockDisplayModel.start()
        overlayWindowController.show(defaultSize: preferences.windowSize)
        overlayWindowController.apply(preferences: preferences)
    }

    func hideOverlay() {
        isOverlayVisible = false
        clockDisplayModel.stop()
        overlayWindowController.hide()
    }

    func toggleOverlayVisibility() {
        if isOverlayVisible {
            hideOverlay()
        } else {
            showOverlay()
        }
    }

    func presentSettings() {
        isSettingsPresented = true
        let window = settingsWindow ?? makeSettingsWindow()
        settingsWindow = window
        window.makeKeyAndOrderFront(nil)
        NSApplication.shared.activate(ignoringOtherApps: true)
    }

    func dismissSettings() {
        isSettingsPresented = false
        settingsWindow?.orderOut(nil)
    }

    func switchDisplayMode(to mode: DisplayMode) {
        guard mode != displayMode else {
            return
        }

        timerSessionStore.applyModeSwitchAction(preferencesStore.preferences.timerOnModeSwitch)
        displayMode = mode
        updatePreferences { preferences in
            preferences.lastDisplayMode = mode
        }
    }

    func updatePreferences(_ update: (inout OverlayPreferences) -> Void) {
        var updatedPreferences = preferences
        update(&updatedPreferences)
        preferencesStore.save(updatedPreferences)
        preferences = preferencesStore.preferences
        applyLivePreferences()
    }

    @discardableResult
    func updateHotkeyBinding(
        _ binding: HotkeyBinding,
        replacingConflicts: Bool
    ) -> HotkeyBindingUpdateResult {
        var bindingSet = HotkeyBindingSet(preferences.hotkeyBindings)
        let result = bindingSet.update(binding, replacingConflicts: replacingConflicts)
        guard result == .accepted else {
            return result
        }

        updatePreferences { preferences in
            preferences.hotkeyBindings = bindingSet.bindings
        }
        return result
    }

    @discardableResult
    func setLaunchAtLoginEnabled(_ enabled: Bool) -> Bool {
        let didApply = launchAtLoginController.setEnabled(enabled)
        reloadPreferences()
        return didApply
    }

    @discardableResult
    func setShowDockIcon(_ showDockIcon: Bool) -> Bool {
        let didApply = appVisibilityController.setShowDockIcon(showDockIcon)
        reloadPreferences()
        return didApply
    }

    func reloadPreferences() {
        preferences = preferencesStore.load()
        applyLivePreferences()
    }

    func handle(_ command: HotkeyCommand) {
        switch command {
        case .start:
            timerSessionStore.start()
        case .pause:
            timerSessionStore.pause()
        case .stopReset:
            timerSessionStore.stopReset()
        case .loop:
            timerSessionStore.loop()
        case .switchMode:
            switchDisplayMode(to: displayMode == .clock ? .timer : .clock)
        }
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

    private func applyLivePreferences() {
        overlayWindowController.apply(preferences: preferences)
        hotkeyRegistrar.refresh(bindings: preferences.hotkeyBindings)
    }

    private func makeSettingsWindow() -> NSWindow {
        let window = NSWindow(
            contentRect: CGRect(x: 0, y: 0, width: 620, height: 460),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = SettingsWindowView.windowTitle
        window.minSize = CGSize(width: 560, height: 400)
        window.isReleasedWhenClosed = false
        window.contentView = NSHostingView(rootView: SettingsWindowView(coordinator: self))
        window.center()
        return window
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
