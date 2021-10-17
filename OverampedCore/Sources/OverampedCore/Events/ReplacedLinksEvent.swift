import Foundation

public struct ReplacedLinksEvent: Identifiable {
    public let id: UUID
    public let date: Date
    public var domains: [String]

    public init(id: UUID, date: Date, domains: [String]) {
        self.id = id
        self.date = date
        self.domains = domains
    }
}
