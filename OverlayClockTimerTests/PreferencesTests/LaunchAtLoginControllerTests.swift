import XCTest
@testable import OverlayClockTimer

@MainActor
final class LaunchAtLoginControllerTests: XCTestCase {
    func testSuccessfulEnablePersistsActualRegistrationState() {
        let service = MockLaunchAtLoginService(isEnabled: false)
        let preferencesStore = TestPreferencesStore()
        let controller = LaunchAtLoginController(service: service, preferencesStore: preferencesStore)

        let didApply = controller.setEnabled(true)

        XCTAssertTrue(didApply)
        XCTAssertTrue(controller.isEnabled)
        XCTAssertTrue(preferencesStore.preferences.launchAtLoginEnabled)
        XCTAssertEqual(service.enableCount, 1)
    }

    func testFailedEnableKeepsStoredPreferenceConsistentWithActualState() {
        let service = MockLaunchAtLoginService(isEnabled: false)
        service.enableError = TestError.failed
        let preferencesStore = TestPreferencesStore()
        let controller = LaunchAtLoginController(service: service, preferencesStore: preferencesStore)

        let didApply = controller.setEnabled(true)

        XCTAssertFalse(didApply)
        XCTAssertFalse(controller.isEnabled)
        XCTAssertFalse(preferencesStore.preferences.launchAtLoginEnabled)
        XCTAssertNotNil(controller.lastError)
    }

    func testFailedDisableDoesNotClaimDisabledWhenSystemRemainsEnabled() {
        let service = MockLaunchAtLoginService(isEnabled: true)
        service.disableError = TestError.failed
        var preferences = OverlayPreferences.defaults
        preferences.launchAtLoginEnabled = true
        let preferencesStore = TestPreferencesStore(preferences: preferences)
        let controller = LaunchAtLoginController(service: service, preferencesStore: preferencesStore)

        let didApply = controller.setEnabled(false)

        XCTAssertFalse(didApply)
        XCTAssertTrue(controller.isEnabled)
        XCTAssertTrue(preferencesStore.preferences.launchAtLoginEnabled)
        XCTAssertNotNil(controller.lastError)
    }
}

private final class MockLaunchAtLoginService: LaunchAtLoginServicing {
    var isEnabled: Bool
    var enableError: Error?
    var disableError: Error?
    private(set) var enableCount = 0
    private(set) var disableCount = 0

    init(isEnabled: Bool) {
        self.isEnabled = isEnabled
    }

    func enable() throws {
        enableCount += 1
        if let enableError {
            throw enableError
        }
        isEnabled = true
    }

    func disable() throws {
        disableCount += 1
        if let disableError {
            throw disableError
        }
        isEnabled = false
    }
}

private enum TestError: Error {
    case failed
}
