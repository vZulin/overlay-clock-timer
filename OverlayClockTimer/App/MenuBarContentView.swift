import SwiftUI

struct MenuBarContentView: View {
    @ObservedObject var coordinator: AppCoordinator

    var body: some View {
        Button("Show Overlay") {
            coordinator.showOverlay()
        }
        .disabled(coordinator.isOverlayVisible)

        Button("Hide Overlay") {
            coordinator.hideOverlay()
        }
        .disabled(!coordinator.isOverlayVisible)

        Divider()

        Button("Settings") {
            coordinator.presentSettings()
        }

        Divider()

        Button("Quit") {
            coordinator.quit()
        }
    }
}
