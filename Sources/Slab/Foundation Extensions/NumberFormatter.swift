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
}
