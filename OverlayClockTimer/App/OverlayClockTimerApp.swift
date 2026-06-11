import Foundation
import SwiftUI

@main
struct OverlayClockTimerApp: App {
    @StateObject private var coordinator: AppCoordinator

    init() {
        let arguments = ProcessInfo.processInfo.arguments

        if
            arguments.contains("--ui-testing"),
            let bundleIdentifier = Bundle.main.bundleIdentifier
        {
            UserDefaults.standard.removePersistentDomain(forName: bundleIdentifier)
        }

        let shouldShowOverlayOnLaunch = !arguments.contains("--hide-overlay-on-launch")
        let inputEventObserver = arguments.contains("--mock-input-event-capture")
            ? InputEventObserver(eventSource: MockInputEventSource())
            : InputEventObserver()
        let logSessionWriter: LogSessionWriting = arguments.contains("--delayed-input-event-log-writing")
            ? DelayedLogSessionWriter(
                delayNanoseconds: 2_000_000_000
            )
            : LogSessionWriter()

        _coordinator = StateObject(
            wrappedValue: AppCoordinator(
                launchOverlayOnStart: shouldShowOverlayOnLaunch,
                inputEventObserver: inputEventObserver,
                logSessionWriter: logSessionWriter
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
