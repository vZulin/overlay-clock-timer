import Foundation

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
    let eventName: String

    init(
        id: UUID = UUID(),
        captureOrder: InputEventCaptureOrder,
        timestamp: String,
        eventName: String
    ) {
        self.id = id
        self.captureOrder = captureOrder
        self.timestamp = timestamp
        self.eventName = eventName
    }

    static func newestFirst(_ lhs: InputEventRecord, _ rhs: InputEventRecord) -> Bool {
        lhs.captureOrder > rhs.captureOrder
    }

    var logLine: String {
        "\(timestamp.sanitizedInputEventLogField)\t\(eventName.sanitizedInputEventLogField)"
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
