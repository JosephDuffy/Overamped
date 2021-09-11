import Foundation

public struct Question: Decodable, Identifiable, Hashable {
    public enum Platform: String, Codable {
        case app
        case website
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case answer
        case platforms
    }

    public let id: String
    public let title: String
    public let answer: [AttributedString]
    public let platforms: [Platform]

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        id = try container.decodeIfPresent(String.self, forKey: .id) ?? title
        let answerStrings = try container.decode([String].self, forKey: .answer)
        answer = try answerStrings.map { try AttributedString(markdown: $0, options: .init()) }
        platforms = try container.decode([Platform].self, forKey: .platforms)
    }
}
