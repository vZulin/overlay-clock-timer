import Foundation

enum HotkeyCommand: String, CaseIterable, Codable, Equatable, Hashable {
    case start
    case pause
    case stopReset
    case loop
    case switchMode
}

struct HotkeyConflictIdentity: Codable, Equatable, Hashable {
    let keyCode: UInt16
    let modifiers: UInt
}

struct HotkeyBinding: Codable, Equatable, Hashable {
    let command: HotkeyCommand
    var keyCode: UInt16
    var modifiers: UInt
    var isEnabled: Bool

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
}
