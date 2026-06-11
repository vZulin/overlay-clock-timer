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

    func testKeyboardEventsInsertRowsNewestFirstTrimToLimitAndAppendLogRecords() async {
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

        let appendedRecords = await writer.waitForAppendedRecords(count: 6)

        XCTAssertEqual(store.visibleRows.map(\.captureOrder.rawValue), [6, 5, 4, 3, 2])
        XCTAssertEqual(store.visibleRows.first?.eventName, "s")
        XCTAssertEqual(appendedRecords.map(\.captureOrder.rawValue), [1, 2, 3, 4, 5, 6])
        XCTAssertEqual(appendedRecords.first?.logLine, "00:00:00.001\ts")
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

    func testPanelOpenCreatesNewSessionAndCloseStopsFurtherWrites() async {
        let writer = RecordingLogSessionWriter()
        let store = InputEventStore(
            preferences: preferences(rowLimit: 5, preservesRows: false),
            logSessionWriter: writer
        )

        store.openPanel()
        store.recordMouseEvent(MouseInputEvent(button: .left, phase: .mouseDown), timestamp: "12:00:00.001")
        _ = await writer.waitForAppendedRecords(count: 1)
        store.closePanel()
        store.recordMouseEvent(MouseInputEvent(button: .left, phase: .mouseUp), timestamp: "12:00:00.002")

        XCTAssertEqual(writer.openCallCount, 1)
        XCTAssertEqual(writer.closeCallCount, 1)
        XCTAssertEqual(writer.appendedRecords.map(\.eventName), ["LM ↓"])
        XCTAssertEqual(store.fileRecordingStatus, .inactive)
    }

    func testMouseEventsAppendSeparateDownAndUpRecords() async {
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

        let appendedRecords = await writer.waitForAppendedRecords(count: 4)

        XCTAssertEqual(store.visibleRows.map(\.eventName), ["SM ↓", "SM ↑", "RM ↑", "LM ↓"])
        XCTAssertEqual(appendedRecords.map(\.eventName), ["LM ↓", "RM ↑", "SM ↑", "SM ↓"])
        XCTAssertEqual(
            appendedRecords.map(\.logLine),
            [
                "12:00:00.001\tLM ↓",
                "12:00:00.002\tRM ↑",
                "12:00:00.003\tSM ↑",
                "12:00:00.004\tSM ↓"
            ]
        )
    }

    func testPreservedRowsAreVisibleButExcludedFromNewSessionFile() async {
        let writer = RecordingLogSessionWriter()
        let store = InputEventStore(
            preferences: preferences(rowLimit: 5, preservesRows: true),
            logSessionWriter: writer
        )

        store.openPanel()
        store.recordMouseEvent(MouseInputEvent(button: .left, phase: .mouseDown), timestamp: "12:00:00.001")
        _ = await writer.waitForAppendedRecords(count: 1)
        store.closePanel()
        writer.removeAllAppendedRecords()

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

    func testAppendFailureReportsUnavailableStatusAndKeepsVisibleRow() async {
        let writer = RecordingLogSessionWriter()
        writer.appendError = LogSessionWriterError.failedToAppend("Disk is full.")
        let store = InputEventStore(
            preferences: preferences(rowLimit: 5, preservesRows: false),
            logSessionWriter: writer
        )

        store.openPanel()
        store.recordMouseEvent(MouseInputEvent(button: .left, phase: .mouseUp), timestamp: "12:00:00.001")

        await waitUntil { store.fileRecordingStatus == .unavailable(reason: "Disk is full.") }

        XCTAssertEqual(store.fileRecordingStatus, .unavailable(reason: "Disk is full."))
        XCTAssertEqual(store.visibleRows.map(\.eventName), ["LM ↑"])
    }

    func testSessionLogLinesUseTimestampTabEventNameOnly() async {
        let writer = RecordingLogSessionWriter()
        let store = InputEventStore(
            preferences: preferences(rowLimit: 5, preservesRows: false),
            logSessionWriter: writer
        )

        store.openPanel()
        store.recordMouseEvent(MouseInputEvent(button: .additional(4), phase: .mouseDown), timestamp: "12:00:00.001")
        store.recordScrollEvent(ScrollInputEvent(direction: .up), timestamp: "12:00:00.002")

        let appendedRecords = await writer.waitForAppendedRecords(count: 2)

        XCTAssertEqual(
            appendedRecords.map(\.logLine),
            [
                "12:00:00.001\t4M ↓",
                "12:00:00.002\tSM ↑"
            ]
        )
        for line in appendedRecords.map(\.logLine) {
            XCTAssertFalse(line.contains("order="))
            XCTAssertFalse(line.contains("timestamp="))
            XCTAssertFalse(line.contains("category="))
            XCTAssertFalse(line.contains("type="))
            XCTAssertFalse(line.contains("name="))
            XCTAssertFalse(line.contains("phase="))
        }
    }

    func testVisibleRowsUpdateBeforeDelayedLogAppendCompletesAndFailureStatusChanges() async {
        let writer = RecordingLogSessionWriter()
        writer.appendDelayNanoseconds = 200_000_000
        writer.appendError = LogSessionWriterError.failedToAppend("Delayed write failed.")
        let store = InputEventStore(
            preferences: preferences(rowLimit: 5, preservesRows: false),
            logSessionWriter: writer
        )

        store.openPanel()
        store.recordKeyboardEvent(
            KeyboardInputEvent(
                characters: "s",
                key: "S",
                modifiers: [],
                isRepeat: false
            ),
            timestamp: "00:00:00.123"
        )

        XCTAssertEqual(store.visibleRows.first?.eventName, "s")
        XCTAssertEqual(store.visibleRows.first?.timestamp, "00:00:00.123")
        XCTAssertEqual(store.fileRecordingStatus, .active)
        XCTAssertTrue(writer.appendedRecords.isEmpty)

        await waitUntil {
            store.fileRecordingStatus == .unavailable(reason: "Delayed write failed.")
        }

        XCTAssertEqual(store.visibleRows.first?.eventName, "s")
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

private final class RecordingLogSessionWriter: LogSessionWriting, @unchecked Sendable {
    var openError: Error?
    var appendError: Error?
    var appendDelayNanoseconds: UInt64 = 0

    private let lock = NSLock()
    private var _openCallCount = 0
    private var _closeCallCount = 0
    private var _appendedRecords: [InputEventRecord] = []
    private var _currentSession: LogSessionFile?

    var openCallCount: Int {
        lock.withLock { _openCallCount }
    }

    var closeCallCount: Int {
        lock.withLock { _closeCallCount }
    }

    var appendedRecords: [InputEventRecord] {
        lock.withLock { _appendedRecords }
    }

    private(set) var currentSession: LogSessionFile? {
        get {
            lock.withLock { _currentSession }
        }
        set {
            lock.withLock { _currentSession = newValue }
        }
    }

    func open() throws -> LogSessionFile {
        lock.withLock { _openCallCount += 1 }
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

    func append(_ record: InputEventRecord) async throws {
        if appendDelayNanoseconds > 0 {
            try? await Task.sleep(nanoseconds: appendDelayNanoseconds)
        }

        if let appendError {
            throw appendError
        }

        lock.withLock {
            _appendedRecords.append(record)
        }
    }

    func close() {
        lock.withLock { _closeCallCount += 1 }
        currentSession = currentSession.map {
            LogSessionFile(url: $0.url, createdAt: $0.createdAt, status: .closed)
        }
    }

    func removeAllAppendedRecords() {
        lock.withLock {
            _appendedRecords.removeAll()
        }
    }

    func waitForAppendedRecords(
        count: Int,
        timeout: TimeInterval = 2,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async -> [InputEventRecord] {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            let records = appendedRecords
            if records.count >= count {
                return records
            }

            try? await Task.sleep(nanoseconds: 10_000_000)
        }

        XCTFail("Timed out waiting for \(count) appended records.", file: file, line: line)
        return appendedRecords
    }
}

private func waitUntil(
    timeout: TimeInterval = 2,
    condition: @MainActor @escaping () -> Bool,
    file: StaticString = #filePath,
    line: UInt = #line
) async {
    let deadline = Date().addingTimeInterval(timeout)
    while Date() < deadline {
        if await condition() {
            return
        }

        try? await Task.sleep(nanoseconds: 10_000_000)
    }

    XCTFail("Timed out waiting for condition.", file: file, line: line)
}

private extension NSLock {
    func withLock<T>(_ work: () throws -> T) rethrows -> T {
        lock()
        defer { unlock() }
        return try work()
    }
}
