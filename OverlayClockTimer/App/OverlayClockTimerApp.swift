import SwiftUI

@main
struct OverlayClockTimerApp: App {
    @StateObject private var coordinator: AppCoordinator

    init() {
        _coordinator = StateObject(
            wrappedValue: AppCoordinator(
                launchOverlayOnStart: ProcessInfo.processInfo.arguments.contains("--show-overlay-on-launch")
            )
        )
    }

    var body: some Scene {
        MenuBarExtra("Overlay Clock Timer", systemImage: "clock") {
            MenuBarContentView(coordinator: coordinator)
        }
    }
}
