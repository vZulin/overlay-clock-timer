import Foundation

enum HotkeyCommand: String, CaseIterable, Codable, Equatable, Hashable, Identifiable {
    case start
    case pause
    case stopReset
    case loop
    case switchMode

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .start:
            return "Start"
        case .pause:
            return "Pause"
        case .stopReset:
            return "Stop/Reset"
        case .loop:
            return "Loop"
        case .switchMode:
            return "Switch Mode"
        }
    }
}
