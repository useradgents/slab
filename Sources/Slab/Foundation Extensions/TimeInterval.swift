import Foundation

extension TimeInterval {
    /// Returns the number of minutes in this TimeInterval
    @inlinable public var minutes: Int {
        Int((self / 60).truncatingRemainder(dividingBy: 60))
    }
    
    /// Returns the number of hours in this TimeInterval
    @inlinable public var hours: Int {
        Int(self / 3600)
    }
}

extension TimeInterval {
    // MARK: - Computed Type Properties
    internal static var secondsPerDay: Double { return 24 * 60 * 60 }
    internal static var secondsPerHour: Double { return 60 * 60 }
    internal static var secondsPerMinute: Double { return 60 }

    // MARK: - Type Methods
    /// - Returns: The time in days using the `TimeInterval` type.
    public static func days(_ value: Double) -> TimeInterval {
        return value * secondsPerDay
    }

    /// - Returns: The time in hours using the `TimeInterval` type.
    public static func hours(_ value: Double) -> TimeInterval {
        return value * secondsPerHour
    }

    /// - Returns: The time in minutes using the `TimeInterval` type.
    public static func minutes(_ value: Double) -> TimeInterval {
        return value * secondsPerMinute
    }
}
