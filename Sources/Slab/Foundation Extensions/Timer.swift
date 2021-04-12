import Foundation
import CoreFoundation

extension Timer {
    @discardableResult public static func scheduledAt(_ date: Date, interval: TimeInterval = 0, repeats: Bool = false, tolerance: TimeInterval? = nil, block: @escaping (Timer)->Void) -> Timer {
        let timer = Timer(fire: date, interval: interval, repeats: repeats, block: block)
        if let t = tolerance { timer.tolerance = t }
        RunLoop.main.add(timer, forMode: .common)
        return timer
    }
    
    @discardableResult public static func scheduledAt(_ date: Date, interval: TimeInterval = 0, repeats: Bool = false, tolerance: TimeInterval? = nil, target: Any, selector: Selector, userInfo: Any? = nil) -> Timer {
        let timer = Timer(fireAt: date, interval: interval, target: target, selector: selector, userInfo: userInfo, repeats: repeats)
        if let t = tolerance { timer.tolerance = t }
        RunLoop.main.add(timer, forMode: .common)
        return timer
    }
    
    // Inspired by SwiftyTimer
    
    /// Create a timer that will call `block` once on the specified date.
    ///
    /// - Note: The timer won't fire until it's scheduled on the run loop.
    ///         User `NSTimer.on to create and schedule a timer in one step.
    /// - Note: The `new` class function is a workaround for initializers.
    public class func new(on date: Date, _ block: @escaping () -> Void) -> Timer {
        return CFRunLoopTimerCreateWithHandler(kCFAllocatorDefault, date.timeIntervalSinceReferenceDate, 0, 0, 0) { _ in block() }
    }
    
    /// Schedule this timer on the run loop
    ///
    /// By default, the timer is scheduled on the current run loop for the default mode.
    public func start(runLoop: RunLoop = .current, modes: RunLoop.Mode...) -> Timer {
        let modes = modes.isEmpty ? [.default] : modes
        for mode in modes {
            runLoop.add(self, forMode: mode)
        }
        return self
    }
    
}

