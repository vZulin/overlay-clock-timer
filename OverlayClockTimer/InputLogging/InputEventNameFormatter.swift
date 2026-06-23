import Foundation

enum InputEventModifier: String, CaseIterable, Hashable, Sendable {
    case control
    case option
    case shift
    case command

    static let canonicalOrder: [InputEventModifier] = [
        .control,
        .option,
        .shift,
        .command
    ]

    var displayName: String {
        switch self {
        case .control:
            return "Control"
        case .option:
            return "Option"
        case .shift:
            return "Shift"
        case .command:
            return "Command"
        }
    }
}

struct KeyboardInputEvent: Equatable, Sendable {
    let characters: String?
    let key: String
    let modifiers: Set<InputEventModifier>
    let isRepeat: Bool

    init(
        characters: String?,
        key: String,
        modifiers: Set<InputEventModifier>,
        isRepeat: Bool
    ) {
        self.characters = characters
        self.key = key
        self.modifiers = modifiers
        self.isRepeat = isRepeat
    }
}

enum MouseInputEventButton: Equatable, Sendable {
    case left
    case right
    case third
    case additional(Int)
}

enum MouseInputEventPhase: Equatable, Sendable {
    case mouseDown
    case mouseUp
}

struct MouseInputEvent: Equatable, Sendable {
    let button: MouseInputEventButton
    let phase: MouseInputEventPhase

    init(button: MouseInputEventButton, phase: MouseInputEventPhase) {
        self.button = button
        self.phase = phase
    }
}

enum ScrollInputEventDirection: Equatable, Sendable {
    case up
    case down
}

struct ScrollInputEvent: Equatable, Sendable {
    let direction: ScrollInputEventDirection

    init(direction: ScrollInputEventDirection) {
        self.direction = direction
    }
}

struct FormattedInputEvent: Equatable, Sendable {
    let eventName: String
}

struct InputEventNameFormatter {
    func format(keyboard event: KeyboardInputEvent) -> FormattedInputEvent {
        FormattedInputEvent(
            eventName: keyboardEventName(for: event)
        )
    }

    func format(mouse event: MouseInputEvent) -> FormattedInputEvent {
        FormattedInputEvent(
            eventName: mouseEventName(for: event)
        )
    }

    func format(scroll event: ScrollInputEvent) -> FormattedInputEvent {
        FormattedInputEvent(
            eventName: scrollEventName(for: event)
        )
    }

    private func keyboardEventName(for event: KeyboardInputEvent) -> String {
        if let visibleCharacterName = visibleCharacterName(from: event.characters) {
            return visibleCharacterName
        }

        let keyName = normalizedKeyName(event.key)
        guard !event.modifiers.isEmpty else {
            return keyName
        }

        let modifierNames = InputEventModifier.canonicalOrder
            .filter { event.modifiers.contains($0) }
            .map(\.displayName)

        return (modifierNames + [keyName]).joined(separator: "+")
    }

    private func visibleCharacterName(from characters: String?) -> String? {
        guard let characters, !characters.isEmpty else {
            return nil
        }

        if characters == " " {
            return "Space"
        }

        let containsNonTextScalar = characters.unicodeScalars.contains { scalar in
            CharacterSet.controlCharacters.contains(scalar)
                || CharacterSet.newlines.contains(scalar)
                || isPrivateUseScalar(scalar)
        }

        guard !containsNonTextScalar else {
            return nil
        }

        return characters
    }

    private func isPrivateUseScalar(_ scalar: Unicode.Scalar) -> Bool {
        (0xE000...0xF8FF).contains(scalar.value)
            || (0xF0000...0xFFFFD).contains(scalar.value)
            || (0x100000...0x10FFFD).contains(scalar.value)
    }

    private func normalizedKeyName(_ key: String) -> String {
        let trimmedKey = key.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedKey.isEmpty ? "Unknown Key" : trimmedKey
    }

    private func mouseEventName(for event: MouseInputEvent) -> String {
        let buttonName = mouseButtonName(for: event.button)
        switch event.phase {
        case .mouseDown:
            return "\(buttonName) ↓"
        case .mouseUp:
            return "\(buttonName) ↑"
        }
    }

    private func mouseButtonName(for button: MouseInputEventButton) -> String {
        switch button {
        case .left:
            return "LM"
        case .right:
            return "RM"
        case .third:
            return "3M"
        case .additional(let number):
            return "\(number)M"
        }
    }

    private func scrollEventName(for event: ScrollInputEvent) -> String {
        switch event.direction {
        case .up:
            return "SM ↑"
        case .down:
            return "SM ↓"
        }
    }
}
