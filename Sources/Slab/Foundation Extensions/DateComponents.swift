import Foundation

/*
 Notably, this extension allows creating DateComponents by writing
 1.year.and(1.week)
 
 Or creating past/future Date by writing
 18.months.ago
 1.year.and(2.months).fromNow
 Date.tomorrow >> 3.hours
 
 */

extension Int {
    public var seconds: DateComponents { DateComponents(second: self) }
    public var minutes: DateComponents { DateComponents(minute: self) }
    public var hours:   DateComponents { DateComponents(hour: self) }
    public var days:    DateComponents { DateComponents(day: self) }
    public var weeks:   DateComponents { DateComponents(day: 7*self) }
    public var months:  DateComponents { DateComponents(month : self) }
    public var years:   DateComponents { DateComponents(year: self) }
    
    public var second:  DateComponents { DateComponents(second: self) }
    public var minute:  DateComponents { DateComponents(minute: self) }
    public var hour:    DateComponents { DateComponents(hour: self) }
    public var day:     DateComponents { DateComponents(day: self) }
    public var week:    DateComponents { DateComponents(day: 7*self) }
    public var month:   DateComponents { DateComponents(month : self) }
    public var year:    DateComponents { DateComponents(year: self) }
}

extension DateComponents {
    /// Adds other DateComponents to these DateComponents
    ///
    /// Values that are added: era, year, month, day, hour, minute, second, nanosecond
    ///
    /// Values that are ignored: calendar, timeZone, weekday, weekdayOrdinal, quarter, weekOfMonth, weekOfYear, yearForWeekOfYear
    public func and(_ other: DateComponents) -> DateComponents {
        var ret = self
        if let e = other.era { ret.era = (ret.era ?? 0) + e }
        if let y = other.year { ret.year = (ret.year ?? 0) + y }
        if let m = other.month { ret.month = (ret.month ?? 0) + m }
        if let d = other.day { ret.day = (ret.day ?? 0) + d }
        if let h = other.hour { ret.hour = (ret.hour ?? 0) + h }
        if let m = other.minute { ret.minute = (ret.minute ?? 0) + m }
        if let s = other.second { ret.second = (ret.second ?? 0) + s }
        if let n = other.nanosecond { ret.nanosecond = (ret.nanosecond ?? 0) + n }
        return ret
    }
    
    /// Negates all values of the current DateComponents
    ///
    /// Values that are negated: era, year, month, day, hour, minute, second, nanosecond
    ///
    /// Values that are ignored: calendar, timeZone, weekday, weekdayOrdinal, quarter, weekOfMonth, weekOfYear, yearForWeekOfYear
    public var negated: DateComponents {
        var ret = DateComponents()
        if let e = era { ret.era = -e }
        if let y = year { ret.year = -y }
        if let m = month { ret.month = -m }
        if let d = day { ret.day = -d }
        if let h = hour { ret.hour = -h }
        if let m = minute { ret.minute = -m }
        if let s = second { ret.second = -s }
        if let n = nanosecond { ret.nanosecond = -n }
        return ret
    }
    
    /// Returns the Date corresponding to these DateComponents, according the the current Calendar
    public var currentCalendarDate: Date { Calendar.current.date(from: self)! }
    
    /// Returns the current Date according to the current Calendar, minus these DateComponents
    ///
    /// Example :
    /// ```
    /// let threeHoursAgo = DateComponents(hour: 3).ago
    /// // Alternative way to write this:
    /// let threeHoursAgo = 3.hours.ago
    /// ```
    public var ago: Date { Calendar.current.date(byAdding: negated, to: Date())! }
    
    /// Returns the current Date according to the current Calendar, adding these DateComponents
    ///
    /// Example :
    /// ```
    /// let nextYear = DateComponents(year: 1).fromNow
    /// // Alternative way to write this:
    /// let nextYear = 1.year.fromNow
    /// ```
    public var fromNow: Date { Calendar.current.date(byAdding: self, to: Date())! }
    
    /// Returns the day, month, year components for today
    public static var today: DateComponents { Date().dmy }
}

/// Adds two time components
public func >> (lhs: DateComponents, rhs: DateComponents) -> DateComponents {
    lhs.and(rhs)
}

/// Subtracts time components
public func << (lhs: DateComponents, rhs: DateComponents) -> DateComponents {
    lhs.and(rhs.negated)
}
