import Foundation

extension DateFormatter {
    
    /// Initializes a DateFormatter with the given date format
    public convenience init(dateFormat: String) {
        self.init()
        self.dateFormat = dateFormat
    }
    
    /// Initializes a DateFormatter with the given date style, time style and `relative` flag.
    public convenience init(dateStyle: DateFormatter.Style, timeStyle: DateFormatter.Style, relative: Bool = false) {
        self.init()
        self.dateStyle = dateStyle
        self.timeStyle = timeStyle
        self.doesRelativeDateFormatting = relative
    }
    
    /// Common DateFormatter with short date and no time
    public static var shortDate = DateFormatter(dateStyle: .short, timeStyle: .none)
    
    /// Common DateFormatter with medium date and no time
    public static var mediumDate = DateFormatter(dateStyle: .medium, timeStyle: .none)
    
    /// Common DateFormatter with long date and no time
    public static var longDate = DateFormatter(dateStyle: .long, timeStyle: .none)
    
    /// Common DateFormatter with no date and short time
    public static var shortTime = DateFormatter(dateStyle: .none, timeStyle: .short)
    
    /// Common DateFormatter with relative short date and no time
    public static var relativeDate = DateFormatter(dateStyle: .short, timeStyle: .none, relative: true)
    
    /// Common DateFormatter with relative short date and short time
    public static var relativeDateTime = DateFormatter(dateStyle: .short, timeStyle: .short, relative: true)
    
    /// Common DateFormatter with ISO8601 date-only format
    public static var isoDate = DateFormatter(dateFormat: "yyyy-MM-dd")
    
    /// Common DateFormatter with ISO8601 date-only format and no timezone
    public static var isoDateAbsolute = DateFormatter(dateFormat: "yyyy-MM-dd")
        .with(\DateFormatter.calendar, Calendar(identifier: .iso8601))
        .with(\DateFormatter.locale, Locale(identifier: "en_US_POSIX"))
        .with(\DateFormatter.timeZone, TimeZone(secondsFromGMT: 0))
    
    /// Common DateFormatter with ISO8601 date+time format
    public static var isoDateTime = DateFormatter(dateFormat: "yyyy-MM-dd'T'HH:mm:ssZ")
    
    /// Common DateFormatter with ISO8601 date+time format and no timezone
    public static var isoDateTimeAbsolute = DateFormatter(dateFormat: "yyyy-MM-dd'T'HH:mm:ssZ")
        .with(\DateFormatter.calendar, Calendar(identifier: .iso8601))
        .with(\DateFormatter.locale, Locale(identifier: "en_US_POSIX"))
        .with(\DateFormatter.timeZone, TimeZone(secondsFromGMT: 0))
    
    /// Common DateFormatter with ISO8601 date+time format with millisecond precision
    public static var isoDateTimeMilliseconds = DateFormatter(dateFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ")
    
    /// Common DateFormatter with ISO8601 date+time format with millisecond precision and no timezone
    public static var isoDateTimeMillisecondsAbsolute = DateFormatter(dateFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ")
        .with(\DateFormatter.calendar, Calendar(identifier: .iso8601))
        .with(\DateFormatter.locale, Locale(identifier: "en_US_POSIX"))
        .with(\DateFormatter.timeZone, TimeZone(secondsFromGMT: 0))
}

// Allow formatting dates with Swift 5 string interpolation:
// print("Will start at \(startTime, using: .shortTime)")
extension String.StringInterpolation {
    public mutating func appendInterpolation(_ value: Date, using formatter: DateFormatter) {
        appendLiteral(formatter.string(from: value))
    }
}
