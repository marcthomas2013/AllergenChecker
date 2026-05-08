import SwiftData
import StoreKit
import SwiftUI

struct AllergyProfilePicker: View {
    let profiles: [AllergyProfile]
    @Binding var selectedProfileID: String

    var body: some View {
        Picker("Person", selection: $selectedProfileID) {
            Text("Me").tag(AllergyProfileOption.defaultID)

            ForEach(profiles) { profile in
                Text(profile.name).tag(profile.id.uuidString)
            }
        }
        .pickerStyle(.menu)
    }
}

struct ProfileManagementView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var subscriptionManager: SubscriptionManager

    @AppStorage("selectedAllergyProfileID") private var selectedProfileID = AllergyProfileOption.defaultID
    @Query(sort: \AllergyProfile.name) private var profiles: [AllergyProfile]
    @Query private var allergens: [Allergen]
    @Query private var historyEntries: [ScanHistoryEntry]

    @State private var newPersonName = ""

    private var trimmedNewPersonName: String {
        newPersonName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Add Person") {
                    TextField("Name", text: $newPersonName)
                        .textInputAutocapitalization(.words)

                    Button {
                        addPerson()
                    } label: {
                        Label("Add Person", systemImage: "plus")
                    }
                    .disabled(trimmedNewPersonName.isEmpty)
                }

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
                    Text("Remove Ads Subscription")
                } footer: {
                    Text("When this subscription is active, banner and interstitial ads are removed. If the subscription ends or is cancelled, ads will return automatically.")
                }

                Section {
                    HStack {
                        Text("Me")
                        Spacer()
                        Text("Default")
                            .foregroundStyle(.secondary)
                    }

                    ForEach(profiles) { profile in
                        Text(profile.name)
                    }
                    .onDelete(perform: deletePeople)
                } header: {
                    Text("People")
                } footer: {
                    Text("Removing a person also removes their saved allergies and scan history.")
                }
            }
            .navigationTitle("Manage People")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
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

    private func addPerson() {
        let name = trimmedNewPersonName

        guard !name.isEmpty else {
            return
        }

        let profile = AllergyProfile(name: name)
        modelContext.insert(profile)
        selectedProfileID = profile.id.uuidString
        newPersonName = ""
    }

    private func deletePeople(at offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let profile = profiles[index]

                for allergen in allergens where allergen.profileID == profile.id {
                    modelContext.delete(allergen)
                }

                for entry in historyEntries where entry.profileID == profile.id {
                    modelContext.delete(entry)
                }

                if selectedProfileID == profile.id.uuidString {
                    selectedProfileID = AllergyProfileOption.defaultID
                }

                modelContext.delete(profile)
            }
        }
    }
}

#Preview {
    ProfileManagementView()
        .modelContainer(for: [AllergyProfile.self, Allergen.self, ScanHistoryEntry.self], inMemory: true)
}
