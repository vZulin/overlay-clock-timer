import Foundation

enum InputLoggingSessionStatus: Equatable {
    case inactive
    case active
    case unavailable(reason: String)
}

@MainActor
final class InputEventStore: ObservableObject {
    @Published private(set) var isPanelOpen = false
    @Published private(set) var visibleRows: [InputEventRecord] = []
    @Published private(set) var captureStatus: InputLoggingSessionStatus = .inactive
    @Published private(set) var fileRecordingStatus: InputLoggingSessionStatus = .inactive

    private(set) var preferences: OverlayPreferences
    private var preservedRows: [InputEventRecord] = []

    init(preferences: OverlayPreferences) {
        self.preferences = preferences.validated()
    }

    func togglePanel() {
        if isPanelOpen {
            closePanel()
        } else {
            openPanel()
        }
    }

    func openPanel() {
        isPanelOpen = true
        captureStatus = .inactive
        fileRecordingStatus = .inactive
        visibleRows = preferences.preserveEventTableBetweenOpens ? trimmed(preservedRows) : []
    }

    func closePanel() {
        guard isPanelOpen else {
            return
        }

        if preferences.preserveEventTableBetweenOpens {
            preservedRows = trimmed(visibleRows)
        } else {
            preservedRows = []
            visibleRows = []
        }

        captureStatus = .inactive
        fileRecordingStatus = .inactive
        isPanelOpen = false
    }

    func append(_ record: InputEventRecord) {
        guard isPanelOpen else {
            return
        }

        visibleRows.append(record)
        visibleRows = trimmed(visibleRows)
    }

    func apply(preferences: OverlayPreferences) {
        self.preferences = preferences.validated()

        if !self.preferences.preserveEventTableBetweenOpens {
            preservedRows = []
        }

        visibleRows = trimmed(visibleRows)
        preservedRows = trimmed(preservedRows)
    }

    func clearPreservedRows() {
        preservedRows = []
    }

    private func trimmed(_ records: [InputEventRecord]) -> [InputEventRecord] {
        Array(records.sorted(by: InputEventRecord.newestFirst).prefix(preferences.eventTableRowLimit))
    }
}
