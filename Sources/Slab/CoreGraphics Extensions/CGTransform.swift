import CoreGraphics

extension CGAffineTransform {
    public static func Δ(_ x: CGFloat = 0, _ y: CGFloat = 0) -> CGAffineTransform {
        CGAffineTransform(translationX: x, y: y)
    }
    
    public static func Δx(_ x: CGFloat) -> CGAffineTransform {
        CGAffineTransform(translationX: x, y: 0)
    }
    
    public static func Δy(_ y: CGFloat) -> CGAffineTransform {
        CGAffineTransform(translationX: 0, y: y)
    }
    
    public static func scale(_ scale: CGFloat) -> CGAffineTransform {
        CGAffineTransform(scaleX: scale, y: scale)
    }
}

public func + (lhs: CGAffineTransform, rhs: CGAffineTransform) -> CGAffineTransform {
    return lhs.concatenating(rhs)
}

#if canImport(UIKit)
import UIKit
extension CATransform3D {
    public static func scale3D(_ scale: CGFloat) -> CATransform3D {
        CATransform3DMakeScale(scale, scale, 1)
    }
}
#endif
