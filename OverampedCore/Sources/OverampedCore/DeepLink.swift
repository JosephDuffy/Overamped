import Foundation

public enum DeepLink: Hashable {
    case debug
    case statistics
    case eventsLog
    case support
    case websiteFeedback(websiteURL: URL?, permittedOrigins: [String]?)
    case searchFeedback(searchURL: URL?, permittedOrigins: [String]?)
    case settings
    case about
    case installationInstructions
    case unlock

    public var appSchemeURL: URL {
        switch self {
        case .debug:
            return URL(string: "overamped://debug")!
        case .statistics:
            return URL(string: "overamped://statistics")!
        case .eventsLog:
            return URL(string: "overamped://events-log")!
        case .support:
            return URL(string: "overamped://support")!
        case .websiteFeedback(let url, let permittedOrigins), .searchFeedback(let url, let permittedOrigins):
            var urlComponents = URLComponents()
            urlComponents.scheme = "overamped"
            urlComponents.host = "feedback"
            urlComponents.queryItems = [
                URLQueryItem(name: "url", value: url?.absoluteString),
                URLQueryItem(name: "permittedOrigins", value: permittedOrigins?.joined(separator: ",")),
            ]
            return urlComponents.url!
        case .settings:
            return URL(string: "overamped://settings")!
        case .about:
            return URL(string: "overamped://about")!
        case .installationInstructions:
            return URL(string: "overamped://installation-instructions")!
        case .unlock:
            return URL(string: "overamped://unlock")!
        }
    }

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
        case "statistics":
            self = .statistics
        case "events-log":
            self = .eventsLog
        case "support":
            self = .support
        case "feedback":
            self.init(feedbackComponents: components)
        case "settings":
            self = .settings
        case "about":
            self = .about
        case "debug":
            self = .debug
        case "installation-instructions":
            self = .installationInstructions
        case "unlock":
            self = .unlock
        default:
            return nil
        }
    }

    private init?(websiteURL url: URL) {
        switch url.path {
        case "/feedback":
            guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else { return nil }
            self.init(feedbackComponents: components)
        case "/how-to-disable-amp-in-safari" where url.fragment == "setup-overamped":
            self = .installationInstructions
        default:
            return nil
        }
    }

    private init(feedbackComponents components: URLComponents) {
        let openURL: URL? = (components.queryItems?.first(where: { $0.name == "url" })?.value).flatMap { URL(string: $0) }

        let permittedOrigins = components
            .queryItems?
            .first(where: { $0.name == "permittedOrigins" })?
            .value
            .flatMap {
                $0.split(separator: ",").map(String.init(_:))
            }

        if openURL?.host?.contains("google.") == true, openURL?.path.hasPrefix("/search") == true || openURL?.host?.hasPrefix("news.google.") == true {
            self = .searchFeedback(searchURL: openURL, permittedOrigins: permittedOrigins)
        } else {
            self = .websiteFeedback(websiteURL: openURL, permittedOrigins: permittedOrigins)
        }
    }
}
