import Foundation
import SwiftUI

@main
struct OverlayClockTimerApp: App {
    @StateObject private var coordinator: AppCoordinator

    init() {
        let arguments = ProcessInfo.processInfo.arguments

        if
            arguments.contains("--ui-testing"),
            !arguments.contains("--preserve-ui-testing-preferences"),
            let bundleIdentifier = Bundle.main.bundleIdentifier
        {
            UserDefaults.standard.removePersistentDomain(forName: bundleIdentifier)
        }

        let shouldShowOverlayOnLaunch = !arguments.contains("--hide-overlay-on-launch")
        let preferencesStore = UserDefaultsPreferencesStore()
        Self.applyUITestingPreferenceOverrides(arguments: arguments, preferencesStore: preferencesStore)
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
                preferencesStore: preferencesStore,
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

    private static func applyUITestingPreferenceOverrides(
        arguments: [String],
        preferencesStore: UserDefaultsPreferencesStore
    ) {
        guard arguments.contains("--ui-testing") else {
            return
        }

        var preferences = preferencesStore.preferences
        var didChangePreferences = false

        if arguments.contains("--preserve-input-event-table-between-opens") {
            preferences.eventTableRowLimit = OverlayPreferences.maximumEventTableRowLimit
            preferences.preserveEventTableBetweenOpens = true
            didChangePreferences = true
        }

        if
            let rawTheme = launchArgumentValue(prefix: "--ui-testing-theme=", in: arguments),
            let theme = OverlayThemePreference(rawValue: rawTheme)
        {
            preferences.theme = theme
            didChangePreferences = true
        }

        if
            let rawOpacity = launchArgumentValue(prefix: "--ui-testing-background-opacity=", in: arguments),
            let opacity = Double(rawOpacity)
        {
            preferences.backgroundOpacity = opacity
            didChangePreferences = true
        }

        if didChangePreferences {
            preferencesStore.save(preferences)
        }
    }

    private static func launchArgumentValue(prefix: String, in arguments: [String]) -> String? {
        arguments
            .first { $0.hasPrefix(prefix) }
            .map { String($0.dropFirst(prefix.count)) }
    }
}
