import Foundation

final class DisplayTicker {
    static let maximumSupportedFramesPerSecond: Double = 60
    static let minimumSupportedFramesPerSecond: Double = 1

    let framesPerSecond: Double
    let interval: TimeInterval

    private let lock = NSLock()
    private var timer: DispatchSourceTimer?

    init(maximumFramesPerSecond: Double = maximumSupportedFramesPerSecond) {
        let sanitized = maximumFramesPerSecond.isFinite ? maximumFramesPerSecond : Self.maximumSupportedFramesPerSecond
        framesPerSecond = min(
            max(sanitized, Self.minimumSupportedFramesPerSecond),
            Self.maximumSupportedFramesPerSecond
        )
        interval = 1 / framesPerSecond
    }

    var isRunning: Bool {
        lock.withLock {
            timer != nil
        }
    }

    func start(on queue: DispatchQueue = .main, handler: @escaping () -> Void) {
        stop()

        let source = DispatchSource.makeTimerSource(queue: queue)
        source.schedule(deadline: .now(), repeating: interval)
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
