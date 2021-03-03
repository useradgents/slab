#if canImport(UIKit)
import UIKit
import CoreTelephony
import Foundation

/// Convenient ways to get device information
public enum DeviceInfo {

    /// device model
    public enum Model: String {
        case iPhone = "iphone"
        case iPad = "ipad"
        case watch = "watch"
        case simulator = "x86_64"
        case notSupported = ""
    }

    /// Get model name according to enum
    public static var model: Model {
        switch UIDevice.current.userInterfaceIdiom {
            case .pad: return Model.iPad
            case .phone: return Model.iPhone
            default: return Model.notSupported
        }
    }

    /// whether device is iPad or not
    public static let isPad: Bool = UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad
    /// whether device is iPhone or not
    public static let isPhone: Bool = UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone

    /// indicate iOS version
    public static let osVersion = UIDevice.current.systemVersion

    /// Get app version
    /// - returns: String
    public static var appVersion: String? {
        Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String
    }

    /// Get build version
    /// - returns: String
    public static var buildVersion: String? {
        Bundle.main.infoDictionary!["CFBundleVersion"] as? String
    }

    /// Get IDFV: vendor identifier
    /// This variable can be automatically updated at runtime
    public static var deviceId: String {
        UIDevice.current.identifierForVendor?.uuidString ?? "n/a"
    }

    /// Display the locale as "lang-region"
    public static var locale: String {
        Locale.current.collatorIdentifier ?? "xx-xx"
    }

    /// Get info if app debuger is running or not
    /// - returns: Bool
    public static var isDebugAttached: Bool {
        var info = kinfo_proc()
        var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
        var size = MemoryLayout.stride(ofValue: info)
        let junk = sysctl(&mib, UInt32(mib.count), &info, &size, nil, 0)
        assert(junk == 0, "sysctl failed")
        return (info.kp_proc.p_flag & P_TRACED) != 0
    }

    /// Get the memory heap usage by the app in Bytes
    public static func memoryHeap() -> Int {
        var taskInfo = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        let result: kern_return_t = withUnsafeMutablePointer(to: &taskInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        var used: Int = 0
        if result == KERN_SUCCESS {
            used = Int(taskInfo.resident_size)
        }
        return used
    }

    ///whether screen is in landscape mode or not
    public static var isLandscape: Bool {
        [UIDeviceOrientation.landscapeLeft, .landscapeRight].contains(UIDevice.current.orientation)
    }

    ///get current battery level
    public static var batteryLevel: Float {
        return UIDevice.current.batteryLevel
    }

    /// is low power mode (mode launched in iOS 9)
    public static var lowPowerModeEnabled: Bool {
        return ProcessInfo.processInfo.isLowPowerModeEnabled
    }

    /// name of user network operator carrier
    public static var carrierName: String? {
        return CTTelephonyNetworkInfo().subscriberCellularProvider?.carrierName
    }

    /// which wwan (cellular) technology user is connected on
    public static var radioTechnology: String? {
        if #available(iOS 14.1, *) {
            switch CTTelephonyNetworkInfo().serviceCurrentRadioAccessTechnology?.first?.value {
                case nil: return nil
                case CTRadioAccessTechnologyHSDPA: return "3G+"
                case CTRadioAccessTechnologyGPRS: return "GPRS"
                case CTRadioAccessTechnologyEdge: return "EDGE"
                case CTRadioAccessTechnologyWCDMA: return "3G"
                case CTRadioAccessTechnologyHSUPA: return "H+"
                case CTRadioAccessTechnologyCDMA1x: return "CDMA 1x"
                case CTRadioAccessTechnologyCDMAEVDORev0: return "3G-EVDO-0"
                case CTRadioAccessTechnologyCDMAEVDORevA: return "3G-EVDO-A"
                case CTRadioAccessTechnologyCDMAEVDORevB: return "3G-EVDO-B"
                case CTRadioAccessTechnologyeHRPD: return "3G-HRPD"
                case CTRadioAccessTechnologyLTE: return "4G"
                case CTRadioAccessTechnologyNRNSA: return "5GS"
                case CTRadioAccessTechnologyNR: return "5G"
                case let type: return type?.replacingOccurrences(of: "CTRadioAccessTechnology", with: "")
            }
        }
        if #available(iOS 12.0, *) {
            switch CTTelephonyNetworkInfo().serviceCurrentRadioAccessTechnology?.first?.value {
                case nil: return nil
                case CTRadioAccessTechnologyHSDPA: return "3G+"
                case CTRadioAccessTechnologyGPRS: return "GPRS"
                case CTRadioAccessTechnologyEdge: return "EDGE"
                case CTRadioAccessTechnologyWCDMA: return "3G"
                case CTRadioAccessTechnologyHSUPA: return "H+"
                case CTRadioAccessTechnologyCDMA1x: return "CDMA 1x"
                case CTRadioAccessTechnologyCDMAEVDORev0: return "3G-EVDO-0"
                case CTRadioAccessTechnologyCDMAEVDORevA: return "3G-EVDO-A"
                case CTRadioAccessTechnologyCDMAEVDORevB: return "3G-EVDO-B"
                case CTRadioAccessTechnologyeHRPD: return "3G-HRPD"
                case CTRadioAccessTechnologyLTE: return "4G"
                case let type: return type?.replacingOccurrences(of: "CTRadioAccessTechnology", with: "")
            }
        }
        return nil
    }

    public static var deviceName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
}

#endif
