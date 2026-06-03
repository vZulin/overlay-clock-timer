import SwiftUI

struct StartupSettingsView: View {
    @ObservedObject var coordinator: AppCoordinator

    var body: some View {
        Form {
            Text("Startup")
                .font(.title2.weight(.semibold))

            Toggle("Launch at login", isOn: launchAtLoginBinding)

            if let lastError = coordinator.launchAtLoginController.lastError {
                Text(lastError)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
        .formStyle(.grouped)
    }

    private var launchAtLoginBinding: Binding<Bool> {
        Binding(
            get: { coordinator.launchAtLoginController.isEnabled },
            set: { enabled in
                coordinator.setLaunchAtLoginEnabled(enabled)
            }
        )
    }
}
