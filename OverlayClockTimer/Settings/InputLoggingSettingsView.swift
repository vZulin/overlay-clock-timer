import SwiftUI

struct InputLoggingSettingsView: View {
    @ObservedObject var coordinator: AppCoordinator

    var body: some View {
        Form {
            Text("Input Logging")
                .font(.title2.weight(.semibold))
                .accessibilityIdentifier("settings.inputLogging.title")

            Stepper(
                "Event rows: \(coordinator.preferences.eventTableRowLimit)",
                value: rowLimitBinding,
                in: OverlayPreferences.minimumEventTableRowLimit...OverlayPreferences.maximumEventTableRowLimit
            )
            .accessibilityIdentifier("settings.inputLogging.rowLimit")

            Toggle("Preserve rows between panel openings", isOn: preserveRowsBinding)
                .accessibilityIdentifier("settings.inputLogging.preserveRows")
        }
        .formStyle(.grouped)
    }

    private var rowLimitBinding: Binding<Int> {
        Binding(
            get: { coordinator.preferences.eventTableRowLimit },
            set: { rowLimit in
                coordinator.updatePreferences { preferences in
                    preferences.eventTableRowLimit = rowLimit
                }
            }
        )
    }

    private var preserveRowsBinding: Binding<Bool> {
        Binding(
            get: { coordinator.preferences.preserveEventTableBetweenOpens },
            set: { preserveRows in
                coordinator.updatePreferences { preferences in
                    preferences.preserveEventTableBetweenOpens = preserveRows
                }
            }
        )
    }
}
