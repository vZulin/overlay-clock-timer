import XCTest
@testable import OverlayClockTimer

@MainActor
final class InputEventStoreTests: XCTestCase {
    func testPanelOpenStartsWithEmptyRowsByDefault() {
        let store = InputEventStore(preferences: preferences(rowLimit: 5, preservesRows: false))

        store.openPanel()
        store.append(record(order: 1))
        store.closePanel()
        store.openPanel()

        XCTAssertTrue(store.isPanelOpen)
        XCTAssertTrue(store.visibleRows.isEmpty)
        XCTAssertEqual(store.captureStatus, .inactive)
        XCTAssertEqual(store.fileRecordingStatus, .inactive)
    }

    func testRowsAreNewestFirstAndTrimmedToLimit() {
        let store = InputEventStore(preferences: preferences(rowLimit: 5, preservesRows: false))

        store.openPanel()
        store.append(record(order: 1))
        store.append(record(order: 2))
        store.append(record(order: 3))
        store.append(record(order: 4))
        store.append(record(order: 5))
        store.append(record(order: 6))

        XCTAssertEqual(store.visibleRows.map(\.captureOrder.rawValue), [6, 5, 4, 3, 2])
    }

    func testPreservesRowsAcrossPanelOpensWhenEnabledForCurrentLaunch() {
        let store = InputEventStore(preferences: preferences(rowLimit: 5, preservesRows: true))

        store.openPanel()
        store.append(record(order: 1))
        store.append(record(order: 2))
        store.closePanel()
        store.openPanel()

        XCTAssertEqual(store.visibleRows.map(\.captureOrder.rawValue), [2, 1])
    }

    func testApplyingSmallerRowLimitTrimsVisibleAndPreservedRows() {
        let store = InputEventStore(preferences: preferences(rowLimit: 8, preservesRows: true))

        store.openPanel()
        (1...8).forEach { store.append(record(order: UInt64($0))) }
        store.closePanel()

        store.apply(preferences: preferences(rowLimit: 5, preservesRows: true))
        store.openPanel()

        XCTAssertEqual(store.visibleRows.map(\.captureOrder.rawValue), [8, 7, 6, 5, 4])
    }

    func testClearPreservedRowsRemovesSameLaunchHistory() {
        let store = InputEventStore(preferences: preferences(rowLimit: 5, preservesRows: true))

        store.openPanel()
        store.append(record(order: 1))
        store.closePanel()
        store.clearPreservedRows()
        store.openPanel()

        XCTAssertTrue(store.visibleRows.isEmpty)
    }

    func testKeyboardEventsInsertRowsNewestFirstTrimToLimitAndAppendLogRecords() {
        let writer = RecordingLogSessionWriter()
        let store = InputEventStore(
            preferences: preferences(rowLimit: 5, preservesRows: false),
            logSessionWriter: writer
        )

        store.openPanel()
        (1...6).forEach { index in
            store.recordKeyboardEvent(
                KeyboardInputEvent(
                    characters: "s",
                    key: "S",
                    modifiers: [],
                    isRepeat: index == 6
                ),
                timestamp: "00:00:00.00\(index)"
            )
        }

        XCTAssertEqual(store.visibleRows.map(\.captureOrder.rawValue), [6, 5, 4, 3, 2])
        XCTAssertEqual(store.visibleRows.first?.phase, .repeatKeyDown)
        XCTAssertEqual(writer.appendedRecords.map(\.captureOrder.rawValue), [1, 2, 3, 4, 5, 6])
        XCTAssertEqual(store.fileRecordingStatus, .active)
    }

    func testKeyboardEventsAreIgnoredWhilePanelIsClosed() {
        let writer = RecordingLogSessionWriter()
        let store = InputEventStore(
            preferences: preferences(rowLimit: 5, preservesRows: false),
            logSessionWriter: writer
        )

        store.recordKeyboardEvent(
            KeyboardInputEvent(
                characters: "s",
                key: "S",
                modifiers: [],
                isRepeat: false
            ),
            timestamp: "00:00:00.001"
        )

        XCTAssertTrue(store.visibleRows.isEmpty)
        XCTAssertTrue(writer.appendedRecords.isEmpty)
    }

    func testPanelOpenCreatesNewSessionAndCloseStopsFurtherWrites() {
        let writer = RecordingLogSessionWriter()
        let store = InputEventStore(
            preferences: preferences(rowLimit: 5, preservesRows: false),
            logSessionWriter: writer
        )

        store.openPanel()
        store.recordMouseEvent(MouseInputEvent(phase: .mouseDown), timestamp: "12:00:00.001")
        store.closePanel()
        store.recordMouseEvent(MouseInputEvent(phase: .mouseUp), timestamp: "12:00:00.002")

        XCTAssertEqual(writer.openCallCount, 1)
        XCTAssertEqual(writer.closeCallCount, 1)
        XCTAssertEqual(writer.appendedRecords.map(\.name), ["Mouse Down"])
        XCTAssertEqual(store.fileRecordingStatus, .inactive)
    }

    func testMouseEventsAppendSeparateDownAndUpRecords() {
        let writer = RecordingLogSessionWriter()
        let store = InputEventStore(
            preferences: preferences(rowLimit: 5, preservesRows: false),
            logSessionWriter: writer
        )

        store.openPanel()
        store.recordMouseEvent(MouseInputEvent(phase: .mouseDown), timestamp: "12:00:00.001")
        store.recordMouseEvent(MouseInputEvent(phase: .mouseUp), timestamp: "12:00:00.002")

        XCTAssertEqual(store.visibleRows.map(\.name), ["Mouse Up", "Mouse Down"])
        XCTAssertEqual(store.visibleRows.map(\.phase), [.mouseUp, .mouseDown])
        XCTAssertEqual(writer.appendedRecords.map(\.name), ["Mouse Down", "Mouse Up"])
        XCTAssertEqual(writer.appendedRecords.map(\.category), [.mouse, .mouse])
    }

    func testPreservedRowsAreVisibleButExcludedFromNewSessionFile() {
        let writer = RecordingLogSessionWriter()
        let store = InputEventStore(
            preferences: preferences(rowLimit: 5, preservesRows: true),
            logSessionWriter: writer
        )

        store.openPanel()
        store.recordMouseEvent(MouseInputEvent(phase: .mouseDown), timestamp: "12:00:00.001")
        store.closePanel()
        writer.appendedRecords.removeAll()

        store.openPanel()

        XCTAssertEqual(store.visibleRows.map(\.name), ["Mouse Down"])
        XCTAssertTrue(writer.appendedRecords.isEmpty)
        XCTAssertEqual(writer.openCallCount, 2)
    }

    func testFileOpenFailureKeepsRowsUsableAndReportsUnavailableStatus() {
        let writer = RecordingLogSessionWriter()
        writer.openError = LogSessionWriterError.failedToOpen("Cannot create log file.")
        let store = InputEventStore(
            preferences: preferences(rowLimit: 5, preservesRows: false),
            logSessionWriter: writer
        )

        store.openPanel()
        store.recordMouseEvent(MouseInputEvent(phase: .mouseDown), timestamp: "12:00:00.001")

        XCTAssertEqual(store.fileRecordingStatus, .unavailable(reason: "Cannot create log file."))
        XCTAssertEqual(store.visibleRows.map(\.name), ["Mouse Down"])
        XCTAssertTrue(writer.appendedRecords.isEmpty)
    }

    func testAppendFailureReportsUnavailableStatusAndKeepsVisibleRow() {
        let writer = RecordingLogSessionWriter()
        writer.appendError = LogSessionWriterError.failedToAppend("Disk is full.")
        let store = InputEventStore(
            preferences: preferences(rowLimit: 5, preservesRows: false),
            logSessionWriter: writer
        )

        store.openPanel()
        store.recordMouseEvent(MouseInputEvent(phase: .mouseUp), timestamp: "12:00:00.001")

        XCTAssertEqual(store.fileRecordingStatus, .unavailable(reason: "Disk is full."))
        XCTAssertEqual(store.visibleRows.map(\.name), ["Mouse Up"])
    }

    private func preferences(rowLimit: Int, preservesRows: Bool) -> OverlayPreferences {
        var preferences = OverlayPreferences.defaults
        preferences.eventTableRowLimit = rowLimit
        preferences.preserveEventTableBetweenOpens = preservesRows
        return preferences.validated()
    }

    private func record(order: UInt64) -> InputEventRecord {
        InputEventRecord(
            captureOrder: InputEventCaptureOrder(order),
            timestamp: "12:34:56.789",
            category: .keyboard,
            name: "s",
            phase: .keyDown
        )
    }
}

private final class RecordingLogSessionWriter: LogSessionWriting {
    var openError: Error?
    var appendError: Error?

    private(set) var openCallCount = 0
    private(set) var closeCallCount = 0
    var appendedRecords: [InputEventRecord] = []
    private(set) var currentSession: LogSessionFile?

    func open() throws -> LogSessionFile {
        openCallCount += 1
        if let openError {
            throw openError
        }

        let session = LogSessionFile(
            url: URL(fileURLWithPath: "/tmp/input-event-store-test.log"),
            createdAt: Date(timeIntervalSince1970: 0),
            status: .open
        )
        currentSession = session
        return session
    }

    func append(_ record: InputEventRecord) throws {
        if let appendError {
            throw appendError
        }

        appendedRecords.append(record)
    }

    func close() {
        closeCallCount += 1
        currentSession = currentSession.map {
            LogSessionFile(url: $0.url, createdAt: $0.createdAt, status: .closed)
        }
    }
}
