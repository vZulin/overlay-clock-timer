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
        switch displayMode {
        case .clock:
            clockDisplayModel.displayText
        case .timer:
            timerSessionStore.elapsedDisplayText
        }
    }
}
