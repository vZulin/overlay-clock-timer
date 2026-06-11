import XCTest
@testable import OverlayClockTimer

final class InputEventNameFormatterTests: XCTestCase {
    func testCharacterProducingKeyDownUsesVisibleCharacterName() {
        let formatted = InputEventNameFormatter().format(
            keyboard: KeyboardInputEvent(
                characters: "s",
                key: "S",
                modifiers: [],
                isRepeat: false
            )
        )

        XCTAssertEqual(formatted.eventName, "s")
    }

    func testRepeatCharacterKeyDownKeepsOneRecordShapeWithRepeatPhase() {
        let formatted = InputEventNameFormatter().format(
            keyboard: KeyboardInputEvent(
                characters: "s",
                key: "S",
                modifiers: [],
                isRepeat: true
            )
        )

        XCTAssertEqual(formatted.eventName, "s")
    }

    func testNonCharacterKeyUsesKeyName() {
        let formatted = InputEventNameFormatter().format(
            keyboard: KeyboardInputEvent(
                characters: nil,
                key: "Escape",
                modifiers: [],
                isRepeat: false
            )
        )

        XCTAssertEqual(formatted.eventName, "Escape")
    }

    func testModifierCombinationUsesCanonicalModifierOrder() {
        let formatted = InputEventNameFormatter().format(
            keyboard: KeyboardInputEvent(
                characters: nil,
                key: "S",
                modifiers: [.command, .shift, .control, .option],
                isRepeat: false
            )
        )

        XCTAssertEqual(formatted.eventName, "Control+Option+Shift+Command+S")
    }

    func testVisibleTextTakesPrecedenceOverModifierCombination() {
        let formatted = InputEventNameFormatter().format(
            keyboard: KeyboardInputEvent(
                characters: "ß",
                key: "S",
                modifiers: [.option],
                isRepeat: false
            )
        )

        XCTAssertEqual(formatted.eventName, "ß")
    }

    func testCompactMouseButtonLabels() {
        let cases: [(MouseInputEvent, String)] = [
            (MouseInputEvent(button: .left, phase: .mouseDown), "LM ↓"),
            (MouseInputEvent(button: .left, phase: .mouseUp), "LM ↑"),
            (MouseInputEvent(button: .right, phase: .mouseDown), "RM ↓"),
            (MouseInputEvent(button: .right, phase: .mouseUp), "RM ↑"),
            (MouseInputEvent(button: .third, phase: .mouseDown), "3M ↓"),
            (MouseInputEvent(button: .third, phase: .mouseUp), "3M ↑"),
            (MouseInputEvent(button: .additional(4), phase: .mouseDown), "4M ↓"),
            (MouseInputEvent(button: .additional(4), phase: .mouseUp), "4M ↑"),
            (MouseInputEvent(button: .additional(5), phase: .mouseDown), "5M ↓"),
            (MouseInputEvent(button: .additional(5), phase: .mouseUp), "5M ↑")
        ]

        for (event, expectedName) in cases {
            XCTAssertEqual(InputEventNameFormatter().format(mouse: event).eventName, expectedName)
        }
    }

    func testCompactScrollLabelsUsePhysicalGestureDirection() {
        let formatter = InputEventNameFormatter()

        XCTAssertEqual(
            formatter.format(scroll: ScrollInputEvent(direction: .up)).eventName,
            "SM ↑"
        )
        XCTAssertEqual(
            formatter.format(scroll: ScrollInputEvent(direction: .down)).eventName,
            "SM ↓"
        )
    }
}
