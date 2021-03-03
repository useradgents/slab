import Foundation

public enum LogCategory: String {
    case none = "   "
    case info = "ℹ️ "
    case warning = "⚠️ "
    case error = "⛔️ "
    case success = "✅ "
    case likeABoss = "😎 "
    case test = "❔ "
    case request = "➡️ "
    case response = "⬅️ "
    case start = "🚀 "
    case end = "🏁 "
    case package = "📦 "
    case delete = "🗑 "
    case user = "👤 "
    case tracking  = "🏷 "
}

public let logger = Logger()

public class Logger {

    /// The log filename
    private static let logFileName = "logFile.txt"

    /// Get the full URL where the logs are stored
    public static var logFile: URL = (FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).last! as URL).appendingPathComponent(logFileName)
    

    lazy private var dateFormatter = DateFormatter(dateFormat: "HH:mm:ss.SSS")

    /// Get the log content
    static var logs: String {
        (try? String(contentsOf: Logger.logFile, encoding: String.Encoding.utf8)) ?? ""
    }

    /// Logs configuration by enabling or not them
    public func configure(isEnabled: Bool) {
        self.isEnabled = isEnabled
    }

    /// Boolean indicates if logging is enabled
    private var isEnabled: Bool = false

    /// Used to print message. Use shortend "LOG(...)" instead of this method
    func log(message: Any..., category: LogCategory) {
        guard isEnabled else { return }
        let message = format(message: message, category: category)
        print(message)
        addToPersistentLogs(message)
    }

    func format(message: Any..., category: LogCategory) -> String {
        category.rawValue.appending(
            getString(from: message)
        ).replacingOccurrences(of: "\n", with: "\n   ")
    }

    private func getString(from obj: Any, withoutTime: Bool = false) -> String {
        if let o = obj as? String {
            return withoutTime ? o : dateFormatter.string(from: Date()) + " " + o
        } else if let o = obj as? [Any] {
            var msg = withoutTime ? "" : dateFormatter.string(from: Date()) + " "
            for item in o {
                msg += getString(from: item, withoutTime: true) + " "
            }
            return msg
        } else {
            return withoutTime ? String(describing: obj) : dateFormatter.string(from: Date()) + " " + String(describing: obj)
        }
    }

    /// Store the given string has persistent
    private func addToPersistentLogs(_ message: String) {
        try? message.appendNewLine(from: Self.logFile)
    }

    /// Remove the existing logs
    private func removePersistentLogs() {
        do {
            try FileManager.default.removeItem(at: Self.logFile)
        } catch let error as NSError {
            print("Error: \(error.domain)")
        }
    }
}

#if DEBUG

public func LOG(_ message: String, _ category: LogCategory = .none) {
    logger.log(message: message, category: category)
}

public func LOG(_ message: Any..., category: LogCategory = .none) {
    logger.log(message: message, category: category)
}

#else
public func LOG(_ message: String, _ category: LogCategory = .none) {}
public func LOG(_ message: String, _ emoji: String) {}
#endif
