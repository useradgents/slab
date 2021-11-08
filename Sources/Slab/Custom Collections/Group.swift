import Foundation

/// A way to group elements by a common property like a section name
public struct Group<Element, GroupKey: Hashable>: Identifiable, RandomAccessCollection {
    public var id: UUID
    public var name: GroupKey
    public var elements: [Element]
    
    // Conformance
    public func index(after i: Int) -> Int { i+1 }
    public var indices: Range<Int> { elements.indices }
    public var startIndex: Int { elements.startIndex }
    public var endIndex: Int { elements.endIndex }
    public subscript(position: Int) -> Slice<NamedGroup<Element>> { elements[position] as! Slice<NamedGroup<Element>> }
}

public typealias Groups<Element, GroupKey: Hashable> = Array<Group<Element, GroupKey>>

extension Array {
    /// Groups element having a common property returned by the grouper.
    /// Order is maintained.
    public func grouped<GroupKey>(by grouper: (Element) -> GroupKey) -> Groups<Element, GroupKey> {
        var ret = Groups<Element, GroupKey>()
        var lastGroupElements: [Element] = []
        var lastGroupKey: GroupKey?
        for element in self {
            let thisGroupKey = grouper(element)
            if lastGroupKey == nil { lastGroupKey = thisGroupKey }
            if let lgk = lastGroupKey, lgk != thisGroupKey {
                ret.append(Group(id: UUID(), name: lgk, elements: lastGroupElements))
                lastGroupKey = thisGroupKey
                lastGroupElements = []
            }
            lastGroupElements.append(element)
        }
        if let lgk = lastGroupKey, lastGroupElements.isNotEmpty {
            ret.append(Group(id: UUID(), name: lgk, elements: lastGroupElements))
        }
        return ret
    }
}


public typealias NamedGroup<Element> = Group<Element, String>
public typealias NamedGroups<Element> = Array<Group<Element, String>>


