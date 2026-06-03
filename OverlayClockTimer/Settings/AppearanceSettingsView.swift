import SwiftUI

struct AppearanceSettingsView: View {
    @ObservedObject var coordinator: AppCoordinator

    var body: some View {
        Form {
            Text("Appearance")
                .font(.title2.weight(.semibold))
                .accessibilityIdentifier("settings.appearance.title")

            Picker("Theme", selection: themeBinding) {
                ForEach(OverlayThemePreference.allCases, id: \.self) { theme in
                    Text(theme.title).tag(theme)
                }
            }
            .pickerStyle(.segmented)

            SliderRow(
                title: "Opacity",
                valueText: "\(Int(coordinator.preferences.backgroundOpacity * 100))%",
                value: opacityBinding,
                range: OverlayPreferences.minimumBackgroundOpacity...OverlayPreferences.maximumBackgroundOpacity,
                step: 0.01
            )

            SliderRow(
                title: "Overlay width",
                valueText: "\(Int(coordinator.preferences.windowSize.width)) px",
                value: widthBinding,
                range: Double(OverlayPreferences.minimumWindowSize.width)...Double(OverlayPreferences.maximumWindowSize.width),
                step: 1
            )

            SliderRow(
                title: "Overlay height",
                valueText: "\(Int(coordinator.preferences.windowSize.height)) px",
                value: heightBinding,
                range: Double(OverlayPreferences.minimumWindowSize.height)...Double(OverlayPreferences.maximumWindowSize.height),
                step: 1
            )

            SliderRow(
                title: "Timer font",
                valueText: "\(Int(coordinator.preferences.timerFontSize)) pt",
                value: timerFontBinding,
                range: OverlayPreferences.minimumTimerFontSize...OverlayPreferences.maximumTimerFontSize,
                step: 1
            )
        }
        .formStyle(.grouped)
    }

    private var themeBinding: Binding<OverlayThemePreference> {
        Binding(
            get: { coordinator.preferences.theme },
            set: { theme in
                coordinator.updatePreferences { preferences in
                    preferences.theme = theme
                }
            }
        )
    }

    private var opacityBinding: Binding<Double> {
        Binding(
            get: { coordinator.preferences.backgroundOpacity },
            set: { opacity in
                coordinator.updatePreferences { preferences in
                    preferences.backgroundOpacity = opacity
                }
            }
        )
    }

    private var widthBinding: Binding<Double> {
        Binding(
            get: { Double(coordinator.preferences.windowSize.width) },
            set: { width in
                coordinator.updatePreferences { preferences in
                    preferences.windowSize = CGSize(width: CGFloat(width), height: preferences.windowSize.height)
                }
            }
        )
    }

    private var heightBinding: Binding<Double> {
        Binding(
            get: { Double(coordinator.preferences.windowSize.height) },
            set: { height in
                coordinator.updatePreferences { preferences in
                    preferences.windowSize = CGSize(width: preferences.windowSize.width, height: CGFloat(height))
                }
            }
        )
    }

    private var timerFontBinding: Binding<Double> {
        Binding(
            get: { coordinator.preferences.timerFontSize },
            set: { fontSize in
                coordinator.updatePreferences { preferences in
                    preferences.timerFontSize = fontSize
                }
            }
        )
    }
}

private struct SliderRow: View {
    let title: String
    let valueText: String
    let value: Binding<Double>
    let range: ClosedRange<Double>
    let step: Double

    var body: some View {
        HStack {
            Text(title)
            Slider(value: value, in: range, step: step)
            Text(valueText)
                .monospacedDigit()
                .frame(width: 72, alignment: .trailing)
        }
    }
}

private extension OverlayThemePreference {
    var title: String {
        switch self {
        case .system:
            return "System"
        case .light:
            return "Light"
        case .dark:
            return "Dark"
        }
    }
}
