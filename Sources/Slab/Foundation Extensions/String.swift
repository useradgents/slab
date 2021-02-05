import Foundation
import CommonCrypto

// Easy NSLocalizedString operator
// "hello"† == NSLocalizedString("hello", comment: "?⃤ hello ?⃤")
// Cross † is done as alt+T on a US (QWERTY) or FR (AZERTY) keyboard
// Looks like a T, reads like Translated
postfix operator †
public postfix func † (left: String) -> String {
    NSLocalizedString(left, comment: "?⃤ " + left + " ?⃤")
}

extension String {
    public var initials: String {
        components(separatedBy: .whitespacesAndNewlines).compactMap { String($0.first ?? Character("")) }.joined()
    }
    
    public var forSort: String {
        localizedLowercase.folding(options: .diacriticInsensitive, locale: .current)
    }
    
    // Remove all diacritics, uppercase, keep only alphanumerics
    public var cleanedUp: String {
        String(self
                .folding(options: .diacriticInsensitive, locale: nil)
                .uppercased()
                .unicodeScalars.filter({ CharacterSet.alphanumerics.contains($0) })
        )
    }
    
    public func sha1() -> String {
        let data = Data(self.utf8)
        var digest = [UInt8](repeating: 0, count:Int(CC_SHA1_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA1($0.baseAddress, CC_LONG(data.count), &digest)
        }
        let hexBytes = digest.map { String(format: "%02hhx", $0) }
        return hexBytes.joined()
    }
}

extension Optional where Wrapped == String {
    public var forSort: String {
        self?.forSort ?? ""
    }
}

extension Collection where Element == String {
    public var noneIsEmpty: Bool {
        for i in self where i.isEmpty { return false }
        return true
    }
}

extension Collection where Element == String? {
    public func compactJoined(separator: String = "\n") -> String? {
        let mapped = compactMap { $0 }
        return mapped.isEmpty ? nil : mapped.joined(separator: separator)
    }
}
