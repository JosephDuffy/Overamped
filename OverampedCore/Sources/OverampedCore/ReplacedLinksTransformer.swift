import Foundation
import Persist

struct ReplacedLinksTransformer: Transformer {
    func transformValue(_ value: [Date: [String]]) -> [String: [String]] {
        lazy var dateFormatter = ISO8601DateFormatter()
        return value.reduce(into: [:]) { partialResult, element in
            let (date, hostnames) = element
            let dateString = dateFormatter.string(from: date)
            partialResult[dateString] = hostnames
        }
    }

    func untransformValue(_ value: [String: [String]]) -> [Date: [String]] {
        lazy var dateFormatter = ISO8601DateFormatter()
        return value.reduce(into: [:]) { partialResult, element in
            let (dateString, hostnames) = element
            if let date = dateFormatter.date(from: dateString) {
                partialResult[date] = hostnames
            } else {
                print("Failed to parse date from \(dateString)")
            }
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
