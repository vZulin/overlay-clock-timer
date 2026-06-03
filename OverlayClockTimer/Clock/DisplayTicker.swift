import Foundation

final class DisplayTicker {
    static let maximumSupportedFramesPerSecond: Double = 60
    static let minimumSupportedFramesPerSecond: Double = 1
    static let defaultLeeway: TimeInterval = 0.002

    let framesPerSecond: Double
    let interval: TimeInterval
    let leeway: TimeInterval

    private let lock = NSLock()
    private var timer: DispatchSourceTimer?

    init(
        maximumFramesPerSecond: Double = maximumSupportedFramesPerSecond,
        leeway: TimeInterval = defaultLeeway
    ) {
        let sanitized = maximumFramesPerSecond.isFinite ? maximumFramesPerSecond : Self.maximumSupportedFramesPerSecond
        framesPerSecond = min(
            max(sanitized, Self.minimumSupportedFramesPerSecond),
            Self.maximumSupportedFramesPerSecond
        )
        interval = 1 / framesPerSecond
        let sanitizedLeeway = leeway.isFinite ? max(0, leeway) : Self.defaultLeeway
        self.leeway = min(sanitizedLeeway, interval)
    }

    var isRunning: Bool {
        lock.withLock {
            timer != nil
        }
    }

    func start(on queue: DispatchQueue = .main, handler: @escaping () -> Void) {
        stop()

        let source = DispatchSource.makeTimerSource(queue: queue)
        source.schedule(
            deadline: .now() + interval,
            repeating: interval,
            leeway: .nanoseconds(Int((leeway * 1_000_000_000).rounded()))
        )
        source.setEventHandler(handler: handler)

        lock.withLock {
            timer = source
        }
        source.resume()
    }

    func stop() {
        let source = lock.withLock {
            let current = timer
            timer = nil
            return current
        }
        source?.cancel()
    }

    deinit {
        stop()
    }
}
