import Foundation

extension Sequence {
    public func sorted<T: Comparable>(by keyPath: KeyPath<Element, T>, reversed r: Bool = false) -> [Element] {
        sorted { a, b in
            r ? a[keyPath: keyPath] > b[keyPath: keyPath]
                : a[keyPath: keyPath] < b[keyPath: keyPath]
        }
    }
}
