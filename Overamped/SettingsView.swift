import OverampedCore
import Persist
import SwiftUI

struct SettingsView: View {
    @AppStorage("enabledAdvancedStatistics")
    private var enabledAdvancedStatistics = false

    @SceneStorage("SettingsView.isShowingIgnoredHostnames")
    private var isShowingIgnoredHostnames = false

    @PersistStorage(persister: .ignoredHostnames)
    private(set) var ignoredHostnames: [String]

    var body: some View {
        List {
            Section(footer: Text("Enable advanced statistics to collect the domains and timestamps of replaced and redirect links.")) {
                Toggle(isOn: $enabledAdvancedStatistics, label: { Text("Advanced Statistics") })

            Section(footer: Text("Overamped will not redirect to the canonical version of websites it has been disabled on.")) {
                NavigationLink(
                    isActive: $isShowingIgnoredHostnames
                ) {
                    IgnoredHostnamesView()
                } label: {
                    HStack {
                        Text("Disabled Websites")
                        Spacer()
                        Text(ignoredHostnames.count.formatted())
                            .foregroundColor(Color(.placeholderText))
                    }
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
