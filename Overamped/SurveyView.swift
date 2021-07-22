import SwiftUI

public struct SurveyView: View {
    @StateObject
    private var store: SurveyPricesProvider = SurveyPricesProvider()

    public var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("How much would you be willing to pay for Overamped?")
                    .font(.title)

                switch store.state {
                case .loadingProducts:
                    ProgressView("Loading Options...")
                case .error(let error):
                    Text("Failed to load options: \(error.localizedDescription)")
                case .idle:
                    Button("I would not pay for Overamped") {
                        print("0")
                    }

                    ForEach(store.products) { product in
                        Button(product.displayPrice) {
                            print(product)
                        }
                    }

                    store.products.sorted(by: { $0.price < $1.price }).last.flatMap { product in
                        Button("More than \(product.displayPrice)") {
                            print("More")
                        }
                    }
                }
            }
        }
        .navigationTitle("Pricing Survey")
    }
}
