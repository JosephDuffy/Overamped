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

struct RedirectedLinksTransformer: Transformer {
    func transformValue(_ value: [Date: String]) throws -> [String: String] {
        lazy var dateFormatter = ISO8601DateFormatter()
        return value.reduce(into: [:]) { partialResult, element in
            let (date, hostname) = element
            let dateString = dateFormatter.string(from: date)
            partialResult[dateString] = hostname
        }
    }

    func untransformValue(_ value: [String: String]) throws -> [Date: String] {
        lazy var dateFormatter = ISO8601DateFormatter()
        return value.reduce(into: [:]) { partialResult, element in
            let (dateString, hostname) = element
            if let date = dateFormatter.date(from: dateString) {
                partialResult[date] = hostname
            } else {
                print("Failed to parse date from \(dateString)")
            }
        }
    }
}
