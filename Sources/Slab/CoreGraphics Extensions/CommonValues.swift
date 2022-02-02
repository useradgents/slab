import Foundation
import CoreGraphics

public let λ: CGFloat = 16 // common margin
public let qλ: CGFloat = λ/4 // quarter of a lambda
public let hλ: CGFloat = λ/2 // half of a lambda

public let δ: TimeInterval = 0.2 // common duration for UI animations

public struct AnchorPoint {
    public static let northWest = CGPoint(x: 0, y: 0)
    public static let north = CGPoint(x: 0.5, y: 0)
    public static let northEast = CGPoint(x: 1, y: 0)
    public static let west = CGPoint(x: 0, y: 0.5)
    public static let center = CGPoint(x: 0.5, y: 0.5)
    public static let east = CGPoint(x: 1, y: 0.5)
    public static let southWest = CGPoint(x: 0, y: 1)
    public static let south = CGPoint(x: 0.5, y: 1)
    public static let southEast = CGPoint(x: 1, y: 1)
}

public struct UnitAngle {
    public static let north = 3 * CGFloat.pi / 2
    public static let west = CGFloat(0)
    public static let westLow = CGFloat(0)
    public static let westHi = 2 * CGFloat.pi
    public static let south = CGFloat.pi / 2
    public static let east = CGFloat.pi
}

public enum UIRectSide {
    case top
    case left
    case bottom
    case right
}

public extension CGSize {
    static let microscopic = CGSize(width: 0.001, height: 0.001)
}
