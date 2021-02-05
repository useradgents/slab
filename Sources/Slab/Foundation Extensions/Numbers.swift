import Foundation
import CoreGraphics.CGGeometry

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
   │        ╰ from ╯
 
 
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
    func fallIn(from inRange: ClosedRange<Self>, to outRange: ClosedRange<Self> = 0...1) -> Self {
        guard inRange.upperBound > inRange.lowerBound else { return outRange.lowerBound }
        
        let inPercent = (self - inRange.lowerBound) / (inRange.upperBound - inRange.lowerBound)
        let inPercentClipped = Self.maximum(0, Self.minimum(inPercent, 1))
        
        return outRange.lowerBound + inPercentClipped * (outRange.upperBound - outRange.lowerBound)
    }
    
    func fallOff(from inRange: ClosedRange<Self>, to outRange: ClosedRange<Self> = 0...1) -> Self {
        guard inRange.upperBound > inRange.lowerBound else { return outRange.lowerBound }
        
        let inPercent = (self - inRange.lowerBound) / (inRange.upperBound - inRange.lowerBound)
        let inPercentClipped = Self.maximum(0, Self.minimum(inPercent, 1))
        
        return outRange.upperBound - inPercentClipped * (outRange.upperBound - outRange.lowerBound)
    }
}

// Easing using sin() from 0...1 to 0...1
public func ease(_ x: CGFloat) -> CGFloat {
    0.5 + 0.5 * sin(CGFloat.pi * (max(0, min(x, 1)) - 0.5))
}
public func ease(_ x: Float) -> Float {
    0.5 + 0.5 * sin(Float.pi * (max(0, min(x, 1)) - 0.5))
}
public func ease(_ x: Double) -> Double {
    0.5 + 0.5 * sin(Double.pi * (max(0, min(x, 1)) - 0.5))
}
