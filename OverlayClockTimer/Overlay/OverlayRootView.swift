import SwiftUI

struct OverlayRootView: View {
    @ObservedObject var coordinator: AppCoordinator
    @ObservedObject var clockDisplayModel: ClockDisplayModel
    @ObservedObject var timerSessionStore: TimerSessionStore
    @ObservedObject var inputEventStore: InputEventStore

    @Environment(\.colorScheme) private var colorScheme

    private var tokens: OverlayThemeTokens {
        OverlayTheme.tokens(for: preferences.theme, resolvedColorScheme: colorScheme)
    }

    private var preferences: OverlayPreferences {
        coordinator.preferences
    }

    var body: some View {
        VStack(spacing: 0) {
            dragRegion
            displayArea
            OverlayToolbarView(
                coordinator: coordinator,
                timerSessionStore: timerSessionStore,
                inputEventStore: inputEventStore,
                tokens: tokens
            )
            if inputEventStore.isPanelOpen {
                InputEventTableView(store: inputEventStore, tokens: tokens)
            }
        }
        .frame(
            minWidth: OverlayMetrics.minimumSize.width,
            idealWidth: preferences.windowSize.width,
            maxWidth: OverlayMetrics.maximumSize.width,
            minHeight: OverlayMetrics.minimumSize.height,
            idealHeight: idealHeight,
            maxHeight: maximumHeight
        )
        .background(
            RoundedRectangle(cornerRadius: OverlayMetrics.cornerRadius, style: .continuous)
                .fill(tokens.panelColor.opacity(preferences.backgroundOpacity))
        )
        .animation(.easeInOut(duration: 0.16), value: inputEventStore.isPanelOpen)
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
                    .font(.system(size: displayFontSize, weight: .semibold, design: .monospaced))
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.62)
                    .foregroundStyle(tokens.primaryTextColor)
            } else {
                timerDisplayArea
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, OverlayMetrics.horizontalPadding)
    }

    private var timerDisplayArea: some View {
        VStack(spacing: 5) {
            Text(timerSessionStore.elapsedDisplayText)
                .accessibilityIdentifier("timer.display")
                .accessibilityLabel("Timer elapsed time")
                .font(.system(size: displayFontSize, weight: .semibold, design: .monospaced))
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.62)
                .foregroundStyle(tokens.primaryTextColor)

            Text(timerSessionStore.latestLoopDisplayText ?? "00:00:00.000")
                .accessibilityIdentifier("timer.latestLoop")
                .accessibilityLabel("Latest loop")
                .accessibilityHidden(timerSessionStore.latestLoopDisplayText == nil)
                .font(.system(size: latestLoopFontSize, weight: .medium, design: .monospaced))
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .foregroundStyle(tokens.secondaryTextColor)
                .opacity(timerSessionStore.latestLoopDisplayText == nil ? 0 : 1)
        }
    }

    private var displayFontSize: CGFloat {
        if coordinator.displayMode == .clock {
            return min(CGFloat(preferences.timerFontSize), 46)
        }
        return min(CGFloat(preferences.timerFontSize), 34)
    }

    private var latestLoopFontSize: CGFloat {
        max(12, displayFontSize * 0.44)
    }

    private var idealHeight: CGFloat {
        if inputEventStore.isPanelOpen {
            return min(
                preferences.windowSize.height + OverlayMetrics.inputLoggingExpandedHeightDelta,
                OverlayMetrics.maximumExpandedSize.height
            )
        }
        return preferences.windowSize.height
    }

    private var maximumHeight: CGFloat {
        inputEventStore.isPanelOpen
            ? OverlayMetrics.maximumExpandedSize.height
            : OverlayMetrics.maximumSize.height
    }
}
