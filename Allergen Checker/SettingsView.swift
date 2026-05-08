import StoreKit
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var subscriptionManager: SubscriptionManager

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
    }

    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "unknown"
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    subscriptionStatusView

                    if subscriptionManager.isLoadingProducts {
                        ProgressView("Loading subscription options...")
                    } else if subscriptionManager.products.isEmpty {
                        Text("Subscription plans are not available right now.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(subscriptionManager.products, id: \.id) { product in
                            Button {
                                Task {
                                    await subscriptionManager.purchase(product)
                                }
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(product.displayName)
                                        Text(product.description)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                            .lineLimit(2)
                                    }

                                    Spacer()
                                    Text(product.displayPrice)
                                }
                            }
                            .disabled(subscriptionManager.isPurchasing)
                        }
                    }

                    Button("Restore Purchases") {
                        Task {
                            await subscriptionManager.restorePurchases()
                        }
                    }
                    .disabled(subscriptionManager.isPurchasing)
                } header: {
                    Text("Ad-Free Subscription")
                } footer: {
                    Text("While subscribed, ads are removed. If the subscription is cancelled or expires, ads return automatically.")
                }

                Section {
                    LabeledContent("Version", value: appVersion)
                    LabeledContent("Build", value: buildNumber)
                } header: {
                    Text("App")
                }
            }
            .navigationTitle("Settings")
            .alert("Purchase Error", isPresented: Binding(
                get: { subscriptionManager.purchaseErrorMessage != nil },
                set: { if !$0 { subscriptionManager.purchaseErrorMessage = nil } }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(subscriptionManager.purchaseErrorMessage ?? "Could not complete purchase.")
            }
        }
    }

    @ViewBuilder
    private var subscriptionStatusView: some View {
        if subscriptionManager.hasActiveSubscription {
            Label("Active: ads are currently removed", systemImage: "checkmark.seal.fill")
                .foregroundStyle(.green)
        } else {
            Label("No active subscription: ads are shown", systemImage: "megaphone")
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(SubscriptionManager())
}
