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

    func testKeyboardKeyNameUsesKeyCodeForFunctionKeys() {
        let cases: [(UInt16, String?, String)] = [
            (122, "\u{F704}", "F1"),
            (120, "\u{F705}", "F2"),
            (99, "\u{F706}", "F3"),
            (118, "\u{F707}", "F4"),
            (96, "\u{F708}", "F5"),
            (97, "\u{F709}", "F6"),
            (98, "\u{F70A}", "F7"),
            (100, "\u{F70B}", "F8"),
            (101, "\u{F70C}", "F9"),
            (109, "\u{F70D}", "F10"),
            (103, "\u{F70E}", "F11"),
            (111, "\u{F70F}", "F12")
        ]

        for (keyCode, charactersIgnoringModifiers, expectedName) in cases {
            XCTAssertEqual(
                KeyboardKeyName.name(
                    forKeyCode: keyCode,
                    charactersIgnoringModifiers: charactersIgnoringModifiers
                ),
                expectedName
            )
        }
    }

    func testKeyboardKeyNameUsesKeyCodeForArrowKeysAndDeleteKeys() {
        let cases: [(UInt16, String?, String)] = [
            (126, "\u{F700}", "Up Arrow"),
            (125, "\u{F701}", "Down Arrow"),
            (123, "\u{F702}", "Left Arrow"),
            (124, "\u{F703}", "Right Arrow"),
            (51, "\u{7F}", "Backspace"),
            (117, "\u{F728}", "Delete")
        ]

        for (keyCode, charactersIgnoringModifiers, expectedName) in cases {
            XCTAssertEqual(
                KeyboardKeyName.name(
                    forKeyCode: keyCode,
                    charactersIgnoringModifiers: charactersIgnoringModifiers
                ),
                expectedName
            )
        }
    }

    func testPrivateUseKeyboardCharactersFallBackToSpecialKeyNames() {
        let cases: [(String, String, String)] = [
            ("\u{F704}", "F1", "F1"),
            ("\u{F70F}", "F12", "F12"),
            ("\u{F700}", "Up Arrow", "Up Arrow"),
            ("\u{F701}", "Down Arrow", "Down Arrow"),
            ("\u{F702}", "Left Arrow", "Left Arrow"),
            ("\u{F703}", "Right Arrow", "Right Arrow"),
            ("\u{F728}", "Delete", "Delete")
        ]

        for (characters, key, expectedName) in cases {
            let formatted = InputEventNameFormatter().format(
                keyboard: KeyboardInputEvent(
                    characters: characters,
                    key: key,
                    modifiers: [],
                    isRepeat: false
                )
            )

            XCTAssertEqual(formatted.eventName, expectedName)
        }
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
