import Foundation

@MainActor
final class ClockDisplayModel: ObservableObject {
    @Published private(set) var displayText: String

    private let timeSource: WallClockTimeSource
    private let formatter: ClockFormatter
    private let ticker: DisplayTicker
    private var isStarted = false

    init(
        timeSource: WallClockTimeSource = SystemWallClockTimeSource(),
        formatter: ClockFormatter = ClockFormatter(),
        ticker: DisplayTicker = DisplayTicker()
    ) {
        self.timeSource = timeSource
        self.formatter = formatter
        self.ticker = ticker
        self.displayText = formatter.string(from: timeSource.now)
    }

    func start() {
        guard !isStarted else {
            return
        }

        isStarted = true
        refresh()
        ticker.start(on: .main) { [weak self] in
            Task { @MainActor in
                self?.refresh()
            }
        }
    }

    func stop() {
        guard isStarted else {
            return
        }

        isStarted = false
        ticker.stop()
    }

    func refresh() {
        displayText = formatter.string(from: timeSource.now)
    }
}
