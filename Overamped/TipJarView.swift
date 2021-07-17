import SwiftUI
import StoreKit

public struct TipJarView: View {
    @StateObject var store: TipJarStore = TipJarStore()
    @AppStorage("TipJarView.showRecurringSubscriptionsToggle")
    private var showRecurringSubscriptionsToggle = false

    private var showRecurringSubscriptions: Bool {
        showRecurringSubscriptionsToggle || store.currentSubscription != nil
    }

    public var body: some View {
        Text("Tip Jar")
            .font(.title)

        Text("Overamped requires ongoing maintenance to keep up-to-date with changes to iOS and Google. Any extra financial support will help with this tremendously.")

        if store.currentSubscription == nil {
            VStack(alignment: .leading, spacing: 0) {
                Toggle(
                    isOn: $showRecurringSubscriptionsToggle.animation(),
                    label: {
                        Text("Recurring Tip")
                    }
                )
                if showRecurringSubscriptionsToggle {
                    Text("Turn off to provide a one-off tip.")
                        .font(.caption)
                } else {
                    Text("Turn on to provide a recurring monthly tip.")
                        .font(.caption)
                }
            }
        }

        HStack(spacing: 16) {
            switch store.state {
            case .loadingProducts:
                ProgressView("Loading Tips...")
            case .idle, .purchasingProduct:
                ForEach(showRecurringSubscriptions ? store.subscriptions : store.consumables) { product in
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
                            TipOptionView(
                                product: product,
                                isCurrent: product.id == store.currentSubscription?.productID,
                                isRecurring: $showRecurringSubscriptionsToggle
                            )
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

struct TipOptionView: View {
    private let product: Product
    private let isCurrent: Bool
    @Binding private var isRecurring: Bool

    var body: some View {
        VStack {
            Text(emojiForProduct(product))
            Text(product.displayName)
            Spacer()
            if isRecurring {
                Text("\(product.displayPrice)\n/month")
            } else {
                Text(product.displayPrice)
            }

            if isCurrent {
                Text("Current")
            }
        }
        .frame(maxWidth: .infinity)
        .multilineTextAlignment(.center)
        .padding()
        .background(Color.accentColor.cornerRadius(16))
    }

    init(product: Product, isCurrent: Bool, isRecurring: Binding<Bool>) {
        self.product = product
        self.isCurrent = isCurrent
        _isRecurring = isRecurring
    }

    private func emojiForProduct(_ product: Product) -> String {
        switch product.id {
        case "consumable.regulartip",
            "subscription.regulartip.monthly":
            return "☺️"
        case "consumable.largetip",
            "subscription.largetip.monthly":
            return "😃"
        case "consumable.hugetip",
            "subscription.hugetip.monthly":
            fallthrough
        default:
            return "🤩"
        }
    }
}
