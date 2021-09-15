import Persist
import OverampedCore
import SwiftUI

struct ClearBasicStatisticsView: View {
    @PersistStorage(persister: .replacedLinksCount)
    private var replacedLinksCount: Int

    @PersistStorage(persister: .redirectedLinksCount)
    private var redirectedLinksCount: Int

    @PersistStorage(persister: .basicStatisticsResetDate)
    private var basicStatisticsResetDate: Date?

    @State
    private var showClearBasicStatistics = false

    var body: some View {
        Button("Clear Basic Statistics") {
            showClearBasicStatistics = true
        }
        .alert(isPresented: $showClearBasicStatistics) {
            Alert(
                title: Text("Clear Basic Statistics?"),
                message: Text("All basic statistics will be deleted. This cannot be undone."),
                primaryButton: .destructive(Text("Clear"), action: {
                    replacedLinksCount = 0
                    redirectedLinksCount = 0
                    basicStatisticsResetDate = .now
                }),
                secondaryButton: .cancel(Text("Cancel"))
            )
        }
    }
}
