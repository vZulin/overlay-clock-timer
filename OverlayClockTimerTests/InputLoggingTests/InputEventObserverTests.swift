import XCTest
@testable import OverlayClockTimer

@MainActor
final class InputEventObserverTests: XCTestCase {
    func testObservationStartsAndForwardsKeyboardAndMouseEvents() {
        let source = TestInputEventSource()
        let observer = InputEventObserver(eventSource: source)
        var receivedKeyboardEvents: [KeyboardInputEvent] = []
        var receivedMouseEvents: [MouseInputEvent] = []
        var receivedScrollEvents: [ScrollInputEvent] = []

        let status = observer.startObservation(
            keyboardHandler: { event in
                receivedKeyboardEvents.append(event)
            },
            mouseHandler: { event in
                receivedMouseEvents.append(event)
            },
            scrollHandler: { event in
                receivedScrollEvents.append(event)
            }
        )

        source.emitKeyboardEvent(keyboardEvent("s"))
        source.emitMouseEvent(MouseInputEvent(button: .right, phase: .mouseDown))
        source.emitMouseEvent(MouseInputEvent(button: .third, phase: .mouseUp))
        source.emitMouseEvent(MouseInputEvent(button: .additional(4), phase: .mouseDown))
        source.emitScrollEvent(ScrollInputEvent(direction: .up))
        source.emitScrollEvent(ScrollInputEvent(direction: .down))

        XCTAssertEqual(status, .active)
        XCTAssertEqual(observer.status, .active)
        XCTAssertEqual(source.startObservationCallCount, 1)
        XCTAssertEqual(receivedKeyboardEvents.map(\.characters), ["s"])
        XCTAssertEqual(
            receivedMouseEvents,
            [
                MouseInputEvent(button: .right, phase: .mouseDown),
                MouseInputEvent(button: .third, phase: .mouseUp),
                MouseInputEvent(button: .additional(4), phase: .mouseDown)
            ]
        )
        XCTAssertEqual(receivedScrollEvents.map(\.direction), [.up, .down])
    }

    func testStopObservationIsIdempotentAndDropsLaterKeyboardAndMouseEvents() {
        let source = TestInputEventSource()
        let observer = InputEventObserver(eventSource: source)
        var receivedKeyboardEvents: [KeyboardInputEvent] = []
        var receivedMouseEvents: [MouseInputEvent] = []
        var receivedScrollEvents: [ScrollInputEvent] = []

        observer.startObservation(
            keyboardHandler: { event in
                receivedKeyboardEvents.append(event)
            },
            mouseHandler: { event in
                receivedMouseEvents.append(event)
            },
            scrollHandler: { event in
                receivedScrollEvents.append(event)
            }
        )
        observer.stopObservation()
        observer.stopObservation()
        source.emitKeyboardEvent(keyboardEvent("s"))
        source.emitMouseEvent(MouseInputEvent(button: .left, phase: .mouseUp))
        source.emitScrollEvent(ScrollInputEvent(direction: .down))

        XCTAssertEqual(observer.status, .inactive)
        XCTAssertEqual(source.stopObservationCallCount, 1)
        XCTAssertTrue(receivedKeyboardEvents.isEmpty)
        XCTAssertTrue(receivedMouseEvents.isEmpty)
        XCTAssertTrue(receivedScrollEvents.isEmpty)
    }

    func testUnavailableObservationDoesNotInstallHandlers() {
        let source = TestInputEventSource()
        source.startStatus = .unavailable(reason: "Input monitoring permission is unavailable.")
        let observer = InputEventObserver(eventSource: source)
        var receivedKeyboardEvents: [KeyboardInputEvent] = []
        var receivedMouseEvents: [MouseInputEvent] = []
        var receivedScrollEvents: [ScrollInputEvent] = []

        let status = observer.startObservation(
            keyboardHandler: { event in
                receivedKeyboardEvents.append(event)
            },
            mouseHandler: { event in
                receivedMouseEvents.append(event)
            },
            scrollHandler: { event in
                receivedScrollEvents.append(event)
            }
        )
        source.emitKeyboardEvent(keyboardEvent("s"))
        source.emitMouseEvent(MouseInputEvent(button: .left, phase: .mouseDown))
        source.emitScrollEvent(ScrollInputEvent(direction: .up))

        XCTAssertEqual(status, .unavailable(reason: "Input monitoring permission is unavailable."))
        XCTAssertEqual(observer.status, .unavailable(reason: "Input monitoring permission is unavailable."))
        XCTAssertTrue(receivedKeyboardEvents.isEmpty)
        XCTAssertTrue(receivedMouseEvents.isEmpty)
        XCTAssertTrue(receivedScrollEvents.isEmpty)
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
    private var scrollHandler: ScrollInputEventHandler?

    func startObservation(
        keyboardHandler: @escaping KeyboardInputEventHandler,
        mouseHandler: @escaping MouseInputEventHandler,
        scrollHandler: @escaping ScrollInputEventHandler
    ) -> InputLoggingSessionStatus {
        startObservationCallCount += 1

        guard startStatus == .active else {
            self.keyboardHandler = nil
            self.mouseHandler = nil
            self.scrollHandler = nil
            return startStatus
        }

        self.keyboardHandler = keyboardHandler
        self.mouseHandler = mouseHandler
        self.scrollHandler = scrollHandler
        return .active
    }

    func stopObservation() {
        guard keyboardHandler != nil || mouseHandler != nil || scrollHandler != nil else {
            return
        }

        stopObservationCallCount += 1
        keyboardHandler = nil
        mouseHandler = nil
        scrollHandler = nil
    }

    func emitKeyboardEvent(_ event: KeyboardInputEvent) {
        keyboardHandler?(event)
    }

    func emitMouseEvent(_ event: MouseInputEvent) {
        mouseHandler?(event)
    }

    func emitScrollEvent(_ event: ScrollInputEvent) {
        scrollHandler?(event)
    }
}
