import Foundation

final class ClockFormatter {
    private let formatter: DateFormatter

    init(timeZone: TimeZone = .current) {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = timeZone
        formatter.dateFormat = "HH:mm:ss.SSS"
        self.formatter = formatter
    }

    func string(
        from date: Date,
        timeFormat: TimeFormatPreference = TimeFormatPreference.defaultValue
    ) -> String {
        switch timeFormat {
        case .standardMilliseconds:
            return formatter.string(from: date)
        case .epochMilliseconds:
            return epochMillisecondsString(from: date)
        }
    }

    private func epochMillisecondsString(from date: Date) -> String {
        let rawMilliseconds = (date.timeIntervalSince1970 * 1_000).rounded(.towardZero)
        guard rawMilliseconds.isFinite else {
            return "0"
        }

        if rawMilliseconds >= Double(Int64.max) {
            return String(Int64.max)
        }

        if rawMilliseconds <= Double(Int64.min) {
            return String(Int64.min)
        }

        return String(Int64(rawMilliseconds))
    }
}
