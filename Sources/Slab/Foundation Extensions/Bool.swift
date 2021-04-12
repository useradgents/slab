import Foundation

extension Bool: ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    
    public init(stringLiteral value: String) {
        switch value {
            case "o", "O", "y", "Y", "true", "TRUE", "yes", "YES": self = true
            default: self = false
        }
    }
    
    public init(stringLiteral value: String?) {
        switch value {
            case .none:
                self = false
            case .some(let s):
                switch s {
                    case "o", "O", "y", "Y", "true", "TRUE", "yes", "YES": self = true
                    default: self = false
                }
        }
    }
}
