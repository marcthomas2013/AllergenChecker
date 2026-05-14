import Combine
import Foundation
import OSLog
import StoreKit

@MainActor
final class SubscriptionManager: ObservableObject {
    @Published private(set) var products: [Product] = []
    @Published private(set) var hasActiveSubscription = false
    @Published private(set) var isLoadingProducts = false
    @Published private(set) var isPurchasing = false
    @Published var purchaseErrorMessage: String?
    @Published private(set) var debugMessages: [String] = []

    private var transactionListenerTask: Task<Void, Never>?
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "AllergenChecker", category: "Subscription")

    init() {
        addDebugMessage("SubscriptionManager init")
        transactionListenerTask = observeTransactionUpdates()
    }

    deinit {
        transactionListenerTask?.cancel()
    }

    func initialize() async {
        addDebugMessage("Initialize started")
        logEnvironmentDiagnostics()
        await loadProducts()
        await refreshSubscriptionStatus()
        addDebugMessage("Initialize completed")
    }

    func loadProducts() async {
        isLoadingProducts = true
        defer { isLoadingProducts = false }
        let requestedIDs = MonetizationConfig.Subscription.productIDs.sorted()
        addDebugMessage("Loading products for IDs: \(requestedIDs.joined(separator: ", "))")

        do {
            let storeProducts = try await Product.products(for: MonetizationConfig.Subscription.productIDs)
            products = storeProducts.sorted(by: { $0.price < $1.price })
            let loadedIDs = products.map(\.id).sorted()
            addDebugMessage("Loaded \(products.count) products from StoreKit: \(loadedIDs.joined(separator: ", "))")

            let missingIDs = Set(requestedIDs).subtracting(Set(loadedIDs))
            if !missingIDs.isEmpty {
                addDebugMessage("Missing configured product IDs: \(missingIDs.sorted().joined(separator: ", "))")
            }
            if products.isEmpty {
                addDebugMessage("No products returned. Verify the active Run scheme uses the StoreKit config.")
            }
        } catch {
            purchaseErrorMessage = error.localizedDescription
            addDebugMessage("Product load failed: \(error.localizedDescription)")
        }
    }

    func refreshSubscriptionStatus() async {
        var isEntitled = false
        addDebugMessage("Refreshing subscription status")

        for await verificationResult in Transaction.currentEntitlements {
            guard case .verified(let transaction) = verificationResult else {
                addDebugMessage("Ignored unverified entitlement")
                continue
            }

            guard MonetizationConfig.Subscription.productIDs.contains(transaction.productID) else {
                addDebugMessage("Ignoring unrelated entitlement: \(transaction.productID)")
                continue
            }

            if transaction.revocationDate != nil {
                addDebugMessage("Ignoring revoked entitlement: \(transaction.productID)")
                continue
            }

            if let expirationDate = transaction.expirationDate, expirationDate < Date() {
                addDebugMessage("Ignoring expired entitlement: \(transaction.productID)")
                continue
            }

            isEntitled = true
            addDebugMessage("Active entitlement found: \(transaction.productID)")
            break
        }

        hasActiveSubscription = isEntitled
        addDebugMessage("Subscription active = \(isEntitled)")
    }

    func purchase(_ product: Product) async {
        isPurchasing = true
        defer { isPurchasing = false }
        addDebugMessage("Purchase started for: \(product.id)")

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verificationResult):
                guard case .verified(let transaction) = verificationResult else {
                    purchaseErrorMessage = String(localized: "Purchase verification failed.")
                    addDebugMessage("Purchase verification failed for: \(product.id)")
                    return
                }

                await transaction.finish()
                addDebugMessage("Purchase finished transaction: \(transaction.productID)")
                await refreshSubscriptionStatus()
            case .userCancelled, .pending:
                addDebugMessage("Purchase cancelled or pending for: \(product.id)")
                break
            @unknown default:
                addDebugMessage("Unknown purchase result for: \(product.id)")
                break
            }
        } catch {
            purchaseErrorMessage = error.localizedDescription
            addDebugMessage("Purchase failed for \(product.id): \(error.localizedDescription)")
        }
    }

    func restorePurchases() async {
        addDebugMessage("Restore purchases started")
        do {
            try await AppStore.sync()
            await refreshSubscriptionStatus()
            addDebugMessage("Restore purchases completed")
        } catch {
            purchaseErrorMessage = error.localizedDescription
            addDebugMessage("Restore purchases failed: \(error.localizedDescription)")
        }
    }

    private func observeTransactionUpdates() -> Task<Void, Never> {
        Task {
            for await update in Transaction.updates {
                guard case .verified(let transaction) = update else {
                    await MainActor.run { self.addDebugMessage("Ignoring unverified transaction update") }
                    continue
                }

                await transaction.finish()
                await MainActor.run { self.addDebugMessage("Transaction update finished: \(transaction.productID)") }
                await refreshSubscriptionStatus()
            }
        }
    }

    private func addDebugMessage(_ message: String) {
        logger.debug("\(message, privacy: .public)")
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        debugMessages.insert("[\(timestamp)] \(message)", at: 0)
        if debugMessages.count > 40 {
            debugMessages.removeLast(debugMessages.count - 40)
        }
    }

    private func logEnvironmentDiagnostics() {
        let bundleID = Bundle.main.bundleIdentifier ?? "unknown"
        addDebugMessage("App bundle ID: \(bundleID)")
        let receiptURL = Bundle.main.appStoreReceiptURL?.path ?? "none"
        addDebugMessage("Receipt URL path: \(receiptURL)")
#if targetEnvironment(simulator)
        addDebugMessage("Runtime: Simulator")
#else
        addDebugMessage("Runtime: Physical Device")
#endif

        let configuredIDs = MonetizationConfig.Subscription.productIDs.sorted()
        let nonMatchingPrefixIDs = configuredIDs.filter { !$0.hasPrefix(bundleID + ".") }
        if !nonMatchingPrefixIDs.isEmpty {
            addDebugMessage("Configured IDs not prefixed by bundle ID: \(nonMatchingPrefixIDs.joined(separator: ", "))")
        }
    }
}
