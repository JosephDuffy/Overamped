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
    private var showStatisticsTab: Bool = DistributionMethod.current == .debug

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

            NavigationView {
                FeedbackForm()
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
            case .feedback:
                selectedTab = .feedback
            case .statistics:
                showStatisticsTab = true
                selectedTab = .statistics
            case .support:
                selectedTab = .support
            case .settings:
                selectedTab = .settings
            }
        })
    }
}
