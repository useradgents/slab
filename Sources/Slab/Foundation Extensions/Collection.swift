import Foundation

extension Collection {
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
