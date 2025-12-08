import Persist
import ReceiptParser
import StoreKit
import SwiftUI

struct DebugView: View {
    @PersistStorage(persister: .extensionHasBeenEnabled)
    private var extensionHasBeenEnabled: Bool

    @State
    private var receiptParserReceipt: Result<AppleReceipt, Error>?

    var body: some View {
        List {
            Section("Installation") {
                Button("Reset extension has been enabled") {
                    extensionHasBeenEnabled = false
                }
            }

            Section("Receipt") {
                HStack {
                    Text("StoreKit Receipt")

                    Spacer()

                    if #available(iOS 16, *) {
                        StoreKitReceiptVersionRow()
                    } else {
                        Text("Unavailable")
                            .italic()
                            .foregroundColor(Color(.secondaryLabel))
                    }
                }

                HStack {
                    Text("ReceiptParser")
                    Spacer()

                    if let receiptParserReceipt {
                        switch receiptParserReceipt {
                        case .success(let receipt):
                            if let originalApplicationVersion = receipt.originalApplicationVersion {
                                Text(originalApplicationVersion)
                            } else {
                                Text("Unknown")
                                    .italic()
                                    .foregroundColor(Color(.secondaryLabel))
                            }
                        case .failure(let failure):
                            Text(String(describing: failure))
                                .italic()
                                .foregroundColor(Color(.secondaryLabel))
                        }
                    } else {
                        Text("Loading…")
                            .italic()
                            .foregroundColor(Color(.secondaryLabel))
                    }
                }

                HStack {
                    Text("Path")
                    Spacer()
                    Text(Bundle.main.appStoreReceiptURL?.path ?? "nil")
                        .foregroundColor(Color(.secondaryLabel))
                }

                HStack {
                    Text("Exists")
                    Spacer()
                    Text(
                        Bundle
                            .main
                            .appStoreReceiptURL
                            .flatMap { url in
                                FileManager.default.fileExists(atPath: url.path).description
                            }
                        ?? "-"
                    )
                        .foregroundColor(Color(.secondaryLabel))
                }

                HStack {
                    Text("Distribution Method")
                    Spacer()
                    Text(String(describing: DistributionMethod.current))
                        .foregroundColor(Color(.secondaryLabel))
                }
            }
        }
        .navigationTitle("Debug")
        .task {
            do {
                let receipt = try PurchasesReceiptParser
                    .default
                    .fetchAndParseLocalReceipt()
                receiptParserReceipt = .success(receipt)
            } catch {
                receiptParserReceipt = .failure(error)
            }
        }
    }
}

@available(iOS 16.0, *)
private struct StoreKitReceiptVersionRow: View {
    @State
    private var storeKitReceipt: Result<VerificationResult<AppTransaction>, Error>?

    var body: some View {
        Group {
            if let storeKitReceipt {
                switch storeKitReceipt {
                case .success(let receipt):
                    switch receipt {
                    case .verified(let transaction):
                        Text(transaction.originalAppVersion)
                    case .unverified(_, let error):
                        Text("Unverified: ")
                            + Text(String(describing: error))
                                .italic()
                                .foregroundColor(Color(.secondaryLabel))
                    }
                case .failure(let failure):
                    Text(String(describing: failure))
                        .italic()
                        .foregroundColor(Color(.secondaryLabel))
                }
            } else {
                Text("Loading…")
                    .italic()
                    .foregroundColor(Color(.secondaryLabel))
            }
        }
        .task {
            do {
                let receipt = try await AppTransaction.shared
                storeKitReceipt = .success(receipt)
            } catch {
                storeKitReceipt = .failure(error)
            }
        }
    }
}
