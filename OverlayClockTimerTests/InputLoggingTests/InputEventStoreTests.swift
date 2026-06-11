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
        XCTAssertEqual(store.visibleRows.first?.eventName, "s")
        XCTAssertEqual(writer.appendedRecords.map(\.captureOrder.rawValue), [1, 2, 3, 4, 5, 6])
        XCTAssertEqual(writer.appendedRecords.first?.logLine, "00:00:00.001\ts")
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
        store.recordMouseEvent(MouseInputEvent(button: .left, phase: .mouseDown), timestamp: "12:00:00.001")
        store.closePanel()
        store.recordMouseEvent(MouseInputEvent(button: .left, phase: .mouseUp), timestamp: "12:00:00.002")

        XCTAssertEqual(writer.openCallCount, 1)
        XCTAssertEqual(writer.closeCallCount, 1)
        XCTAssertEqual(writer.appendedRecords.map(\.eventName), ["LM ↓"])
        XCTAssertEqual(store.fileRecordingStatus, .inactive)
    }

    func testMouseEventsAppendSeparateDownAndUpRecords() {
        let writer = RecordingLogSessionWriter()
        let store = InputEventStore(
            preferences: preferences(rowLimit: 5, preservesRows: false),
            logSessionWriter: writer
        )

        store.openPanel()
        store.recordMouseEvent(MouseInputEvent(button: .left, phase: .mouseDown), timestamp: "12:00:00.001")
        store.recordMouseEvent(MouseInputEvent(button: .right, phase: .mouseUp), timestamp: "12:00:00.002")
        store.recordScrollEvent(ScrollInputEvent(direction: .up), timestamp: "12:00:00.003")
        store.recordScrollEvent(ScrollInputEvent(direction: .down), timestamp: "12:00:00.004")

        XCTAssertEqual(store.visibleRows.map(\.eventName), ["SM ↓", "SM ↑", "RM ↑", "LM ↓"])
        XCTAssertEqual(writer.appendedRecords.map(\.eventName), ["LM ↓", "RM ↑", "SM ↑", "SM ↓"])
        XCTAssertEqual(
            writer.appendedRecords.map(\.logLine),
            [
                "12:00:00.001\tLM ↓",
                "12:00:00.002\tRM ↑",
                "12:00:00.003\tSM ↑",
                "12:00:00.004\tSM ↓"
            ]
        )
    }

    func testPreservedRowsAreVisibleButExcludedFromNewSessionFile() {
        let writer = RecordingLogSessionWriter()
        let store = InputEventStore(
            preferences: preferences(rowLimit: 5, preservesRows: true),
            logSessionWriter: writer
        )

        store.openPanel()
        store.recordMouseEvent(MouseInputEvent(button: .left, phase: .mouseDown), timestamp: "12:00:00.001")
        store.closePanel()
        writer.appendedRecords.removeAll()

        store.openPanel()

        XCTAssertEqual(store.visibleRows.map(\.eventName), ["LM ↓"])
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
        store.recordMouseEvent(MouseInputEvent(button: .left, phase: .mouseDown), timestamp: "12:00:00.001")

        XCTAssertEqual(store.fileRecordingStatus, .unavailable(reason: "Cannot create log file."))
        XCTAssertEqual(store.visibleRows.map(\.eventName), ["LM ↓"])
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
        store.recordMouseEvent(MouseInputEvent(button: .left, phase: .mouseUp), timestamp: "12:00:00.001")

        XCTAssertEqual(store.fileRecordingStatus, .unavailable(reason: "Disk is full."))
        XCTAssertEqual(store.visibleRows.map(\.eventName), ["LM ↑"])
    }

    func testSessionLogLinesUseTimestampTabEventNameOnly() {
        let writer = RecordingLogSessionWriter()
        let store = InputEventStore(
            preferences: preferences(rowLimit: 5, preservesRows: false),
            logSessionWriter: writer
        )

        store.openPanel()
        store.recordMouseEvent(MouseInputEvent(button: .additional(4), phase: .mouseDown), timestamp: "12:00:00.001")
        store.recordScrollEvent(ScrollInputEvent(direction: .up), timestamp: "12:00:00.002")

        XCTAssertEqual(
            writer.appendedRecords.map(\.logLine),
            [
                "12:00:00.001\t4M ↓",
                "12:00:00.002\tSM ↑"
            ]
        )
        for line in writer.appendedRecords.map(\.logLine) {
            XCTAssertFalse(line.contains("order="))
            XCTAssertFalse(line.contains("timestamp="))
            XCTAssertFalse(line.contains("category="))
            XCTAssertFalse(line.contains("type="))
            XCTAssertFalse(line.contains("name="))
            XCTAssertFalse(line.contains("phase="))
        }
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
            eventName: "s"
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
