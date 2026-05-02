import SwiftData
import SwiftUI

struct AllergenListView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("selectedAllergyProfileID") private var selectedProfileID = AllergyProfileOption.defaultID

    @Query(sort: \AllergyProfile.name) private var profiles: [AllergyProfile]
    @Query(sort: \Allergen.name) private var allergens: [Allergen]

    @State private var searchText = ""
    @State private var isAddingAllergen = false
    @State private var isManagingPeople = false

    private var selectedProfile: AllergyProfileOption {
        AllergyProfileSelection.selectedOption(storedID: selectedProfileID, profiles: profiles)
    }

    private var selectedProfileUUID: UUID? {
        selectedProfile.profileID
    }

    private var profileAllergens: [Allergen] {
        allergens.filter { $0.profileID == selectedProfileUUID }
    }

    private var savedAllergenNames: Set<String> {
        Set(profileAllergens.map { AllergenMatcher.normalizedSearchString($0.name) })
    }

    private var quickAddCommonAllergens: [CommonAllergen] {
        availableQuickAddAllergens(from: CommonAllergenCatalog.allergens)
    }

    private var quickAddENumberIngredients: [CommonAllergen] {
        availableQuickAddAllergens(from: CommonAllergenCatalog.eNumberIngredients)
    }

    private var filteredQuickAddCommonAllergens: [CommonAllergen] {
        filteredQuickAddAllergens(from: quickAddCommonAllergens)
    }

    private var filteredQuickAddENumberIngredients: [CommonAllergen] {
        filteredQuickAddAllergens(from: quickAddENumberIngredients)
    }

    private var hasFilteredQuickAddSuggestions: Bool {
        !filteredQuickAddCommonAllergens.isEmpty || !filteredQuickAddENumberIngredients.isEmpty
    }

    private func availableQuickAddAllergens(from catalog: [CommonAllergen]) -> [CommonAllergen] {
        catalog.filter { commonAllergen in
            !savedAllergenNames.contains(AllergenMatcher.normalizedSearchString(commonAllergen.name))
        }
    }

    private func filteredQuickAddAllergens(from allergens: [CommonAllergen]) -> [CommonAllergen] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !query.isEmpty else {
            return allergens
        }

        return allergens.filter { allergen in
            allergen.name.localizedCaseInsensitiveContains(query)
                || allergen.aliases.contains { $0.localizedCaseInsensitiveContains(query) }
        }
    }

    private var filteredAllergens: [Allergen] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !query.isEmpty else {
            return profileAllergens
        }

        return profileAllergens.filter { allergen in
            allergen.name.localizedCaseInsensitiveContains(query)
                || allergen.aliases.contains { $0.localizedCaseInsensitiveContains(query) }
                || allergen.notes.localizedCaseInsensitiveContains(query)
        }
    }

    var body: some View {
        NavigationStack {
            List {
                if !filteredAllergens.isEmpty {
                    Section(selectedProfile.allergiesTitle) {
                        ForEach(filteredAllergens) { allergen in
                            NavigationLink {
                                AllergenEditorView(allergen: allergen)
                            } label: {
                                AllergenRow(allergen: allergen)
                            }
                        }
                        .onDelete(perform: deleteAllergens)
                    }
                } else if !searchText.isEmpty && !hasFilteredQuickAddSuggestions {
                    ContentUnavailableView.search(text: searchText)
                } else if profileAllergens.isEmpty {
                    Section {
                        Text("Add the ingredients \(selectedProfile.name) needs to avoid, including any aliases you want the scanner to recognise.")
                            .foregroundStyle(.secondary)
                    } header: {
                        Text(selectedProfile.allergiesTitle)
                    }
                }

                Section {
                    if filteredQuickAddCommonAllergens.isEmpty {
                        Text(quickAddCommonAllergens.isEmpty ? String(localized: "All common allergens have been added.") : String(localized: "No common allergens match this search."))
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(filteredQuickAddCommonAllergens) { allergen in
                            QuickAddAllergenRow(allergen: allergen) {
                                addCommonAllergen(allergen)
                            }
                        }
                    }
                } header: {
                    Text("Quick Add Common Allergens")
                } footer: {
                    Text("This list uses the common UK/EU major allergen categories. You can still add anything specific to you with the plus button.")
                }

                Section {
                    if filteredQuickAddENumberIngredients.isEmpty {
                        Text(quickAddENumberIngredients.isEmpty ? String(localized: "All E-number ingredients have been added.") : String(localized: "No E-number ingredients match this search."))
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(filteredQuickAddENumberIngredients) { allergen in
                            QuickAddAllergenRow(allergen: allergen) {
                                addCommonAllergen(allergen)
                            }
                        }
                    }
                } header: {
                    Text("Quick Add E-Number Ingredients")
                } footer: {
                    Text("Some ingredients and additives are often listed by E number. Add the ones relevant to your allergy or sensitivity profile.")
                }
            }
            .navigationTitle(selectedProfile.allergiesTitle)
            .searchable(text: $searchText, prompt: "Search allergens")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        isManagingPeople = true
                    } label: {
                        Label("Manage People", systemImage: "person.2")
                    }
                }

                ToolbarItem(placement: .principal) {
                    AllergyProfilePicker(profiles: profiles, selectedProfileID: $selectedProfileID)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isAddingAllergen = true
                    } label: {
                        Label("Add Allergen", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $isAddingAllergen) {
                NavigationStack {
                    AllergenEditorView(profileID: selectedProfileUUID)
                }
            }
            .sheet(isPresented: $isManagingPeople) {
                ProfileManagementView()
            }
        }
    }

    private func deleteAllergens(at offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(filteredAllergens[index])
            }
        }
    }

    private func addCommonAllergen(_ commonAllergen: CommonAllergen) {
        let now = Date()

        withAnimation {
            modelContext.insert(
                Allergen(
                    profileID: selectedProfileUUID,
                    name: commonAllergen.name,
                    aliases: commonAllergen.aliases,
                    createdAt: now,
                    updatedAt: now
                )
            )
        }
    }
}

private struct AllergenRow: View {
    let allergen: Allergen

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(allergen.name)
                .font(.headline)

            if !allergen.aliases.isEmpty {
                Text(allergen.aliases.joined(separator: ", "))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
    }
}

private struct QuickAddAllergenRow: View {
    let allergen: CommonAllergen
    let add: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(allergen.name)
                    .font(.headline)

                if !allergen.aliases.isEmpty {
                    Text(allergen.aliases.joined(separator: ", "))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }

            Spacer()

            Button(action: add) {
                Label("Add", systemImage: "plus.circle.fill")
                    .labelStyle(.iconOnly)
                    .font(.title3)
            }
            .buttonStyle(.borderless)
            .accessibilityLabel(Text("Add \(allergen.name)"))
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    AllergenListView()
        .modelContainer(for: [AllergyProfile.self, Allergen.self, ScanHistoryEntry.self], inMemory: true)
}
