import Foundation
import Persist

struct RedirectedLinksTransformer: Transformer {
    func transformValue(_ value: [RedirectLinkEvent]) throws -> [[String: Any]] {
        value.map { event in
            return [
                "id": event.id.uuidString,
                "date": event.date,
                "domain": event.domain,
            ]
        }
    }

    func untransformValue(_ value: [[String: Any]]) throws -> [RedirectLinkEvent] {
        value.compactMap { dictionary in
            guard let uuidString = dictionary["id"] as? String else { return nil }
            guard let uuid = UUID(uuidString: uuidString) else { return nil }
            guard let date = dictionary["date"] as? Date else { return nil }
            guard let domain = dictionary["domain"] as? String else { return nil }
            return RedirectLinkEvent(id: uuid, date: date, domain: domain)
        }
    }
}
