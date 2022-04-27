import Foundation

infix operator ∈: ComparisonPrecedence
infix operator !∈: ComparisonPrecedence
infix operator ∉: ComparisonPrecedence

public func ∈ <T: Equatable>(lhs: T, rhs: [T]) -> Bool { rhs.contains(lhs) }
public func !∈ <T: Equatable>(lhs: T, rhs: [T]) -> Bool { !rhs.contains(lhs) }
public func ∉ <T: Equatable>(lhs: T, rhs: [T]) -> Bool { !rhs.contains(lhs) }


// Sugar operators for first, filter, …
// instead of
//     let foo = array.first(where: { $0.bar == baz }
// just write
//     let foo = array.first(where: \.bar == baz)
//
@inlinable public func == <T, V: Equatable> (lhs: KeyPath<T, V>, rhs: V) -> (T) -> Bool {
    { $0[keyPath: lhs] == rhs }
}

@inlinable public func != <T, V: Equatable> (lhs: KeyPath<T, V>, rhs: V) -> (T) -> Bool {
    { $0[keyPath: lhs] != rhs }
}

@inlinable public func ∈ <T, V: Equatable> (lhs: KeyPath<T, V>, rhs: [V]) -> (T) -> Bool {
    { rhs.contains($0[keyPath: lhs]) }
}

@inlinable public func !∈ <T, V: Equatable> (lhs: KeyPath<T, V>, rhs: [V]) -> (T) -> Bool {
    { !rhs.contains($0[keyPath: lhs]) }
}

@inlinable public func ∉ <T, V: Equatable> (lhs: KeyPath<T, V>, rhs: [V]) -> (T) -> Bool {
    { !rhs.contains($0[keyPath: lhs]) }
}

@inlinable public func < <T, V: Comparable> (lhs: KeyPath<T, V>, rhs: V) -> (T) -> Bool {
    { $0[keyPath: lhs] < rhs }
}

@inlinable public func > <T, V: Comparable> (lhs: KeyPath<T, V>, rhs: V) -> (T) -> Bool {
    { $0[keyPath: lhs] > rhs }
}

@inlinable public func <= <T, V: Comparable> (lhs: KeyPath<T, V>, rhs: V) -> (T) -> Bool {
    { $0[keyPath: lhs] <= rhs }
}

@inlinable public func >= <T, V: Comparable> (lhs: KeyPath<T, V>, rhs: V) -> (T) -> Bool {
    { $0[keyPath: lhs] >= rhs }
}


extension Collection {
    /// Starts a new group every time the closure returns true.
    /// Useful for splitting credit card numbers by groups of 4, for example.
    public func grouped(_ where: (Element) -> Bool) -> [[Element]] {
        guard !isEmpty else { return [] }
        var ret: [[Element]] = []
        var subret: [Element] = []
        for i in self {
            if `where`(i), !subret.isEmpty {
                ret.append(subret)
                subret = []
            }
            subret.append(i)
        }
        ret.append(subret)
        return ret
    }
    
    /// A Boolean value indicating whether the collection is **not** empty
    ///
    /// When you need to check whether your collection is not empty, use the isNotEmpty property instead of checking that the count property is greater than zero. For collections that don’t conform to RandomAccessCollection, accessing the count property iterates through the elements of the collection.
    /// ```
    /// let horseName = "Silver"
    /// if horseName.isNotEmpty {
    ///     print("Hi ho, \(horseName)!")
    /// } else {
    ///     print("My horse has no name.")
    /// }
    /// // Prints "Hi ho, Silver!"
    /// ```
    /// Complexity: O(1)
    public var isNotEmpty: Bool {
        !isEmpty
    }
    
    /// Turns an empty collection into a nil
    public var nilIfEmpty: Self? {
        isEmpty ? .none : .some(self)
    }
}


extension Collection where Element: Collection {
    /// Returns true if no element in this collection is empty.
    public var noneIsEmpty: Bool {
        first(where: {$0.isEmpty}) == nil
    }
    
    /// Returns true if all elements in this collection are empty.
    public var allAreEmpty: Bool {
        first(where: {$0.isEmpty == false}) == nil
    }
}

extension Collection where Element: Equatable {
    /// Returns the collection where all instances of an element have been replaced by another element.
    ///
    /// Uses `map` internally.
    ///
    /// Complexity: O(n)
    ///
    /// - parameters:
    ///     - old: The element to search for
    ///     - new: The element to replace **all** occurences of `old` with
    public func replacing(_ old: Element, with new: Element) -> [Element] {
        map { $0 == old ? new : $0 }
    }
}

extension Optional where Wrapped: Collection {
    /// A Boolean value indicating whether the optional is nil or the wrapped collection is empty.
    public var isEmpty: Bool {
        map(\.isEmpty) ?? true
    }
    
    /// A Boolean value indicating whether the wrapped collection is not nil and not empty.
    public var isNotEmpty: Bool {
        map(\.isNotEmpty) ?? false
    }
    
    /// Collapses an empty wrapped collection into a nil
    public var nilIfEmpty: Self {
        isEmpty ? nil : self
    }
    
    /// The count of the wrapped value, or zero if the optional is nil.
    public var count: Int {
        map(\.count) ?? 0
    }
}

@available(iOS 13, macOS 11, *)
extension Collection where Element: Identifiable {
    /// Access identifiable elements by subscripting their id
    public subscript(id id: Element.ID) -> Element? {
        first(where: { $0.id == id })
    }
}

extension Collection {
    /// Access elements by index if exists else return nil but not crash
    public subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

#if canImport(SwiftUI)

import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public extension Binding {
    static func emptyIfNil<T: Collection & Emptiable>(_ bString: Binding<T?>) -> Binding<T> {
        .init(
            get: { bString.wrappedValue ?? T.empty },
            set: { bString.wrappedValue = $0.nilIfEmpty }
        )
    }
}
#endif



