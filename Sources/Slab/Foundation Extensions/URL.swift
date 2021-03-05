import Foundation

extension URL: ExpressibleByStringLiteral {
    /// Creates an URL with any string literal
    public init(stringLiteral value: String) {
        self = URL(string: value)!
    }
}
