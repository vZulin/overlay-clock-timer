import Foundation

struct DurationFormatter {
    func string(
        from duration: TimeInterval,
        timeFormat: TimeFormatPreference = TimeFormatPreference.defaultValue
    ) -> String {
        let milliseconds = Self.elapsedMilliseconds(from: duration)

        switch timeFormat {
        case .standardMilliseconds:
            return standardString(fromMilliseconds: milliseconds)
        case .epochMilliseconds:
            return String(format: "%013lld", milliseconds)
        }
    }

    private static func elapsedMilliseconds(from duration: TimeInterval) -> Int64 {
        guard duration.isFinite, duration > 0 else {
            return 0
        }

        let rawMilliseconds = (duration * 1_000).rounded(.towardZero)
        guard rawMilliseconds < Double(Int64.max) else {
            return Int64.max
        }

        return Int64(rawMilliseconds)
    }

    private func standardString(fromMilliseconds milliseconds: Int64) -> String {
        let hours = milliseconds / 3_600_000
        let minutes = (milliseconds / 60_000) % 60
        let seconds = (milliseconds / 1_000) % 60
        let remainingMilliseconds = milliseconds % 1_000

        return String(
            format: "%02lld:%02lld:%02lld.%03lld",
            hours,
            minutes,
            seconds,
            remainingMilliseconds
        )
    }
}
