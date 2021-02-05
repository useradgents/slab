import Foundation

public enum AsyncStatus<Value> {
    case loading(AsyncLoadingMetadata)
    case success(Value, AsyncSuccessMetadata)
    case failure(Error, AsyncFailureMetadata)
    
    public var isSuccess: Bool {
        if case .success = self { return true }
        return false
    }
    
    public var isFailure: Bool {
        if case .failure = self { return true }
        return false
    }
    
    public var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }
    
    public var value: Value? {
        if case let .success(value, _) = self { return value }
        return nil
    }
}

public struct AsyncLoadingMetadata: Dated {
    public let date: Date
    public let silent: Bool
    public let readFromCache: Bool
    public let writeToCache: Bool
    
    public init(date: Date? = nil, silent: Bool = false, readFromCache: Bool = false, writeToCache: Bool = false) {
        self.date = date ?? Date()
        self.silent = silent
        self.readFromCache = readFromCache
        self.writeToCache = writeToCache
    }
    
    public init(_ md: RequestMetadata, date: Date? = nil) {
        self.date = date ?? Date()
        self.silent = md.silent
        self.readFromCache = md.readFromCache
        self.writeToCache = md.writeToCache
    }
}

public struct AsyncFailureMetadata: Dated {
    public let date: Date
    
    public init(date: Date = .init()) {
        self.date = date
    }
}

public struct AsyncSuccessMetadata: Dated {
    public let date: Date
    public let isRefreshing: Bool
    public let source: Source
    
    public enum Source: Int {
        case network
        case cache
    }
    
    public init(date: Date = .init(), isRefreshing: Bool = false, source: Source) {
        self.date = date
        self.isRefreshing = isRefreshing
        self.source = source
    }
    
    public var madeRefreshing: AsyncSuccessMetadata {
        .init(date: date, isRefreshing: true, source: source)
    }
}


extension AsyncStatus: Equatable where Value: Equatable {
    public static func == (lhs: AsyncStatus<Value>, rhs: AsyncStatus<Value>) -> Bool {
        switch (lhs, rhs) {
            case (.loading, .loading): return true
            case (.failure, .failure): return true
            case (.success(let a, _), .success(let b, _)): return a == b
            default: return false
        }
    }
}

public struct RequestMetadata {
    public let silent: Bool
    public let readFromCache: Bool
    public let writeToCache: Bool
    
    public init(silent: Bool, readFromCache: Bool, writeToCache: Bool) {
        self.silent = silent
        self.readFromCache = readFromCache
        self.writeToCache = writeToCache
    }
    
    public static let initialLoad = RequestMetadata(silent: false, readFromCache: true, writeToCache: true)
    public static let manualRefresh = RequestMetadata(silent: false, readFromCache: false, writeToCache: true)
    public static let backgroundRefresh = RequestMetadata(silent: true, readFromCache: false, writeToCache: true)
}
