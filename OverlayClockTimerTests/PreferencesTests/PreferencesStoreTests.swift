import XCTest
@testable import OverlayClockTimer

final class PreferencesStoreTests: XCTestCase {
    private var userDefaults: UserDefaults!
    private var suiteName: String!

    override func setUp() {
        super.setUp()
        suiteName = "PreferencesStoreTests.\(UUID().uuidString)"
        userDefaults = UserDefaults(suiteName: suiteName)
        userDefaults.removePersistentDomain(forName: suiteName)
    }

    override func tearDown() {
        userDefaults.removePersistentDomain(forName: suiteName)
        userDefaults = nil
        suiteName = nil
        super.tearDown()
    }

    func testLoadsDefaultPreferences() {
        let store = UserDefaultsPreferencesStore(userDefaults: userDefaults)

        XCTAssertEqual(store.preferences, OverlayPreferences.defaults)
        XCTAssertTrue(store.preferences.appVisibility.statusItemVisible)
        XCTAssertFalse(store.preferences.showDockIcon)
        XCTAssertEqual(store.preferences.eventTableRowLimit, OverlayPreferences.defaultEventTableRowLimit)
        XCTAssertFalse(store.preferences.preserveEventTableBetweenOpens)
    }

    func testClampsOutOfRangeAppearanceValues() {
        userDefaults.set(2.0, forKey: UserDefaultsPreferencesStore.Keys.backgroundOpacity)
        userDefaults.set(100, forKey: UserDefaultsPreferencesStore.Keys.windowWidth)
        userDefaults.set(1_000, forKey: UserDefaultsPreferencesStore.Keys.windowHeight)
        userDefaults.set(1_000, forKey: UserDefaultsPreferencesStore.Keys.timerFontSize)

        let preferences = UserDefaultsPreferencesStore(userDefaults: userDefaults).preferences

        XCTAssertEqual(preferences.backgroundOpacity, OverlayPreferences.maximumBackgroundOpacity)
        XCTAssertEqual(preferences.windowSize.width, OverlayPreferences.minimumWindowSize.width)
        XCTAssertEqual(preferences.windowSize.height, OverlayPreferences.maximumWindowSize.height)
        XCTAssertLessThanOrEqual(preferences.timerFontSize, OverlayPreferences.maximumTimerFontSize)
    }

    func testCorruptedValuesFallBackToSafeDefaults() {
        userDefaults.set("invalid", forKey: UserDefaultsPreferencesStore.Keys.theme)
        userDefaults.set("invalid", forKey: UserDefaultsPreferencesStore.Keys.backgroundOpacity)
        userDefaults.set("invalid", forKey: UserDefaultsPreferencesStore.Keys.lastDisplayMode)
        userDefaults.set("invalid", forKey: UserDefaultsPreferencesStore.Keys.timerOnModeSwitch)
        userDefaults.set("invalid", forKey: UserDefaultsPreferencesStore.Keys.showDockIcon)

        let preferences = UserDefaultsPreferencesStore(userDefaults: userDefaults).preferences

        XCTAssertEqual(preferences.theme, OverlayPreferences.defaults.theme)
        XCTAssertEqual(preferences.backgroundOpacity, OverlayPreferences.defaults.backgroundOpacity)
        XCTAssertNil(preferences.lastDisplayMode)
        XCTAssertEqual(preferences.timerOnModeSwitch, OverlayPreferences.defaults.timerOnModeSwitch)
        XCTAssertEqual(preferences.showDockIcon, OverlayPreferences.defaults.showDockIcon)
    }

    func testStatusItemInvariantIgnoresLegacyHiddenPreference() {
        userDefaults.set(false, forKey: UserDefaultsPreferencesStore.Keys.legacyStatusItemVisible)

        let preferences = UserDefaultsPreferencesStore(userDefaults: userDefaults).preferences

        XCTAssertTrue(preferences.appVisibility.statusItemVisible)
        XCTAssertNil(userDefaults.object(forKey: UserDefaultsPreferencesStore.Keys.legacyStatusItemVisible))
    }

    func testDockVisibilityPersistsAcrossReload() {
        let store = UserDefaultsPreferencesStore(userDefaults: userDefaults)
        var preferences = store.preferences
        preferences.showDockIcon = true

        store.save(preferences)

        let reloaded = UserDefaultsPreferencesStore(userDefaults: userDefaults).preferences
        XCTAssertTrue(reloaded.showDockIcon)
        XCTAssertTrue(reloaded.appVisibility.statusItemVisible)
    }

    func testPersistsAppearanceModeSwitchAndDisplayModeAcrossReload() {
        let store = UserDefaultsPreferencesStore(userDefaults: userDefaults)
        var preferences = store.preferences
        preferences.theme = .dark
        preferences.backgroundOpacity = 0.72
        preferences.windowSize = CGSize(width: 480, height: 244)
        preferences.timerFontSize = 58
        preferences.timerOnModeSwitch = .pause
        preferences.lastDisplayMode = .timer

        store.save(preferences)

        let reloaded = UserDefaultsPreferencesStore(userDefaults: userDefaults).preferences
        XCTAssertEqual(reloaded.theme, .dark)
        XCTAssertEqual(reloaded.backgroundOpacity, 0.72)
        XCTAssertEqual(reloaded.windowSize, CGSize(width: 480, height: 244))
        XCTAssertEqual(reloaded.timerFontSize, 58)
        XCTAssertEqual(reloaded.timerOnModeSwitch, .pause)
        XCTAssertEqual(reloaded.lastDisplayMode, .timer)
    }

    func testClampsPersistedAppearanceLowerBoundsAcrossReload() {
        let store = UserDefaultsPreferencesStore(userDefaults: userDefaults)
        var preferences = store.preferences
        preferences.backgroundOpacity = 0.10
        preferences.windowSize = CGSize(width: 80, height: 80)
        preferences.timerFontSize = 4

        store.save(preferences)

        let reloaded = UserDefaultsPreferencesStore(userDefaults: userDefaults).preferences
        XCTAssertEqual(reloaded.backgroundOpacity, OverlayPreferences.minimumBackgroundOpacity)
        XCTAssertEqual(reloaded.windowSize, OverlayPreferences.minimumWindowSize)
        XCTAssertEqual(reloaded.timerFontSize, OverlayPreferences.minimumTimerFontSize)
    }

    func testLoadsDefaultInputLoggingPreferences() {
        let preferences = UserDefaultsPreferencesStore(userDefaults: userDefaults).preferences

        XCTAssertEqual(preferences.eventTableRowLimit, 15)
        XCTAssertFalse(preferences.preserveEventTableBetweenOpens)
    }

    func testClampsInputLoggingRowLimitFromPersistedValues() {
        userDefaults.set(1, forKey: UserDefaultsPreferencesStore.Keys.eventTableRowLimit)

        var preferences = UserDefaultsPreferencesStore(userDefaults: userDefaults).preferences
        XCTAssertEqual(preferences.eventTableRowLimit, OverlayPreferences.minimumEventTableRowLimit)

        userDefaults.set(99, forKey: UserDefaultsPreferencesStore.Keys.eventTableRowLimit)

        preferences = UserDefaultsPreferencesStore(userDefaults: userDefaults).preferences
        XCTAssertEqual(preferences.eventTableRowLimit, OverlayPreferences.maximumEventTableRowLimit)
    }

    func testPersistsInputLoggingPreferencesAcrossReload() {
        let store = UserDefaultsPreferencesStore(userDefaults: userDefaults)
        var preferences = store.preferences
        preferences.eventTableRowLimit = 25
        preferences.preserveEventTableBetweenOpens = true

        store.save(preferences)

        let reloaded = UserDefaultsPreferencesStore(userDefaults: userDefaults).preferences
        XCTAssertEqual(reloaded.eventTableRowLimit, 25)
        XCTAssertTrue(reloaded.preserveEventTableBetweenOpens)
    }

    func testCorruptedInputLoggingPreferencesFallBackToSafeDefaults() {
        userDefaults.set("invalid", forKey: UserDefaultsPreferencesStore.Keys.eventTableRowLimit)
        userDefaults.set("invalid", forKey: UserDefaultsPreferencesStore.Keys.preserveEventTableBetweenOpens)

        let preferences = UserDefaultsPreferencesStore(userDefaults: userDefaults).preferences

        XCTAssertEqual(preferences.eventTableRowLimit, OverlayPreferences.defaultEventTableRowLimit)
        XCTAssertEqual(
            preferences.preserveEventTableBetweenOpens,
            OverlayPreferences.defaults.preserveEventTableBetweenOpens
        )
    }
}
