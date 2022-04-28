import Foundation

extension Dictionary.Values {
    @inlinable public func reject(_ isExcluded: (Element) throws -> Bool) rethrows -> [Element] {
        try filter { !(try isExcluded($0)) }
    }
    
    @inlinable public func filter<T: Equatable>(_ keyPath: KeyPath<Element, T>, equals value: T) -> [Element] {
        filter { $0[keyPath: keyPath] == value }
    }
    
    @inlinable public func filter<T: Equatable>(_ keyPath: KeyPath<Element, T?>, equals value: T) -> [Element] {
        filter { $0[keyPath: keyPath] == .some(value) }
    }
    
    @inlinable public func filter<T: Equatable>(_ keyPath: KeyPath<Element, T>, in values: [T]) -> [Element] {
        filter { values.contains($0[keyPath: keyPath]) }
    }
    
    @inlinable public func reject<T: Equatable>(_ keyPath: KeyPath<Element, T>, equals value: T) -> [Element] {
        filter { $0[keyPath: keyPath] != value }
    }
}

extension Dictionary {
    @inlinable public subscript(opt key: Key?) -> Value? {
        key.flatMap { self[$0] }
    }
}
