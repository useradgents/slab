import Foundation
import CoreGraphics

extension MeasurementFormatter {
    public func string(from value: Double, _ unit: Unit) -> String {
        string(from: .init(value: value, unit: unit))
    }
    
    public func string(from value: Float, _ unit: Unit) -> String {
        string(from: .init(value: Double(value), unit: unit))
    }
    
    public func string(from value: CGFloat, _ unit: Unit) -> String {
        string(from: .init(value: Double(value), unit: unit))
    }
}
