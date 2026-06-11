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

        XCTAssertEqual(formatted.category, .keyboard)
        XCTAssertEqual(formatted.name, "s")
        XCTAssertEqual(formatted.phase, .keyDown)
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

        XCTAssertEqual(formatted.name, "s")
        XCTAssertEqual(formatted.phase, .repeatKeyDown)
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

        XCTAssertEqual(formatted.name, "Escape")
        XCTAssertEqual(formatted.phase, .keyDown)
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

        XCTAssertEqual(formatted.name, "Control+Option+Shift+Command+S")
        XCTAssertEqual(formatted.phase, .keyDown)
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

        XCTAssertEqual(formatted.name, "ß")
        XCTAssertEqual(formatted.phase, .keyDown)
    }

    func testMouseDownUsesMouseCategoryAndMouseDownPhase() {
        let formatted = InputEventNameFormatter().format(
            mouse: MouseInputEvent(phase: .mouseDown)
        )

        XCTAssertEqual(formatted.category, .mouse)
        XCTAssertEqual(formatted.name, "Mouse Down")
        XCTAssertEqual(formatted.phase, .mouseDown)
    }

    func testMouseUpUsesMouseCategoryAndMouseUpPhase() {
        let formatted = InputEventNameFormatter().format(
            mouse: MouseInputEvent(phase: .mouseUp)
        )

        XCTAssertEqual(formatted.category, .mouse)
        XCTAssertEqual(formatted.name, "Mouse Up")
        XCTAssertEqual(formatted.phase, .mouseUp)
    }
}
