import Foundation

protocol WallClockTimeSource {
    var now: Date { get }
}

protocol MonotonicTimeSource {
    var now: TimeInterval { get }
}

struct SystemWallClockTimeSource: WallClockTimeSource {
    var now: Date {
        Date()
    }
}

struct SystemMonotonicTimeSource: MonotonicTimeSource {
    var now: TimeInterval {
        ProcessInfo.processInfo.systemUptime
    }
}

final class ManualWallClockTimeSource: WallClockTimeSource {
    var now: Date

    init(now: Date) {
        self.now = now
    }

    func advance(by interval: TimeInterval) {
        now = now.addingTimeInterval(interval)
    }
}

final class ManualMonotonicTimeSource: MonotonicTimeSource {
    private(set) var now: TimeInterval

    init(now: TimeInterval = 0) {
        self.now = max(0, now)
    }

    func advance(by interval: TimeInterval) {
        now = max(0, now + interval)
    }
}
