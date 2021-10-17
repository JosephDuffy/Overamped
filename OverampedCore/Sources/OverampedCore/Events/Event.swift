import Foundation

public enum Event: Identifiable {
    case replacedLinks(ReplacedLinksEvent)
    case redirectedLink(RedirectLinkEvent)

    public var id: UUID {
        switch self {
        case .replacedLinks(let event):
            return event.id
        case .redirectedLink(let event):
            return event.id
        }
    }

    public var date: Date {
        switch self {
        case .replacedLinks(let event):
            return event.date
        case .redirectedLink(let event):
            return event.date
        }
    }
}
