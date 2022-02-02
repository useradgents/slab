import CoreGraphics

public extension CGRect {
    var northWest: CGPoint { CGPoint(x: minX, y: minY) }
    var north: CGPoint     { CGPoint(x: midX, y: minY) }
    var northEast: CGPoint { CGPoint(x: maxX, y: minY) }
    var west: CGPoint      { CGPoint(x: minX, y: midY) }
    var center: CGPoint    { CGPoint(x: midX, y: midY) }
    var east: CGPoint      { CGPoint(x: maxX, y: midY) }
    var southWest: CGPoint { CGPoint(x: minX, y: maxY) }
    var south: CGPoint     { CGPoint(x: midX, y: maxY) }
    var southEast: CGPoint { CGPoint(x: maxX, y: maxY) }
    
    func insetBy(t: CGFloat = 0, l: CGFloat = 0, r: CGFloat = 0, b: CGFloat = 0) -> CGRect {
        CGRect(x: minX + l, y: minY + t, width: width - l - r, height: height - t - b)
    }
    
    func scaled(by scale: CGFloat) -> CGRect {
        CGRect(x: minX * scale, y: minY * scale, width: width * scale, height: height * scale)
    }
    
    func side(_ side: UIRectSide, size dim: CGFloat) -> CGRect {
        switch side {
            case .left: return CGRect(x: origin.x, y: origin.y, width: min(dim, size.width), height: size.height)
            case .right: return CGRect(x: origin.x + size.width - min(dim, size.width), y: origin.y, width: min(dim, size.width), height: size.height)
            case .top: return CGRect(x: origin.x, y: origin.y, width: size.width, height: min(dim, size.height))
            case .bottom: return CGRect(x: origin.x, y: origin.y + size.height - min(dim, size.height), width: size.width, height: min(dim, size.height))
        }
    }
    
    var inscribedSquare: CGRect {
        let s = min(size.width, size.height)
        return CGRect(
            x: midX - s/2,
            y: midY - s/2,
            width: s,
            height: s
        )
    }
    
    var outscribedSquare: CGRect {
        let s = max(size.width, size.height)
        return CGRect(
            x: midX - s/2,
            y: midY - s/2,
            width: s,
            height: s
        )
    }
    
    var diagonal: CGFloat {
        sqrt(width*width + height*height)
    }
    
    var outscribedCircle: CGRect {
        let radius = diagonal / 2
        return CGRect(
            x: midX - radius,
            y: midY - radius,
            width: 2*radius,
            height: 2*radius
        )
    }
}

public func * (rect: CGRect, scale: CGFloat) -> CGRect {
    CGRect(x: rect.minX * scale, y: rect.minY * scale, width: rect.width * scale, height: rect.height * scale)
}

public extension Collection where Element == CGRect {
    var united:      CGRect { reduce(.null, { $0.union($1)        }) }
    var intersected: CGRect { reduce(.null, { $0.intersection($1) }) }
}

#if canImport(SwiftUI)

import SwiftUI
public extension CGRect {
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
    func inset(by ei: EdgeInsets) -> CGRect {
        CGRect(
            x: origin.x + ei.leading,
            y: origin.y + ei.top,
            width: size.width - ei.leading - ei.trailing,
            height: size.height - ei.top - ei.bottom
        )
    }
}
#endif

#if canImport(UIKit)
import UIKit
public extension CGRect {
    func insetBy(_ insets: UIEdgeInsets) -> CGRect {
        CGRect(x: minX + insets.left, y: minY + insets.top, width: width - insets.left - insets.right, height: height - insets.top - insets.bottom)
    }
    
    func hairline(on side: UIRectSide, for screen: UIScreen = .main) -> CGRect {
        let hairline = screen.hairline
        switch side {
            case .top:
                return CGRect(x: minX, y: minY, width: width, height: hairline)
            case .left:
                return CGRect(x: minX, y: minY, width: hairline, height: height)
            case .bottom:
                return CGRect(x: minX, y: maxY - hairline, width: width, height: hairline)
            case .right:
                return CGRect(x: maxX - hairline, y: minY, width: hairline, height: height)
        }
    }
    
    func side(_ edge: UIRectEdge, size dim: CGFloat) -> CGRect {
        switch edge {
            case .left: return CGRect(x: origin.x, y: origin.y, width: min(dim, size.width), height: size.height)
            case .right: return CGRect(x: origin.x + size.width - min(dim, size.width), y: origin.y, width: min(dim, size.width), height: size.height)
            case .top: return CGRect(x: origin.x, y: origin.y, width: size.width, height: min(dim, size.height))
            case .bottom: return CGRect(x: origin.x, y: origin.y + size.height - min(dim, size.height), width: size.width, height: min(dim, size.height))
            default:
                return self
        }
    }
}

public extension UIScreen {
    var hairline: CGFloat { 1.0 / self.scale }
}
#endif
