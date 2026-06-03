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

    func string(from date: Date) -> String {
        formatter.string(from: date)
    }
}
