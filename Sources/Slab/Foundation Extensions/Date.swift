import Foundation

public protocol Dated {
    var date: Date { get }
}

extension Date {
    public func progress(between start: Date, and end: Date) -> Double {
        guard start < end else { return 0 }
        return min(1, max(0, Date().timeIntervalSince(start) / end.timeIntervalSince(start)))
    }
    
    public func progress(in interval: ClosedRange<Date>) -> Double {
        progress(between: interval.lowerBound, and: interval.upperBound)
    }
    
    public var dmy: DateComponents {
        Calendar.current.dateComponents([.day, .month, .year], from: self)
    }
    
    public var isPast: Bool { timeIntervalSinceNow < 0 }
    public var isFuture: Bool { timeIntervalSinceNow > 0 }
    public var isToday: Bool { midnight == Date().midnight }
    public var isTomorrow: Bool { midnight == Date.tomorrow.midnight }
    
    public var midnight: Date {
        Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: self)!
    }
    
    public var timeIntervalSinceMidnight: TimeInterval {
        timeIntervalSince(midnight)
    }
    
    public static var midnight: Date {
        Date().midnight
    }
    
    public static var timeIntervalSinceMidnight: TimeInterval {
        Date().timeIntervalSinceMidnight
    }
    
    public static var tomorrow: Date {
        Date().midnight >> 1.day
    }
    
    public static var yesterday: Date {
        Date().midnight >> (-1).day
    }
}

public func >> (lhs: Date, rhs: TimeInterval) -> Date {
    lhs.addingTimeInterval(rhs)
}

public func << (lhs: Date, rhs: TimeInterval) -> Date {
    lhs.addingTimeInterval(-rhs)
}

public func >> (lhs: Date, rhs: DateComponents) -> Date {
    Calendar.current.date(byAdding: rhs, to: lhs)!
}

public func << (lhs: Date, rhs: DateComponents) -> Date {
    Calendar.current.date(byAdding: rhs.negated, to: lhs)!
}

extension ClosedRange where Bound == Date {
    public var isPresent: Bool { contains(Date()) }
    public var isPast: Bool { upperBound.isPast }
    public var isFuture: Bool { lowerBound.isFuture }
}

