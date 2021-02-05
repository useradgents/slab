import Foundation

extension Collection {
    public func grouped(_ where: (Element) -> Bool) -> [[Element]] {
        guard !isEmpty else { return [] }
        var ret: [[Element]] = []
        var subret: [Element] = []
        for i in self {
            if `where`(i), !subret.isEmpty {
                ret.append(subret)
                subret = []
            }
            subret.append(i)
        }
        ret.append(subret)
        return ret
    }
    
    public var isNotEmpty: Bool {
        !isEmpty
    }
}

extension Collection where Element: Equatable {
    public func replacing(_ old: Element, with new: Element) -> [Element] {
        map { $0 == old ? new : $0 }
    }
}

extension Optional where Wrapped: Collection {
    public var isEmpty: Bool {
        map(\.isEmpty) ?? true
    }
    
    public var isNotEmpty: Bool {
        map { !$0.isEmpty } ?? false
    }
    
    public var nilIfEmpty: Self {
        isEmpty ? nil : self
    }
    
    public var count: Int {
        map(\.count) ?? 0
    }
}

@available(iOS 13, macOS 11, *)
extension Collection where Element: Identifiable {
    public subscript(id id: Element.ID) -> Element? {
        first(where: { $0.id == id })
    }
}
