import Foundation
import CommonCrypto

// Easy NSLocalizedString operators
// "hello"† == NSLocalizedString("hello", comment: "?⃤ hello ?⃤")
// "hello"‡ == NSLocalizedString("hello", comment: "?⃤ hello ?⃤").localizedUppercase

// Cross † is done as alt+T on a US (QWERTY) or FR (AZERTY) keyboard
// Looks like a T, reads like Translated
// Double-cross ‡ is done as shift+alt+7 on a US (QWERTY), or alt+Q on a FR (AZERTY) keyboard.
postfix operator †
@inlinable public postfix func † (left: String) -> String {
    NSLocalizedString(left, comment: "?⃤ " + left + " ?⃤")
}

postfix operator ‡
@inlinable public postfix func ‡ (left: String) -> String {
    NSLocalizedString(left, comment: "?⃤ " + left + " ?⃤").localizedUppercase
}


extension String {
    /// Tests if the string matches a regular expression
    @inlinable public func matches(_ regex: String) -> Bool {
        range(of: regex, options: [.regularExpression]) != nil
    }
    
    /// Returns a version of the string with diacritics removed (eg: "Älphàbêt" becomes "Alphabet").
    @inlinable public var withoutDiacritics: String {
        folding(options: [.diacriticInsensitive], locale: .current)
    }
    
    /// Returns the initials of the string, by keeping the first character of each word.
    @inlinable public var initials: String {
        components(separatedBy: .whitespacesAndNewlines).compactMap { String($0.first ?? Character("")) }.joined()
    }
    
    /// Returns a sort-friendly variant of the string (all lowercase, without diacritics).
    @inlinable public var forSort: String {
        localizedLowercase.withoutDiacritics
    }
    
    /// Returns a sort-friendly variant of the string (all uppercase, without diacritics, keeping only alphanumerics)
    @inlinable public var cleanedUp: String {
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
    @inlinable public var forSort: String {
        self?.forSort ?? ""
    }
}

extension Collection where Element == String? {
    @inlinable public func compactJoined(separator: String = "\n") -> String? {
        let mapped = compactMap { $0 }
        return mapped.isEmpty ? nil : mapped.joined(separator: separator)
    }
}


extension String {
    public func levenshteinDistance(to other: String) -> Int {
        let m = self.count
        let n = other.count
        
        var D = _LevenshteinMatrix(m: m, n: n)
        
        D[0, 0] = 0
        
        for i in 1..<m { D[i, 0] = i }
        for j in 1..<n { D[0, j] = j }
        
        for i in 1..<m {
            for j in 1..<n {
                D[i, j] = D.compute(at: i, j, using: self, other)
            }
        }
        
        return D[m - 1, n - 1]
    }
}

private struct _LevenshteinMatrix {
    let m, n: Int
    
    private var _values: [Int]
    
    init(m: Int, n: Int) {
        self.m = m
        self.n = n
        
        self._values = [Int](repeating: 0, count: m * n)
    }
    
    subscript(i: Int, j: Int) -> Int {
        get {
            return _values[i + j * m]
        }
        set {
            _values[i + j * m] = newValue
        }
    }
    
    func compute(at i: Int, _ j: Int, using u: String, _ v: String) -> Int {
        let indexU = u.index(u.startIndex, offsetBy: i)
        let indexV = v.index(v.startIndex, offsetBy: j)
        
        let a = u[indexU] == v[indexV] ? self[i - 1, j - 1] : Int.max
        let b = self[i - 1, j - 1] + 1 // Replace
        let c = self[i, j - 1] + 1 // Insert
        let d = self[i - 1, j] + 1 // Delete
        
        return min(a, b, c, d)
    }
}


