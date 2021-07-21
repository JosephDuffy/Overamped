import Foundation

private final class InternalClass {}

extension Bundle {
    public var appVersion: String {
        return object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    }

    public var appBuild: String {
        return object(forInfoDictionaryKey: "CFBundleVersion") as! String
    }
}
