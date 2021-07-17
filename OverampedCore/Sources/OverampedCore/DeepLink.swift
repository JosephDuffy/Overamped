import Foundation

public enum DeepLink: Hashable {
    case feedback(String?)
    case statistics
    case support
    case about

    public init?(url: URL) {
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

        let path: String

        if let host = url.host {
            path = host
        } else {
            path = components.path
        }

        switch path {
        case "feedback":
            if let feedbackURL = components.queryItems?.first(where: { $0.name == "url" })?.value {
                self = .feedback(feedbackURL)
            } else {
                self = .feedback(nil)
            }
        case "statistics":
            self = .statistics
        case "support":
            self = .support
        case "about":
            self = .about
        default:
            return nil
        }
    }

    private init?(websiteURL url: URL) {
        switch url.path {
        case "/feedback":
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
