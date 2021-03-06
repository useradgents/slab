import Foundation
import RNCryptor

public class EnvironmentManager {
    public let allEnvironments: [RuntimeEnvironment]
    public private(set) var current: RuntimeEnvironment
    
    static let keyCurrent = "Slab.EnvironmentManager.currentName"
    static let keyLast = "Slab.EnvironmentManager.lastName"
    
    public init(prefix: String = "env_", default defaultID: String = "prod", developmentMode: Bool = false, onChange: Optional<() -> ()> = nil) throws {
        UserDefaults.standard.register(defaults: [
            Self.keyCurrent: defaultID,
            Self.keyLast: defaultID
        ])
        
        let all: [RuntimeEnvironment]
        do {
            all = try FileManager.default.contentsOfDirectory(atPath: Bundle.main.bundlePath)
                .filter({ $0.hasPrefix(prefix) && $0.hasSuffix(".json.aes") })
                .compactMap({ RuntimeEnvironment(filename: $0, prefix: prefix) })
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
    
    @discardableResult
    public func activateWithoutExiting(_ env: RuntimeEnvironment, then: () -> Void) -> Bool {
        guard UserDefaults.standard.string(forKey: Self.keyCurrent) != env.id else { return false }
        UserDefaults.standard.set(env.id, forKey: EnvironmentManager.keyCurrent)
        CFPreferencesAppSynchronize(kCFPreferencesCurrentApplication)
        self.current = env
        then()
        return true
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
    
    public func int(forKey key: String) -> Int? {
        self.value(forKey: key) as? Int
    }
    
    public func int(forKey key: String, `default`: Int) -> Int {
        self.value(forKey: key) as? Int ?? `default`
    }
    
    public func double(forKey key: String) -> Double? {
        self.value(forKey: key) as? Double
    }
    
    public func double(forKey key: String, `default`: Double) -> Double {
        self.value(forKey: key) as? Double ?? `default`
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

#if canImport(UIKit)
import UIKit

extension UIColor {
    /**
     Init a UIColor from a string with a hexadecimal pattern
     - parameter hex: This parameter should have an "#" prefix or not. It must be 3 or 6 characters (wihtout the "#" prefix)
     */
    convenience init(hex string: String) {
        var hex = string.hasPrefix("#")
            ? String(string.dropFirst())
            : string
        guard hex.count == 3 || hex.count == 6 else {
            self.init(white: 0.0, alpha: 0.0)
            return
        }
        
        if hex.count == 3 {
            for (index, char) in hex.enumerated() {
                hex.insert(char, at: hex.index(hex.startIndex, offsetBy: index * 2))
            }
        }
        
        guard let intCode = Int(hex, radix: 16) else {
            self.init(white: 0.0, alpha: 0.0)
            return
        }
        
        self.init(red: CGFloat((intCode >> 16) & 0xFF) / 255.0,
                  green: CGFloat((intCode >> 8) & 0xFF) / 255.0,
                  blue:  CGFloat((intCode) & 0xFF) / 255.0,
                  alpha: 1.0)
    }
}

extension EnvironmentManager {
    public func uiColor(forKey key: String) -> UIColor {
        guard let hex = self.value(forKey: key) as? String else { return UIColor.black }
        return UIColor(hex: hex)
    }
}
#endif

/*
 #if canImport(SwiftUI)
 import SwiftUI
 extension EnvironmentManager {
 public func color(forKey key: String) -> Color {
 // idem
 }
 }
 #endif
 */

@available(iOSApplicationExtension 13.0, iOS 13.0, *)
extension EnvironmentManager: ObservableObject {}


public struct RuntimeEnvironment: Equatable, Identifiable, Hashable {
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
    
    public static func == (lhs: RuntimeEnvironment, rhs: RuntimeEnvironment) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
