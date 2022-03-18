import Foundation

extension Set {
    @inlinable public mutating func toggle(_ value: Element) {
        if contains(value) { remove(value) }
        else { insert(value) }
    }
}
