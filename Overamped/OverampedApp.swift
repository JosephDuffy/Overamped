import Persist
import SwiftUI
import OverampedCore
import os.log

@main
struct OverampedApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self)
    private var appDelegate

    @PersistStorage(persister: .extensionHasBeenEnabled)
    private(set) var extensionHasBeenEnabled: Bool

    @State
    private var showDebugView = false

    var body: some Scene {
        WindowGroup {
            Group {
                if extensionHasBeenEnabled {
                    OverampedTabs()
                        .defaultAppStorage(UserDefaults(suiteName: "group.net.yetii.overamped")!)
                } else {
                    InstallationInstructionsView(hasAlreadyInstalled: false)
                }
            }
            .environmentObject(FAQLoader())
            .onOpenURL(perform: { url in
                Logger(subsystem: "net.yetii.Overamped", category: "URL Handler")
                    .log("Opened via URL \(url.absoluteString)")

                guard let deepLink = DeepLink(url: url) else { return }

                switch deepLink {
                case .debug:
                    showDebugView = true
                case .unlock:
                    extensionHasBeenEnabled = true
                default:
                    break
                }
            })
            .onReceive(NotificationCenter.default.publisher(for: .motionShakeDidEndNotification)) { _ in
                switch DistributionMethod.current {
                case .debug, .testFlight:
                    showDebugView = true
                case .appStore, .unknown:
                    break
                }
            }
            .sheet(isPresented: $showDebugView) {
                NavigationView {
                    List {
                        Section("Installation") {
                            Button("Reset extension has been enabled") {
                                extensionHasBeenEnabled = false
                            }
                        }

                        Section("Receipt") {
                            HStack {
                                Text("Path")
                                Spacer()
                                Text(Bundle.main.appStoreReceiptURL?.path ?? "nil")
                                    .foregroundColor(Color(.secondaryLabel))
                            }

                            HStack {
                                Text("Exists")
                                Spacer()
                                Text(
                                    Bundle
                                        .main
                                        .appStoreReceiptURL
                                        .flatMap { url in
                                            FileManager.default.fileExists(atPath: url.path).description
                                        }
                                    ?? "-"
                                )
                                    .foregroundColor(Color(.secondaryLabel))
                            }

                            HStack {
                                Text("Distribution Method")
                                Spacer()
                                Text(String(describing: DistributionMethod.current))
                                    .foregroundColor(Color(.secondaryLabel))
                            }
                        }
                    }
                    .navigationTitle("Debug")
                }
            }
        }
    }
}

private final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        if CommandLine.arguments.contains("--uiTests") {
            do {
                try Persister<Any>.enabledAdvancedStatistics.persist(true)
                try Persister<Any>.extensionHasBeenEnabled.persist(true)
                let ignoredHostnames = [
                    "nytimes.com",
                    "9to5mac.com",
                    "vice.com",
                ]
                try Persister<Any>.ignoredHostnames.persist(ignoredHostnames)
                try Persister<Any>.replacedLinksCount.persist(387)
                try Persister<Any>.redirectedLinksCount.persist(52)

                let redirectsDomains: [String]
                let replacedLinks: [String]

                switch Locale.current.regionCode {
                case "GB":
                    redirectsDomains = [
                        "reddit.com",
                        "reddit.com",
                        "reddit.com",
                        "reddit.com",
                        "reddit.com",
                        "reddit.com",
                        "reddit.com",
                        "theguardian.com",
                        "theguardian.com",
                        "theguardian.com",
                        "theguardian.com",
                        "theguardian.com",
                        "bbc.com",
                        "bbc.com",
                    ]
                    replacedLinks = Array(repeating: "reddit.com", count: 12) + Array(repeating: "theguardian.com", count: 9) + Array(repeating: "bbc.com", count: 5) + Array(repeating: "amp.dev", count: 1)
                case "RU":
                    redirectsDomains = [
                        "reddit.com",
                        "reddit.com",
                        "reddit.com",
                        "reddit.com",
                        "reddit.com",
                        "reddit.com",
                        "reddit.com",
                        "appleinsider.ru",
                        "appleinsider.ru",
                        "appleinsider.ru",
                        "appleinsider.ru",
                        "appleinsider.ru",
                        "bbc.com",
                        "bbc.com",
                    ]
                    replacedLinks = Array(repeating: "reddit.com", count: 12) + Array(repeating: "applinsider.ru", count: 9) + Array(repeating: "bbc.com", count: 5) + Array(repeating: "amp.dev", count: 1)
                default:
                    redirectsDomains = [
                        "reddit.com",
                        "reddit.com",
                        "reddit.com",
                        "reddit.com",
                        "reddit.com",
                        "reddit.com",
                        "reddit.com",
                        "newegg.com",
                        "newegg.com",
                        "newegg.com",
                        "newegg.com",
                        "newegg.com",
                        "cnn.com",
                        "cnn.com",
                    ]
                    replacedLinks = Array(repeating: "reddit.com", count: 12) + Array(repeating: "newegg.com", count: 9) + Array(repeating: "cnn.com", count: 5) + Array(repeating: "amp.dev", count: 1)
                }

                let replacedLinksEvent = ReplacedLinksEvent(id: UUID(), date: .now, domains: replacedLinks)
                try Persister<Any>.replacedLinks.persist([replacedLinksEvent])

                let redirectsLinks: [RedirectLinkEvent] = redirectsDomains.enumerated().map { element in
                    let (offset, domain) = element
                    return RedirectLinkEvent(id: UUID(), date: .now.addingTimeInterval(TimeInterval(-offset)), domain: domain)
                }
                try Persister<Any>.redirectedLinks.persist(redirectsLinks)
            } catch {}
        }

        if let linksToMigrate = UserDefaults.groupSuite.dictionary(forKey: "replacedLinks") {
            lazy var dateFormatter = ISO8601DateFormatter()
            let migratedEvents = linksToMigrate.compactMap { element -> ReplacedLinksEvent? in
                let (dateString, domains) = element
                guard let domains = domains as? [String] else { return nil }
                guard let date = dateFormatter.date(from: dateString) else { return nil }
                return ReplacedLinksEvent(id: UUID(), date: date, domains: domains)
            }
            let persister = Persister<Any>.replacedLinks
            let existingEvents = persister.retrieveValue()
            try? persister.persist(migratedEvents + existingEvents)
            UserDefaults.groupSuite.removeObject(forKey: "replacedLinks")
        }

        if let linksToMigrate = UserDefaults.groupSuite.dictionary(forKey: "redirectedLinks") {
            lazy var dateFormatter = ISO8601DateFormatter()
            let migratedEvents = linksToMigrate.compactMap { element -> RedirectLinkEvent? in
                let (dateString, domain) = element
                guard let domain = domain as? String else { return nil }
                guard let date = dateFormatter.date(from: dateString) else { return nil }
                return RedirectLinkEvent(id: UUID(), date: date, domain: domain)
            }
            let persister = Persister<Any>.redirectedLinks
            let existingEvents = persister.retrieveValue()
            try? persister.persist(migratedEvents + existingEvents)
            UserDefaults.groupSuite.removeObject(forKey: "redirectedLinks")
        }

        return true
    }
}

extension NSNotification.Name {
    public static let motionShakeDidEndNotification = NSNotification.Name("motionShakeDidEndNotification")
}

extension UIWindow {
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        super.motionEnded(motion, with: event)

        guard motion == .motionShake else { return }
        NotificationCenter.default.post(name: .motionShakeDidEndNotification, object: event)
    }
}
