import Foundation

extension String.StringInterpolation {
    /// Allow formatting Double values with Swift 5 string interpolation
    ///
    /// ```
    /// print("\(percentageDone, using: .percent) done")
    /// // if percent = 0.25, will print "25% done"
    /// ```
    public mutating func appendInterpolation(_ value: Double, using formater: NumberFormatter) {
        if let result = formater.string(from: NSNumber(value: value)) {
            appendLiteral(result)
        }
    }
    
    /// Allow formatting Float values with Swift 5 string interpolation
    ///
    /// ```
    /// print("\(percentageDone, using: .percent) done")
    /// // if percent = 0.25, will print "25% done"
    /// ```
    public mutating func appendInterpolation(_ value: Float, using formater: NumberFormatter) {
        if let result = formater.string(from: NSNumber(value: value)) {
            appendLiteral(result)
        }
    }
    
    /// Allow formatting Int values with Swift 5 string interpolation
    public mutating func appendInterpolation(_ value: Int, using formater: NumberFormatter) {
        if let result = formater.string(from: NSNumber(value: value)) {
            appendLiteral(result)
        }
    }
}

extension NumberFormatter {
    /// Common NumberFormatter for percentages: `percent` number style, 0 to 2 fraction digits
    public static let percentage: NumberFormatter = {
        let f = NumberFormatter()
        f.minimumFractionDigits = 0
        f.maximumFractionDigits = 2
        f.numberStyle = .percent
        return f
    }()
    
    /// Common NumberFormatter for Euro values: `currency` number style, `EUR` currency code.
    public static let euros: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = "EUR"
        return f
    }()
    
    /// Common NumberFormatter for decimal values: `decimal` number style, 0 to 2 fraction digits
    public static let decimal: NumberFormatter = {
        let f = NumberFormatter()
        f.minimumFractionDigits = 0
        f.maximumFractionDigits = 2
        f.numberStyle = .decimal
        return f
    }()
    
    /// Sugar functions
    public func string(from int: Int) -> String {
        string(from: NSNumber(value: int))!
    }
    
    public func string(from double: Double) -> String {
        string(from: NSNumber(value: double))!
    }
    
    public func optionalString(from optionalInt: Int?) -> String? {
        optionalInt.map { string(from: $0) }
    }
    
    public func optionalString(from optionalDouble: Double?) -> String? {
        optionalDouble.map { string(from: $0) }
    }
    
    public func int(from optionalString: String?) -> Int? {
        guard let s = optionalString else { return nil }
        return number(from: s)?.intValue
    }
    
    public func double(from optionalString: String?) -> Double? {
        guard let s = optionalString else { return nil }
        return number(from: s)?.doubleValue
    }
}
