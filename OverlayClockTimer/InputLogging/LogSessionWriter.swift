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

final class LogSessionWriter {
    private let logDirectoryURL: URL
    private let fileManager: FileManager
    private let dateProvider: () -> Date
    private let timeZone: TimeZone
    private var fileHandle: FileHandle?

    private(set) var currentSession: LogSessionFile?

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
        close()

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
            currentSession = session
            return session
        } catch {
            let reason = error.localizedDescription
            currentSession = LogSessionFile(url: url, createdAt: createdAt, status: .failed(reason: reason))
            throw LogSessionWriterError.failedToOpen(reason)
        }
    }

    func append(_ record: InputEventRecord) throws {
        guard var session = currentSession, session.status == .open, let fileHandle else {
            throw LogSessionWriterError.notOpen
        }

        do {
            guard let data = "\(record.logLine)\n".data(using: .utf8) else {
                throw LogSessionWriterError.failedToAppend("Unable to encode log record as UTF-8.")
            }
            try fileHandle.write(contentsOf: data)
        } catch let writerError as LogSessionWriterError {
            session.status = .failed(reason: String(describing: writerError))
            currentSession = session
            throw writerError
        } catch {
            let reason = error.localizedDescription
            session.status = .failed(reason: reason)
            currentSession = session
            throw LogSessionWriterError.failedToAppend(reason)
        }
    }

    func close() {
        guard fileHandle != nil || currentSession?.status == .open else {
            return
        }

        try? fileHandle?.close()
        fileHandle = nil

        if var session = currentSession, session.status == .open {
            session.status = .closed
            currentSession = session
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
}
