import XCTest
@testable import OverlayClockTimer

final class HotkeyBindingTests: XCTestCase {
    func testRejectsDuplicateActiveBindingWithoutReplacing() {
        let startBinding = HotkeyBinding(command: .start, keyCode: 12, modifiers: 1, isEnabled: true)
        let loopBinding = HotkeyBinding(command: .loop, keyCode: 12, modifiers: 1, isEnabled: true)
        var bindings = HotkeyBindingSet([startBinding])

        let result = bindings.update(loopBinding, replacingConflicts: false)

        XCTAssertEqual(result, .rejected(conflictingCommand: .start))
        XCTAssertEqual(bindings.binding(for: .start), startBinding)
        XCTAssertNil(bindings.binding(for: .loop))
    }

    func testExplicitReplacementRemovesConflictingBinding() {
        let startBinding = HotkeyBinding(command: .start, keyCode: 12, modifiers: 1, isEnabled: true)
        let loopBinding = HotkeyBinding(command: .loop, keyCode: 12, modifiers: 1, isEnabled: true)
        var bindings = HotkeyBindingSet([startBinding])

        let result = bindings.update(loopBinding, replacingConflicts: true)

        XCTAssertEqual(result, .accepted)
        XCTAssertNil(bindings.binding(for: .start))
        XCTAssertEqual(bindings.binding(for: .loop), loopBinding)
    }

    func testDisabledBindingsDoNotConflict() {
        let disabledStart = HotkeyBinding(command: .start, keyCode: 12, modifiers: 1, isEnabled: false)
        let enabledLoop = HotkeyBinding(command: .loop, keyCode: 12, modifiers: 1, isEnabled: true)
        var bindings = HotkeyBindingSet([disabledStart])

        let result = bindings.update(enabledLoop, replacingConflicts: false)

        XCTAssertEqual(result, .accepted)
        XCTAssertEqual(bindings.binding(for: .start), disabledStart)
        XCTAssertEqual(bindings.binding(for: .loop), enabledLoop)
    }

    func testUpdatingSameCommandReplacesPreviousBinding() {
        let original = HotkeyBinding(command: .pause, keyCode: 12, modifiers: 1, isEnabled: true)
        let replacement = HotkeyBinding(command: .pause, keyCode: 15, modifiers: 2, isEnabled: true)
        var bindings = HotkeyBindingSet([original])

        let result = bindings.update(replacement, replacingConflicts: false)

        XCTAssertEqual(result, .accepted)
        XCTAssertEqual(bindings.binding(for: .pause), replacement)
        XCTAssertEqual(bindings.bindings.count, 1)
    }
}
