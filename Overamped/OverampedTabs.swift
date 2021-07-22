import SwiftUI
import os.log

struct OverampedTabs: View {
    enum Tab: String {
        case statistics
        case feedback
        case support
        case settings
    }

    @SceneStorage("OverampedTabs.selectedTab")
    private var selectedTab: Tab = .statistics

    @State
    private var searchURL: String = ""

    @State
    private var websiteURL: String = ""

    @State
    private var showStatisticsTab: Bool = DistributionMethod.current == .debug

    @State
    private var showSupportTab: Bool = DistributionMethod.current == .debug

    @State
    private var showAboutTab: Bool = DistributionMethod.current == .debug

    var body: some View {
        TabView(selection: $selectedTab) {
            if showStatisticsTab {
                NavigationView {
                    StatisticsView()
                }
                .tag(Tab.statistics)
                .tabItem {
                    VStack {
                        Image(systemName: "chart.xyaxis.line")
                        Text("Statistics")
                    }
                }
            }

            if showSupportTab {
                NavigationView {
                    SupportView()
                }
                .tag(Tab.support)
                .tabItem {
                    VStack {
                        Image(systemName: "heart.fill")
                        Text("Support")
                    }
                }
            }

            NavigationView {
                FeedbackForm(
                    searchURL: $searchURL,
                    websiteURL: $websiteURL
                )
            }
            .tag(Tab.feedback)
            .tabItem {
                VStack {
                    Image(systemName: "envelope")
                    Text("Feedback")
                }
            }

            NavigationView {
                SettingsView()
            }
            .tag(Tab.settings)
            .tabItem {
                VStack {
                    Image(systemName: "gear")
                    Text("Settings")
                }
            }
        }
        .onOpenURL(perform: { url in
            Logger(subsystem: "net.yetii.Overamped", category: "URL Handler")
                .log("Opened via URL \(url.absoluteString)")

            guard let deepLink = DeepLink(url: url) else { return }

            switch deepLink {
            case .feedback(let searchURL, let websiteURL):
                self.searchURL = searchURL ?? ""
                self.websiteURL = websiteURL ?? ""
                selectedTab = .feedback
            case .statistics:
                showStatisticsTab = true
                selectedTab = .statistics
            case .support:
                showSupportTab = true
                selectedTab = .support
            case .settings:
                selectedTab = .settings
            }
        })
    }
}
