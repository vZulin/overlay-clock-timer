import SwiftUI

struct VisibilitySettingsView: View {
    @ObservedObject var coordinator: AppCoordinator

    var body: some View {
        Form {
            Text("Visibility")
                .font(.title2.weight(.semibold))

            Toggle("Show Dock icon", isOn: dockIconBinding)

            Text("The menu-bar status item always remains visible.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .formStyle(.grouped)
    }

    private var dockIconBinding: Binding<Bool> {
        Binding(
            get: { coordinator.appVisibilityController.appVisibility.showDockIcon },
            set: { showDockIcon in
                coordinator.setShowDockIcon(showDockIcon)
            }
        )
    }
}
