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
    
    /// Pops N leading elements of the array, provided they exist, and returns them. Mutates the array.
    public mutating func popFirst(_ count: Int) -> [Element]? {
        let range = startIndex ..< Swift.min(startIndex+count, endIndex)
        if range.isEmpty { return nil }
        let ret = Array(self[range])
        self.removeSubrange(range)
        return ret
    }
    
    /// Pops the last element of the array, provided it exists, and returns this element. Mutates the array.
    public mutating func popLast() -> Element? {
        isEmpty ? nil : removeLast()
    }
    
    /// Return an array of array of _size_ elements. Useful for grouping credit card numbers, for example.
    public func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
    
    @inlinable public func noneSatisfy(_ predicate: (Element) throws -> Bool) rethrows -> Bool {
        for e in self where try predicate(e) { return false }
        return true
    }
    
    @inlinable public func oneSatisfies(_ predicate: (Element) throws -> Bool) rethrows -> Bool {
        for e in self where try predicate(e) { return true }
        return false
    }
    
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
    
    public func withoutNils<T>() -> [T] where Element == T? {
        compactMap { $0 }
    }
    
    @inlinable public func sorted<T: Comparable>(by keyPath: KeyPath<Element, T?>, defaultIfNil: T) -> [Element] {
        sorted(by: { ($0[keyPath: keyPath] ?? defaultIfNil) < ($1[keyPath: keyPath] ?? defaultIfNil) })
    }
}

extension Array where Element: Hashable {
    @inlinable public func uniq() -> [Element] {
        Array(Set(self))
    }
}

extension Array where Element: Equatable {
    /// Add element at the end of Array if it is not already in it
    /// Return boolean if appending succeed or not
    @discardableResult
    public mutating func appendIfNotContains(_ element: Element) -> Bool {
        guard !contains(element) else { return false }
        append(element)
        return true
    }
    
    /// Remove element in the Array if exists
    /// Return boolean if removing succeed or not
    @discardableResult
    public mutating func removeElement(_ element: Element) -> Bool {
        guard let index = firstIndex(of: element) else { return false }
        remove(at: index)
        return true
    }
}
