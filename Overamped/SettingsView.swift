import Persist
import SwiftUI

struct SettingsView: View {
    @SceneStorage("SettingsView.isShowingIgnoredHostnames")
    private var isShowingIgnoredHostnames = false

    @PersistStorage(
        persister: Persister(
            key: "ignoredHostnames",
            userDefaults: UserDefaults(suiteName: "group.net.yetii.overamped")!,
            defaultValue: []
        )
    )
    private(set) var ignoredHostnames: [String]

    var body: some View {
        List {
            NavigationLink(destination: InstallationInstructionsView()) {
                Text("Installation Instructions")
            }

            Section(footer: Text("Overamped will not redirect the AMP version of websites that have been ignored.")) {
            NavigationLink(
                isActive: $isShowingIgnoredHostnames
            ) {
                IgnoredHostnamesView()
            } label: {
                HStack {
                    Text("Ignored Websites")
                    Spacer()
                    Text(ignoredHostnames.count.formatted())
                }
            }
            }

            Section(footer: Text("© Yetii Ltd. 2021. Overamped \(Bundle.main.appVersion) (\(Bundle.main.appBuild))")) {}
        }
        .navigationTitle("Settings")
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
