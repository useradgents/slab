import Foundation

@available(iOS 13, macOS 10.15, *)
extension Array where Element: Identifiable {
    /// Returns a dictionary where all elements of this array are keyed by their id
    public var keyedByID: [Element.ID: Element] {
        reduce(into: [:]) { $0[$1.id] = $1 }
    }
}

