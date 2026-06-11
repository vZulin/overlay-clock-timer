import XCTest
@testable import OverlayClockTimer

@MainActor
final class InputLoggingPerformanceTests: XCTestCase {
    func testPanelOpenLatencyStaysUnderTwoHundredMilliseconds() {
        let store = InputEventStore(preferences: OverlayPreferences.defaults)

        let startedAt = Date()
        store.openPanel()
        let elapsed = Date().timeIntervalSince(startedAt)

        XCTAssertTrue(store.isPanelOpen)
        XCTAssertLessThan(elapsed, 0.2)
    }

    func testMaximumRowLimitTrimmingStaysResponsive() {
        let store = InputEventStore(preferences: preferences(rowLimit: 50))

        store.openPanel()
        let startedAt = Date()
        for index in 1...500 {
            store.append(record(order: UInt64(index)))
        }
        let elapsed = Date().timeIntervalSince(startedAt)

        XCTAssertEqual(store.visibleRows.count, 50)
        XCTAssertEqual(store.visibleRows.first?.eventName, "event-500")
        XCTAssertLessThan(elapsed, 0.2)
    }

    func testNonblockingLogAppendPathStaysResponsive() {
        let writer = PerformanceLogSessionWriter()
        let store = InputEventStore(
            preferences: preferences(rowLimit: 50),
            logSessionWriter: writer
        )

        store.openPanel()
        let startedAt = Date()
        for index in 1...500 {
            store.recordKeyboardEvent(
                KeyboardInputEvent(
                    characters: "s",
                    key: "S",
                    modifiers: [],
                    isRepeat: false
                ),
                timestamp: "00:00:00.\(String(format: "%03d", index % 1000))"
            )
        }
        let elapsed = Date().timeIntervalSince(startedAt)

        XCTAssertEqual(writer.appendedLineCount, 500)
        XCTAssertEqual(store.visibleRows.count, 50)
        XCTAssertLessThan(elapsed, 0.2)
    }

    func testStoppedObserverDoesNotDeliverIdleEvents() {
        let source = PerformanceInputEventSource()
        let observer = InputEventObserver(eventSource: source)
        var deliveredEventCount = 0

        observer.startObservation(
            keyboardHandler: { _ in deliveredEventCount += 1 },
            mouseHandler: { _ in deliveredEventCount += 1 },
            scrollHandler: { _ in deliveredEventCount += 1 }
        )
        observer.stopObservation()

        let startedAt = Date()
        for _ in 0..<500 {
            source.emitKeyboardEvent()
            source.emitMouseEvent()
            source.emitScrollEvent()
        }
        let elapsed = Date().timeIntervalSince(startedAt)

        XCTAssertEqual(deliveredEventCount, 0)
        XCTAssertLessThan(elapsed, 0.2)
    }

    private func preferences(rowLimit: Int) -> OverlayPreferences {
        var preferences = OverlayPreferences.defaults
        preferences.eventTableRowLimit = rowLimit
        return preferences.validated()
    }

    private func record(order: UInt64) -> InputEventRecord {
        InputEventRecord(
            captureOrder: InputEventCaptureOrder(order),
            timestamp: "12:34:56.789",
            eventName: "event-\(order)"
        )
    }
}

private final class PerformanceLogSessionWriter: LogSessionWriting {
    private(set) var appendedLineCount = 0
    private(set) var currentSession: LogSessionFile?

    func open() throws -> LogSessionFile {
        let session = LogSessionFile(
            url: URL(fileURLWithPath: "/tmp/input-logging-performance.log"),
            createdAt: Date(timeIntervalSince1970: 0),
            status: .open
        )
        currentSession = session
        return session
    }

    func append(_ record: InputEventRecord) throws {
        _ = record.logLine
        appendedLineCount += 1
    }

    func close() {
        currentSession = currentSession.map {
            LogSessionFile(url: $0.url, createdAt: $0.createdAt, status: .closed)
        }
    }
}

@MainActor
private final class PerformanceInputEventSource: InputEventSource {
    private var keyboardHandler: KeyboardInputEventHandler?
    private var mouseHandler: MouseInputEventHandler?
    private var scrollHandler: ScrollInputEventHandler?

    func startObservation(
        keyboardHandler: @escaping KeyboardInputEventHandler,
        mouseHandler: @escaping MouseInputEventHandler,
        scrollHandler: @escaping ScrollInputEventHandler
    ) -> InputLoggingSessionStatus {
        self.keyboardHandler = keyboardHandler
        self.mouseHandler = mouseHandler
        self.scrollHandler = scrollHandler
        return .active
    }

    func stopObservation() {
        keyboardHandler = nil
        mouseHandler = nil
        scrollHandler = nil
    }

    func emitKeyboardEvent() {
        keyboardHandler?(
            KeyboardInputEvent(
                characters: "s",
                key: "S",
                modifiers: [],
                isRepeat: false
            )
        )
    }

    func emitMouseEvent() {
        mouseHandler?(MouseInputEvent(button: .left, phase: .mouseDown))
    }

    func emitScrollEvent() {
        scrollHandler?(ScrollInputEvent(direction: .up))
    }
}
