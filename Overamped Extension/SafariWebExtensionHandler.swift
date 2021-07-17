import SafariServices
import os.log

final class SafariWebExtensionHandler: NSObject, NSExtensionRequestHandling {
    func beginRequest(with context: NSExtensionContext) {
        // Unpack the message from Safari Web Extension.
        let item = context.inputItems[0] as? NSExtensionItem
        let message = item?.userInfo?[SFExtensionMessageKey]

        // Update the value in UserDefaults.
        let defaults = UserDefaults(suiteName: "group.net.yetii.overamped")
        let messageDictionary = message as? [String: String]
        print("messageDictionary", messageDictionary)
        if messageDictionary?["request"] == "ignoredHostnames" {
            let ignoredHostnames = defaults?.array(forKey: "ignoredHostnames") as? [String]
            let response = NSExtensionItem()
            response.userInfo = [
                SFExtensionMessageKey: [
                    "ignoredHostnames": ["9to5mac.com"]
                ]
            ]

            print("Responding with", response)

            context.completeRequest(returningItems: [response], completionHandler: nil)
        } else {
            context.completeRequest(returningItems: nil)
        }
    }
}
