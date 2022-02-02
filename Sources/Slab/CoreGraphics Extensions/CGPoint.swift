import CoreGraphics

public extension CGPoint {
    func offset(x: CGFloat = 0, y: CGFloat = 0) -> CGPoint {
        CGPoint(x: self.x + x, y: self.y + y)
    }
    
    func dotProduct(with other: CGPoint) -> CGFloat {
        self.x * other.x + self.y * other.y
    }
    
    var length: CGFloat { sqrt(dotProduct(with: self)) }
    
    func adding(_ other: CGPoint) -> CGPoint {
        CGPoint(x: self.x + other.x, y: self.y + other.y)
    }
    
    func substracting(_ other: CGPoint) -> CGPoint {
        CGPoint(x: self.x - other.x, y: self.y - other.y)
    }
    
    func multiplied(by value: CGFloat) -> CGPoint {
        CGPoint(x: value * self.x, y: value * self.y)
    }
}


public func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}

public func + (lhs: CGPoint, rhs: CGSize) -> CGPoint {
    CGPoint(x: lhs.x + rhs.width, y: lhs.y + rhs.height)
}

public func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
}

public func - (lhs: CGPoint, rhs: CGSize) -> CGPoint {
    CGPoint(x: lhs.x - rhs.width, y: lhs.y - rhs.height)
}
