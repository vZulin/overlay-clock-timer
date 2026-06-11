import Foundation

enum InputEventCategory: String, CaseIterable, Codable, Equatable, Sendable {
    case keyboard
    case mouse
}

enum InputEventPhase: String, CaseIterable, Codable, Equatable, Sendable {
    case keyDown
    case repeatKeyDown
    case mouseDown
    case mouseUp
}

struct InputEventCaptureOrder: RawRepresentable, Comparable, Codable, Hashable, Sendable {
    let rawValue: UInt64

    init(rawValue: UInt64) {
        self.rawValue = rawValue
    }

    init(_ rawValue: UInt64) {
        self.rawValue = rawValue
    }

    static func < (lhs: InputEventCaptureOrder, rhs: InputEventCaptureOrder) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

struct InputEventRecord: Identifiable, Equatable, Sendable {
    let id: UUID
    let captureOrder: InputEventCaptureOrder
    let timestamp: String
    let category: InputEventCategory
    let name: String
    let phase: InputEventPhase?

    init(
        id: UUID = UUID(),
        captureOrder: InputEventCaptureOrder,
        timestamp: String,
        category: InputEventCategory,
        name: String,
        phase: InputEventPhase? = nil
    ) {
        self.id = id
        self.captureOrder = captureOrder
        self.timestamp = timestamp
        self.category = category
        self.name = name
        self.phase = phase
    }

    static func newestFirst(_ lhs: InputEventRecord, _ rhs: InputEventRecord) -> Bool {
        lhs.captureOrder > rhs.captureOrder
    }

    var logLine: String {
        [
            "order=\(captureOrder.rawValue)",
            "timestamp=\(timestamp.sanitizedInputEventLogField)",
            "category=\(category.rawValue)",
            "name=\(name.sanitizedInputEventLogField)",
            "phase=\((phase?.rawValue ?? "-").sanitizedInputEventLogField)"
        ].joined(separator: "\t")
    }
}

private extension String {
    var sanitizedInputEventLogField: String {
        map { character in
            character.isNewline || character == "\t" ? " " : character
        }
        .reduce(into: "") { result, character in
            result.append(character)
        }
    }
}
