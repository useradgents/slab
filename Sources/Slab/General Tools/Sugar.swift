import Foundation

// Shorthands for async after
public func wait(_ delta: TimeInterval, then: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + delta, execute: then)
}

public func wait(_ delta: Range<Double>, then: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + .random(in: delta), execute: then)
}

// Ascending and descending keypath-based sort operators
// foo.sorted(by: ↑\.name)

prefix operator ↑
prefix operator ↓

/// Create an ascending sort closure from a keypath
public prefix func ↑ <Root, Value: Comparable>(keyPath: KeyPath<Root, Value>) -> (Root, Root) -> Bool {
    { $0[keyPath: keyPath] < $1[keyPath: keyPath] }
}

/// Create a descending sort closure from a keypath
public prefix func ↓ <Root, Value: Comparable>(keyPath: KeyPath<Root, Value>) -> (Root, Root) -> Bool {
    { $0[keyPath: keyPath] > $1[keyPath: keyPath] }
}

/// Protocol to allow using `with()` on any `NSObect`
public protocol Withable {}
extension NSObject: Withable {}

extension Withable where Self: NSObject {
    /// Modifies any object's property. Chainable.
    ///
    /// Allows writing
    /// ```
    /// lazy var label = UILabel()
    ///   .with(\.numberOfLines, 0)
    ///   .with(\.backgroundColor, .clear)
    /// ```
    /// instead of
    /// ```
    /// lazy var label: UILabel {
    ///     let l = label()
    ///     l.numberOfLines = 0
    ///     l.backgroundColor = .clear
    ///     return l
    /// }()
    /// ```
    @discardableResult
    public func with<T>(_ keyPath: WritableKeyPath<Self, T>, _ value: T) -> Self {
        var mutableSelf = self
        mutableSelf[keyPath: keyPath] = value
        return self
    }
    
    /// Modifies any object's property. Chainable.
    ///
    /// Allows writing
    /// ```
    /// lazy var label = UILabel()
    ///   .with(\.numberOfLines, 0)
    ///   .with(\.backgroundColor, .clear)
    /// ```
    /// instead of
    /// ```
    /// lazy var label: UILabel {
    ///     let l = label()
    ///     l.numberOfLines = 0
    ///     l.backgroundColor = .clear
    ///     return l
    /// }()
    /// ```
    @discardableResult
    public func with<T>(_ keyPath: ReferenceWritableKeyPath<Self, T>, _ value: T) -> Self {
        self[keyPath: keyPath] = value
        return self
    }
}

infix operator =^=
@available(iOS 13, *)
/// Identifiable equality by id
public func =^= <T: Identifiable, U: Identifiable> (lhs: T, rhs: U) -> Bool where T.ID == U.ID {
    lhs.id == rhs.id
}
