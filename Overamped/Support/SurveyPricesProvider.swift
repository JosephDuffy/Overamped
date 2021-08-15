import StoreKit

public final class SurveyPricesProvider: ObservableObject {
    public enum State {
        case loadingProducts
        case idle
        case error(Error)
    }

    @Published public private(set) var state: State = .idle
    @Published public private(set) var products: [Product] = []

    private let productIdentifiers: Set<String> = [
        "pricing.tier1",
        "pricing.tier2",
        "pricing.tier3",
    ]

    public init() {
        Task {
            await requestProducts()
        }
    }

    @MainActor
    func requestProducts() async {
        state = .loadingProducts

        do {
            products = try await Product.products(for: productIdentifiers).sorted(by: { $0.price < $1.price })
            state = .idle
        } catch {
            state = .error(error)
            print("Failed product request: \(error)")
        }
    }
}
