import Foundation

@MainActor
final class EventTimestampProvider {
    private let clockDisplayModel: ClockDisplayModel
    private let timerSessionStore: TimerSessionStore

    init(
        clockDisplayModel: ClockDisplayModel,
        timerSessionStore: TimerSessionStore
    ) {
        self.clockDisplayModel = clockDisplayModel
        self.timerSessionStore = timerSessionStore
    }

    func timestamp(for displayMode: DisplayMode) -> String {
        timestamp(for: displayMode, timeFormat: TimeFormatPreference.defaultValue)
    }

    func timestamp(
        for displayMode: DisplayMode,
        timeFormat: TimeFormatPreference
    ) -> String {
        switch displayMode {
        case .clock:
            clockDisplayModel.timestamp(timeFormat: timeFormat)
        case .timer:
            timerSessionStore.elapsedTimestamp(timeFormat: timeFormat)
        }
    }
}
