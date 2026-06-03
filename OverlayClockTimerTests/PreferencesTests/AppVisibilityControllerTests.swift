import AppKit
import XCTest
@testable import OverlayClockTimer

@MainActor
final class AppVisibilityControllerTests: XCTestCase {
    func testShowsDockIconWhilePreservingStatusItemInvariant() {
        let application = MockActivationPolicyApplication(policy: .accessory)
        let preferencesStore = TestPreferencesStore()
        let controller = AppVisibilityController(application: application, preferencesStore: preferencesStore)

        let didApply = controller.setShowDockIcon(true)

        XCTAssertTrue(didApply)
        XCTAssertTrue(controller.appVisibility.statusItemVisible)
        XCTAssertTrue(controller.appVisibility.showDockIcon)
        XCTAssertEqual(application.policy, .regular)
        XCTAssertTrue(preferencesStore.preferences.showDockIcon)
    }

    func testHidesDockIconWhileKeepingStatusItemVisible() {
        let application = MockActivationPolicyApplication(policy: .regular)
        var preferences = OverlayPreferences.defaults
        preferences.showDockIcon = true
        let preferencesStore = TestPreferencesStore(preferences: preferences)
        let controller = AppVisibilityController(application: application, preferencesStore: preferencesStore)

        let didApply = controller.setShowDockIcon(false)

        XCTAssertTrue(didApply)
        XCTAssertFalse(controller.appVisibility.showDockIcon)
        XCTAssertTrue(controller.appVisibility.statusItemVisible)
        XCTAssertEqual(application.policy, .accessory)
        XCTAssertFalse(preferencesStore.preferences.showDockIcon)
    }

    func testFailureKeepsStoredDockPreferenceConsistentWithCurrentPolicy() {
        let application = MockActivationPolicyApplication(policy: .accessory)
        application.shouldFail = true
        let preferencesStore = TestPreferencesStore()
        let controller = AppVisibilityController(application: application, preferencesStore: preferencesStore)

        let didApply = controller.setShowDockIcon(true)

        XCTAssertFalse(didApply)
        XCTAssertFalse(controller.appVisibility.showDockIcon)
        XCTAssertTrue(controller.appVisibility.statusItemVisible)
        XCTAssertEqual(application.policy, .accessory)
        XCTAssertFalse(preferencesStore.preferences.showDockIcon)
    }
}

private final class MockActivationPolicyApplication: AppActivationPolicyApplying {
    var policy: NSApplication.ActivationPolicy
    var shouldFail = false

    init(policy: NSApplication.ActivationPolicy) {
        self.policy = policy
    }

    func setActivationPolicy(_ activationPolicy: NSApplication.ActivationPolicy) -> Bool {
        guard !shouldFail else {
            return false
        }
        policy = activationPolicy
        return true
    }
}

final class TestPreferencesStore: PreferencesStore {
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
