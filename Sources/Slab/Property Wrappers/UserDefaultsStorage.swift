import Foundation

/// Set user defaults
///  Used like
/// ```struct Defaults {
/// @UserDefaultsStorage(key: "count", defaultValue: "") static var count: String
/// }```
/// `Defaults.count`

@propertyWrapper
struct UserDefaultsStorage<T> {
    private let key: String
    private let defaultValue: T
    
    init(key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }
    
    var wrappedValue: T {
        get { UserDefaults.standard.object(forKey: key) as? T ?? defaultValue }
        set { UserDefaults.standard.set(newValue, forKey: key) }
    }
}
