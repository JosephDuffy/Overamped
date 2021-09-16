import StoreKit
import os.log

public final class TipJarStore: ObservableObject {
    public enum Error<T>: Swift.Error {
        case failedVerification(VerificationResult<T>.VerificationError)
    }

    public enum State: Hashable {
        case loadingProducts
        case idle
        case purchasingProduct(Product)
    }

    @Published public private(set) var state: State = .idle
    @Published public private(set) var consumables: [Product] = []
    @Published public private(set) var verifiedTransactions: Set<Transaction> = []

    public var canMakePurchase: Bool {
        switch state {
        case .idle, .loadingProducts:
            return true
        case .purchasingProduct:
            return false
        }
    }

    public var currentSubscription: Transaction? {
        verifiedTransactions.first(where: { transaction in
            guard
                transaction.revocationDate == nil,
                transaction.productType == .autoRenewable,
                let expirationDate = transaction.expirationDate
            else { return false }

            if expirationDate.compare(.now) == .orderedAscending {
                return false
            }

            return true
        })
    }

    private var taskHandle: Task<Void, Never>? = nil

    private let productIdentifiers: Set<String> = [
        "consumable.regulartip",
        "consumable.largetip",
        "consumable.hugetip",
    ]

    private let logger = Logger(subsystem: "net.yetii.Overamped", category: "Tip Jar Store")

    public init() {
        taskHandle = listenForTransactions()

        Task {
            await requestProducts()
        }

        Task.detached {
            // TODO: Validate if this and `updates` is required
            for await transaction in Transaction.all {
                do {
                    try await self.handleTransaction(transaction)
                    self.logger.error("Loaded existing transaction: \(String(describing: transaction))")
                } catch {
                    self.logger.error("Failed to verify existing transaction: \(String(describing: error))")
                }
            }
        }
    }

    deinit {
        taskHandle?.cancel()
    }

    @MainActor
    func requestProducts() async {
        state = .loadingProducts

        defer {
            state = .idle
        }

        logger.log("Loading products")

        do {
            let storeProducts = try await Product.products(for: productIdentifiers)

            var consumables: [Product] = []

            for product in storeProducts {
                switch product.type {
                case .consumable:
                    consumables.append(product)
                case .nonRenewable, .nonConsumable, .autoRenewable:
                    break
                default:
                    break
                }
            }

            self.consumables = sortByPrice(consumables)
        } catch {
            logger.error("Failed to load products: \(String(describing: error))")
        }
    }

    @MainActor
    func purchase(_ product: Product) async throws -> Transaction? {
        state = .purchasingProduct(product)

        logger.log("Attempting to purchase product \(String(describing: product))")

        defer {
            state = .idle
        }

        let result = try await product.purchase()

        switch result {
        case .success(let result):
            return try await handleTransaction(result)
        case .userCancelled:
            logger.log("User cancelled purchase of \(String(describing: product))")
            return nil
        case .pending:
            logger.log("User purchase is pending: \(String(describing: product))")
            return nil
        @unknown default:
            logger.log("Unknown result for purchase of \(String(describing: product)): \(String(describing: result))")
            return nil
        }
    }

    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached {
            for await update in Transaction.updates {
                do {
                    let transaction = try await self.handleTransaction(update)
                    print("Loaded transaction update", transaction)
                } catch {
                    print("Transaction failed verification", error)
                }
            }
        }
    }

    @discardableResult
    private func handleTransaction(_ result: VerificationResult<Transaction>) async throws -> Transaction {
        let transaction = try self.checkVerified(result)

        await self.handleVerifiedTransaction(transaction)

        await transaction.finish()

        return transaction
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error):
            throw Error.failedVerification(error)
        case .verified(let signed):
            return signed
        }
    }

    @MainActor
    private func handleVerifiedTransaction(_ transaction: Transaction) async {
        var verifiedTransactions = verifiedTransactions.filter { $0.id != transaction.id }

        defer {
            self.verifiedTransactions = verifiedTransactions
        }

        if transaction.revocationDate == nil {
            verifiedTransactions.insert(transaction)
        }
    }

    private func sortByPrice(_ products: [Product]) -> [Product] {
        products.sorted(by: { $0.price < $1.price })
    }
}
