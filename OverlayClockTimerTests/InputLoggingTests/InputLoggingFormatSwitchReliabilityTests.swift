import Foundation
import XCTest
@testable import OverlayClockTimer

@MainActor
final class InputLoggingFormatSwitchReliabilityTests: XCTestCase {
    func testLoopedFormatSwitchTrialsPreserveExistingRowsAndLogLines() async {
        let writer = ReliabilityLogSessionWriter()
        let store = InputEventStore(
            preferences: preferences(rowLimit: 50),
            logSessionWriter: writer
        )

        store.openPanel()

        for trial in 1...10 {
            store.recordKeyboardEvent(
                KeyboardInputEvent(characters: "s", key: "S", modifiers: [], isRepeat: false),
                timestamp: standardTimestamp(for: trial)
            )

            var switchedPreferences = preferences(rowLimit: 50)
            switchedPreferences.timeFormat = .epochMilliseconds
            store.apply(preferences: switchedPreferences)

            store.recordMouseEvent(
                MouseInputEvent(button: .left, phase: .mouseDown),
                timestamp: epochTimestamp(for: trial)
            )

            var standardPreferences = preferences(rowLimit: 50)
            standardPreferences.timeFormat = .standardMilliseconds
            store.apply(preferences: standardPreferences)
        }

        let appendedRecords = await writer.waitForAppendedRecords(count: 20)

        let expectedLogLines = (1...10).flatMap { trial in
            [
                "\(standardTimestamp(for: trial))\ts",
                "\(epochTimestamp(for: trial))\tLM ↓"
            ]
        }
        XCTAssertEqual(appendedRecords.map(\.logLine), expectedLogLines)

        let visibleRowsNewestFirst = store.visibleRows
        XCTAssertEqual(visibleRowsNewestFirst.count, 20)
        XCTAssertEqual(visibleRowsNewestFirst.first?.timestamp, epochTimestamp(for: 10))
        XCTAssertTrue(visibleRowsNewestFirst.contains { $0.timestamp == standardTimestamp(for: 1) })
        XCTAssertTrue(visibleRowsNewestFirst.contains { $0.timestamp == epochTimestamp(for: 1) })
    }

    private func preferences(rowLimit: Int) -> OverlayPreferences {
        var preferences = OverlayPreferences.defaults
        preferences.eventTableRowLimit = rowLimit
        preferences.preserveEventTableBetweenOpens = true
        return preferences.validated()
    }

    private func standardTimestamp(for trial: Int) -> String {
        String(format: "12:34:56.%03d", trial)
    }

    private func epochTimestamp(for trial: Int) -> String {
        String(format: "1782918314%03d", trial)
    }
}

private final class ReliabilityLogSessionWriter: LogSessionWriting, @unchecked Sendable {
    private let lock = NSLock()
    private var _appendedRecords: [InputEventRecord] = []
    private var _currentSession: LogSessionFile?

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
        let session = LogSessionFile(
            url: URL(fileURLWithPath: "/tmp/input-logging-format-switch-reliability.log"),
            createdAt: Date(timeIntervalSince1970: 0),
            status: .open
        )
        currentSession = session
        return session
    }

    func append(_ record: InputEventRecord) async throws {
        lock.withLock {
            _appendedRecords.append(record)
        }
    }

    func close() {
        currentSession = currentSession.map {
            LogSessionFile(url: $0.url, createdAt: $0.createdAt, status: .closed)
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

private extension NSLock {
    func withLock<T>(_ work: () throws -> T) rethrows -> T {
        lock()
        defer { unlock() }
        return try work()
    }
}
