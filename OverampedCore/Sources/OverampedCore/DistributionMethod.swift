import Foundation

public enum DistributionMethod {
    case testFlight
    case appStore
    case debug
    case unknown

    public static var current: DistributionMethod {
        #if DEBUG
        return .debug
        #else
        guard
            let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,
            FileManager.default.fileExists(atPath: appStoreReceiptURL.path)
        else {
            return .unknown
        }

        switch appStoreReceiptURL.lastPathComponent {
        case "receipt":
            return .appStore
        case "sandboxReceipt":
            return .testFlight
        default:
            return .unknown
        }
        #endif
    }
}
