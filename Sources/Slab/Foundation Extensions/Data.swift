import Foundation

extension Data {
    /// Append new Data from a content given by an URL
    func append(from: URL) throws {
        if let fileHandle = FileHandle(forWritingAtPath: from.path) {
            defer {
                fileHandle.closeFile()
            }
            fileHandle.seekToEndOfFile()
            fileHandle.write(self)
        } else {
            try write(to: from, options: .atomic)
        }
    }
}
