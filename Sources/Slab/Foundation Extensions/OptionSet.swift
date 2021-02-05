import Foundation

// Straight from https://stackoverflow.com/a/47306053 :
//
// Right now every time you create an OptionSet, just conform it to Sequence.
//
// struct WeekdaySet: OptionSet, Sequence {
//     let rawValue: Int
//
//     ...
// }
// You should now be able to iterate over it:
//
// let weekdays: WeekdaySet = [.monday, .tuesday]
// for weekday in weekdays {
//     // Do something with weekday
// }

public struct OptionSetIterator<Element: OptionSet>: IteratorProtocol where Element.RawValue: FixedWidthInteger {
    private let value: Element
    
    public init(element: Element) {
        value = element
    }
    
    private lazy var remainingBits = Element.RawValue(value.rawValue)
    private var bitMask = Element.RawValue(1)
    
    public mutating func next() -> Element? {
        while remainingBits != 0 {
            defer { bitMask = bitMask &* 2 }
            if remainingBits & bitMask != 0 {
                remainingBits = remainingBits & ~bitMask
                return Element(rawValue: bitMask)
            }
        }
        return nil
    }
}

extension OptionSet where RawValue: FixedWidthInteger {
    public func makeIterator() -> OptionSetIterator<Self> {
        OptionSetIterator(element: self)
    }
}
