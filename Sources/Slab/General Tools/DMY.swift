import Foundation

public struct DMY {
    var y: Int
    var m: Int
    var d: Int
}

// Getting common information
extension DMY {
    public var isToday: Bool { self == .today }
    public var isTomorrow: Bool { self == .today >> 1.day }
    public var isYesterday: Bool { self == .today << 1.day }
    public var isPast: Bool { self < .today }
    public var isNotPast: Bool { self >= .today }
    public var isFuture: Bool { self > .today }
    public var isNotFuture: Bool { self <= .today }
    public var isDistantPast: Bool { self == .distantPast }
    public var isDistantFuture: Bool { self == .distantFuture }
}

// Offsetting DMYs
extension DMY {
    public func offset(days: Int = 0, months: Int = 0, years: Int = 0) -> DMY {
        DMY(Calendar.current.date(byAdding: DateComponents(year: years, month: months, day: days), to: self.date)!)
    }
    
    public func interval(since: DMY, components: Set<Calendar.Component> = [.year, .month, .day]) -> DateComponents {
        Calendar.current.dateComponents(components, from: since.date, to: self.date)
    }
    
    public func interval(until: DMY, components: Set<Calendar.Component> = [.year, .month, .day]) -> DateComponents {
        Calendar.current.dateComponents(components, from: self.date, to: until.date)
    }
    
    public func days(since: DMY) -> Int {
        interval(since: since, components: [.day]).day!
    }
    
    public func days(until: DMY) -> Int {
        interval(until: until, components: [.day]).day!
    }
}

public func >> (lhs: DMY, rhs: DateComponents) -> DMY {
    DMY(Calendar.current.date(byAdding: rhs, to: lhs.date)!)
}

public func << (lhs: DMY, rhs: DateComponents) -> DMY {
    DMY(Calendar.current.date(byAdding: rhs.negated, to: lhs.date)!)
}

// Accessing common values
extension DMY {
    public static var today: DMY {
        DMY(Date())
    }
    
    public static var distantPast: DMY {
        DMY(y: 0, m: 1, d: 1)
    }
    
    public static var distantFuture: DMY {
        DMY(y: 9999, m: 12, d: 31)
    }
}

// Formatting DMYs
extension DMY {
    public enum Format {
        case year // 2022
        case month // 7
        case monthPadded // 07
        case monthName // juillet
        case monthAbreviation // jul
        case day // 1
        case dayPadded // 01
        case localLong // 7 juillet 2022 (uses DateFormatter with long style)
        case localShort // 07/01/2022
        case separator(String) // custom separator
        
        // using formatted(.day, .month, .year, .separator("-"))
        // will yield "1-7-2022"
    }
    
    public func formatted(_ formats: Format...) -> String {
        // do we have a custom separator Format?
        var separator: String?
        for format in formats { if case let .separator(sep) = format { separator = sep }}
        
        var ret: [String] = []
        for format in formats {
            switch format {
                case .year: ret.append(String(y))
                case .month: ret.append(String(m))
                case .monthPadded: ret.append(String(format: "%02n", m))
                case .monthName: ret.append(Calendar.current.monthSymbols[m-1])
                case .monthAbreviation: ret.append(Calendar.current.shortMonthSymbols[m-1])
                case .day: ret.append(String(d))
                case .dayPadded: ret.append(String(format: "%02n", d))
                case .localLong: ret.append(DateFormatter.longDate.string(from: date))
                case .localShort: ret.append(DateFormatter.shortDate.string(from: date))
                default: break
            }
        }
        return ret.joined(separator: separator ?? "/")
    }
}

// Comparing DMYs
extension DMY: Equatable, Comparable, Hashable, Identifiable {
    public static func < (lhs: DMY, rhs: DMY) -> Bool {
        if lhs.y < rhs.y { return true }
        if lhs.m < rhs.m { return true }
        if lhs.d < rhs.d { return true }
        return false
    }
    
    public static func == (lhs: DMY, rhs: DMY) -> Bool {
        (lhs.y, lhs.m, lhs.d) == (rhs.y, rhs.m, rhs.d)
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(y)
        hasher.combine(m)
        hasher.combine(d)
    }
    
    public var id: Int { y * 1_00_00 + m * 1_00 + d }
}

// Converting to/from Date or DateComponents
extension DMY {
    public init(_ date: Date) {
        self.y = Calendar.current.component(.year, from: date)
        self.m = Calendar.current.component(.month, from: date)
        self.d = Calendar.current.component(.day, from: date)
    }
    
    public init?(_ components: DateComponents) {
        guard
            let y = components.year,
            let m = components.month,
            let d = components.day
        else { return nil }
        
        self.y = y
        self.m = m
        self.d = d
    }
    
    public init?(dmy: String, separator: String = "/") {
        let pieces = dmy.components(separatedBy: separator)
        guard pieces.count >= 3 else { return nil }
        guard let d = Int(pieces[0]), let m = Int(pieces[1]), let y = Int(pieces[2]) else { return nil }
        
        self.d = d
        self.m = m
        self.y = (y < 100) ? 2000+y : y
    }
    
    public var components: DateComponents {
        DateComponents(calendar: .current, timeZone: .current, year: y, month: m, day: d)
    }
    
    public var date: Date {
        Calendar.current.date(from: components)!
    }
}

// Encoding/decoding
extension DMY: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        guard
            string.count == 8,
            let y = Int(String(string[0..<4])),
            let m = Int(String(string[4..<6])),
            let d = Int(String(string[6..<8]))
        else { throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "DMY should be encoded as 8 characters")) }
        
        self.y = y
        self.m = m
        self.d = d
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(String(format: "%04d%02d%02d", y, m, d))
    }
}

#if canImport(SwiftUI)
import SwiftUI

@available(iOS 14, macOS 11, *)
public struct DMYPicker: View {
    @Binding var selection: DMY
    @State private var date: Date
    
    public init(selection: Binding<DMY>) {
        self._selection = selection
        self._date = .init(initialValue: selection.wrappedValue.date)
    }
    
    public var body: some View {
        DatePicker(selection: $date, displayedComponents: [.date], label: { EmptyView() })
        #if os(macOS)
        .datePickerStyle(FieldDatePickerStyle())
        #endif
        .labelsHidden()
        .fixedSize()
        .onChange(of: date) { newDate in
            selection = .init(date)
        }
    }
}

@available(iOS 14, macOS 11, *)
public struct OptionalDMYPicker: View {
    @Binding var selection: DMY?
    @State private var date: Date
    
    public init(selection: Binding<DMY?>) {
        self._selection = selection
        self._date = .init(initialValue: selection.wrappedValue?.date ?? Date())
    }
    
    public var body: some View {
        HStack {
            Toggle(isOn: .init(
                get: { selection != nil },
                set: { selection = $0 ? .init(date) : nil }
            ), label: { EmptyView() })
            .labelsHidden()
            #if os(macOS)
            .toggleStyle(CheckboxToggleStyle())
            #endif
            
            if selection != nil {
                DatePicker(selection: $date, displayedComponents: [.date], label: { EmptyView() })
                #if os(macOS)
                .datePickerStyle(FieldDatePickerStyle())
                #endif
                .labelsHidden()
                .fixedSize()
                .onChange(of: date) { newDate in
                    selection = .init(date)
                }
            }
        }
    }
}
#endif
