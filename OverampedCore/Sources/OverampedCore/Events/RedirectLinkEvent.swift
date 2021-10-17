import Foundation

public struct RedirectLinkEvent: Identifiable, Hashable {
    public let id: UUID
    public let date: Date
    public let domain: String

    public init(id: UUID, date: Date, domain: String) {
        self.id = id
        self.date = date
        self.domain = domain
    }
}
