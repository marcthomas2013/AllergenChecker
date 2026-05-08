import Combine
import Foundation
import StoreKit

@MainActor
final class SubscriptionManager: ObservableObject {
    @Published private(set) var products: [Product] = []
    @Published private(set) var hasActiveSubscription = false
    @Published private(set) var isLoadingProducts = false
    @Published private(set) var isPurchasing = false
    @Published var purchaseErrorMessage: String?

    private var transactionListenerTask: Task<Void, Never>?

    init() {
        transactionListenerTask = observeTransactionUpdates()
    }

    deinit {
        transactionListenerTask?.cancel()
    }

    func initialize() async {
        await loadProducts()
        await refreshSubscriptionStatus()
    }

    func loadProducts() async {
        isLoadingProducts = true
        defer { isLoadingProducts = false }

        do {
            let storeProducts = try await Product.products(for: MonetizationConfig.Subscription.productIDs)
            products = storeProducts.sorted(by: { $0.price < $1.price })
        } catch {
            purchaseErrorMessage = error.localizedDescription
        }
    }

    func refreshSubscriptionStatus() async {
        var isEntitled = false

        for await verificationResult in Transaction.currentEntitlements {
            guard case .verified(let transaction) = verificationResult else {
                continue
            }

            guard MonetizationConfig.Subscription.productIDs.contains(transaction.productID) else {
                continue
            }

            if transaction.revocationDate != nil {
                continue
            }

            if let expirationDate = transaction.expirationDate, expirationDate < Date() {
                continue
            }

            isEntitled = true
            break
        }

        hasActiveSubscription = isEntitled
    }

    func purchase(_ product: Product) async {
        isPurchasing = true
        defer { isPurchasing = false }

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verificationResult):
                guard case .verified(let transaction) = verificationResult else {
                    purchaseErrorMessage = String(localized: "Purchase verification failed.")
                    return
                }

                await transaction.finish()
                await refreshSubscriptionStatus()
            case .userCancelled, .pending:
                break
            @unknown default:
                break
            }
        } catch {
            purchaseErrorMessage = error.localizedDescription
        }
    }

    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await refreshSubscriptionStatus()
        } catch {
            purchaseErrorMessage = error.localizedDescription
        }
    }

    private func observeTransactionUpdates() -> Task<Void, Never> {
        Task {
            for await update in Transaction.updates {
                guard case .verified(let transaction) = update else {
                    continue
                }

                await transaction.finish()
                await refreshSubscriptionStatus()
            }
        }
    }
}
