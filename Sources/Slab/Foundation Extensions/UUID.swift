import Foundation

public extension UUID {
    /// The zero UUID
    static let zero = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
}

/// Make all UUIDs identifiable
extension UUID: Identifiable {
    public var id: String { uuidString }
}
