import Foundation
import SwiftUI

@main
struct OverlayClockTimerApp: App {
    @StateObject private var coordinator: AppCoordinator

    init() {
        if
            ProcessInfo.processInfo.arguments.contains("--ui-testing"),
            let bundleIdentifier = Bundle.main.bundleIdentifier
        {
            UserDefaults.standard.removePersistentDomain(forName: bundleIdentifier)
        }

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
        .commands {
            CommandGroup(replacing: .appSettings) {
                Button("Settings") {
                    coordinator.presentSettings()
                }
                .keyboardShortcut(",", modifiers: .command)
            }
        }
    }
}
