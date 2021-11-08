import Foundation

/// Codable dictionary where values are localized with language as key.
public struct Localized<T>: Codable where T: Codable {
    private var inner: [String: T]
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DynamicCodingKey.self)
        inner = [:]
        for key in container.allKeys {
            let decoded = try container.decode(T.self, forKey: DynamicCodingKey(stringValue: key.stringValue)!)
            inner[key.stringValue] = decoded
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DynamicCodingKey.self)
        for (lang, value) in inner {
            try container.encode(value, forKey: DynamicCodingKey(stringValue: lang)!)
        }
    }
    
    private struct DynamicCodingKey: CodingKey {
        var intValue: Int?
        init?(intValue: Int) {
            return nil
        }
        
        var stringValue: String
        init?(stringValue: String) {
            self.stringValue = stringValue
        }
    }
    
    var localized: T {
        for i in Locale.preferredLanguages where inner.keys.contains(i) {
            return inner[i]!
        }
        return inner[Locale.current.languageCode ?? "en"] ?? inner["en"] ?? inner.values.first!
    }
    
    func localized(fallbackLanguageCode: String = "en") -> T {
        for i in Locale.preferredLanguages where inner.keys.contains(i) {
            return inner[i]!
        }
        return inner[Locale.current.languageCode ?? fallbackLanguageCode] ?? inner[fallbackLanguageCode] ?? inner.values.first!
    }
}
