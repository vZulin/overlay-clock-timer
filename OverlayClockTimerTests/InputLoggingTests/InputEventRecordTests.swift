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
            category: .keyboard,
            name: "s",
            phase: .keyDown
        )

        let labels = Set(Mirror(reflecting: record).children.compactMap(\.label))

        XCTAssertEqual(labels, ["id", "captureOrder", "timestamp", "category", "name", "phase"])
        XCTAssertFalse(labels.contains("applicationName"))
        XCTAssertFalse(labels.contains("windowTitle"))
        XCTAssertFalse(labels.contains("coordinates"))
        XCTAssertFalse(labels.contains("clipboardContent"))
        XCTAssertFalse(labels.contains("processMetadata"))
        XCTAssertFalse(labels.contains("networkIdentifier"))
    }

    func testLogLineContainsOnlyAllowedRecordData() {
        let record = InputEventRecord(
            captureOrder: InputEventCaptureOrder(42),
            timestamp: "00:00:01.234",
            category: .mouse,
            name: "Mouse Down",
            phase: .mouseDown
        )

        let logLine = record.logLine

        XCTAssertTrue(logLine.contains("order=42"))
        XCTAssertTrue(logLine.contains("timestamp=00:00:01.234"))
        XCTAssertTrue(logLine.contains("category=mouse"))
        XCTAssertTrue(logLine.contains("name=Mouse Down"))
        XCTAssertTrue(logLine.contains("phase=mouseDown"))
        let fieldNames = Set(logLine.split(separator: "\t").compactMap { field in
            field.split(separator: "=", maxSplits: 1).first.map(String.init)
        })

        XCTAssertFalse(fieldNames.contains("app"))
        XCTAssertFalse(fieldNames.contains("window"))
        XCTAssertFalse(fieldNames.contains("x"))
        XCTAssertFalse(fieldNames.contains("y"))
        XCTAssertFalse(fieldNames.contains("clipboard"))
        XCTAssertFalse(fieldNames.contains("process"))
        XCTAssertFalse(fieldNames.contains("network"))
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
