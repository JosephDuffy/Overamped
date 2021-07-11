import SwiftUI

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
            print("Tabs open url", url)
            guard url.scheme == "overamped" else { return }

            switch url.host {
            case "feedback":
                if
                    let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                    let feedbackURL = components.queryItems?.first(where: { $0.name == "url" })?.value
                {
                    self.feedbackURL = feedbackURL
                }

                selectedTab = .feedback
            default:
                break
            }
        })
    }
}
