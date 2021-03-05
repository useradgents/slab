import Foundation

/**
 Results of an asynchronous network call from a webservice, with associated metadata
 
 Generics: `<Value>` represents the loaded data. Usually a model struct or object.
 
 Cases:
 - `loading(meta)`: the data is currently loading.
     - `meta`: see `AsyncLoadingMetadata`
 - `success(value, meta)`: the data has been loaded correctly.
     - `value`: the actual `Value` loaded
     - `meta`: see `AsyncSuccessMetadata`
 - `failure(error, meta)`: an error has been encountered and no `Value` has been loaded.
     - `error`: the `Error` encountered
     - `meta`: see `AsyncFailureMetadata`
 */
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
    
    public func map<NewValue>(_ transform: (Value) -> NewValue) -> AsyncStatus<NewValue> {
        switch self {
            case let .failure(e, md): return .failure(e, md)
            case let .loading(md): return .loading(md)
            case let .success(v, md): return .success(transform(v), md)
        }
    }
}

/// The metadata associated with a `AsyncStatus.loading` case
public struct AsyncLoadingMetadata: Dated {
    /// The `Date` at which the request has started
    public let date: Date
    
    /// A slient request should not display an activity indicator while loading
    public let silent: Bool
    
    /// This request is allowed to read its data from cache, if available
    public let readFromCache: Bool
    
    /// This request will write any successful answer to the cache, if available
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

/// The metadata associated with a `AsyncStatus.success` case
public struct AsyncSuccessMetadata: Dated {
    /// The `Date` at which the operation did succeed
    public let date: Date
    
    /// Indicates whether the request is reloading somewhere else (like in the background, while still displaying this potentially stale Value)
    public let isRefreshing: Bool
    
    /// Indicates the source of the Value (network or cache)
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
    
    /// Returns a copy of these metadata with the `isRefreshing` flag set to true.
    public var madeRefreshing: AsyncSuccessMetadata {
        .init(date: date, isRefreshing: true, source: source)
    }
}

/// The metadata associated with a `AsyncStatus.failure` case
public struct AsyncFailureMetadata: Dated {
    /// The `Date` at which the error occured
    public let date: Date
    
    public init(date: Date = .init()) {
        self.date = date
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

/// Generic metadata used to represent a network request information before it's started
public struct RequestMetadata {
    /// A slient request should not display an activity indicator while loading
    public let silent: Bool
    
    /// This request is allowed to read its data from cache, if available
    public let readFromCache: Bool
    
    /// This request will write any successful answer to the cache, if available
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
