import SwiftUI
import os.log

struct OverampedTabs: View {
    enum Tab: String, CaseIterable {
        case statistics
        case support
        case feedback
        case settings
        case about

        var title: LocalizedStringKey {
            switch self {
            case .statistics:
                return "Statistics"
            case .support:
                return "Support"
            case .feedback:
                return "Feedback"
            case .settings:
                return "Settings"
            case .about:
                return "About"
            }
        }

        var icon: Image {
            switch self {
            case .statistics:
                return Image(systemName: "chart.xyaxis.line")
            case .support:
                return Image(systemName: "heart.fill")
            case .feedback:
                return Image(systemName: "envelope")
            case .settings:
                return Image(systemName: "gear")
            case .about:
                return Image(systemName: "info.circle")
            }
        }

        @ViewBuilder
        var destination: some View {
            switch self {
            case .statistics:
                StatisticsView()
            case .support:
                SupportView()
            case .feedback:
                FeedbackForm()
            case .settings:
                SettingsView()
            case .about:
                AboutView()
            }
        }
    }

    @SceneStorage("OverampedTabs.selectedTab")
    private var selectedTab: Tab = .support

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        if horizontalSizeClass == .compact {
            tabsView
        } else {
            sidebarView
        }

        EmptyView()
            .onOpenURL(perform: { url in
                guard let deepLink = DeepLink(url: url) else { return }

                switch deepLink {
                case .statistics:
                    selectedTab = .statistics
                case .support:
                    selectedTab = .support
                case .feedback:
                    selectedTab = .feedback
                case .settings:
                    selectedTab = .settings
                case .about:
                    selectedTab = .about
                case .debug, .unlock:
                    break
                }
            })
    }

    private var tabsView: some View {
        TabView(selection: $selectedTab) {
            ForEach(OverampedTabs.Tab.allCases, id: \.self) { tab in
                NavigationView {
                    tab.destination
                }
                .tag(tab)
                .tabItem {
                    VStack {
                        tab.icon
                        Text(tab.title)
                    }
                }
            }
        }
    }

    private var sidebarView: some View {
        NavigationView {
            Sidebar(selectedTab: $selectedTab)
            selectedTab.destination
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct Sidebar: View {
    @Binding var selectedTab: OverampedTabs.Tab?

    @ViewBuilder
    var body: some View {
        List {
            ForEach(OverampedTabs.Tab.allCases, id: \.self) { tab in
                Button {
                    selectedTab = tab
                } label: {
                    Label {
                        Text(tab.title)
                    } icon: {
                        tab.icon
                    }
                }
                .listRowBackground(
                    RoundedRectangle(cornerRadius: 12)
                        .foregroundColor(tab == selectedTab ? Color(.systemFill) : .clear)
                )
                .tag(tab)
            }
        }
        .navigationTitle("Overamped")
        .listStyle(SidebarListStyle())
    }

    init(selectedTab: Binding<OverampedTabs.Tab>) {
        _selectedTab = Binding(get: { selectedTab.wrappedValue }, set: { selectedTab.wrappedValue = $0 ?? .statistics })
    }
}
