import Foundation

/// Protocol for types having a date stamp
public protocol Dated {
    var date: Date { get }
}

extension Date {
    /// Returns the fraction of time elapsed between two dates, as a Double in the range `0...1`
    public func progress(between start: Date, and end: Date) -> Double {
        guard start < end else { return 0 }
        return min(1, max(0, Date().timeIntervalSince(start) / end.timeIntervalSince(start)))
    }
    
    /// Returns the fraction of time elapsed between two dates, as a Double in the range `0...1`
    public func progress(in interval: ClosedRange<Date>) -> Double {
        progress(between: interval.lowerBound, and: interval.upperBound)
    }
    
    /// Returns boolean if this date is the same day of date in parameter. Without looking hour
    public func isSameDayThan(_ date: Date) -> Bool {
        return midnight == date.midnight
    }
    
    /// Returns the day, month and year components of the Date
    public var dmy: DateComponents {
        Calendar.current.dateComponents([.day, .month, .year], from: self)
    }
    
    /// Returns a Bool indicating whether the Date is in the past
    public var isPast: Bool { timeIntervalSinceNow < 0 }
    
    /// Returns a Bool indicating whether the Date is in the future
    public var isFuture: Bool { timeIntervalSinceNow > 0 }
    
    /// Returns a Bool indicating whether the Date is today, according to the current Calendar
    public var isToday: Bool { midnight == Date().midnight }
    
    /// Returns a Bool indicating whether the Date is tomorrow, according to the current Calendar
    public var isTomorrow: Bool { midnight == Date.tomorrow.midnight }
    
    /// Returns a Bool indicating whether the Date is tomorrow, according to the current Calendar
    public var isAfterTomorrow: Bool { midnight == Date.afterTomorrow.midnight }

    /// Returns a Date with hour, minute and second components set to 0, according to the current Calendar
    public var midnight: Date {
        Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: self)!
    }
    
    /// Returns a Date with hour and minute set to a HoursMinute instance, and seconds to zero, according to the current Calendar
    public func at(_ time: HoursMinutes) -> Date {
        Calendar.current.date(bySettingHour: time.hour, minute: time.minute, second: 0, of: self)!
    }
    
    /// Returns the timeInterval since midnight, according to the current Calendar
    public var timeIntervalSinceMidnight: TimeInterval {
        timeIntervalSince(midnight)
    }
    
    /// Returns a Date set to the beginning of the current day, according to the current Calendar
    public static var midnight: Date {
        Date().midnight
    }

    /// Returns the timeInterval of the beginning of the current day, according to the current Calendar
    public static var timeIntervalSinceMidnight: TimeInterval {
        Date().timeIntervalSinceMidnight
    }
    
    /// Returns a Date set to the beginning of tomorrow, according to the current Calendar
    public static var tomorrow: Date {
        Date().midnight >> 1.day
    }
    
    /// Returns a Date set to the beginning of after tomorrow, according to the current Calendar
    public static var afterTomorrow: Date {
        Date().midnight >> 2.day
    }
    
    /// Returns a Date set to the beginning of yesterday, according to the current Calendar
    public static var yesterday: Date {
        Date().midnight >> (-1).day
    }
    
    /// Returns the number of days between this date and now. Use on past dates.
    public var daysAgo: Int {
        Calendar.current.dateComponents([.day], from: self, to: Date()).day!
    }
    
    /// Returns the number of days between now and this date. Use on future dates.
    public var daysFromNow: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: self).day!
    }
    
    /// Constant: number of seconds in a day
    /// WARNING: this is not always the case. Use with caution.
    public static let secondsInDay: Int = 86400
}

/// Adds a time interval to a date
public func >> (lhs: Date, rhs: TimeInterval) -> Date {
    lhs.addingTimeInterval(rhs)
}

/// Subtracts a time interval from a date
public func << (lhs: Date, rhs: TimeInterval) -> Date {
    lhs.addingTimeInterval(-rhs)
}

/// Adds time components to a date, according to the current Calendar
public func >> (lhs: Date, rhs: DateComponents) -> Date {
    Calendar.current.date(byAdding: rhs, to: lhs)!
}

/// Subtracts time components from a date, according to the current Calendar
public func << (lhs: Date, rhs: DateComponents) -> Date {
    Calendar.current.date(byAdding: rhs.negated, to: lhs)!
}

extension ClosedRange where Bound == Date {
    /// Returns a Bool indicating whether the Date range contains the current Date
    public var isPresent: Bool { contains(Date()) }
    
    /// Returns a Bool indicating whether the Date range is entirely in the past
    public var isPast: Bool { upperBound.isPast }
    
    /// Returns a Bool indicating whether the Date range is entirely in the future
    public var isFuture: Bool { lowerBound.isFuture }
    
    /// Returns a Double representing the progress in a given range, clamped to 0...1
    public var progress: Double {
        let total = upperBound.timeIntervalSince(lowerBound)
        guard total > 0 else { return 0 }
        let now = Date()
        if now < lowerBound { return 0 }
        if now > upperBound { return 1 }
        return now.timeIntervalSince(lowerBound) / total
    }
}

