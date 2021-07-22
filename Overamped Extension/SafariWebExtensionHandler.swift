import SafariServices
import os.log

final class SafariWebExtensionHandler: NSObject, NSExtensionRequestHandling {
    func beginRequest(with context: NSExtensionContext) {
        // Unpack the message from Safari Web Extension.
        let item = context.inputItems[0] as? NSExtensionItem
        let message = item?.userInfo?[SFExtensionMessageKey]

        // Update the value in UserDefaults.
        let defaults = UserDefaults(suiteName: "group.net.yetii.overamped")
        defaults?.set(true, forKey: "extensionHasBeenEnabled")

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
            response = nil
            return
        }

        switch messageDictionary["request"] as? String {
        case "ignoredHostnames":
            let ignoredHostnames = (defaults?.array(forKey: "ignoredHostnames") as? [String]) ?? []
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

            var ignoredHostnames = (defaults?.array(forKey: "ignoredHostnames") as? [String]) ?? []
            ignoredHostnames.append(hostname)
            defaults?.set(ignoredHostnames, forKey: "ignoredHostnames")

            response = nil
        case "removeIgnoredHostname":
            guard let payload = messageDictionary["payload"] as? [String: String] else {
                response = nil
                return
            }

            guard let hostname = payload["hostname"] else {
                response = nil
                return
            }

            var ignoredHostnames = (defaults?.array(forKey: "ignoredHostnames") as? [String]) ?? []
            ignoredHostnames.removeAll(where: { $0 == hostname })
            defaults?.set(ignoredHostnames, forKey: "ignoredHostnames")

            response = nil
        case "migrateIgnoredHostnames":
            guard let payload = messageDictionary["payload"] as? [String: [String]] else {
                response = nil
                return
            }

            guard let ignoredHostnamesToMigrate = payload["ignoredHostnames"] else {
                response = nil
                return
            }

            var ignoredHostnames = (defaults?.array(forKey: "ignoredHostnames") as? [String]) ?? []
            ignoredHostnames.append(contentsOf: ignoredHostnamesToMigrate)
            defaults?.set(ignoredHostnames, forKey: "ignoredHostnames")

            response = nil
        default:
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
