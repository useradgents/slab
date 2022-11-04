import Foundation
import CoreGraphics.CGGeometry

public extension Numeric {
    @inlinable var nilIfZero: Self? {
        self == .zero ? .none : .some(self)
    }
}

public extension Numeric where Self: Comparable {
    /// Returns an array from this value, up to another value, with a custom optional step (interval)
    func upTo(_ other: Self, step: Self = 1) -> [Self] {
        var ret = [Self](); var last = self
        while last <= other {
            ret.append(last)
            last += step
        }
        return ret
    }
}

/*
 
 Fall In :
    ▲
    │        ╎      ╎────────
  ⎛ │        ╎     ╱╎
  ⎜ │        ╎    ╱ ╎
  ⎜ │        ╎   ╱  ╎
 to │        ╎  ╱   ╎
  ⎜ │        ╎ ╱    ╎
  ⎜ │        ╎╱     ╎
  ⎝ │────────╎      ╎
    │        ╎      ╎
  ──┼────────┴──────┴───────▶
    │        ╰ from ╯
 
 
 Fall Out :
 
   ▲
   │────────╎      ╎
 ⎛ │        ╎╲     ╎
 ⎜ │        ╎ ╲    ╎
 ⎜ │        ╎  ╲   ╎
to │        ╎   ╲  ╎
 ⎜ │        ╎    ╲ ╎
 ⎜ │        ╎     ╲╎
 ⎝ │        ╎      ╎────────
   │        ╎      ╎
 ──┼────────┴──────┴───────▶
   │        ╰ from ╯
 
 */

public extension FloatingPoint {
    
    /// Maps value from the range `inRange` to `outRange`, rising up. Values outside of `inRange` are clamped.
    @available(*, deprecated, message: "Use `map(from: inRange, to: outRange)` instead")
    func fallIn(from inRange: ClosedRange<Self>, to outRange: ClosedRange<Self> = 0...1) -> Self {
        guard inRange.upperBound > inRange.lowerBound else { return outRange.lowerBound }
        
        let inPercent = (self - inRange.lowerBound) / (inRange.upperBound - inRange.lowerBound)
        let inPercentClipped = Self.maximum(0, Self.minimum(inPercent, 1))
        
        return outRange.lowerBound + inPercentClipped * (outRange.upperBound - outRange.lowerBound)
    }
    
    /// Maps value from the range `inRange` to `outRange`, falling down. Values outside of `inRange` are clamped.
    @available(*, deprecated, message: "Use `map(from: inRange, to: outRange, reverse: true)` instead")
    func fallOff(from inRange: ClosedRange<Self>, to outRange: ClosedRange<Self> = 0...1) -> Self {
        guard inRange.upperBound > inRange.lowerBound else { return outRange.lowerBound }
        
        let inPercent = (self - inRange.lowerBound) / (inRange.upperBound - inRange.lowerBound)
        let inPercentClipped = Self.maximum(0, Self.minimum(inPercent, 1))
        
        return outRange.upperBound - inPercentClipped * (outRange.upperBound - outRange.lowerBound)
    }
}

/// Ease a CGFloat in the range [0...1] using a sin wave
@inlinable public func ease(_ x: CGFloat) -> CGFloat {
    0.5 + 0.5 * sin(CGFloat.pi * (max(0, min(x, 1)) - 0.5))
}

/// Ease a Float in the range [0...1] using a sin wave
@inlinable public func ease(_ x: Float) -> Float {
    0.5 + 0.5 * sin(Float.pi * (max(0, min(x, 1)) - 0.5))
}

/// Ease a Double in the range [0...1] using a sin wave
@inlinable public func ease(_ x: Double) -> Double {
    0.5 + 0.5 * sin(Double.pi * (max(0, min(x, 1)) - 0.5))
}
