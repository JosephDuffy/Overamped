import SwiftUI
import StoreKit

public struct TipJarView: View {
    @StateObject var store: TipJarStore = TipJarStore()

    @State private var didRecentlyTip = false

    public var body: some View {
        Text("Tip Jar")
            .font(.title.weight(.semibold))

        Text("Overamped requires ongoing maintenance to keep up-to-date with changes to iOS, Google, Yahoo, Yandex, etc. Any extra financial support will help with this tremendously.")

        if didRecentlyTip {
            Text("❤️ Thank you so much for your support!")
        }

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
                                    didRecentlyTip = true
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
        .onDisappear {
            didRecentlyTip = false
        }
    }
}
