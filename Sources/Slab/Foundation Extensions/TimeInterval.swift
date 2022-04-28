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
