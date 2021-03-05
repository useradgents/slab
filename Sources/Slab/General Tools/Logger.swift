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
}

#if DEBUG
public func LOG(_ message: String, _ category: LogCategory = .none) {
    print(category.rawValue.appending(message).replacingOccurrences(of: "\n", with: "\n   "))
}

public func LOG(_ message: String, _ emoji: String) {
    print(emoji.appending(" ").appending(message).replacingOccurrences(of: "\n", with: "\n   "))
}

#else
public func LOG(_ message: String, _ category: LogCategory = .none) {}
public func LOG(_ message: String, _ emoji: String) {}
#endif
