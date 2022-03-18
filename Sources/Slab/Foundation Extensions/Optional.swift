import Foundation

public extension Optional where Wrapped: Numeric {
    var zeroIfNil: Wrapped {
        self ?? .zero
    }
}

public extension Optional where Wrapped: Emptiable {
    var emptyIfNil: Wrapped {
        self ?? .empty
    }
}

// Numeric types have a static `.zero` property, but Collection types have no `.empty` property.
// Let's fix that.

public protocol Emptiable {
    static var empty: Self { get }
}

extension String: Emptiable {
    public static var empty = ""
}

extension Dictionary: Emptiable {
    public static var empty: Self { [:] }
}

extension Array: Emptiable {
    public static var empty: Self { [] }
}

extension Set: Emptiable {
    public static var empty: Self { [] }
}

extension Data: Emptiable {
    public static var empty: Self { .init() }
}


