import SwiftUI
import os.log

struct OverampedTabs: View {
    enum Tab: String {
        case install
        case feedback
        case statistics
        case support
        case about
    }

    @SceneStorage("OverampedApp.selectedTab")
    private var selectedTab: Tab = .install

    @State
    private var feedbackURL: String?

    @State
    private var showStatisticsTab: Bool = DistributionMethod.current == .debug

    @State
    private var showSupportTab: Bool = DistributionMethod.current == .debug

    @State
    private var showAboutTab: Bool = DistributionMethod.current == .debug

    var body: some View {
        TabView(selection: $selectedTab) {
            InstallationInstructionsView()
                .tag(Tab.install)

            NavigationView {
                FeedbackForm(openURL: $feedbackURL)
            }
            .tag(Tab.feedback)
            .tabItem {
                VStack {
                    Image(systemName: "envelope")
                    Text("Feedback")
                }
            }

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

            if showAboutTab {
                NavigationView {
                    AboutView()
                }
                .tag(Tab.about)
                .tabItem {
                    VStack {
                        Image(systemName: "info.circle.fill")
                        Text("About")
                    }
                }
            }
        }
        .onOpenURL(perform: { url in
            Logger(subsystem: "net.yetii.Overamped", category: "URL Handler")
                .log("Opened via URL \(url.absoluteString)")

            guard let deepLink = DeepLink(url: url) else { return }

            switch deepLink {
            case .feedback(let feedbackURL):
                self.feedbackURL = feedbackURL
                selectedTab = .feedback
            case .statistics:
                showStatisticsTab = true
                selectedTab = .statistics
            case .support:
                showSupportTab = true
                selectedTab = .support
            case .about:
                showAboutTab = true
                selectedTab = .about
            }
        })
    }
}
