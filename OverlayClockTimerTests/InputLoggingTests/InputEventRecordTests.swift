import XCTest
@testable import OverlayClockTimer

final class InputEventRecordTests: XCTestCase {
    func testSortsRecordsNewestFirstByCaptureOrder() {
        let oldest = record(order: 1)
        let newest = record(order: 3)
        let middle = record(order: 2)

        let sorted = [oldest, newest, middle].sorted(by: InputEventRecord.newestFirst)

        XCTAssertEqual(sorted.map(\.captureOrder.rawValue), [3, 2, 1])
    }

    func testCaptureOrderIsMonotonicComparableValue() {
        let first = InputEventCaptureOrder(1)
        let second = InputEventCaptureOrder(2)

        XCTAssertLessThan(first, second)
        XCTAssertGreaterThan(second, first)
    }

    func testRecordShapeContainsOnlyAllowedFields() {
        let record = InputEventRecord(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
            captureOrder: InputEventCaptureOrder(10),
            timestamp: "12:34:56.789",
            eventName: "s"
        )

        let labels = Set(Mirror(reflecting: record).children.compactMap(\.label))

        XCTAssertEqual(labels, ["id", "captureOrder", "timestamp", "eventName"])
        XCTAssertFalse(labels.contains("applicationName"))
        XCTAssertFalse(labels.contains("windowTitle"))
        XCTAssertFalse(labels.contains("coordinates"))
        XCTAssertFalse(labels.contains("scrollCoordinates"))
        XCTAssertFalse(labels.contains("scrollDeltaMagnitude"))
        XCTAssertFalse(labels.contains("clipboardContent"))
        XCTAssertFalse(labels.contains("textFieldIdentifier"))
        XCTAssertFalse(labels.contains("processMetadata"))
        XCTAssertFalse(labels.contains("networkIdentifier"))
        XCTAssertFalse(labels.contains("category"))
        XCTAssertFalse(labels.contains("type"))
        XCTAssertFalse(labels.contains("phase"))
    }

    func testLogLineContainsOnlyAllowedRecordData() {
        let record = InputEventRecord(
            captureOrder: InputEventCaptureOrder(42),
            timestamp: "00:00:01.234",
            eventName: "LM ↓"
        )

        let logLine = record.logLine

        XCTAssertEqual(logLine, "00:00:01.234\tLM ↓")
        XCTAssertFalse(logLine.contains("order="))
        XCTAssertFalse(logLine.contains("timestamp="))
        XCTAssertFalse(logLine.contains("category="))
        XCTAssertFalse(logLine.contains("type="))
        XCTAssertFalse(logLine.contains("name="))
        XCTAssertFalse(logLine.contains("phase="))
        XCTAssertFalse(logLine.localizedCaseInsensitiveContains("app name"))
        XCTAssertFalse(logLine.localizedCaseInsensitiveContains("window title"))
        XCTAssertFalse(logLine.localizedCaseInsensitiveContains("coordinates"))
        XCTAssertFalse(logLine.localizedCaseInsensitiveContains("delta"))
        XCTAssertFalse(logLine.localizedCaseInsensitiveContains("clipboard"))
        XCTAssertFalse(logLine.localizedCaseInsensitiveContains("text field"))
        XCTAssertFalse(logLine.localizedCaseInsensitiveContains("process"))
        XCTAssertFalse(logLine.localizedCaseInsensitiveContains("network"))
    }

    func testLogLineSanitizesTabsAndNewlinesInsideFields() {
        let record = InputEventRecord(
            captureOrder: InputEventCaptureOrder(1),
            timestamp: "00:00:01.234\n",
            eventName: "Command\tC"
        )

        XCTAssertEqual(record.logLine, "00:00:01.234 \tCommand C")
    }

    private func record(order: UInt64) -> InputEventRecord {
        InputEventRecord(
            captureOrder: InputEventCaptureOrder(order),
            timestamp: "12:34:56.789",
            eventName: "s"
        )
    }
}
