import Foundation

struct LoopCapture: Equatable {
    let capturedElapsed: TimeInterval
    let capturedAt: TimeInterval

    init(capturedElapsed: TimeInterval, capturedAt: TimeInterval) {
        self.capturedElapsed = max(0, capturedElapsed)
        self.capturedAt = max(0, capturedAt)
    }
}

struct TimerSession: Equatable {
    enum State: Equatable {
        case idle
        case running(startedAt: TimeInterval, accumulatedElapsed: TimeInterval, latestLoop: LoopCapture?)
        case paused(accumulatedElapsed: TimeInterval, latestLoop: LoopCapture?)
        case reset
    }

    private(set) var state: State

    init(state: State = .idle) {
        self.state = state.validated
    }

    var isIdle: Bool {
        state == .idle
    }

    var isRunning: Bool {
        if case .running = state {
            return true
        }
        return false
    }

    var isPaused: Bool {
        if case .paused = state {
            return true
        }
        return false
    }

    var isReset: Bool {
        state == .reset
    }

    var latestLoop: LoopCapture? {
        switch state {
        case .idle, .reset:
            return nil
        case .running(_, _, let latestLoop), .paused(_, let latestLoop):
            return latestLoop
        }
    }

    mutating func start(at now: TimeInterval) {
        let sanitizedNow = max(0, now)
        switch state {
        case .idle, .reset:
            state = .running(startedAt: sanitizedNow, accumulatedElapsed: 0, latestLoop: nil)
        case .paused(let accumulatedElapsed, let latestLoop):
            state = .running(
                startedAt: sanitizedNow,
                accumulatedElapsed: max(0, accumulatedElapsed),
                latestLoop: latestLoop
            )
        case .running:
            break
        }
    }

    mutating func pause(at now: TimeInterval) {
        guard case .running(_, _, let latestLoop) = state else {
            return
        }

        state = .paused(
            accumulatedElapsed: elapsed(at: now),
            latestLoop: latestLoop
        )
    }

    mutating func stopReset() {
        state = .reset
    }

    mutating func loop(at now: TimeInterval) {
        guard case .running(let startedAt, let accumulatedElapsed, _) = state else {
            return
        }

        let capturedElapsed = elapsed(at: now)
        state = .running(
            startedAt: startedAt,
            accumulatedElapsed: max(0, accumulatedElapsed),
            latestLoop: LoopCapture(capturedElapsed: capturedElapsed, capturedAt: now)
        )
    }

    func elapsed(at now: TimeInterval) -> TimeInterval {
        switch state {
        case .idle, .reset:
            return 0
        case .paused(let accumulatedElapsed, _):
            return max(0, accumulatedElapsed)
        case .running(let startedAt, let accumulatedElapsed, _):
            return max(0, accumulatedElapsed) + max(0, now - startedAt)
        }
    }
}

private extension TimerSession.State {
    var validated: TimerSession.State {
        switch self {
        case .idle, .reset:
            return self
        case .running(let startedAt, let accumulatedElapsed, let latestLoop):
            return .running(
                startedAt: max(0, startedAt),
                accumulatedElapsed: max(0, accumulatedElapsed),
                latestLoop: latestLoop
            )
        case .paused(let accumulatedElapsed, let latestLoop):
            return .paused(
                accumulatedElapsed: max(0, accumulatedElapsed),
                latestLoop: latestLoop
            )
        }
    }
}
