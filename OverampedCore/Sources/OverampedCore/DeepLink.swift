import Foundation

public enum DeepLink: Hashable {
    case feedback(searchURL: String?, websiteURL: String?)
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
            self.init(feedbackComponents: components)
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
            guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else { return nil }
            self.init(feedbackComponents: components)
        default:
            return nil
        }
    }

    private init(feedbackComponents components: URLComponents) {
        let openURL: URL? = (components.queryItems?.first(where: { $0.name == "url" })?.value).flatMap { URL(string: $0) }

        if openURL?.host?.contains("google.") == true, openURL?.path.hasPrefix("/search") == true {
            self = .feedback(searchURL: openURL?.absoluteString, websiteURL: nil)
        } else {
            self = .feedback(searchURL: nil, websiteURL: openURL?.absoluteString)
        }
    }
}
