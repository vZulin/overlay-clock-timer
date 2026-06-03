import SwiftUI

@main
struct OverlayClockTimerApp: App {
    @StateObject private var coordinator = AppCoordinator()

    var body: some Scene {
        WindowGroup {
            Text("Overlay Clock Timer")
                .frame(width: 280, height: 160)
                .environmentObject(coordinator)
        }
    }
}
