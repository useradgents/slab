public struct CountedSet<Element: Hashable & CaseIterable>: ExpressibleByArrayLiteral {
    public typealias ElementWithCount = (element: Element, count: Int)
    public typealias Index = SetIndex<Element>
    
    fileprivate var backing = Set<Element>()
    fileprivate var countByElement = [Element: Int]()
    
    public mutating func insert(_ member: Element) {
        backing.insert(member)
        let count = countByElement[member] ?? 0
        countByElement[member] = count + 1
    }
    
    @discardableResult public mutating func remove(_ member: Element) -> Element? {
        guard var count = countByElement[member], count > 0 else { return nil }
        count -= 1
        countByElement[member] = Swift.max(count, 0)
        if count <= 0 { backing.remove(member) }
        return member
    }
    
    public func count(for member: Element) -> Int {
        countByElement[member] ?? 0
    }
    
    public init(arrayLiteral elements: Element...) {
        elements.forEach { insert($0) }
    }
    
    public subscript(member: Element) -> Int {
        count(for: member)
    }
    
    @discardableResult public mutating func setCount(_ count: Int, for element: Element) -> Bool {
        precondition(count >= 0, "Count has to be positive")
        guard count != countByElement[element] else { return false }
        
        if count > 0, !contains(element) {
            backing.insert(element)
        }
        countByElement[element] = count
        if count <= 0 {
            backing.remove(element)
        }
        return true
    }
    
    public func mostFrequent() -> ElementWithCount? {
        guard !backing.isEmpty else { return nil }
        return reduce((backing[backing.startIndex], 0)) { max, current in
            let currentCount = count(for: current)
            guard currentCount > max.1 else { return max }
            return (current, currentCount)
        }
    }
    
    public var totalCount: Int {
        guard !backing.isEmpty else { return 0 }
        return backing.reduce(0) { $0 + count(for: $1) }
    }
    
    public var singleElement: (Element, Int)? {
        let nonEmpty = countByElement.filter { $0.value > 0 }
        guard nonEmpty.count == 1, let (element, count) = nonEmpty.first else { return nil }
        return (element, count)
    }
    
    public static var zero: CountedSet<Element> { CountedSet<Element>.init() }
}

// MARK: - Collection

extension CountedSet: Collection {
    public var startIndex: SetIndex<Element> {
        backing.startIndex
    }
    
    public var endIndex: SetIndex<Element> {
        backing.endIndex
    }
    
    public func index(after i: SetIndex<Element>) -> SetIndex<Element> {
        backing.index(after: i)
    }
    
    public subscript(position: SetIndex<Element>) -> Element {
        backing[position]
    }
    
    public func makeIterator() -> SetIterator<Element> {
        backing.makeIterator()
    }
}

// MARK: - Hashable

extension CountedSet: Hashable {
    public func hash(into hasher: inout Hasher) {
        backing.hash(into: &hasher)
        countByElement.hash(into: &hasher)
    }
}

// MARK: - Equatable Operator

public func == <Element>(lhs: CountedSet<Element>, rhs: CountedSet<Element>) -> Bool {
    lhs.backing == rhs.backing && lhs.countByElement == rhs.countByElement
}

// MARK: - CustomStringConvertible

extension CountedSet: CustomStringConvertible {
    public var description: String {
        backing.reduce("<CountedSet>:\n") { sum, element in
            sum + "\t- \(element): \(count(for: element))\n"
        }
    }
}

extension CountedSet: Codable where Element: Codable {
    struct CodedElementAndCount<Element: Codable>: Codable {
        var element: Element
        var count: Int
    }
    
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        backing = Set()
        countByElement = [:]
        while !container.isAtEnd {
            if let ec = try? container.decode(CodedElementAndCount<Element>.self) {
                backing.insert(ec.element)
                countByElement[ec.element] = ec.count
            }
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        for element in backing {
            if let count = countByElement[element] {
                try container.encode(CodedElementAndCount(element: element, count: count))
            }
        }
    }
}
