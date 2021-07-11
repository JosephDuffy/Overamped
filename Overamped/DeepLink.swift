import Foundation

enum DeepLink {
    case feedback(String?)

    init?(url: URL) {
        if url.scheme == "overamped" {
            self.init(appSchemeURL: url)
        } else if url.host == "overamped.app" {
            self.init(websiteURL: url)
        } else {
            return nil
        }
    }

    private init?(appSchemeURL url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else { return nil }

        switch components.path {
        case "feedback":
            if let feedbackURL = components.queryItems?.first(where: { $0.name == "url" })?.value {
                self = .feedback(feedbackURL)
            } else {
                self = .feedback(nil)
            }
        default:
            return nil
        }
    }

    private init?(websiteURL url: URL) {
        switch url.path {
        case "feedback":
            if
                let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                let feedbackURL = components.queryItems?.first(where: { $0.name == "url" })?.value
            {
                self = .feedback(feedbackURL)
            } else {
                self = .feedback(nil)
            }
        default:
            return nil
        }
    }
}
