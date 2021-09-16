import OverampedCore
import SafariServices
import os.log
import Persist

final class SafariWebExtensionHandler: NSObject, NSExtensionRequestHandling {
    private lazy var logger: Logger = {
        Logger(subsystem: "net.yetii.Overamped.Extension", category: "Extension Request Handler")
    }()

    @Persisted(persister: .ignoredHostnames)
    private var ignoredHostnames: [String]

    @Persisted(persister: .extensionHasBeenEnabled)
    private var extensionHasBeenEnabled: Bool

    @Persisted(persister: .replacedLinks)
    private var replacedLinks: [ReplacedLinksEvent]

    @Persisted(persister: .redirectedLinks)
    private var redirectedLinks: [RedirectLinkEvent]

    @Persisted(persister: .enabledAdvancedStatistics)
    private var enabledAdvancedStatistics: Bool

    @Persisted(persister: .replacedLinksCount)
    private var replacedLinksCount: Int

    @Persisted(persister: .redirectedLinksCount)
    private var redirectedLinksCount: Int

    func beginRequest(with context: NSExtensionContext) {
        // Unpack the message from Safari Web Extension.
        let item = context.inputItems[0] as? NSExtensionItem
        let message = item?.userInfo?[SFExtensionMessageKey]

        extensionHasBeenEnabled = true

        let messageDictionary = message as? [String: Any]

        let response: NSExtensionItem?

        defer {
            if let response = response {
                print("Responding with", response)
                context.completeRequest(returningItems: [response])
            } else {
                context.completeRequest(returningItems: nil)
            }
        }

        guard let messageDictionary = messageDictionary else {
            logger.error("Message dictionary was not provided")
            response = nil
            return
        }

        guard let request = messageDictionary["request"] as? String else {
            logger.error("Message did not contain a request")
            response = nil
            return
        }

        logger.debug("Received request: \(request, privacy: .public)")

        switch request {
        case "ignoredHostnames":
            response = NSExtensionItem()
            response?.userInfo = [
                SFExtensionMessageKey: [
                    "ignoredHostnames": ignoredHostnames
                ]
            ]
        case "ignoreHostname":
            guard let payload = messageDictionary["payload"] as? [String: String] else {
                response = nil
                return
            }

            guard let hostname = payload["hostname"] else {
                response = nil
                return
            }

            ignoredHostnames.append(hostname)

            response = NSExtensionItem()
            response?.userInfo = [
                SFExtensionMessageKey: [
                    "ignoredHostnames": ignoredHostnames
                ]
            ]
        case "removeIgnoredHostname":
            guard let payload = messageDictionary["payload"] as? [String: String] else {
                response = nil
                return
            }

            guard let hostname = payload["hostname"] else {
                response = nil
                return
            }

            ignoredHostnames.removeAll(where: { $0 == hostname })

            response = NSExtensionItem()
            response?.userInfo = [
                SFExtensionMessageKey: [
                    "ignoredHostnames": ignoredHostnames
                ]
            ]
        case "migrateIgnoredHostnames":
            guard let payload = messageDictionary["payload"] as? [String: [String]] else {
                response = nil
                return
            }

            guard let ignoredHostnamesToMigrate = payload["ignoredHostnames"] else {
                response = nil
                return
            }

            ignoredHostnames.append(contentsOf: ignoredHostnamesToMigrate)

            response = nil
        case "logReplacedLinks":
            response = nil

            guard let payload = messageDictionary["payload"] as? [String: [String]] else {
                return
            }

            guard let replacedLinks = payload["replacedLinks"] else {
                return
            }

            replacedLinksCount += replacedLinks.count

            logger.log("Increased replaced links count by \(replacedLinks.count, privacy: .public), now \(self.replacedLinksCount, privacy: .public)")

            guard enabledAdvancedStatistics else { return }

            let event = ReplacedLinksEvent(id: UUID(), date: .now, domains: replacedLinks)
            self.replacedLinks.append(event)

            logger.log("Logged replacing links with domains \(replacedLinks)")
        case "logRedirectedLink":
            response = nil

            guard let payload = messageDictionary["payload"] as? [String: String] else {
                return
            }

            guard let redirectedHostname = payload["redirectedHostname"] else {
                return
            }

            redirectedLinksCount += 1

            logger.log("Increased redirected links count by 1, now \(self.redirectedLinksCount, privacy: .public)")

            guard enabledAdvancedStatistics else { return }

            let event = RedirectLinkEvent(id: UUID(), date: .now, domain: redirectedHostname)
            self.redirectedLinks.append(event)

            logger.log("Logged redirect to \(redirectedHostname)")
        default:
            logger.error("Unknown request \(request)")
            response = nil
        }
    }
}

struct Message<Payload: Codable>: Codable {
    let request: Request
    let payload: Payload
}

enum Request: String, Codable {
    case ignoredHostnames
    case ignoreHostname
    case removeIgnoredHostname
}
