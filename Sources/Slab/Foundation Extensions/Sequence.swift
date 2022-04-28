import Foundation

extension Sequence {
    /// Returns the sequence sorted by ascending keypath, optionally reversed.
    public func sorted<T: Comparable>(by keyPath: KeyPath<Element, T>, reversed r: Bool = false) -> [Element] {
        sorted { a, b in
            r ? a[keyPath: keyPath] > b[keyPath: keyPath]
                : a[keyPath: keyPath] < b[keyPath: keyPath]
        }
    }
}

prefix operator ↑
@inlinable public prefix func ↑ <T, V: Comparable> (kp: KeyPath<T, V>) -> (T, T) -> ComparisonResult {{
    let a = $0[keyPath: kp]
    let b = $1[keyPath: kp]
    if a == b { return .orderedSame }
    else if a < b { return .orderedAscending }
    else { return .orderedDescending }
}}

prefix operator ↓
@inlinable public prefix func ↓ <T, V: Comparable> (kp: KeyPath<T, V>) -> (T, T) -> ComparisonResult {{
    let a = $0[keyPath: kp]
    let b = $1[keyPath: kp]
    if a == b { return .orderedSame }
    else if a > b { return .orderedAscending }
    else { return .orderedDescending }
}}

extension Sequence {
    /// Returns the sequence sorted by one or more comparators, in order of precedence.
    ///
    /// Use the `↑` and `↓` prefix operators on `KeyPath`s that are `Comparable` to make it even shorter and enhance readability:
    ///
    ///     let allFlowers = flowers.sorted(by: ↑\.name, ↓\.color)
    @inlinable public func sorted(by comparators: (Element, Element) -> ComparisonResult...) -> [Element] {
        sorted(by: { a, b -> Bool in
            var comparators = comparators
            while let comparator = comparators.popFirst() {
                switch comparator(a, b) {
                    case .orderedAscending: return true
                    case .orderedDescending: return false
                    case .orderedSame where comparators.isEmpty: return true
                    default: continue
                }
            }
            return true
        })
    }
}
