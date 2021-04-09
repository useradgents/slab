import Foundation

extension Bundle {
    public var buildNumber: String? {
        infoDictionary?["CFBundleVersion"] as? String
    }
    
    public var versionString: String? {
        infoDictionary?["CFBundleShortVersionString"] as? String
    }
}
