import Foundation

public enum DistributionMethod {
    case testFlight
    case appStore
    case debug

    public static var current: DistributionMethod {
        #if DEBUG
        return .debug
        #else
        guard
            let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,
            FileManager.default.fileExists(atPath: appStoreReceiptURL.path)
        else {
            return .debug
        }

        return appStoreReceiptURL.lastPathComponent == "sandboxReceipt" ? .testFlight : .appStore
        #endif
    }
}
