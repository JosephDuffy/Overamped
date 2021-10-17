import Foundation
import Persist

struct ReplacedLinksTransformer: Transformer {
    func transformValue(_ value: [ReplacedLinksEvent]) -> [[String: Any]] {
        value.map { event in
            return [
                "id": event.id.uuidString,
                "date": event.date,
                "domains": event.domains,
            ]
        }
    }

    func untransformValue(_ value: [[String: Any]]) -> [ReplacedLinksEvent] {
        value.compactMap { dictionary in
            guard let uuidString = dictionary["id"] as? String else { return nil }
            guard let uuid = UUID(uuidString: uuidString) else { return nil }
            guard let date = dictionary["date"] as? Date else { return nil }
            guard let domains = dictionary["domains"] as? [String] else { return nil }
            return ReplacedLinksEvent(id: uuid, date: date, domains: domains)
        }
    }
}
