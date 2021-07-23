import Combine
import Foundation
import StoreKit
import SwiftUI

public final class SurveyAnswers: ObservableObject, Encodable {
    public enum CodingKeys: CodingKey {
        case wouldYouPayForOveramped
        case wouldYouContributeToATipJar
    }

    public enum WouldYouPayForOveramped: Hashable, CustomStringConvertible {
        case no
        case yes(Product)
        case moreThan(Product)

        public var description: String {
            switch self {
            case .no:
                return "I would not pay for Overamped"
            case .yes(let product):
                return product.displayPrice
            case .moreThan(let product):
                return "More than \(product.displayPrice)"
            }
        }
    }

    public enum WouldYouContributeToATipJar: CaseIterable, Hashable, CustomStringConvertible {
        case no
        case oneOff
        case recurring

        public var description: String {
            switch self {
            case .no:
                return "No"
            case .oneOff:
                return "Yes, a one-off payment"
            case .recurring:
                return "Yes, a recurring monthly/yearly payment"
            }
        }
    }

    @Published
    public var wouldYouPayForOveramped: WouldYouPayForOveramped?

    @Published
    public var wouldYouContributeToATipJar: WouldYouContributeToATipJar?

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(wouldYouPayForOveramped?.description, forKey: .wouldYouPayForOveramped)
        try container.encode(wouldYouContributeToATipJar?.description, forKey: .wouldYouContributeToATipJar)
    }
}
