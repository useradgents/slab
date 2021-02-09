import Foundation

public struct NamedGroup<Element>: Identifiable, RandomAccessCollection {
    public var id: UUID
    public var name: String
    public var elements: [Element]
    
    // Conformance
    public func index(after i: Int) -> Int { i+1 }
    public var indices: Range<Int> { elements.indices }
    public var startIndex: Int { elements.startIndex }
    public var endIndex: Int { elements.endIndex }
    public subscript(position: Int) -> Slice<NamedGroup<Element>> { elements[position] as! Slice<NamedGroup<Element>> }
}

public typealias NamedGroups<T> = [NamedGroup<T>]

extension Array {
    public func namedGroups(by grouper: (Element) -> String) -> NamedGroups<Element> {
        var ret = [NamedGroup<Element>]()
        var lastGroupElements: [Element] = []
        var lastGroupName: String?
        for element in self {
            let thisGroupName = grouper(element)
            if lastGroupName == nil { lastGroupName = thisGroupName }
            if let lgn = lastGroupName, lgn != thisGroupName {
                ret.append(NamedGroup(id: UUID(), name: lgn, elements: lastGroupElements))
                lastGroupName = thisGroupName
                lastGroupElements = []
            }
            lastGroupElements.append(element)
        }
        if let lgn = lastGroupName, lastGroupElements.isNotEmpty {
            ret.append(NamedGroup(id: UUID(), name: lgn, elements: lastGroupElements))
        }
        return ret
    }
}
