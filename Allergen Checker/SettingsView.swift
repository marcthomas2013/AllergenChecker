import StoreKit
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @AppStorage(ScanFeedbackSoundCatalog.positiveStorageKey) private var positiveSoundOptionID = ScanFeedbackSoundCatalog.defaultPositiveOptionID
    @AppStorage(ScanFeedbackSoundCatalog.negativeStorageKey) private var negativeSoundOptionID = ScanFeedbackSoundCatalog.defaultNegativeOptionID

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

                    Button("Reload Subscription Products") {
                        Task {
                            await subscriptionManager.loadProducts()
                            await subscriptionManager.refreshSubscriptionStatus()
                        }
                    }
                    .disabled(subscriptionManager.isLoadingProducts || subscriptionManager.isPurchasing)

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

#if DEBUG
                Section("Subscription Debug") {
                    if subscriptionManager.debugMessages.isEmpty {
                        Text("No subscription debug logs yet.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(subscriptionManager.debugMessages, id: \.self) { message in
                            Text(message)
                                .font(.caption.monospaced())
                                .textSelection(.enabled)
                        }
                    }
                }
#endif

                Section {
                    LabeledContent("Version", value: appVersion)
                    LabeledContent("Build", value: buildNumber)
                } header: {
                    Text("App")
                }

                Section {
                    Picker("Positive Sound", selection: $positiveSoundOptionID) {
                        ForEach(ScanFeedbackSoundCatalog.positiveOptions) { option in
                            Text(option.name).tag(option.id)
                        }
                    }

                    Picker("Negative Sound", selection: $negativeSoundOptionID) {
                        ForEach(ScanFeedbackSoundCatalog.negativeOptions) { option in
                            Text(option.name).tag(option.id)
                        }
                    }
                } header: {
                    Text("Scan Feedback")
                } footer: {
                    Text("Choose which sounds play when a scan finds no allergens or detects possible allergens.")
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
            .onChange(of: positiveSoundOptionID) { _, newValue in
                let option = ScanFeedbackSoundCatalog.positiveOption(for: newValue)
                ScanFeedbackPlayer.play(option)
            }
            .onChange(of: negativeSoundOptionID) { _, newValue in
                let option = ScanFeedbackSoundCatalog.negativeOption(for: newValue)
                ScanFeedbackPlayer.play(option)
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
