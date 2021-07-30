import SwiftUI
import os.log

struct OverampedTabs: View {
    enum Tab: String {
        case statistics
        case feedback
        case support
        case allowList
        case about
    }

    @SceneStorage("OverampedTabs.selectedTab")
    private var selectedTab: Tab = .statistics

    var body: some View {
        TabView(selection: $selectedTab) {
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
                IgnoredHostnamesView()
            }
            .tag(Tab.allowList)
            .tabItem {
                VStack {
                    Image(systemName: "checkmark")
                    Text("Allow List")
                }
            }

            NavigationView {
                AboutView()
            }
            .tag(Tab.about)
            .tabItem {
                VStack {
                    Image(systemName: "info.circle")
                    Text("About")
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
                selectedTab = .statistics
            case .support:
                selectedTab = .support
            case .settings:
                selectedTab = .allowList
            }
        })
    }
}
