import XCTest
@testable import OverlayClockTimer

@MainActor
final class InputEventObserverTests: XCTestCase {
    func testObservationStartsAndForwardsKeyboardAndMouseEvents() {
        let source = TestInputEventSource()
        let observer = InputEventObserver(eventSource: source)
        var receivedKeyboardEvents: [KeyboardInputEvent] = []
        var receivedMouseEvents: [MouseInputEvent] = []

        let status = observer.startObservation(
            keyboardHandler: { event in
                receivedKeyboardEvents.append(event)
            },
            mouseHandler: { event in
                receivedMouseEvents.append(event)
            }
        )

        source.emitKeyboardEvent(keyboardEvent("s"))
        source.emitMouseEvent(MouseInputEvent(phase: .mouseDown))

        XCTAssertEqual(status, .active)
        XCTAssertEqual(observer.status, .active)
        XCTAssertEqual(source.startObservationCallCount, 1)
        XCTAssertEqual(receivedKeyboardEvents.map(\.characters), ["s"])
        XCTAssertEqual(receivedMouseEvents.map(\.phase), [.mouseDown])
    }

    func testStopObservationIsIdempotentAndDropsLaterKeyboardAndMouseEvents() {
        let source = TestInputEventSource()
        let observer = InputEventObserver(eventSource: source)
        var receivedKeyboardEvents: [KeyboardInputEvent] = []
        var receivedMouseEvents: [MouseInputEvent] = []

        observer.startObservation(
            keyboardHandler: { event in
                receivedKeyboardEvents.append(event)
            },
            mouseHandler: { event in
                receivedMouseEvents.append(event)
            }
        )
        observer.stopObservation()
        observer.stopObservation()
        source.emitKeyboardEvent(keyboardEvent("s"))
        source.emitMouseEvent(MouseInputEvent(phase: .mouseUp))

        XCTAssertEqual(observer.status, .inactive)
        XCTAssertEqual(source.stopObservationCallCount, 1)
        XCTAssertTrue(receivedKeyboardEvents.isEmpty)
        XCTAssertTrue(receivedMouseEvents.isEmpty)
    }

    func testUnavailableObservationDoesNotInstallHandlers() {
        let source = TestInputEventSource()
        source.startStatus = .unavailable(reason: "Input monitoring permission is unavailable.")
        let observer = InputEventObserver(eventSource: source)
        var receivedKeyboardEvents: [KeyboardInputEvent] = []
        var receivedMouseEvents: [MouseInputEvent] = []

        let status = observer.startObservation(
            keyboardHandler: { event in
                receivedKeyboardEvents.append(event)
            },
            mouseHandler: { event in
                receivedMouseEvents.append(event)
            }
        )
        source.emitKeyboardEvent(keyboardEvent("s"))
        source.emitMouseEvent(MouseInputEvent(phase: .mouseDown))

        XCTAssertEqual(status, .unavailable(reason: "Input monitoring permission is unavailable."))
        XCTAssertEqual(observer.status, .unavailable(reason: "Input monitoring permission is unavailable."))
        XCTAssertTrue(receivedKeyboardEvents.isEmpty)
        XCTAssertTrue(receivedMouseEvents.isEmpty)
    }

    private func keyboardEvent(_ characters: String) -> KeyboardInputEvent {
        KeyboardInputEvent(
            characters: characters,
            key: characters.uppercased(),
            modifiers: [],
            isRepeat: false
        )
    }
}

@MainActor
private final class TestInputEventSource: InputEventSource {
    var startStatus: InputLoggingSessionStatus = .active
    private(set) var startObservationCallCount = 0
    private(set) var stopObservationCallCount = 0

    private var keyboardHandler: KeyboardInputEventHandler?
    private var mouseHandler: MouseInputEventHandler?

    func startObservation(
        keyboardHandler: @escaping KeyboardInputEventHandler,
        mouseHandler: @escaping MouseInputEventHandler
    ) -> InputLoggingSessionStatus {
        startObservationCallCount += 1

        guard startStatus == .active else {
            self.keyboardHandler = nil
            self.mouseHandler = nil
            return startStatus
        }

        self.keyboardHandler = keyboardHandler
        self.mouseHandler = mouseHandler
        return .active
    }

    func stopObservation() {
        guard keyboardHandler != nil || mouseHandler != nil else {
            return
        }

        stopObservationCallCount += 1
        keyboardHandler = nil
        mouseHandler = nil
    }

    func emitKeyboardEvent(_ event: KeyboardInputEvent) {
        keyboardHandler?(event)
    }

    func emitMouseEvent(_ event: MouseInputEvent) {
        mouseHandler?(event)
    }
}
