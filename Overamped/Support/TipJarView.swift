import SwiftUI
import StoreKit

public struct TipJarView: View {
    @StateObject var store: TipJarStore = TipJarStore()

    public var body: some View {
        Text("Tip Jar")
            .font(.title)

        Text("Overamped requires ongoing maintenance to keep up-to-date with changes to iOS, Google, and Yandex. Any extra financial support will help with this tremendously.")

        HStack(spacing: 16) {
            switch store.state {
            case .loadingProducts:
                ProgressView("Loading Tips...")
            case .idle, .purchasingProduct:
                ForEach(store.consumables) { product in
                    Button(
                        action: {
                            Task {
                                do {
                                    try await store.purchase(product)
                                } catch {
                                    print("Purchase failed", error)
                                }
                            }
                        },
                        label: {
                            TipOptionView(product: product)
                        }
                    )
                        .buttonStyle(PlainButtonStyle())
                        .disabled(!store.canMakePurchase)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}
