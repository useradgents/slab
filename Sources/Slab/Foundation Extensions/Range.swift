import Foundation
import CoreGraphics

infix operator .... : RangeFormationPrecedence
infix operator ...< : RangeFormationPrecedence

/// Creates a closed range with values that may not be in ascending order
@inlinable public func .... <T: Comparable>(lhs: T, rhs: T) -> ClosedRange<T> {
    min(lhs, rhs) ... max(lhs, rhs)
}

/// Creates a half-open range with values that may not be in ascending order
@inlinable public func ...< <T: Comparable>(lhs: T, rhs: T) -> Range<T> {
    min(lhs, rhs) ..< max(lhs, rhs)
}

@inlinable public func ∈ <T: Equatable, C: RangeExpression>(lhs: T, rhs: C) -> Bool where C.Bound == T { rhs.contains(lhs) }
@inlinable public func !∈ <T: Equatable, C: RangeExpression>(lhs: T, rhs: C) -> Bool where C.Bound == T { !rhs.contains(lhs) }
@inlinable public func ∉ <T: Equatable, C: RangeExpression>(lhs: T, rhs: C) -> Bool where C.Bound == T { !rhs.contains(lhs) }

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

extension ClosedRange where Bound: Numeric {
    /// Returns the length of the range
    public var extent: Bound { upperBound - lowerBound }
}

extension Collection {
    /// Encompasses several ranges into one big range
    public func union<T>() -> ClosedRange<T>? where Element == ClosedRange<T> {
        guard let min = map(\.lowerBound).min() else { return nil }
        guard let max = map(\.upperBound).max() else { return nil }
        return min ... max
    }
}

extension FloatingPoint {
    /// Returns the position of a value inside a range, normalized to 0...1
    @inlinable public func progress(in range: ClosedRange<Self>) -> Self {
        (self - range.lowerBound) / (range.upperBound - range.lowerBound)
    }
    
    /// Performs a reference change from a source range to a destination range
    @inlinable public func map(from sourceRange: ClosedRange<Self> = 0...1, to destRange: ClosedRange<Self> = 0...1, reversed: Bool = false) -> Self {
        if reversed {
            return destRange.upperBound - (self - sourceRange.lowerBound) / (sourceRange.upperBound - sourceRange.lowerBound) * (destRange.upperBound - destRange.lowerBound)
        }
        else {
            return destRange.lowerBound + (self - sourceRange.lowerBound) / (sourceRange.upperBound - sourceRange.lowerBound) * (destRange.upperBound - destRange.lowerBound)
        }
    }
}

extension FloatingPoint where Self: BinaryInteger {
    /// Performs a reference change from a source range to a date range
    @inlinable public func map(from sourceRange: ClosedRange<Self> = 0...1, to destRange: ClosedRange<Date>) -> Date {
        let destDaysInterval = Self(Calendar.current.dateComponents([.day], from: destRange.lowerBound, to: destRange.upperBound).day!)
        let daysSinceStart = (self - sourceRange.lowerBound) / (sourceRange.upperBound - sourceRange.lowerBound) * destDaysInterval
        return Calendar.current.date(byAdding: .day, value: Int(daysSinceStart), to: destRange.lowerBound)!
    }
}

public enum RelationToRange {
    case before
    case inside
    case after
}

extension Comparable {
    @inlinable public func position(relativeTo range: ClosedRange<Self>) -> RelationToRange {
        if self < range.lowerBound { return .before }
        if self > range.upperBound { return .after }
        return .inside
    }
    
    @inlinable public func position(relativeTo range: Range<Self>) -> RelationToRange {
        if self < range.lowerBound { return .before }
        if self >= range.upperBound { return .after }
        return .inside
    }
}

extension Collection where Element: Comparable {
    /// Returns the min...max range from this array of values.
    @inlinable var range: ClosedRange<Element>? {
        guard let min = self.min(), let max = self.max() else { return nil }
        return min...max
    }
}

extension CGRect {
    /// The x values range
    var xRange: ClosedRange<CGFloat> { minX...maxX }
    
    /// The y values range
    var yRange: ClosedRange<CGFloat> { minY...maxY }
}
