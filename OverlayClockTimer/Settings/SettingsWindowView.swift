import SwiftUI

struct SettingsWindowView: View {
    static let windowTitle = "Overlay Clock Timer Settings"

    @ObservedObject var coordinator: AppCoordinator
    @State private var selection: SettingsCategory? = .appearance

    var body: some View {
        NavigationSplitView {
            List(SettingsCategory.allCases, selection: $selection) { category in
                Label(category.title, systemImage: category.systemImage)
                    .tag(category)
            }
            .navigationSplitViewColumnWidth(min: 160, ideal: 180, max: 220)
        } detail: {
            detailView(for: selection ?? .appearance)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(24)
        }
        .frame(minWidth: 560, minHeight: 400)
    }

    @ViewBuilder
    private func detailView(for category: SettingsCategory) -> some View {
        switch category {
        case .appearance:
            AppearanceSettingsView(coordinator: coordinator)
        case .timer:
            TimerSettingsView(coordinator: coordinator)
        case .inputLogging:
            InputLoggingSettingsView(coordinator: coordinator)
        case .hotkeys:
            HotkeySettingsView(coordinator: coordinator)
        case .startup:
            StartupSettingsView(coordinator: coordinator)
        case .visibility:
            VisibilitySettingsView(coordinator: coordinator)
        }
    }
}

private enum SettingsCategory: String, CaseIterable, Identifiable, Hashable {
    case appearance
    case timer
    case inputLogging
    case hotkeys
    case startup
    case visibility

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .appearance:
            return "Appearance"
        case .timer:
            return "Timer"
        case .inputLogging:
            return "Input Logging"
        case .hotkeys:
            return "Hotkeys"
        case .startup:
            return "Startup"
        case .visibility:
            return "Visibility"
        }
    }

    var systemImage: String {
        switch self {
        case .appearance:
            return "paintbrush"
        case .timer:
            return "timer"
        case .inputLogging:
            return "list.bullet.rectangle"
        case .hotkeys:
            return "keyboard"
        case .startup:
            return "power"
        case .visibility:
            return "dock.rectangle"
        }
    }
}
