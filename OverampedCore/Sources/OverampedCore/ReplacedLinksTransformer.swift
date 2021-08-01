import Foundation
import Persist

struct ReplacedLinksTransformer: Transformer {
    func transformValue(_ value: [Date: [String]]) throws -> [String: [String]] {
        value.reduce(into: [:]) { partialResult, element in
            let (date, hostnames) = element
            partialResult[date.ISO8601Format()] = hostnames
        }
    }

    func untransformValue(_ value: [String: [String]]) throws -> [Date: [String]] {
        value.reduce(into: [:]) { partialResult, element in
            let (dateString, hostnames) = element
            do {
                let date = try Date(dateString, strategy: .iso8601)
                partialResult[date] = hostnames
            } catch {
                print("Failed to parse date from \(dateString)")
            }
        }
    }
}

struct RedirectedLinksTransformer: Transformer {
    func transformValue(_ value: [Date: String]) throws -> [String: String] {
        value.reduce(into: [:]) { partialResult, element in
            let (date, hostname) = element
            partialResult[date.ISO8601Format()] = hostname
        }
    }

    func untransformValue(_ value: [String: String]) throws -> [Date: String] {
        value.reduce(into: [:]) { partialResult, element in
            let (dateString, hostname) = element
            do {
                let date = try Date(dateString, strategy: .iso8601)
                partialResult[date] = hostname
            } catch {
                print("Failed to parse date from \(dateString)")
            }
        }
    }
}
