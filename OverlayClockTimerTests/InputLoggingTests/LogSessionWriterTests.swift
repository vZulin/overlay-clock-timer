import XCTest
@testable import OverlayClockTimer

final class LogSessionWriterTests: XCTestCase {
    private var temporaryDirectoryURL: URL!

    override func setUpWithError() throws {
        try super.setUpWithError()
        temporaryDirectoryURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("LogSessionWriterTests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(
            at: temporaryDirectoryURL,
            withIntermediateDirectories: true
        )
    }

    override func tearDownWithError() throws {
        if let temporaryDirectoryURL {
            try? FileManager.default.removeItem(at: temporaryDirectoryURL)
        }
        temporaryDirectoryURL = nil
        try super.tearDownWithError()
    }

    func testOpenCreatesSessionFileWithExpectedName() throws {
        let writer = writer(date: date(year: 2026, month: 6, day: 11, hour: 14, minute: 30, second: 5))

        let session = try writer.open()

        XCTAssertEqual(session.url.lastPathComponent, "2026-06-11_14-30-05.log")
        XCTAssertTrue(FileManager.default.fileExists(atPath: session.url.path))
        XCTAssertEqual(session.status, .open)
    }

    func testOpenUsesCollisionSafeVariantWhenBaseFileExists() throws {
        let writer = writer(date: date(year: 2026, month: 6, day: 11, hour: 14, minute: 30, second: 5))
        let existingURL = temporaryDirectoryURL.appendingPathComponent("2026-06-11_14-30-05.log")
        FileManager.default.createFile(atPath: existingURL.path, contents: Data())

        let session = try writer.open()

        XCTAssertEqual(session.url.lastPathComponent, "2026-06-11_14-30-05-1.log")
        XCTAssertTrue(FileManager.default.fileExists(atPath: session.url.path))
    }

    func testAppendWritesRecordLinesWhileOpen() async throws {
        let writer = writer()
        let session = try writer.open()

        try await writer.append(record())
        writer.close()

        let content = try String(contentsOf: session.url, encoding: .utf8)
        XCTAssertEqual(content, "12:34:56.789\ts\n")
        XCTAssertFalse(content.contains("order="))
        XCTAssertFalse(content.contains("timestamp="))
        XCTAssertFalse(content.contains("category="))
        XCTAssertFalse(content.contains("type="))
        XCTAssertFalse(content.contains("name="))
        XCTAssertFalse(content.contains("phase="))
    }

    func testAppendKeepsExistingLinesAndWritesMixedTimestampFormats() async throws {
        let writer = writer()
        let session = try writer.open()

        try await writer.append(record(order: 1, timestamp: "12:34:56.789", eventName: "s"))
        try await writer.append(record(order: 2, timestamp: "1782918314123", eventName: "LM ↓"))
        writer.close()

        let content = try String(contentsOf: session.url, encoding: .utf8)
        XCTAssertEqual(content, "12:34:56.789\ts\n1782918314123\tLM ↓\n")
    }

    func testSessionFileNameDoesNotChangeWhenMixedTimestampFormatsAreAppended() async throws {
        let writer = writer(date: date(year: 2026, month: 7, day: 1, hour: 15, minute: 5, second: 14))
        let session = try writer.open()

        try await writer.append(record(order: 1, timestamp: "15:05:14.123", eventName: "s"))
        let urlAfterStandardAppend = writer.currentSession?.url
        try await writer.append(record(order: 2, timestamp: "1782918314123", eventName: "LM ↓"))
        let urlAfterEpochAppend = writer.currentSession?.url
        writer.close()

        XCTAssertEqual(session.url.lastPathComponent, "2026-07-01_15-05-14.log")
        XCTAssertEqual(urlAfterStandardAppend, session.url)
        XCTAssertEqual(urlAfterEpochAppend, session.url)
        XCTAssertTrue(FileManager.default.fileExists(atPath: session.url.path))
    }

    func testClosePreventsAdditionalWrites() async throws {
        let writer = writer()
        let session = try writer.open()

        try await writer.append(record(order: 1))
        writer.close()

        do {
            try await writer.append(record(order: 2))
            XCTFail("Expected append to fail after close.")
        } catch {
            XCTAssertEqual(error as? LogSessionWriterError, .notOpen)
        }
        let content = try String(contentsOf: session.url, encoding: .utf8)
        XCTAssertEqual(content, "12:34:56.789\ts\n")
        XCTAssertEqual(writer.currentSession?.status, .closed)
    }

    func testOpenReportsFailureWhenLogDirectoryCannotBeCreated() throws {
        let blockedURL = temporaryDirectoryURL.appendingPathComponent("blocked")
        FileManager.default.createFile(atPath: blockedURL.path, contents: Data())
        let writer = LogSessionWriter(logDirectoryURL: blockedURL)

        XCTAssertThrowsError(try writer.open())
        guard case .failed = writer.currentSession?.status else {
            return XCTFail("Expected failed session status")
        }
    }

    private func writer(date: Date = Date(timeIntervalSince1970: 0)) -> LogSessionWriter {
        LogSessionWriter(
            logDirectoryURL: temporaryDirectoryURL,
            dateProvider: { date },
            timeZone: TimeZone(secondsFromGMT: 0)!
        )
    }

    private func record(
        order: UInt64 = 1,
        timestamp: String = "12:34:56.789",
        eventName: String = "s"
    ) -> InputEventRecord {
        InputEventRecord(
            captureOrder: InputEventCaptureOrder(order),
            timestamp: timestamp,
            eventName: eventName
        )
    }

    private func date(
        year: Int,
        month: Int,
        day: Int,
        hour: Int,
        minute: Int,
        second: Int
    ) -> Date {
        var components = DateComponents()
        components.calendar = Calendar(identifier: .gregorian)
        components.timeZone = TimeZone(secondsFromGMT: 0)
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        components.second = second
        return components.date!
    }
}
