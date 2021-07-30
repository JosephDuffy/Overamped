import SwiftUI

struct StatisticsView: View {
    @SceneStorage("EnabledAdvancedStatistics")
    private var enabledAdvancedStatistics = false

    @AppStorage("replaceLinksCount")
    private var replaceLinksCount: Int = 0

    @AppStorage("redirectedLinksCount")
    private var redirectedLinksCount: Int = 0

    @State
    private var showLinksReplacedHelp = false

    @State
    private var showLinksRedirectedHelp = false

    @State
    private var showShareSheet = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("All statistics are collected and remain on-device; these statistics are never given to anyone else. For more information read the [privacy policy](https://overamped.app/privacy).")

                Text("Basic Statistics")
                    .font(.title)

                HStack {
                    Button(
                        action: {
                            showLinksReplacedHelp = true
                        },
                        label: {
                            Image(systemName: "questionmark.circle")
                        }
                    )
                    .alert(isPresented: $showLinksReplacedHelp) {
                        Alert(
                            title: Text("Links Replaced"),
                            message: Text("A replaced link is a link that Overamped replaced."),
                            dismissButton: .default(Text("Dismiss"))
                        )
                    }

                    Text("Links replaced: \(replaceLinksCount.formatted())")
                }

                HStack {
                    Button(
                        action: {
                            showLinksRedirectedHelp = true
                        },
                        label: {
                            Image(systemName: "questionmark.circle")
                        }
                    )
                    .alert(isPresented: $showLinksRedirectedHelp) {
                        Alert(
                            title: Text("Links Redirected"),
                            message: Text("A redirected link is a link that has been opened and – without Overamped – would've opened the AMP version."),
                            dismissButton: .default(Text("Dismiss"))
                        )
                    }

                    Text("Links redirected: \(redirectedLinksCount.formatted())")
                }

                Text("Advanced Statistics")
                    .font(.title)

                if enabledAdvancedStatistics {
                    // TODO: Show advanced statistics
                } else {
                    Text("""
                    Advanced statistics are disabled by default due to the sensitive nature of the data collected. Enable advanced statistics to collect the domains of links replaced
                    """)
                }
            }
            .padding()
        }
        .navigationTitle("Statistics")
        .toolbar {
            Button(
                action: {
                    showShareSheet = true
                },
                label: {
                    Image(systemName: "square.and.arrow.up")
                }
            )
                .background(
                    ActivityView(
                        isPresented: $showShareSheet,
                        items: {
                            [
                                String.localizedStringWithFormat(
                                    String(localized: "statistics_share_content"),
                                    replaceLinksCount
                                ),
                                URLUIActivityItemSource(
                                    url: URL(string: "https://overamped.app")!
                                ),
                            ]
                        }
                    )
                )
        }
    }
}

struct StatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        StatisticsView()
    }
}
