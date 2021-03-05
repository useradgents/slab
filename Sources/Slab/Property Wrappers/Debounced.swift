import Foundation

/// Only sets the value after the given delay has elapsed, if no other new value has been set meanwhile.
@propertyWrapper
public final class Debounced<T: Hashable> {
    public let delay: Double
    
    private var _value: T
    private var timer: Timer? = nil
    
    public var wrappedValue: T {
        get {
            return _value
        }
        set(newValue) {
            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false, block: { [weak self] timer in
                self?._value = newValue
                timer.invalidate()
            })
        }
    }
    
    public init(wrappedValue: T, delay: Double) {
        self._value = wrappedValue
        self.delay = delay
    }
}
