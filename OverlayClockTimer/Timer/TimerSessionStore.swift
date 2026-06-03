import Foundation

@MainActor
final class TimerSessionStore: ObservableObject {
    @Published private(set) var session: TimerSession
    @Published private(set) var elapsedDisplayText: String
    @Published private(set) var latestLoopDisplayText: String?

    private let timeSource: MonotonicTimeSource
    private let formatter: DurationFormatter
    private let ticker: DisplayTicker

    init(
        session: TimerSession = TimerSession(),
        timeSource: MonotonicTimeSource = SystemMonotonicTimeSource(),
        formatter: DurationFormatter = DurationFormatter(),
        ticker: DisplayTicker = DisplayTicker()
    ) {
        self.session = session
        self.timeSource = timeSource
        self.formatter = formatter
        self.ticker = ticker
        self.elapsedDisplayText = formatter.string(from: session.elapsed(at: timeSource.now))
        self.latestLoopDisplayText = session.latestLoop.map { formatter.string(from: $0.capturedElapsed) }
        updateTickerLifecycle()
    }

    var canStart: Bool {
        !session.isRunning
    }

    var canPause: Bool {
        session.isRunning
    }

    var canStopReset: Bool {
        session.isRunning || session.isPaused
    }

    var canLoop: Bool {
        session.isRunning
    }

    func start() {
        session.start(at: timeSource.now)
        refresh()
        updateTickerLifecycle()
    }

    func pause() {
        session.pause(at: timeSource.now)
        refresh()
        updateTickerLifecycle()
    }

    func stopReset() {
        session.stopReset()
        refresh()
        updateTickerLifecycle()
    }

    func loop() {
        session.loop(at: timeSource.now)
        refresh()
    }

    func applyModeSwitchAction(_ action: ModeSwitchAction) {
        guard session.isRunning else {
            refresh()
            updateTickerLifecycle()
            return
        }

        switch action {
        case .continue:
            refresh()
            updateTickerLifecycle()
        case .pause:
            pause()
        case .stopAndReset:
            stopReset()
        }
    }

    func refresh() {
        elapsedDisplayText = formatter.string(from: session.elapsed(at: timeSource.now))
        latestLoopDisplayText = session.latestLoop.map { formatter.string(from: $0.capturedElapsed) }
    }

    private func updateTickerLifecycle() {
        if session.isRunning {
            guard !ticker.isRunning else {
                return
            }
            ticker.start { [weak self] in
                Task { @MainActor [weak self] in
                    self?.refresh()
                }
            }
        } else {
            ticker.stop()
        }
    }

}
