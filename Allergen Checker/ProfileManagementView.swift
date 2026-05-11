import SwiftData
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
                    HStack {
                        TextField("Name", text: $newPersonName)
                            .textInputAutocapitalization(.words)

                        Button("Add") {
                            addPerson()
                        }
                        .disabled(trimmedNewPersonName.isEmpty)
                    }
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
