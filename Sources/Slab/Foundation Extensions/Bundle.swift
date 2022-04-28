import Foundation

extension Bundle {
    @inlinable public var buildNumber: String? {
        infoDictionary?["CFBundleVersion"] as? String
    }
    
    @inlinable public var versionString: String? {
        infoDictionary?["CFBundleShortVersionString"] as? String
    }
}
