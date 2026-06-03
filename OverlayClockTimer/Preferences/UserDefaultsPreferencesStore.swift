import CoreGraphics
import Foundation

final class UserDefaultsPreferencesStore: PreferencesStore {
    enum Keys {
        static let theme = "overlay.theme"
        static let backgroundOpacity = "overlay.backgroundOpacity"
        static let windowWidth = "overlay.window.width"
        static let windowHeight = "overlay.window.height"
        static let timerFontSize = "overlay.timerFontSize"
        static let frameX = "overlay.frame.x"
        static let frameY = "overlay.frame.y"
        static let frameWidth = "overlay.frame.width"
        static let frameHeight = "overlay.frame.height"
        static let lastDisplayMode = "overlay.lastDisplayMode"
        static let timerOnModeSwitch = "timer.modeSwitchAction"
        static let showDockIcon = "app.showDockIcon"
        static let launchAtLoginEnabled = "app.launchAtLoginEnabled"
        static let legacyStatusItemVisible = "app.statusItemVisible"
    }

    private let userDefaults: UserDefaults
    private(set) var preferences: OverlayPreferences

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        self.preferences = OverlayPreferences.defaults
        self.preferences = load()
    }

    @discardableResult
    func load() -> OverlayPreferences {
        let defaults = OverlayPreferences.defaults
        let width = doubleValue(forKey: Keys.windowWidth) ?? Double(defaults.windowSize.width)
        let height = doubleValue(forKey: Keys.windowHeight) ?? Double(defaults.windowSize.height)

        let loaded = OverlayPreferences(
            theme: OverlayThemePreference(storedValue: userDefaults.string(forKey: Keys.theme)),
            backgroundOpacity: doubleValue(forKey: Keys.backgroundOpacity) ?? defaults.backgroundOpacity,
            windowSize: CGSize(width: width, height: height),
            timerFontSize: doubleValue(forKey: Keys.timerFontSize) ?? defaults.timerFontSize,
            lastWindowFrame: readFrame(),
            lastDisplayMode: optionalDisplayMode(),
            timerOnModeSwitch: ModeSwitchAction(storedValue: userDefaults.string(forKey: Keys.timerOnModeSwitch)),
            showDockIcon: boolValue(forKey: Keys.showDockIcon) ?? defaults.showDockIcon,
            launchAtLoginEnabled: boolValue(forKey: Keys.launchAtLoginEnabled) ?? defaults.launchAtLoginEnabled
        ).validated()

        userDefaults.removeObject(forKey: Keys.legacyStatusItemVisible)
        preferences = loaded
        return loaded
    }

    func save(_ preferences: OverlayPreferences) {
        let validated = preferences.validated()
        userDefaults.set(validated.theme.rawValue, forKey: Keys.theme)
        userDefaults.set(validated.backgroundOpacity, forKey: Keys.backgroundOpacity)
        userDefaults.set(Double(validated.windowSize.width), forKey: Keys.windowWidth)
        userDefaults.set(Double(validated.windowSize.height), forKey: Keys.windowHeight)
        userDefaults.set(validated.timerFontSize, forKey: Keys.timerFontSize)
        userDefaults.set(validated.timerOnModeSwitch.rawValue, forKey: Keys.timerOnModeSwitch)
        userDefaults.set(validated.showDockIcon, forKey: Keys.showDockIcon)
        userDefaults.set(validated.launchAtLoginEnabled, forKey: Keys.launchAtLoginEnabled)

        if let lastDisplayMode = validated.lastDisplayMode {
            userDefaults.set(lastDisplayMode.rawValue, forKey: Keys.lastDisplayMode)
        } else {
            userDefaults.removeObject(forKey: Keys.lastDisplayMode)
        }

        if let frame = validated.lastWindowFrame {
            writeFrame(frame)
        } else {
            removeFrame()
        }

        userDefaults.removeObject(forKey: Keys.legacyStatusItemVisible)
        self.preferences = validated
    }

    private func optionalDisplayMode() -> DisplayMode? {
        guard let rawValue = userDefaults.string(forKey: Keys.lastDisplayMode) else {
            return nil
        }
        return DisplayMode(rawValue: rawValue)
    }

    private func readFrame() -> CGRect? {
        guard
            let x = doubleValue(forKey: Keys.frameX),
            let y = doubleValue(forKey: Keys.frameY),
            let width = doubleValue(forKey: Keys.frameWidth),
            let height = doubleValue(forKey: Keys.frameHeight)
        else {
            return nil
        }

        let size = OverlayPreferences.clampedWindowSize(CGSize(width: width, height: height))
        return CGRect(x: x, y: y, width: size.width, height: size.height)
    }

    private func writeFrame(_ frame: CGRect) {
        userDefaults.set(Double(frame.origin.x), forKey: Keys.frameX)
        userDefaults.set(Double(frame.origin.y), forKey: Keys.frameY)
        userDefaults.set(Double(frame.size.width), forKey: Keys.frameWidth)
        userDefaults.set(Double(frame.size.height), forKey: Keys.frameHeight)
    }

    private func removeFrame() {
        userDefaults.removeObject(forKey: Keys.frameX)
        userDefaults.removeObject(forKey: Keys.frameY)
        userDefaults.removeObject(forKey: Keys.frameWidth)
        userDefaults.removeObject(forKey: Keys.frameHeight)
    }

    private func doubleValue(forKey key: String) -> Double? {
        guard let number = userDefaults.object(forKey: key) as? NSNumber else {
            return nil
        }
        let value = number.doubleValue
        return value.isFinite ? value : nil
    }

    private func boolValue(forKey key: String) -> Bool? {
        guard let number = userDefaults.object(forKey: key) as? NSNumber else {
            return nil
        }
        return number.boolValue
    }
}
