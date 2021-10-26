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
        let data = Data(utf8)
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA1($0.baseAddress, CC_LONG(data.count), &digest)
        }
        return digest.map { String(format: "%02hhx", $0) }.joined()
    }
    
    /// Returns the SHA-256 hash of the string
    public func sha256() -> String {
        let data = Data(utf8)
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &digest)
        }
        return digest.map { String(format: "%02hhx", $0) }.joined()
    }
    
    /// Returns the HMAC SHA-256 of the string with a given key
    public func hmacSha256(key: String) -> Data? {
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA256), key, key.count, self, self.count, &digest)
        return Data(digest)
    }

    /// Append new Data from an UTF8 content given by an URL + add a line break
    func appendNewLine(from: URL) throws {
        try appending("\n").append(from: from)
    }

    /// Append new Data from an UTF8 content given by an URL
    func append(from: URL) throws {
        let data = self.data(using: String.Encoding.utf8)!
        try data.append(from: from)
    }
    
    public subscript (bounds: CountableClosedRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start...end])
    }

    public subscript (bounds: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start..<end])
    }
}

extension Optional where Wrapped == String {
    public var forSort: String {
        self?.forSort ?? ""
    }
}

extension Collection where Element == String? {
    public func compactJoined(separator: String = "\n") -> String? {
        let mapped = compactMap { $0 }
        return mapped.isEmpty ? nil : mapped.joined(separator: separator)
    }
}
