import Foundation

extension UserDefaults {
    /// The suite shared by the app group the app and the extension are a part of.
    public static var groupSuite: Self {
        .init(suiteName: "group.net.yetii.overamped")!
    }
}
