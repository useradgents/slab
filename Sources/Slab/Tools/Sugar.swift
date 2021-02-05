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

public prefix func ↑ <Root, Value: Comparable>(keyPath: KeyPath<Root, Value>) -> (Root, Root) -> Bool {
    { $0[keyPath: keyPath] < $1[keyPath: keyPath] }
}

public prefix func ↓ <Root, Value: Comparable>(keyPath: KeyPath<Root, Value>) -> (Root, Root) -> Bool {
    { $0[keyPath: keyPath] > $1[keyPath: keyPath] }
}

// Allow modifying any object's property
//     lazy var label = UILabel().with(\.numberOfLines, 0)
// instead of
//     lazy var label: UILabel { let l = label(); l.numberOfLines = 0; return l }
public protocol Withable {}
extension NSObject: Withable {}
extension Withable where Self: NSObject {
    @discardableResult
    public func with<T>(_ kp: WritableKeyPath<Self, T>, _ value: T) -> Self {
        var mutableSelf = self
        mutableSelf[keyPath: kp] = value
        return self
    }
    
    @discardableResult
    public func with<T>(_ kp: ReferenceWritableKeyPath<Self, T>, _ value: T) -> Self {
        self[keyPath: kp] = value
        return self
    }
}

// Identifiable equality by id
infix operator =^=
@available(iOS 13, *)
public func =^= <T: Identifiable, U: Identifiable> (lhs: T, rhs: U) -> Bool where T.ID == U.ID {
    lhs.id == rhs.id
}
