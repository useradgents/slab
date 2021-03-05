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
    /// Tests if the string matches a regular expression
    public func matches(_ regex: String) -> Bool {
        range(of: regex, options: [.regularExpression]) != nil
    }
    
    /// Returns a version of the string with diacritics removed (eg: "Älphàbêt" becomes "Alphabet").
    public var withoutDiacritics: String {
        folding(options: [.diacriticInsensitive], locale: .current)
    }
    
    /// Returns the initials of the string, by keeping the first character of each word.
    public var initials: String {
        components(separatedBy: .whitespacesAndNewlines).compactMap { String($0.first ?? Character("")) }.joined()
    }
    
    /// Returns a sort-friendly variant of the string (all lowercase, without diacritics).
    public var forSort: String {
        localizedLowercase.withoutDiacritics
    }
    
    /// Returns a sort-friendly variant of the string (all uppercase, without diacritics, keeping only alphanumerics)
    public var cleanedUp: String {
        String(self
                .folding(options: .diacriticInsensitive, locale: nil)
                .uppercased()
                .unicodeScalars.filter({ CharacterSet.alphanumerics.contains($0) })
        )
    }
    
    /// Returns the SHA-1 hash of the string
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
