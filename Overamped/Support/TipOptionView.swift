import StoreKit
import SwiftUI

struct TipOptionView: View {
    private let emoji: String
    private let displayName: String
    private let displayPrice: String

    var body: some View {
        VStack {
            Text(emoji)
            Text(displayName)
            Spacer()

            Text(displayPrice)
        }
        .frame(maxWidth: .infinity)
        .multilineTextAlignment(.center)
        .padding()
        .background(Color.accentColor.cornerRadius(16))
    }

    init(product: Product) {
        emoji = product.emoji
        displayName = product.displayName
        displayPrice = product.displayPrice
    }

    fileprivate init(emoji: String, displayName: String, displayPrice: String) {
        self.emoji = emoji
        self.displayName = displayName
        self.displayPrice = displayPrice
    }
}

extension Product {
    fileprivate var emoji: String {
        switch id {
        case "consumable.regulartip":
            return "☺️"
        case "consumable.largetip":
            return "😃"
        case "consumable.hugetip":
            fallthrough
        default:
            return "🤩"
        }
    }
}

struct TipOptionView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
            Group {
                TipOptionView(emoji: "☺️", displayName: "Regular Tip", displayPrice: "£0.99")
                TipOptionView(emoji: "😃", displayName: "Large Tip", displayPrice: "£1.99")
                TipOptionView(emoji: "🤩", displayName: "Huge Tip", displayPrice: "£2.99")
            }
            .preferredColorScheme(colorScheme)
        }
    }
}
