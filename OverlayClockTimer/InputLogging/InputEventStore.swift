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
    private var nextCaptureOrder = InputEventCaptureOrder(0)

    private let eventNameFormatter: InputEventNameFormatter
    private let logSessionWriter: LogSessionWriting?

    init(
        preferences: OverlayPreferences,
        eventNameFormatter: InputEventNameFormatter = InputEventNameFormatter(),
        logSessionWriter: LogSessionWriting? = nil
    ) {
        self.preferences = preferences.validated()
        self.eventNameFormatter = eventNameFormatter
        self.logSessionWriter = logSessionWriter
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
        visibleRows = preferences.preserveEventTableBetweenOpens ? trimmed(preservedRows) : []
        openLogSession()
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

        logSessionWriter?.close()
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

    func recordKeyboardEvent(_ event: KeyboardInputEvent, timestamp: String) {
        guard isPanelOpen else {
            return
        }

        let formattedEvent = eventNameFormatter.format(keyboard: event)
        let record = InputEventRecord(
            captureOrder: nextOrder(),
            timestamp: timestamp,
            category: formattedEvent.category,
            name: formattedEvent.name,
            phase: formattedEvent.phase
        )

        append(record)
        appendLogRecord(record)
    }

    func recordMouseEvent(_ event: MouseInputEvent, timestamp: String) {
        guard isPanelOpen else {
            return
        }

        let formattedEvent = eventNameFormatter.format(mouse: event)
        let record = InputEventRecord(
            captureOrder: nextOrder(),
            timestamp: timestamp,
            category: formattedEvent.category,
            name: formattedEvent.name,
            phase: formattedEvent.phase
        )

        append(record)
        appendLogRecord(record)
    }

    func setCaptureStatus(_ status: InputLoggingSessionStatus) {
        guard isPanelOpen || status == .inactive else {
            return
        }

        captureStatus = status
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

    private func nextOrder() -> InputEventCaptureOrder {
        let nextRawValue = nextCaptureOrder.rawValue + 1
        nextCaptureOrder = InputEventCaptureOrder(nextRawValue)
        return nextCaptureOrder
    }

    private func openLogSession() {
        guard let logSessionWriter else {
            fileRecordingStatus = .inactive
            return
        }

        do {
            try logSessionWriter.open()
            fileRecordingStatus = .active
        } catch {
            fileRecordingStatus = .unavailable(reason: reason(from: error))
        }
    }

    private func appendLogRecord(_ record: InputEventRecord) {
        guard fileRecordingStatus == .active, let logSessionWriter else {
            return
        }

        do {
            try logSessionWriter.append(record)
        } catch {
            fileRecordingStatus = .unavailable(reason: reason(from: error))
        }
    }

    private func reason(from error: Error) -> String {
        switch error {
        case LogSessionWriterError.failedToOpen(let reason),
             LogSessionWriterError.failedToAppend(let reason):
            return reason
        case LogSessionWriterError.notOpen:
            return "Log session is not open."
        default:
            return error.localizedDescription
        }
    }
}
