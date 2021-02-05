import Foundation

extension String.StringInterpolation {
    public mutating func appendInterpolation(percent value: Double) {
        appendInterpolation(value, using: NumberFormatter.percentageFormatter)
    }
    
    public mutating func appendInterpolation(euros value: Double) {
        appendInterpolation(value, using: NumberFormatter.euroFormatter)
    }
    
    public mutating func appendInterpolation(_ value: Double, using formater: NumberFormatter) {
        if let result = formater.string(from: NSNumber(value: value)) {
            appendLiteral(result)
        }
    }
}

extension NumberFormatter {
    public static let percentageFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.minimumFractionDigits = 0
        f.maximumFractionDigits = 2
        f.numberStyle = .percent
        return f
    }()
    
    public static let euroFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = "EUR"
        return f
    }()
    
    public  static let decimalFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.minimumFractionDigits = 0
        f.maximumFractionDigits = 2
        f.numberStyle = .decimal
        return f
    }()
}
