import SafariServices
import os.log

final class SafariWebExtensionHandler: NSObject, NSExtensionRequestHandling {
    private lazy var logger: Logger = {
        Logger(subsystem: "net.yetii.Overamped.Extension", category: "Extension Request Handler")
    }()

    func beginRequest(with context: NSExtensionContext) {
        // Unpack the message from Safari Web Extension.
        let item = context.inputItems[0] as? NSExtensionItem
        let message = item?.userInfo?[SFExtensionMessageKey]

        // Update the value in UserDefaults.
        let defaults = UserDefaults(suiteName: "group.net.yetii.overamped")!
        defaults.set(true, forKey: "extensionHasBeenEnabled")

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

        logger.debug("Received request: \(request)")

        switch request {
        case "ignoredHostnames":
            let ignoredHostnames = (defaults.array(forKey: "ignoredHostnames") as? [String]) ?? []
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

            var ignoredHostnames = (defaults.array(forKey: "ignoredHostnames") as? [String]) ?? []
            ignoredHostnames.append(hostname)
            defaults.set(ignoredHostnames, forKey: "ignoredHostnames")

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

            var ignoredHostnames = (defaults.array(forKey: "ignoredHostnames") as? [String]) ?? []
            ignoredHostnames.removeAll(where: { $0 == hostname })
            defaults.set(ignoredHostnames, forKey: "ignoredHostnames")

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

            var ignoredHostnames = (defaults.array(forKey: "ignoredHostnames") as? [String]) ?? []
            ignoredHostnames.append(contentsOf: ignoredHostnamesToMigrate)
            defaults.set(ignoredHostnames, forKey: "ignoredHostnames")

            response = nil
        case "logReplacedLinks":
            response = nil

            guard let payload = messageDictionary["payload"] as? [String: [String]] else {
                return
            }

            guard let replacedLinks = payload["replacedLinks"] else {
                return
            }

            var replaceLinksCount = defaults.integer(forKey: "replaceLinksCount")
            replaceLinksCount += replacedLinks.count
            defaults.set(replaceLinksCount, forKey: "replaceLinksCount")

            logger.log("Increased replaced links count by \(replacedLinks.count), now \(replaceLinksCount)")

            let logReplacedLinks = defaults.bool(forKey: "enabledAdvancedStatistics")

            guard logReplacedLinks else { return }

            let existingReplacedLinks = defaults.array(forKey: "replacedLinks") ?? []
            guard var existingReplacedLinks = existingReplacedLinks as? [[Date: [String]]] else { return }
            existingReplacedLinks.append(
                [
                    .now: replacedLinks,
                ]
            )
            defaults.set(existingReplacedLinks, forKey: "replacedLinks")
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
