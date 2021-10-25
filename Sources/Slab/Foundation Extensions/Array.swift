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
}

extension Array where Element: Equatable {
    /// Add element at the end of Array if it is not already in it
    /// Return boolean if appending succeed or not
    @discardableResult
    public mutating func appendIfNotContains(_ element: Element) -> Bool {
        if !contains(element) {
            append(element)
            return true
        }
        return false
    }
    
    /// Remove element in the Array if exists
    /// Return boolean if removing succeed or not
    @discardableResult
    public mutating func removeElement(_ element: Element) -> Bool {
        if let index = firstIndex(of: element) {
            remove(at: index)
            return true
        }
        return false
    }
}
