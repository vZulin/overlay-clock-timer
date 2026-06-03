import AppKit
import Foundation

@MainActor
protocol AppActivationPolicyApplying: AnyObject {
    var policy: NSApplication.ActivationPolicy { get }

    func setActivationPolicy(_ activationPolicy: NSApplication.ActivationPolicy) -> Bool
}

extension NSApplication: AppActivationPolicyApplying {
    var policy: NSApplication.ActivationPolicy {
        activationPolicy()
    }
}

@MainActor
final class AppVisibilityController: ObservableObject {
    @Published private(set) var appVisibility: AppVisibilityPreference

    private let application: AppActivationPolicyApplying
    private let preferencesStore: PreferencesStore

    init(
        application: AppActivationPolicyApplying = NSApplication.shared,
        preferencesStore: PreferencesStore
    ) {
        self.application = application
        self.preferencesStore = preferencesStore
        self.appVisibility = preferencesStore.preferences.appVisibility
        applySavedPreference()
    }

    @discardableResult
    func setShowDockIcon(_ showDockIcon: Bool) -> Bool {
        let didApply = application.setActivationPolicy(showDockIcon ? .regular : .accessory)
        let actualShowDockIcon = didApply ? showDockIcon : application.policy == .regular
        persist(showDockIcon: actualShowDockIcon)
        return didApply
    }

    private func applySavedPreference() {
        _ = setShowDockIcon(preferencesStore.preferences.showDockIcon)
    }

    private func persist(showDockIcon: Bool) {
        appVisibility = AppVisibilityPreference(showDockIcon: showDockIcon)
        var preferences = preferencesStore.preferences
        preferences.showDockIcon = showDockIcon
        preferencesStore.save(preferences)
    }
}
