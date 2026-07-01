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
            collapsedContent
                .frame(height: preferences.windowSize.height, alignment: .top)

            if inputEventStore.isPanelOpen {
                InputEventTableView(store: inputEventStore, tokens: tokens)
                    .layoutPriority(0)
            }
        }
        .frame(
            minWidth: OverlayMetrics.minimumSize.width,
            idealWidth: preferences.windowSize.width,
            maxWidth: OverlayMetrics.maximumSize.width,
            minHeight: OverlayMetrics.minimumSize.height,
            idealHeight: idealHeight,
            maxHeight: maximumHeight,
            alignment: .top
        )
        .background(
            RoundedRectangle(cornerRadius: OverlayMetrics.cornerRadius, style: .continuous)
                .fill(tokens.panelColor.opacity(preferences.backgroundOpacity))
        )
        .preferredColorScheme(OverlayTheme.preferredColorScheme(for: preferences.theme))
    }

    private var collapsedContent: some View {
        VStack(spacing: 0) {
            dragRegion
            displayArea
            OverlayToolbarView(
                coordinator: coordinator,
                timerSessionStore: timerSessionStore,
                inputEventStore: inputEventStore,
                tokens: tokens
            )
            .layoutPriority(1)
        }
    }

    private var dragRegion: some View {
        DragRegionView()
            .frame(height: OverlayMetrics.dragRegionHeight)
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
                    .accessibilityValue(clockDisplayModel.displayText)
                    .font(.system(size: displayFontSize, weight: .semibold, design: .monospaced))
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(clockDisplayMinimumScaleFactor)
                    .foregroundStyle(tokens.primaryTextColor)
            } else {
                timerDisplayArea
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: displayAreaHeight)
        .padding(.horizontal, OverlayMetrics.horizontalPadding)
    }

    private var timerDisplayArea: some View {
        ZStack {
            Text(timerSessionStore.elapsedDisplayText)
                .accessibilityIdentifier("timer.display")
                .accessibilityLabel("Timer elapsed time")
                .accessibilityValue(timerSessionStore.elapsedDisplayText)
                .font(.system(size: displayFontSize, weight: .semibold, design: .monospaced))
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(timerDisplayMinimumScaleFactor)
                .foregroundStyle(tokens.primaryTextColor)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)

            if let latestLoopDisplayText = timerSessionStore.latestLoopDisplayText {
                VStack(spacing: 0) {
                    Spacer(minLength: 0)
                    Text(latestLoopDisplayText)
                        .accessibilityIdentifier("timer.latestLoop")
                        .accessibilityLabel("Latest loop")
                        .accessibilityValue(latestLoopDisplayText)
                        .font(.system(size: latestLoopFontSize, weight: .medium, design: .monospaced))
                        .monospacedDigit()
                        .lineLimit(1)
                        .minimumScaleFactor(latestLoopMinimumScaleFactor)
                        .foregroundStyle(tokens.secondaryTextColor)
                        .padding(.bottom, 2)
                }
            }
        }
    }

    private var displayFontSize: CGFloat {
        if coordinator.displayMode == .clock {
            return min(CGFloat(preferences.timerFontSize), 46)
        }
        return min(CGFloat(preferences.timerFontSize), 34)
    }

    private var clockDisplayMinimumScaleFactor: CGFloat {
        preferences.timeFormat == .epochMilliseconds ? 0.52 : 0.62
    }

    private var timerDisplayMinimumScaleFactor: CGFloat {
        preferences.timeFormat == .epochMilliseconds ? 0.52 : 0.62
    }

    private var latestLoopMinimumScaleFactor: CGFloat {
        preferences.timeFormat == .epochMilliseconds ? 0.58 : 0.7
    }

    private var latestLoopFontSize: CGFloat {
        max(12, displayFontSize * 0.44)
    }

    private var displayAreaHeight: CGFloat {
        OverlayMetrics.displayAreaHeight(for: preferences.windowSize.height)
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
