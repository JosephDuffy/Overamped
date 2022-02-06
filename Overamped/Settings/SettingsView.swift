import OverampedCore
import Persist
import SwiftUI

struct SettingsView: View {
    enum NotificationsAuthorizationState {
        case unknown
        case known(UNAuthorizationStatus)
        case checking
        case requesting

        var enableSwitch: Bool {
            switch self {
            case .unknown, .checking, .requesting:
                return false
            case .known:
                return true
            }
        }
    }

    @AppStorage("enabledAdvancedStatistics")
    private var enabledAdvancedStatistics = false

    @SceneStorage("SettingsView.isShowingIgnoredHostnames")
    private var isShowingIgnoredHostnames = false

    // MARK: Basic statistics

    @PersistStorage(persister: .basicStatisticsResetDate)
    private var basicStatisticsResetDate: Date?

    @PersistStorage(persister: .replacedLinksCount)
    private var replacedLinksCount: Int

    @PersistStorage(persister: .redirectedLinksCount)
    private var redirectedLinksCount: Int

    @State
    private var hasCollectedAnyBasicStatistics = false

    // MARK: Advanced statistics

    @PersistStorage(persister: .advancedStatisticsResetDate)
    private var advancedStatisticsResetDate: Date?

    @PersistStorage(persister: .replacedLinks)
    private var replacedLinks: [ReplacedLinksEvent]

    @PersistStorage(persister: .redirectedLinks)
    private var redirectedLinks: [RedirectLinkEvent]

    @State
    private var hasCollectedAnyAdvancesStatistics = false

    // MARK: Ignored hostnames

    @PersistStorage(persister: .ignoredHostnames)
    private(set) var ignoredHostnames: [String]

    @PersistStorage(persister: .postNotificationWhenRedirecting)
    private var postNotificationWhenRedirecting: Bool

    @State
    private var notificationsAuthorizationState: NotificationsAuthorizationState = .unknown

    var body: some View {
        List {
            Section(footer: Text("Basic statistics last reset: \(basicStatisticsResetDate?.formatted() ?? "Never").")) {
                ClearBasicStatisticsView()
                    .onReceive(_replacedLinksCount.persister.publisher.combineLatest(_redirectedLinksCount.persister.publisher)) { (replacedLinksCount, redirectedLinksCount) in
                        hasCollectedAnyBasicStatistics = replacedLinksCount > 0 || redirectedLinksCount > 0
                    }
                    .disabled(!hasCollectedAnyBasicStatistics)
            }

            Section(footer: Text("Advanced statistics includes the domains and timestamps of replaced and redirect links.\nAdvanced statistics last reset: \(advancedStatisticsResetDate?.formatted() ?? "Never").")) {
                Toggle(
                    isOn: $enabledAdvancedStatistics,
                    label: { Text("Collect Advanced Statistics") }
                )
                    .onReceive(_replacedLinks.persister.publisher.combineLatest(_redirectedLinks.persister.publisher)) { (replacedLinks, redirectedLinks) in
                        hasCollectedAnyAdvancesStatistics = replacedLinks.contains(where: { !$0.domains.isEmpty }) || !redirectedLinks.isEmpty
                    }

                ClearAdvancedStatisticsView()
                    .disabled(!hasCollectedAnyAdvancesStatistics)
            }

            Section(footer: Text("Overamped will not redirect to the canonical version of websites it has been disabled on.")) {
                NavigationLink(
                    isActive: $isShowingIgnoredHostnames
                ) {
                    IgnoredHostnamesView()
                } label: {
                    HStack {
                        Text("Disabled Websites")
                        Spacer()
                        Text(ignoredHostnames.count.formatted())
                            .foregroundColor(Color(.secondaryLabel))
                    }
                }
            }

            Section(footer: Text("When enabled Overamped will post a notification when an AMP or Yandex Turbo page is redirected in Safari.")) {
                Toggle(
                    isOn: $postNotificationWhenRedirecting,
                    label: { Text("Post Notification When Redirecting") }
                )
                    .disabled(!notificationsAuthorizationState.enableSwitch)
                    .onChange(of: postNotificationWhenRedirecting) { postNotificationWhenRedirecting in
                        guard postNotificationWhenRedirecting else { return }

                        switch notificationsAuthorizationState {
                        case .unknown, .checking, .requesting:
                            assertionFailure("Invalid state")
                        case .known(let authorizationStatus):
                            switch authorizationStatus {
                            case .denied:
                                if let appSettings = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(appSettings) {
                                    UIApplication.shared.open(appSettings)
                                }
                            case .authorized:
                                break
                            case .provisional, .notDetermined, .ephemeral:
                                fallthrough
                            @unknown default:
                                self.notificationsAuthorizationState = .requesting
                                UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) { hasPermissions, error in
                                    DispatchQueue.main.async {
                                        self.notificationsAuthorizationState = .known(.authorized)
                                    }

                                    if let error = error {
                                        print("Error requesting authorization", error)
                                    }
                                }
                            }
                        }
                    }

                if
                    let settingsURL = URL(string: UIApplication.openSettingsURLString),
                    UIApplication.shared.canOpenURL(settingsURL)
                {
                    Button("Manage Settings") {
                        UIApplication.shared.open(settingsURL)
                    }
                }
            }
        }
        .onAppear(perform: {
            checkNotificationAuthorizationState()
        })
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            checkNotificationAuthorizationState()
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarTitle("Settings")
    }

    private func checkNotificationAuthorizationState() {
        switch notificationsAuthorizationState {
        case .unknown, .known:
            notificationsAuthorizationState = .checking
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                DispatchQueue.main.async {
                    withAnimation {
                        switch settings.authorizationStatus {
                        case .denied:
                            postNotificationWhenRedirecting = false
                        case .authorized, .provisional, .notDetermined, .ephemeral:
                            break
                        @unknown default:
                            break
                        }
                        notificationsAuthorizationState = .known(settings.authorizationStatus)
                    }
                }
            }
        case .checking, .requesting:
            break
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
