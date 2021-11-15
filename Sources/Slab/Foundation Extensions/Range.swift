import Foundation

infix operator .... : RangeFormationPrecedence
infix operator ...< : RangeFormationPrecedence

/// Creates a closed range with values that may not be in ascending order
public func .... <T: Comparable>(lhs: T, rhs: T) -> ClosedRange<T> {
    min(lhs, rhs) ... max(lhs, rhs)
}

/// Creates a half-open range with values that may not be in ascending order
public func ...< <T: Comparable>(lhs: T, rhs: T) -> Range<T> {
    min(lhs, rhs) ..< max(lhs, rhs)
}

extension ClosedRange: ExpressibleByIntegerLiteral where Bound == Int {
    /// Creates a closed range with just an Int
    public init(integerLiteral value: Int) {
        self = value ... value
    }
    
    public static var zero: ClosedRange<Int> = 0 ... 0
    public static var zeroOrOne: ClosedRange<Int> = 0 ... 1
    public static var any: ClosedRange<Int> = 0 ... Int.max
    public static var one: ClosedRange<Int> = 1 ... 1
    public static var oneOrMore: ClosedRange<Int> = 1 ... Int.max
}

extension Collection {
    public func union<T>() -> ClosedRange<T>? where Element == ClosedRange<T> {
        guard let min = map(\.lowerBound).min() else { return nil }
        guard let max = map(\.upperBound).max() else { return nil }
        return min ... max
    }
}

public enum RelationToRange {
    case before
    case inside
    case after
}

extension Comparable {
    public func position(relativeTo range: ClosedRange<Self>) -> RelationToRange {
        if self < range.lowerBound { return .before }
        if self > range.upperBound { return .after }
        return .inside
    }
    
    public func position(relativeTo range: Range<Self>) -> RelationToRange {
        if self < range.lowerBound { return .before }
        if self >= range.upperBound { return .after }
        return .inside
    }
}
