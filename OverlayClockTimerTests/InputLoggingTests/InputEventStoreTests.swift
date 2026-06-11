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
