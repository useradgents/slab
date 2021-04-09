import Foundation
import RNCryptor

public struct EnvironmentManager {
    public let allEnvironments: [Environment]
    public let current: Environment
    
    static let keyCurrent = "Slab.EnvironmentManager.currentName"
    static let keyLast = "Slab.EnvironmentManager.lastName"
    
    public init(prefix: String = "env_", default defaultID: String = "prod", developmentMode: Bool = false, onChange: Optional<() -> ()> = nil) throws {
        UserDefaults.standard.register(defaults: [
            Self.keyCurrent: defaultID,
            Self.keyLast: defaultID
        ])
        
        let all: [Environment]
        do {
            all = try FileManager.default.contentsOfDirectory(atPath: Bundle.main.bundlePath)
                .filter({ $0.hasPrefix(prefix) && $0.hasSuffix(".json.aes") })
                .compactMap({ Environment(filename: $0, prefix: prefix) })
                .sorted(by: \.order)
        }
        catch {
            throw EnvError.noEnvironment
        }
        
        guard all.isNotEmpty else { throw EnvError.noEnvironment }
        self.allEnvironments = all
        
        let currentName: String
        if developmentMode {
            currentName = UserDefaults.standard.string(forKey: Self.keyCurrent) ?? defaultID
        }
        else {
            currentName = defaultID
        }
        
        guard let current = all.first(where: { $0.id == currentName }) else {
            throw EnvError.noEnvironment
        }
        self.current = current
        
        if UserDefaults.standard.string(forKey: Self.keyLast) != currentName {
            onChange?()
            UserDefaults.standard.set(currentName, forKey: Self.keyLast)
        }
        
        LOG("Running on environment: \(current.emoji) \(current.displayName)", .start)
    }
    
    public enum EnvError: Error {
        case noEnvironment
    }
    
    // MARK: Public accessors
    public func string(forKey key: String) -> String? {
        self.value(forKey: key) as? String
    }
    
    public func url(forKey key: String) -> URL? {
        self.string(forKey: key).flatMap({ URL(string: $0) })
    }
    
    public func bool(forKey key: String) -> Bool? {
        self.value(forKey: key) as? Bool
    }
    
    public func bool(forKey key: String, `default`: Bool) -> Bool {
        self.value(forKey: key) as? Bool ?? `default`
    }
    
    public func value(forKey key: String) -> Any? {
        var ptr: Any = current.data
        for piece in key.components(separatedBy: ".") {
            guard let newPtr = (ptr as! [String:Any])[piece] else {
                return nil
            }
            ptr = newPtr
        }
        return ptr
    }
}

public struct Environment: Equatable, Identifiable {
    public let id: String
    public let displayName: String
    public let emoji: String
    public let order: Int
    public let data: [String: Any]
    
    init?(filename: String, prefix: String) {
        guard
            let url = Bundle.main.url(forResource: filename, withExtension: nil),
            let rawData = try? Data(contentsOf: url),
            case let passKey = String(describing: NSURLConnection.self) + "^%$" + String(describing: NSDateComponents.self),
            let decryptedData = try? RNCryptor.decrypt(data: rawData, withPassword: passKey),
            let decoded = try? JSONSerialization.jsonObject(with: decryptedData, options: []),
            let json = decoded as? [String: Any],
            let info = json["environment"] as? [String: Any],
            let name = info["name"] as? String,
            let emoji = info["emoji"] as? String
        else {
            return nil
        }
        
        var id = filename
        id.removeFirst(prefix.count)
        id.removeLast(".json.aes".count)
        
        self.id = id
        self.data = json
        self.displayName = name
        self.emoji = emoji
        self.order = info["order"] as? Int ?? 999
    }
    
    public func activate() {
        UserDefaults.standard.set(id, forKey: EnvironmentManager.keyCurrent)
        CFPreferencesAppSynchronize(kCFPreferencesCurrentApplication)
        exit(0)
    }
    
    public static func == (lhs: Environment, rhs: Environment) -> Bool {
        lhs.id == rhs.id
    }
}
