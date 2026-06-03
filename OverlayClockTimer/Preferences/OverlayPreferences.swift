import CoreGraphics
import Foundation

enum DisplayMode: String, CaseIterable, Equatable {
    case clock
    case timer

    static let defaultValue: DisplayMode = .clock

    init(storedValue: String?) {
        self = storedValue.flatMap(DisplayMode.init(rawValue:)) ?? Self.defaultValue
    }
}

enum OverlayThemePreference: String, CaseIterable, Equatable {
    case system
    case light
    case dark

    static let defaultValue: OverlayThemePreference = .system

    init(storedValue: String?) {
        self = storedValue.flatMap(OverlayThemePreference.init(rawValue:)) ?? Self.defaultValue
    }
}

struct AppVisibilityPreference: Equatable {
    var showDockIcon: Bool
    var statusItemVisible: Bool {
        true
    }
}

struct OverlayPreferences: Equatable {
    static let minimumBackgroundOpacity: Double = 0.60
    static let maximumBackgroundOpacity: Double = 1.00
    static let defaultBackgroundOpacity: Double = 0.90

    static let minimumWindowSize = CGSize(width: 220, height: 124)
    static let defaultWindowSize = CGSize(width: 280, height: 160)
    static let maximumWindowSize = CGSize(width: 520, height: 300)

    static let minimumTimerFontSize: Double = 24
    static let defaultTimerFontSize: Double = 48
    static let maximumTimerFontSize: Double = 96

    var theme: OverlayThemePreference
    var backgroundOpacity: Double
    var windowSize: CGSize
    var timerFontSize: Double
    var lastWindowFrame: CGRect?
    var lastDisplayMode: DisplayMode?
    var timerOnModeSwitch: ModeSwitchAction
    var showDockIcon: Bool
    var launchAtLoginEnabled: Bool
    var hotkeyBindings: [HotkeyBinding]

    var appVisibility: AppVisibilityPreference {
        AppVisibilityPreference(showDockIcon: showDockIcon)
    }

    static let defaults = OverlayPreferences(
        theme: OverlayThemePreference.defaultValue,
        backgroundOpacity: defaultBackgroundOpacity,
        windowSize: defaultWindowSize,
        timerFontSize: defaultTimerFontSize,
        lastWindowFrame: nil,
        lastDisplayMode: nil,
        timerOnModeSwitch: ModeSwitchAction.defaultValue,
        showDockIcon: false,
        launchAtLoginEnabled: false,
        hotkeyBindings: []
    )

    func validated() -> OverlayPreferences {
        let clampedWindowSize = Self.clampedWindowSize(windowSize)
        return OverlayPreferences(
            theme: theme,
            backgroundOpacity: backgroundOpacity.clamped(
                to: Self.minimumBackgroundOpacity...Self.maximumBackgroundOpacity
            ),
            windowSize: clampedWindowSize,
            timerFontSize: Self.clampedTimerFontSize(timerFontSize, for: clampedWindowSize),
            lastWindowFrame: lastWindowFrame,
            lastDisplayMode: lastDisplayMode,
            timerOnModeSwitch: timerOnModeSwitch,
            showDockIcon: showDockIcon,
            launchAtLoginEnabled: launchAtLoginEnabled,
            hotkeyBindings: HotkeyBindingSet.validated(hotkeyBindings)
        )
    }

    static func clampedWindowSize(_ size: CGSize) -> CGSize {
        CGSize(
            width: Double(size.width).clamped(to: Double(minimumWindowSize.width)...Double(maximumWindowSize.width)),
            height: Double(size.height).clamped(to: Double(minimumWindowSize.height)...Double(maximumWindowSize.height))
        )
    }

    static func clampedTimerFontSize(_ fontSize: Double, for windowSize: CGSize) -> Double {
        let heightBound = Double(windowSize.height) * 0.45
        let maximumAllowed = min(maximumTimerFontSize, heightBound)
        return fontSize.clamped(to: minimumTimerFontSize...maximumAllowed)
    }
}

extension Double {
    func clamped(to range: ClosedRange<Double>) -> Double {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
