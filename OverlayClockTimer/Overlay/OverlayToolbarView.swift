import SwiftUI

struct OverlayToolbarView: View {
    @ObservedObject var coordinator: AppCoordinator
    @ObservedObject var timerSessionStore: TimerSessionStore

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
        HStack(spacing: 10) {
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

            Spacer(minLength: 16)

            modeSwitchButton(identifier: "clock.switchMode")
        }
    }

    private var timerToolbar: some View {
        HStack(spacing: 10) {
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

            Spacer(minLength: 16)

            modeSwitchButton(identifier: "timer.switchMode")
        }
    }

    private func modeSwitchButton(identifier: String) -> some View {
        toolbarButton(
            systemName: coordinator.displayMode == .clock ? "timer" : "clock",
            label: coordinator.displayMode == .clock ? "Switch to Timer Mode" : "Switch to Clock Mode",
            identifier: identifier
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
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(tokens.primaryTextColor.opacity(isEnabled ? 1 : 0.42))
        }
        .buttonStyle(
            SymbolButtonStyle(
                backgroundColor: tokens.controlColor,
                buttonSize: OverlayMetrics.controlButtonSize
            )
        )
        .disabled(!isEnabled)
        .help(label)
        .accessibilityLabel(label)
        .accessibilityIdentifier(identifier)
    }
}
