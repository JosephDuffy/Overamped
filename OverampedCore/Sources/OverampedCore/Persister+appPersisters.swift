import Foundation
import Persist

extension Persister {
    /// A `Persister` that stores whether the extension has been enabled.
    public static var extensionHasBeenEnabled: Persister<Bool> {
        Persister<Bool>(
            key: "extensionHasBeenEnabled",
            userDefaults: UserDefaults.groupSuite,
            defaultValue: false
        )
    }

    /// A `Persister` that stores the array of hostnames the user has disabled Overamped on.
    public static var ignoredHostnames: Persister<[String]> {
        Persister<[String]>(
            key: "ignoredHostnames",
            userDefaults: UserDefaults.groupSuite,
            defaultValue: []
        )
    }

    /// A `Persister` that stores the date basic statistics were reset.
    public static var basicStatisticsResetDate: Persister<Date?> {
        Persister<Date?>(
            key: "basicStatisticsResetDate",
            userDefaults: UserDefaults.groupSuite
        )
    }

    /// A `Persister` that stores a collection of the links replaced.
    public static var replacedLinks: Persister<[ReplacedLinksEvent]> {
        Persister<[ReplacedLinksEvent]>(
            key: "replacedLinkEvents",
            userDefaults: UserDefaults.groupSuite,
            transformer: ReplacedLinksTransformer(),
            defaultValue: []
        )
    }

    /// A `Persister` that stores a collection of the links redirected.
    public static var redirectedLinks: Persister<[RedirectLinkEvent]> {
        Persister<[RedirectLinkEvent]>(
            key: "redirectedLinkEvents",
            userDefaults: UserDefaults.groupSuite,
            transformer: RedirectedLinksTransformer(),
            defaultValue: []
        )
    }

    /// A `Persister` that stores the date advanced statistics were reset.
    public static var advancedStatisticsResetDate: Persister<Date?> {
        Persister<Date?>(
            key: "advancedStatisticsResetDate",
            userDefaults: UserDefaults.groupSuite
        )
    }

    /// A `Persister` that stores the "Enable Advanced Statistics" setting.
    public static var enabledAdvancedStatistics: Persister<Bool> {
        Persister<Bool>(
            key: "enabledAdvancedStatistics",
            userDefaults: UserDefaults.groupSuite,
            defaultValue: false
        )
    }

    /// A `Persister` that stores the number of replaced links.
    public static var replacedLinksCount: Persister<Int> {
        Persister<Int>(
            key: "replaceLinksCount",
            userDefaults: UserDefaults.groupSuite,
            defaultValue: 0
        )
    }

    /// A `Persister` that stores the number of redirected links.
    public static var redirectedLinksCount: Persister<Int> {
        Persister<Int>(
            key: "redirectedLinksCount",
            userDefaults: UserDefaults.groupSuite,
            defaultValue: 0
        )
    }
}
