import Foundation

extension Array {
    /// Returns a copy of the Array with the nth Element removed
    public func removing(at index: Index) -> Array {
        var new = self
        new.remove(at: index)
        return new
    }
    
    /// Returns a copy of the Array with the given Element appended
    public func appending(_ newElement: Element) -> Array {
        var ret = self
        ret.append(newElement)
        return ret
    }
    
    /// Pops the first element of the array, provided it exists, and returns this element. Mutates the array.
    public mutating func popFirst() -> Element? {
        isEmpty ? nil : removeFirst()
    }
    
    /// Pops the last element of the array, provided it exists, and returns this element. Mutates the array.
    public mutating func popLast() -> Element? {
        isEmpty ? nil : removeLast()
    }
    public mutating func sort<T: Comparable>(by keyPath: KeyPath<Element, T>, reversed r: Bool = false) {
        if r {
            sort { $0[keyPath: keyPath] > $1[keyPath: keyPath] }
        }
        else {
            sort { $0[keyPath: keyPath] < $1[keyPath: keyPath] }
        }
    }
}

extension Array where Element: Equatable {
    /// Returns an array containing the unique elements of this Array
    public func uniq() -> [Element] {
        reduce(into: []) { if !$0.contains($1) { $0.append($1) } }
    }
}
