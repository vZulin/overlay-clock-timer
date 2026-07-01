import SwiftUI

struct OverlayToolbarView: View {
    @ObservedObject var coordinator: AppCoordinator
    @ObservedObject var timerSessionStore: TimerSessionStore
    @ObservedObject var inputEventStore: InputEventStore

    let tokens: OverlayThemeTokens

    var body: some View {
        Group {
            if coordinator.displayMode == .clock {
                clockToolbar
            } else {
                timerToolbar
            }
        }
        .padding(.horizontal, OverlayMetrics.horizontalPadding)
        .padding(.bottom, OverlayMetrics.verticalPadding)
    }

    private var clockToolbar: some View {
        HStack(spacing: OverlayMetrics.compactToolbarSpacing) {
            toolbarButton(
                systemName: "gearshape",
                label: "Settings",
                identifier: "clock.settings"
            ) {
                coordinator.presentSettings()
            }

            toolbarButton(
                systemName: "eye.slash",
                label: "Hide Overlay",
                identifier: "clock.hideOverlay"
            ) {
                coordinator.hideOverlay()
            }

            Spacer(minLength: OverlayMetrics.toolbarGroupSpacing)

            timeFormatButton(identifier: "clock.timeFormatToggle")
            inputLoggingButton(identifier: "clock.inputLoggingToggle")
            modeSwitchButton(identifier: "clock.switchMode")
        }
    }

    private var timerToolbar: some View {
        HStack(spacing: OverlayMetrics.compactToolbarSpacing) {
            toolbarButton(
                systemName: "stop.fill",
                label: "Stop and Reset",
                identifier: "timer.stopReset",
                isEnabled: timerSessionStore.canStopReset
            ) {
                timerSessionStore.stopReset()
            }

            toolbarButton(
                systemName: timerSessionStore.canPause ? "pause.fill" : "play.fill",
                label: timerSessionStore.canPause ? "Pause" : "Start",
                identifier: timerSessionStore.canPause ? "timer.pause" : "timer.start",
                isEnabled: timerSessionStore.canPause || timerSessionStore.canStart
            ) {
                if timerSessionStore.canPause {
                    timerSessionStore.pause()
                } else {
                    timerSessionStore.start()
                }
            }

            toolbarButton(
                systemName: "repeat",
                label: "Loop",
                identifier: "timer.loop",
                isEnabled: timerSessionStore.canLoop
            ) {
                timerSessionStore.loop()
            }

            Spacer(minLength: OverlayMetrics.compactToolbarSpacing)

            timeFormatButton(identifier: "timer.timeFormatToggle")
            inputLoggingButton(identifier: "timer.inputLoggingToggle")
            modeSwitchButton(identifier: "timer.switchMode")
        }
    }

    private func inputLoggingButton(identifier: String) -> some View {
        toolbarButton(
            systemName: inputEventStore.isPanelOpen ? "list.bullet.rectangle.fill" : "list.bullet.rectangle",
            label: inputEventStore.isPanelOpen ? "Hide Input Event Log" : "Show Input Event Log",
            identifier: identifier,
            isActive: inputEventStore.isPanelOpen
        ) {
            coordinator.toggleInputEventLoggingPanel()
        }
    }

    private func timeFormatButton(identifier: String) -> some View {
        let isEpochSelected = coordinator.preferences.timeFormat == .epochMilliseconds
        return toolbarButton(
            icon: .epochToggle,
            label: isEpochSelected ? "Switch to Standard Time Format" : "Switch to Epoch Milliseconds",
            identifier: identifier,
            isActive: isEpochSelected
        ) {
            coordinator.toggleTimeFormat()
        }
    }

    private func modeSwitchButton(identifier: String) -> some View {
        toolbarButton(
            systemName: coordinator.displayMode == .clock ? "timer" : "clock",
            label: coordinator.displayMode == .clock ? "Switch to Timer Mode" : "Switch to Clock Mode",
            identifier: identifier,
            isModeSwitch: true
        ) {
            coordinator.switchDisplayMode(
                to: coordinator.displayMode == .clock ? .timer : .clock
            )
        }
    }

    private func toolbarButton(
        systemName: String,
        label: String,
        identifier: String,
        isEnabled: Bool = true,
        isActive: Bool = false,
        isModeSwitch: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        toolbarButton(
            icon: .system(systemName),
            label: label,
            identifier: identifier,
            isEnabled: isEnabled,
            isActive: isActive,
            isModeSwitch: isModeSwitch,
            action: action
        )
    }

    private func toolbarButton(
        icon: ToolbarButtonIcon,
        label: String,
        identifier: String,
        isEnabled: Bool = true,
        isActive: Bool = false,
        isModeSwitch: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        let iconColor = tokens.primaryTextColor.opacity(isEnabled ? 1 : 0.42)

        return Button(action: action) {
            switch icon {
            case .system(let systemName):
                Image(systemName: systemName)
                    .font(.system(size: OverlayMetrics.toolbarIconSize, weight: .semibold))
                    .foregroundStyle(iconColor)
            case .epochToggle:
                EpochToggleIcon(color: iconColor)
            }
        }
        .buttonStyle(
            SymbolButtonStyle(
                backgroundColor: isModeSwitch || isActive
                    ? tokens.primaryTextColor.opacity(0.16)
                    : tokens.controlColor,
                buttonSize: OverlayMetrics.controlButtonSize
            )
        )
        .overlay {
            if isModeSwitch || isActive {
                RoundedRectangle(cornerRadius: OverlayMetrics.controlCornerRadius)
                    .stroke(tokens.secondaryTextColor.opacity(0.46), lineWidth: 1)
            }
        }
        .disabled(!isEnabled)
        .help(label)
        .accessibilityLabel(label)
        .accessibilityIdentifier(identifier)
    }
}

private enum ToolbarButtonIcon {
    case system(String)
    case epochToggle
}

private struct EpochToggleIcon: View {
    let color: Color

    var body: some View {
        ZStack {
            clockCue
            timestampCue
            conversionCue
        }
        .frame(
            width: OverlayMetrics.epochToggleIconSize,
            height: OverlayMetrics.epochToggleIconSize
        )
        .accessibilityHidden(true)
    }

    private var clockCue: some View {
        ZStack {
            Circle()
                .stroke(color, style: strokeStyle)
                .frame(width: 7.5, height: 7.5)
                .position(x: 5.2, y: 7.2)

            Path { path in
                path.move(to: CGPoint(x: 5.2, y: 7.2))
                path.addLine(to: CGPoint(x: 5.2, y: 4.9))
                path.move(to: CGPoint(x: 5.2, y: 7.2))
                path.addLine(to: CGPoint(x: 7.1, y: 7.2))
            }
            .stroke(color, style: strokeStyle)
        }
    }

    private var timestampCue: some View {
        ZStack {
            ForEach(0..<3, id: \.self) { row in
                Capsule(style: .continuous)
                    .fill(color)
                    .frame(width: row == 1 ? 6.8 : 5.8, height: 1.45)
                    .position(x: 13.1, y: 4.7 + CGFloat(row) * 4.1)
            }
        }
    }

    private var conversionCue: some View {
        Path { path in
            path.move(to: CGPoint(x: 7.9, y: 11.5))
            path.addQuadCurve(
                to: CGPoint(x: 12.4, y: 14.0),
                control: CGPoint(x: 10.0, y: 13.7)
            )
            path.move(to: CGPoint(x: 12.4, y: 14.0))
            path.addLine(to: CGPoint(x: 11.0, y: 14.2))
            path.move(to: CGPoint(x: 12.4, y: 14.0))
            path.addLine(to: CGPoint(x: 11.8, y: 12.7))
        }
        .stroke(color, style: strokeStyle)
    }

    private var strokeStyle: StrokeStyle {
        StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round)
    }
}
