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
    
    public func allocatedSizeOfDirectory(at directoryURL: URL) throws -> UInt64 {
        var enumeratorError: Error? = nil
        func errorHandler(_: URL, error: Error) -> Bool {
            enumeratorError = error
            return false
        }
        
        let enumerator = self.enumerator(at: directoryURL,
                                         includingPropertiesForKeys: Array(allocatedSizeResourceKeys),
                                         options: [],
                                         errorHandler: errorHandler)!
        
        var accumulatedSize: UInt64 = 0
        for item in enumerator {
            if enumeratorError != nil { break }
            let contentItemURL = item as! URL
            accumulatedSize += try contentItemURL.regularFileAllocatedSize()
        }
        if let error = enumeratorError { throw error }
        return accumulatedSize
    }
}

fileprivate let allocatedSizeResourceKeys: Set<URLResourceKey> = [
    .isRegularFileKey,
    .fileAllocatedSizeKey,
    .totalFileAllocatedSizeKey,
]


fileprivate extension URL {
    
    func regularFileAllocatedSize() throws -> UInt64 {
        let resourceValues = try self.resourceValues(forKeys: allocatedSizeResourceKeys)
        
        // We only look at regular files.
        guard resourceValues.isRegularFile ?? false else {
            return 0
        }
        
        // To get the file's size we first try the most comprehensive value in terms of what
        // the file may use on disk. This includes metadata, compression (on file system
        // level) and block size.
        // In case totalFileAllocatedSize is unavailable we use the fallback value (excluding
        // meta data and compression) This value should always be available.
        return UInt64(resourceValues.totalFileAllocatedSize ?? resourceValues.fileAllocatedSize ?? 0)
    }
}
