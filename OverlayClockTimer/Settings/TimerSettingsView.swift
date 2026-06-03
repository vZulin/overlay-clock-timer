import SwiftUI

struct TimerSettingsView: View {
    @ObservedObject var coordinator: AppCoordinator

    var body: some View {
        Form {
            Text("Timer")
                .font(.title2.weight(.semibold))

            Picker("When switching modes", selection: modeSwitchBinding) {
                ForEach(ModeSwitchAction.allCases, id: \.self) { action in
                    Text(action.title).tag(action)
                }
            }
            .pickerStyle(.radioGroup)
        }
        .formStyle(.grouped)
    }

    private var modeSwitchBinding: Binding<ModeSwitchAction> {
        Binding(
            get: { coordinator.preferences.timerOnModeSwitch },
            set: { action in
                coordinator.updatePreferences { preferences in
                    preferences.timerOnModeSwitch = action
                }
            }
        )
    }
}

private extension ModeSwitchAction {
    var title: String {
        switch self {
        case .continue:
            return "Continue timer"
        case .pause:
            return "Pause timer"
        case .stopAndReset:
            return "Stop and reset timer"
        }
    }
}
