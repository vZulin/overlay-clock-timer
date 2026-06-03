import SwiftUI

struct OverlayThemeTokens: Equatable {
    let panelColor: Color
    let primaryTextColor: Color
    let secondaryTextColor: Color
    let controlColor: Color
}

enum OverlayTheme {
    static func preferredColorScheme(for preference: OverlayThemePreference) -> ColorScheme? {
        switch preference {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }

    static func tokens(for preference: OverlayThemePreference, resolvedColorScheme: ColorScheme) -> OverlayThemeTokens {
        let effectiveScheme = preferredColorScheme(for: preference) ?? resolvedColorScheme
        switch effectiveScheme {
        case .dark:
            return OverlayThemeTokens(
                panelColor: Color(red: 0.08, green: 0.08, blue: 0.09),
                primaryTextColor: .white,
                secondaryTextColor: Color(red: 0.72, green: 0.74, blue: 0.78),
                controlColor: Color(red: 0.16, green: 0.17, blue: 0.19)
            )
        case .light:
            return OverlayThemeTokens(
                panelColor: Color(red: 0.94, green: 0.95, blue: 0.96),
                primaryTextColor: Color(red: 0.08, green: 0.09, blue: 0.10),
                secondaryTextColor: Color(red: 0.34, green: 0.36, blue: 0.39),
                controlColor: Color(red: 0.84, green: 0.86, blue: 0.88)
            )
        @unknown default:
            return tokens(for: .system, resolvedColorScheme: .dark)
        }
    }
}
