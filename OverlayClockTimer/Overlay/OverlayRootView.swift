import SwiftUI

struct OverlayRootView: View {
    @ObservedObject var coordinator: AppCoordinator
    @ObservedObject var clockDisplayModel: ClockDisplayModel

    let preferences: OverlayPreferences

    @Environment(\.colorScheme) private var colorScheme

    private var tokens: OverlayThemeTokens {
        OverlayTheme.tokens(for: preferences.theme, resolvedColorScheme: colorScheme)
    }

    var body: some View {
        VStack(spacing: 0) {
            dragRegion
            displayArea
            clockToolbar
        }
        .frame(
            minWidth: OverlayMetrics.minimumSize.width,
            idealWidth: preferences.windowSize.width,
            maxWidth: OverlayMetrics.maximumSize.width,
            minHeight: OverlayMetrics.minimumSize.height,
            idealHeight: preferences.windowSize.height,
            maxHeight: OverlayMetrics.maximumSize.height
        )
        .background(
            RoundedRectangle(cornerRadius: OverlayMetrics.cornerRadius, style: .continuous)
                .fill(tokens.panelColor.opacity(preferences.backgroundOpacity))
        )
        .preferredColorScheme(OverlayTheme.preferredColorScheme(for: preferences.theme))
    }

    private var dragRegion: some View {
        DragRegionView()
            .frame(height: 34)
            .overlay(alignment: .trailing) {
                Text(coordinator.displayMode == .clock ? "CLOCK" : "TIMER")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundStyle(tokens.secondaryTextColor)
                    .padding(.trailing, OverlayMetrics.horizontalPadding)
            }
            .accessibilityHidden(true)
    }

    private var displayArea: some View {
        Group {
            if coordinator.displayMode == .clock {
                Text(clockDisplayModel.displayText)
                    .accessibilityIdentifier("clock.display")
                    .accessibilityLabel("Current time")
            } else {
                Text("00:00:00.000")
                    .accessibilityIdentifier("timer.display")
                    .accessibilityLabel("Timer elapsed time")
            }
        }
        .font(.system(size: displayFontSize, weight: .semibold, design: .monospaced))
        .monospacedDigit()
        .lineLimit(1)
        .minimumScaleFactor(0.62)
        .foregroundStyle(tokens.primaryTextColor)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, OverlayMetrics.horizontalPadding)
    }

    private var clockToolbar: some View {
        HStack(spacing: 10) {
            iconButton(
                systemName: "gearshape",
                label: "Settings",
                identifier: "clock.settings"
            ) {
                coordinator.presentSettings()
            }

            iconButton(
                systemName: "eye.slash",
                label: "Hide Overlay",
                identifier: "clock.hideOverlay"
            ) {
                coordinator.hideOverlay()
            }

            Spacer(minLength: 16)

            iconButton(
                systemName: coordinator.displayMode == .clock ? "timer" : "clock",
                label: coordinator.displayMode == .clock ? "Switch to Timer Mode" : "Switch to Clock Mode",
                identifier: "clock.switchMode"
            ) {
                coordinator.switchDisplayMode(
                    to: coordinator.displayMode == .clock ? .timer : .clock
                )
            }
        }
        .padding(.horizontal, OverlayMetrics.horizontalPadding)
        .padding(.bottom, OverlayMetrics.verticalPadding)
    }

    private var displayFontSize: CGFloat {
        if coordinator.displayMode == .clock {
            return min(CGFloat(preferences.timerFontSize), 46)
        }
        return min(CGFloat(preferences.timerFontSize), 34)
    }

    private func iconButton(
        systemName: String,
        label: String,
        identifier: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(tokens.primaryTextColor)
        }
        .buttonStyle(
            SymbolButtonStyle(
                backgroundColor: tokens.controlColor,
                buttonSize: OverlayMetrics.controlButtonSize
            )
        )
        .help(label)
        .accessibilityLabel(label)
        .accessibilityIdentifier(identifier)
    }
}
