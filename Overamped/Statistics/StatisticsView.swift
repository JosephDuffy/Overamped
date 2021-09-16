import SwiftUI
import Persist
import Containers

struct StatisticsView: View {
    @AppStorage("enabledAdvancedStatistics")
    private var enabledAdvancedStatistics = false

    @PersistStorage(persister: .replacedLinksCount)
    private var replacedLinksCount: Int

    @PersistStorage(persister: .redirectedLinksCount)
    private var redirectedLinksCount: Int

    @State
    private var showLinksReplacedHelp = false

    @State
    private var showLinksRedirectedHelp = false

    @State
    private var showShareSheet = false

    @State
    private var displayedURL: DisplayedURL?

    private struct DisplayedURL: Identifiable {
        var id: String {
            url.absoluteString
        }

        let url: URL
    }

    var body: some View {
        ScrollView {
            HStack {
                VStack(alignment: .leading, spacing: 16) {
                    Text("All statistics are collected and remain on-device; these statistics are never given to anyone else. For more information read the [privacy policy](https://overamped.app/privacy).")

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Basic Statistics")
                            .font(.title.weight(.semibold))

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
                                    title: Text("AMP Search Results Found"),
                                    message: Text("A count of the Google search results that without Overamped would open with AMP."),
                                    dismissButton: .default(Text("Dismiss"))
                                )
                            }

                            Text("AMP search results found: \(replacedLinksCount.formatted())")
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
                                    message: Text("A count of all the AMP and Yandex Turbo links that have been redirected to their canonical version."),
                                    dismissButton: .default(Text("Dismiss"))
                                )
                            }

                            Text("Links redirected: \(redirectedLinksCount.formatted())")
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Advanced Statistics")
                            .font(.title.weight(.semibold))

                        if !enabledAdvancedStatistics {
                            Button("Enable Advanced Statistics") {
                                enabledAdvancedStatistics = true
                            }
                                .buttonStyle(BorderedButtonStyle())

                            Text("Enable advanced statistics to collect the domains and timestamps of replaced and redirect links.")
                                .font(.footnote)
                        }

                        AdvancedStatisticsView(showEmptyMessage: $enabledAdvancedStatistics)
                    }
                }
                .padding()
                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
        .background(Color(.systemGroupedBackground))
        .environment(\.openURL, OpenURLAction { url in
            displayedURL = DisplayedURL(url: url)
            return .handled
        })
        .sheet(item: $displayedURL, onDismiss: { displayedURL = nil }) { displayedURL in
            SafariView(url: displayedURL.url) {
                self.displayedURL = nil
            }
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
                                    replacedLinksCount
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
