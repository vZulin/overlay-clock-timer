import Foundation

struct DurationFormatter {
    func string(from duration: TimeInterval) -> String {
        let milliseconds = max(0, Int((duration * 1000).rounded(.towardZero)))
        let hours = milliseconds / 3_600_000
        let minutes = (milliseconds / 60_000) % 60
        let seconds = (milliseconds / 1_000) % 60
        let remainingMilliseconds = milliseconds % 1_000

        return String(format: "%02d:%02d:%02d.%03d", hours, minutes, seconds, remainingMilliseconds)
    }
}
