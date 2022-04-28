import CoreGraphics

extension CGSize: CustomStringConvertible {
    public var description: String { "\(width) × \(height)" }
}

infix operator × : RangeFormationPrecedence
@inlinable public func × (lhs: CGFloat, rhs: CGFloat) -> CGSize {
    CGSize(width: lhs, height: rhs)
}

public extension CGSize {
    init(vectorFrom origin: CGPoint, to dest: CGPoint) {
        self = CGSize(width: dest.x - origin.x, height: dest.y - origin.y)
    }
    
    @inlinable func makeRect(origin: CGPoint = .zero) -> CGRect {
        CGRect(origin: origin, size: self)
    }
    
    @inlinable func centeredIn(_ outerRect: CGRect) -> CGRect {
        CGRect(x: outerRect.midX - width / 2, y: outerRect.midY - height / 2, width: width, height: height)
    }
    
    @inlinable func scaled(_ factor: CGFloat) -> CGSize {
        CGSize(width: width * factor, height: height * factor)
    }
    
    var widthComponent: CGSize { CGSize(width: width, height: 0) }
    var heightComponent: CGSize { CGSize(width: 0, height: height) }
}

@inlinable public func + (lhs: CGSize, rhs: CGSize) -> CGSize {
    CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
}

@inlinable public func - (lhs: CGSize, rhs: CGSize) -> CGSize {
    CGSize(width: lhs.width - rhs.width, height: lhs.height - rhs.height)
}

#if canImport(UIKit)
import UIKit
public extension CGSize {
    func rectWithMode(_ mode: UIView.ContentMode, inside rect: CGRect) -> CGRect {
        switch mode {
            case .scaleToFill, .redraw:
                return rect
                
            case .scaleAspectFit:
                let scale = min(rect.width / width, rect.height / height)
                return CGRect(x: rect.midX - width * scale / 2, y: rect.midY - height * scale / 2, width: width * scale, height: height * scale)
                
            case .scaleAspectFill:
                let scale = max(rect.width / width, rect.height / height)
                return CGRect(x: rect.midX - width * scale / 2, y: rect.midY - height * scale / 2, width: width * scale, height: height * scale)
                
            case .center:
                return CGRect(x: rect.midX - width / 2, y: rect.midY - height / 2, width: width, height: height)
                
            case .top:
                return CGRect(x: rect.midX - width / 2, y: 0, width: width, height: height)
                
            case .bottom:
                return CGRect(x: rect.midX - width / 2, y: rect.maxY - height, width: width, height: height)
                
            case .left:
                return CGRect(x: 0, y: rect.midY - height / 2, width: width, height: height)
                
            case .right:
                return CGRect(x: rect.maxX - width, y: rect.midY - height / 2, width: width, height: height)
                
            case .topLeft:
                return CGRect(x: 0, y: 0, width: width, height: height)
                
            case .topRight:
                return CGRect(x: rect.maxX - width, y: 0, width: width, height: height)
                
            case .bottomLeft:
                return CGRect(x: 0, y: rect.maxY - height, width: width, height: height)
                
            case .bottomRight:
                return CGRect(x: rect.maxX - width, y: rect.maxY - height, width: width, height: height)
                
            @unknown default:
                return rect
        }
    }
    
    var screenScaled: CGSize {
        scaled(UIScreen.main.scale)
    }
}
#endif
