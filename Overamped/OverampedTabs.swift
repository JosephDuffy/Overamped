import SwiftUI
import os.log

struct OverampedTabs: View {
    enum Tab: String {
        case install
        case feedback
    }

    @SceneStorage("OverampedApp.selectedTab")
    private var selectedTab: Tab = .install

    @State
    private var feedbackURL: String?

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
        }
        .onOpenURL(perform: { url in
            Logger(subsystem: "net.yetii.Overamped", category: "URL Handler")
                .log("Opened via URL \(url.absoluteString)")

            guard let deepLink = DeepLink(url: url) else { return }

            switch deepLink {
            case .feedback(let feedbackURL):
                self.feedbackURL = feedbackURL
                selectedTab = .feedback
            }
        })
    }
}
