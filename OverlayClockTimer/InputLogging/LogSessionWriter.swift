import Foundation

struct LogSessionFile: Equatable {
    enum Status: Equatable {
        case open
        case closed
        case failed(reason: String)
    }

    let url: URL
    let createdAt: Date
    var status: Status
}

enum LogSessionWriterError: Error, Equatable {
    case failedToOpen(String)
    case notOpen
    case failedToAppend(String)
}

protocol LogSessionWriting: AnyObject, Sendable {
    var currentSession: LogSessionFile? { get }

    @discardableResult
    func open() throws -> LogSessionFile
    func append(_ record: InputEventRecord) async throws
    func close()
}

final class LogSessionWriter: @unchecked Sendable {
    private let logDirectoryURL: URL
    private let fileManager: FileManager
    private let dateProvider: () -> Date
    private let timeZone: TimeZone
    private let writeQueue = DispatchQueue(label: "OverlayClockTimer.LogSessionWriter.writeQueue")
    private var fileHandle: FileHandle?
    private var _currentSession: LogSessionFile?

    var currentSession: LogSessionFile? {
        writeQueue.sync {
            _currentSession
        }
    }

    init(
        logDirectoryURL: URL = FileManager.default
            .homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Logs/OverlayClockTimer", isDirectory: true),
        fileManager: FileManager = .default,
        dateProvider: @escaping () -> Date = Date.init,
        timeZone: TimeZone = .current
    ) {
        self.logDirectoryURL = logDirectoryURL
        self.fileManager = fileManager
        self.dateProvider = dateProvider
        self.timeZone = timeZone
    }

    @discardableResult
    func open() throws -> LogSessionFile {
        try writeQueue.sync {
            try openSynchronously()
        }
    }

    func append(_ record: InputEventRecord) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            writeQueue.async { [weak self] in
                guard let self else {
                    continuation.resume(throwing: LogSessionWriterError.notOpen)
                    return
                }

                do {
                    try self.appendSynchronously(record)
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func close() {
        writeQueue.sync {
            closeSynchronously()
        }
    }

    private func openSynchronously() throws -> LogSessionFile {
        closeSynchronously()

        let createdAt = dateProvider()
        let url = availableLogFileURL(for: createdAt)

        do {
            try fileManager.createDirectory(
                at: logDirectoryURL,
                withIntermediateDirectories: true
            )
            fileManager.createFile(atPath: url.path, contents: Data())
            fileHandle = try FileHandle(forWritingTo: url)

            let session = LogSessionFile(url: url, createdAt: createdAt, status: .open)
            _currentSession = session
            return session
        } catch {
            let reason = error.localizedDescription
            _currentSession = LogSessionFile(url: url, createdAt: createdAt, status: .failed(reason: reason))
            throw LogSessionWriterError.failedToOpen(reason)
        }
    }

    private func closeSynchronously() {
        guard fileHandle != nil || _currentSession?.status == .open else {
            return
        }

        try? fileHandle?.close()
        fileHandle = nil

        if var session = _currentSession, session.status == .open {
            session.status = .closed
            _currentSession = session
        }
    }

    private func availableLogFileURL(for date: Date) -> URL {
        let baseName = baseFileName(for: date)
        let baseURL = logDirectoryURL.appendingPathComponent(baseName)
        guard fileManager.fileExists(atPath: baseURL.path) else {
            return baseURL
        }

        let stem = String(baseName.dropLast(".log".count))
        var suffix = 1
        while true {
            let candidate = logDirectoryURL.appendingPathComponent("\(stem)-\(suffix).log")
            if !fileManager.fileExists(atPath: candidate.path) {
                return candidate
            }
            suffix += 1
        }
    }

    private func baseFileName(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = timeZone
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        return "\(formatter.string(from: date)).log"
    }

    private func appendSynchronously(_ record: InputEventRecord) throws {
        guard var session = _currentSession, session.status == .open, let fileHandle else {
            throw LogSessionWriterError.notOpen
        }

        do {
            guard let data = "\(record.logLine)\n".data(using: .utf8) else {
                throw LogSessionWriterError.failedToAppend("Unable to encode log record as UTF-8.")
            }
            try fileHandle.write(contentsOf: data)
        } catch let writerError as LogSessionWriterError {
            session.status = .failed(reason: String(describing: writerError))
            _currentSession = session
            throw writerError
        } catch {
            let reason = error.localizedDescription
            session.status = .failed(reason: reason)
            _currentSession = session
            throw LogSessionWriterError.failedToAppend(reason)
        }
    }
}

extension LogSessionWriter: LogSessionWriting {}

final class DelayedLogSessionWriter: LogSessionWriting, @unchecked Sendable {
    private let wrapped: LogSessionWriting
    private let delayNanoseconds: UInt64

    var currentSession: LogSessionFile? {
        wrapped.currentSession
    }

    init(
        wrapped: LogSessionWriting = LogSessionWriter(),
        delayNanoseconds: UInt64
    ) {
        self.wrapped = wrapped
        self.delayNanoseconds = delayNanoseconds
    }

    @discardableResult
    func open() throws -> LogSessionFile {
        try wrapped.open()
    }

    func append(_ record: InputEventRecord) async throws {
        let acceptedSession = wrapped.currentSession
        if delayNanoseconds > 0 {
            try await Task.sleep(nanoseconds: delayNanoseconds)
        }

        guard wrapped.currentSession == acceptedSession else {
            throw LogSessionWriterError.notOpen
        }

        try await wrapped.append(record)
    }

    func close() {
        wrapped.close()
    }
}
