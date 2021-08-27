import Combine
import Persist
import SwiftUI
import OverampedCore
import os.log

struct FeedbackView: View {
    @State private var searchURL: URL?
    @State private var websiteURL: URL?
    @State private var domainPermissionsChecker: DomainPermissionsChecker = DomainPermissionsChecker(permittedOrigins: nil)

    var body: some View {
        ScrollView {
            Text("Submit this form to send me feedback about Overamped. I am a solo indie app developer so please allow a couple of days before your message is addressed.")

            NavigationLink(destination: FeedbackForm()) {
                VStack {
                    Image(systemName: "bolt.fill")

                    Text("Website Loaded AMP Version")

                    Text("Submit this form if a website loaded the AMP version while Overamped is active.")

                    if let searchURL = searchURL, !domainPermissionsChecker.hasAccessToURL(searchURL) {
                        Text("\(Image(systemName: "exclamationmark.triangle.fill")) Overamped does not have access to \(searchURL.host ?? searchURL.absoluteString) and may not be able to redirect AMP URLs")
                    }

                    if let websiteURL = websiteURL, !domainPermissionsChecker.hasAccessToURL(websiteURL) {
                        Text("\(Image(systemName: "exclamationmark.triangle.fill")) Overamped does not have access to \(websiteURL.host ?? websiteURL.absoluteString) and will not be able to redirect to a non-AMP version")
                    }
                }
            }
        }
        .navigationBarTitle("Submit Feedback")
        .navigationBarTitleDisplayMode(.inline)
        .onOpenURL(perform: { url in
            Logger(subsystem: "net.yetii.Overamped", category: "Feedback Form")
                .log("Opened via URL \(url.absoluteString)")

            guard let deepLink = DeepLink(url: url) else { return }

            switch deepLink {
            case .feedback(let searchURL, let websiteURL, let permittedOrigins):
                print("searchURL", searchURL)
                print("websiteURL", websiteURL)
                print("permittedOrigins", permittedOrigins)
                self.searchURL = searchURL
                self.websiteURL = websiteURL
                domainPermissionsChecker.permittedOrigins = permittedOrigins
            default:
                break
            }
        })
    }
}

struct FeedbackView_Previews: PreviewProvider {
    static var previews: some View {
        FeedbackView()
    }
}

struct DomainPermissionsChecker {
    var permittedOrigins: [String]?

    init(permittedOrigins: [String]?) {
        self.permittedOrigins = permittedOrigins
    }

    func hasAccessToURL(_ url: URL) -> Bool {
        guard let permittedOrigins = permittedOrigins else {
            return false
        }

        if permittedOrigins.contains("*://*/*") {
            return true
        }

        let accessPrefix = "*://*."
        for permittedOrigin in permittedOrigins {
            guard permittedOrigin.hasPrefix(accessPrefix) else { continue }
            guard let domain = String(permittedOrigin.dropFirst(accessPrefix.count)).split(separator: "/").first.flatMap(String.init(_:)) else { continue }
            if domain == url.host || url.host?.hasSuffix("." + domain) == true {
                return true
            }
        }

        return false
    }
}
