import Foundation

extension DateFormatter {
    public convenience init(dateFormat: String) {
        self.init()
        self.dateFormat = dateFormat
    }
    
    public convenience init(dateStyle: DateFormatter.Style, timeStyle: DateFormatter.Style, relative: Bool = false) {
        self.init()
        self.dateStyle = dateStyle
        self.timeStyle = timeStyle
        self.doesRelativeDateFormatting = relative
    }
    
    public static var shortDate = DateFormatter(dateStyle: .short, timeStyle: .none)
    public static var shortTime = DateFormatter(dateStyle: .none, timeStyle: .short)
    public static var relativeDate = DateFormatter(dateStyle: .short, timeStyle: .none, relative: true)
    public static var relativeDateTime = DateFormatter(dateStyle: .short, timeStyle: .short, relative: true)
}

// Allow formatting dates with Swift 5 string interpolation:
// print("Will start at \(startTime, using: .shortTime)")
extension String.StringInterpolation {
    public mutating func appendInterpolation(_ value: Date, using formatter: DateFormatter) {
        appendLiteral(formatter.string(from: value))
    }
}
