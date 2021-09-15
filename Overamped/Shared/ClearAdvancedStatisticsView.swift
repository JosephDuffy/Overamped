import Persist
import OverampedCore
import SwiftUI

struct ClearAdvancedStatisticsView: View {
    @PersistStorage(persister: .replacedLinks)
    private var replacedLinks: [Date: [String]]

    @PersistStorage(persister: .redirectedLinks)
    private var redirectedLinks: [Date: String]

    @PersistStorage(persister: .advancedStatisticsResetDate)
    private var advancedStatisticsResetDate: Date?

    @State
    private var showClearAdvancedStatistics = false

    var body: some View {
        Button("Clear Advanced Statistics") {
            showClearAdvancedStatistics = true
        }
        .alert(isPresented: $showClearAdvancedStatistics) {
            Alert(
                title: Text("Clear Advanced Statistics?"),
                message: Text("All logged advanced statistics will be deleted. This cannot be undone."),
                primaryButton: .destructive(Text("Clear"), action: {
                    replacedLinks = [:]
                    redirectedLinks = [:]
                    advancedStatisticsResetDate = .now
                }),
                secondaryButton: .cancel(Text("Cancel"))
            )
        }
    }
}
