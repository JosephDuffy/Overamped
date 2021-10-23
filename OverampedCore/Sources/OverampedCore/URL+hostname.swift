import Foundation

extension URL {
    /// The hostname component of the URL. If the URL contains
    /// a port number in the host this will be removed, otherwise
    /// the value is equal to `host`.
    public var hostname: String? {
        guard let host = host else { return nil }
        let split = host.split(separator: ":")
        return split.first.flatMap(String.init(_:))
    }
}
