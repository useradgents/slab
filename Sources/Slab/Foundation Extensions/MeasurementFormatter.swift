import Foundation
import CoreGraphics

extension MeasurementFormatter {
    @inlinable public func string(from value: Double, _ unit: Unit) -> String {
        string(from: .init(value: value, unit: unit))
    }
    
    @inlinable public func string(from value: Float, _ unit: Unit) -> String {
        string(from: .init(value: Double(value), unit: unit))
    }
    
    @inlinable public func string(from value: CGFloat, _ unit: Unit) -> String {
        string(from: .init(value: Double(value), unit: unit))
    }
}
