import SwiftUI

struct SettingsView: View {
    @AppStorage("enabledAdvancedStatistics")
    private var enabledAdvancedStatistics = false

    var body: some View {
        List {
            Section(footer: Text("Enable advanced statistics to collect the domains and timestamps of replaced and redirect links.")) {
                Toggle(isOn: $enabledAdvancedStatistics, label: { Text("Advanced Statistics") })
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
