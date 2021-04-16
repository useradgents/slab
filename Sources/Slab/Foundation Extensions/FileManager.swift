import Foundation

extension FileManager {
    public func fileExists(at url: URL) -> Bool {
        fileExists(atPath: url.path)
    }
    
    public func directoryExists(atPath path: String) -> Bool {
        var isDir: ObjCBool = false
        guard fileExists(atPath: path, isDirectory: &isDir) else { return false }
        return isDir.boolValue
    }
    
    public func directoryExists(at url: URL) -> Bool {
        directoryExists(atPath: url.path)
    }
    
    public var cacheDirectory: URL {
        urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    public var documentsDirectory: URL {
        urls(for: .documentDirectory, in: .userDomainMask).first!
    }
}
