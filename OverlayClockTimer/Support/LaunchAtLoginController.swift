import Foundation
import ServiceManagement

protocol LaunchAtLoginServicing: AnyObject {
    var isEnabled: Bool { get }

    func enable() throws
    func disable() throws
}

@MainActor
final class LaunchAtLoginController: ObservableObject {
    @Published private(set) var isEnabled: Bool
    @Published private(set) var lastError: String?

    private let service: LaunchAtLoginServicing
    private let preferencesStore: PreferencesStore

    init(
        service: LaunchAtLoginServicing = ServiceManagementLaunchAtLoginService(),
        preferencesStore: PreferencesStore
    ) {
        self.service = service
        self.preferencesStore = preferencesStore
        self.isEnabled = service.isEnabled
        persistActualState()
    }

    @discardableResult
    func setEnabled(_ enabled: Bool) -> Bool {
        do {
            if enabled {
                try service.enable()
            } else {
                try service.disable()
            }
            lastError = nil
            persistActualState()
            return service.isEnabled == enabled
        } catch {
            lastError = error.localizedDescription
            persistActualState()
            return false
        }
    }

    private func persistActualState() {
        isEnabled = service.isEnabled
        var preferences = preferencesStore.preferences
        preferences.launchAtLoginEnabled = isEnabled
        preferencesStore.save(preferences)
    }
}

final class ServiceManagementLaunchAtLoginService: LaunchAtLoginServicing {
    var isEnabled: Bool {
        SMAppService.mainApp.status == .enabled
    }

    func enable() throws {
        guard !isEnabled else {
            return
        }
        try SMAppService.mainApp.register()
    }

    func disable() throws {
        guard isEnabled else {
            return
        }
        try SMAppService.mainApp.unregister()
    }
}
