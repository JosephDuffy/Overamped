import OverampedCore
import Persist
import SwiftUI

struct SettingsView: View {
    @AppStorage("enabledAdvancedStatistics")
    private var enabledAdvancedStatistics = false

    @SceneStorage("SettingsView.isShowingIgnoredHostnames")
    private var isShowingIgnoredHostnames = false

    @PersistStorage(persister: .basicStatisticsResetDate)
    private var basicStatisticsResetDate: Date?

    @PersistStorage(persister: .advancedStatisticsResetDate)
    private var advancedStatisticsResetDate: Date?

    @PersistStorage(persister: .replacedLinks)
    private var replacedLinks: [Date: [String]]

    @PersistStorage(persister: .redirectedLinks)
    private var redirectedLinks: [Date: String]

    @State
    private var hasCollectedAnyAdvancesStatistics = false

    @PersistStorage(persister: .ignoredHostnames)
    private(set) var ignoredHostnames: [String]

    var body: some View {
        List {
            Section(footer: Text("Basic statistics last reset: \(basicStatisticsResetDate?.formatted() ?? "Never").")) {
                ClearBasicStatisticsView()
            }

            Section(footer: Text("Advanced statistics includes the domains and timestamps of replaced and redirect links.\nAdvanced statistics last reset: \(advancedStatisticsResetDate?.formatted() ?? "Never").")) {
                Toggle(
                    isOn: $enabledAdvancedStatistics,
                    label: { Text("Collect Advanced Statistics") }
                )
                    .onReceive(_replacedLinks.persister.publisher.combineLatest(_redirectedLinks.persister.publisher)) { (replacedLinks, redirectedLinks) in
                        guard !replacedLinks.contains(where: { !$0.value.isEmpty }) else {
                            hasCollectedAnyAdvancesStatistics = true
                            return
                        }
                        guard !redirectedLinks.contains(where: { !$0.value.isEmpty }) else {
                            hasCollectedAnyAdvancesStatistics = true
                            return
                        }
                        hasCollectedAnyAdvancesStatistics = false
                    }

                if hasCollectedAnyAdvancesStatistics {
                    ClearAdvancedStatisticsView()
                }
            }

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
                            .foregroundColor(Color(.secondaryLabel))
                    }
                }
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarTitle("Settings")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
