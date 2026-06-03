import Foundation

struct HotkeyConflictIdentity: Codable, Equatable, Hashable {
    let keyCode: UInt16
    let modifiers: UInt
}

struct HotkeyBinding: Codable, Equatable, Hashable, Identifiable {
    let command: HotkeyCommand
    var keyCode: UInt16
    var modifiers: UInt
    var isEnabled: Bool

    var id: HotkeyCommand {
        command
    }

    var conflictIdentity: HotkeyConflictIdentity? {
        guard isEnabled else {
            return nil
        }
        return HotkeyConflictIdentity(keyCode: keyCode, modifiers: modifiers)
    }

    func conflicts(with other: HotkeyBinding) -> Bool {
        guard command != other.command else {
            return false
        }
        return conflictIdentity != nil && conflictIdentity == other.conflictIdentity
    }

    var displayText: String {
        guard isEnabled else {
            return "Disabled"
        }

        if modifiers == 0 {
            return "Key \(keyCode)"
        }

        return "Modifiers \(modifiers) + Key \(keyCode)"
    }
}

enum HotkeyBindingUpdateResult: Equatable {
    case accepted
    case rejected(conflictingCommand: HotkeyCommand)
}

struct HotkeyBindingSet: Equatable {
    private var storage: [HotkeyCommand: HotkeyBinding]

    init(_ bindings: [HotkeyBinding] = []) {
        self.storage = [:]
        for binding in bindings {
            _ = update(binding, replacingConflicts: false)
        }
    }

    var bindings: [HotkeyBinding] {
        HotkeyCommand.allCases.compactMap { storage[$0] }
    }

    func binding(for command: HotkeyCommand) -> HotkeyBinding? {
        storage[command]
    }

    mutating func update(
        _ binding: HotkeyBinding,
        replacingConflicts: Bool
    ) -> HotkeyBindingUpdateResult {
        if let conflictingCommand = conflictingCommand(for: binding) {
            guard replacingConflicts else {
                return .rejected(conflictingCommand: conflictingCommand)
            }
            storage.removeValue(forKey: conflictingCommand)
        }

        storage[binding.command] = binding
        return .accepted
    }

    static func validated(_ bindings: [HotkeyBinding]) -> [HotkeyBinding] {
        HotkeyBindingSet(bindings).bindings
    }

    private func conflictingCommand(for binding: HotkeyBinding) -> HotkeyCommand? {
        guard let identity = binding.conflictIdentity else {
            return nil
        }

        return storage.values.first {
            $0.command != binding.command && $0.conflictIdentity == identity
        }?.command
    }
}
