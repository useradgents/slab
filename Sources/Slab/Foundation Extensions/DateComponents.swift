import Foundation

/*
 Notably, this extension allows creating DateComponents by writing
 1.year.and(1.week)
 
 Or creating past/future Date by writing
 18.months.ago
 1.year.and(2.months).fromNow
 
 */

extension Int {
    public var seconds: DateComponents { var ret = DateComponents(); ret.second = self; return ret }
    public var minutes: DateComponents { var ret = DateComponents(); ret.minute = self; return ret }
    public var hours: DateComponents { var ret = DateComponents(); ret.hour = self; return ret }
    public var days: DateComponents { var ret = DateComponents(); ret.day = self; return ret }
    public var weeks: DateComponents { var ret = DateComponents(); ret.day = 7 * self; return ret }
    public var months: DateComponents { var ret = DateComponents(); ret.month = self; return ret }
    public var years: DateComponents { var ret = DateComponents(); ret.year = self; return ret }
    
    public var second: DateComponents { var ret = DateComponents(); ret.second = self; return ret }
    public var minute: DateComponents { var ret = DateComponents(); ret.minute = self; return ret }
    public var hour: DateComponents { var ret = DateComponents(); ret.hour = self; return ret }
    public var day: DateComponents { var ret = DateComponents(); ret.day = self; return ret }
    public var week: DateComponents { var ret = DateComponents(); ret.day = 7 * self; return ret }
    public var month: DateComponents { var ret = DateComponents(); ret.month = self; return ret }
    public var year: DateComponents { var ret = DateComponents(); ret.year = self; return ret }
}

extension DateComponents {
    public init?(day: Int, month: Int, year: Int) {
        self = DateComponents()
        self.day = day
        self.month = month
        self.year = year
    }
    
    public func and(_ other: DateComponents) -> DateComponents {
        var ret = self
        if let d = other.day { ret.day = (ret.day ?? 0) + d }
        if let m = other.month { ret.month = (ret.month ?? 0) + m }
        if let y = other.year { ret.year = (ret.year ?? 0) + y }
        if let h = other.hour { ret.hour = (ret.hour ?? 0) + h }
        if let m = other.minute { ret.minute = (ret.minute ?? 0) + m }
        if let s = other.second { ret.second = (ret.second ?? 0) + s }
        return ret
    }
    
    public var negated: DateComponents {
        var ret = DateComponents()
        if let d = day { ret.day = -d }
        if let m = month { ret.month = -m }
        if let y = year { ret.year = -y }
        if let h = hour { ret.hour = -h }
        if let m = minute { ret.minute = -m }
        if let s = second { ret.second = -s }
        return ret
    }
    
    public var ago: Date { Calendar.current.date(byAdding: negated, to: Date())! }
    public var fromNow: Date { Calendar.current.date(byAdding: self, to: Date())! }
    public var date: Date { Calendar.current.date(from: self)! }
    
    public static var today: DateComponents { Calendar.current.dateComponents([.day, .month, .year], from: Date()) }
}
