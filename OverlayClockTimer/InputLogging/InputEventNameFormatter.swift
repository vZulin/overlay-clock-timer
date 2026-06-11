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

enum MouseInputEventPhase: Equatable, Sendable {
    case mouseDown
    case mouseUp

    var recordPhase: InputEventPhase {
        switch self {
        case .mouseDown:
            return .mouseDown
        case .mouseUp:
            return .mouseUp
        }
    }
}

struct MouseInputEvent: Equatable, Sendable {
    let phase: MouseInputEventPhase

    init(phase: MouseInputEventPhase) {
        self.phase = phase
    }
}

struct FormattedInputEvent: Equatable, Sendable {
    let category: InputEventCategory
    let name: String
    let phase: InputEventPhase?
}

struct InputEventNameFormatter {
    func format(keyboard event: KeyboardInputEvent) -> FormattedInputEvent {
        FormattedInputEvent(
            category: .keyboard,
            name: keyboardEventName(for: event),
            phase: event.isRepeat ? .repeatKeyDown : .keyDown
        )
    }

    func format(mouse event: MouseInputEvent) -> FormattedInputEvent {
        FormattedInputEvent(
            category: .mouse,
            name: mouseEventName(for: event),
            phase: event.phase.recordPhase
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

        let containsControlOrNewline = characters.unicodeScalars.contains { scalar in
            CharacterSet.controlCharacters.contains(scalar)
                || CharacterSet.newlines.contains(scalar)
        }

        guard !containsControlOrNewline else {
            return nil
        }

        return characters
    }

    private func normalizedKeyName(_ key: String) -> String {
        let trimmedKey = key.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedKey.isEmpty ? "Unknown Key" : trimmedKey
    }

    private func mouseEventName(for event: MouseInputEvent) -> String {
        switch event.phase {
        case .mouseDown:
            return "Mouse Down"
        case .mouseUp:
            return "Mouse Up"
        }
    }
}
