import SwiftUI

@main
struct OverampedApp: App {
    var body: some Scene {
        WindowGroup {
            OverampedTabs()
                .defaultAppStorage(UserDefaults(suiteName: "group.net.yetii.overamped")!)
        }
    }
}
