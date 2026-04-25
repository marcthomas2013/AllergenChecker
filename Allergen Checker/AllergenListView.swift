import SwiftData
import SwiftUI

struct AllergenListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Allergen.name) private var allergens: [Allergen]

    @State private var searchText = ""
    @State private var isAddingAllergen = false

    private var savedAllergenNames: Set<String> {
        Set(allergens.map { AllergenMatcher.normalizedSearchString($0.name) })
    }

    private var quickAddAllergens: [CommonAllergen] {
        CommonAllergenCatalog.allergens.filter { commonAllergen in
            !savedAllergenNames.contains(AllergenMatcher.normalizedSearchString(commonAllergen.name))
        }
    }

    private var filteredQuickAddAllergens: [CommonAllergen] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !query.isEmpty else {
            return quickAddAllergens
        }

        return quickAddAllergens.filter { allergen in
            allergen.name.localizedCaseInsensitiveContains(query)
                || allergen.aliases.contains { $0.localizedCaseInsensitiveContains(query) }
        }
    }

    private var filteredAllergens: [Allergen] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !query.isEmpty else {
            return allergens
        }

        return allergens.filter { allergen in
            allergen.name.localizedCaseInsensitiveContains(query)
                || allergen.aliases.contains { $0.localizedCaseInsensitiveContains(query) }
                || allergen.notes.localizedCaseInsensitiveContains(query)
        }
    }

    var body: some View {
        NavigationStack {
            List {
                if !filteredAllergens.isEmpty {
                    Section("Your Allergens") {
                        ForEach(filteredAllergens) { allergen in
                            NavigationLink {
                                AllergenEditorView(allergen: allergen)
                            } label: {
                                AllergenRow(allergen: allergen)
                            }
                        }
                        .onDelete(perform: deleteAllergens)
                    }
                } else if !searchText.isEmpty && filteredQuickAddAllergens.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                } else if allergens.isEmpty {
                    Section {
                        Text("Add the ingredients you need to avoid, including any aliases you want the scanner to recognise.")
                            .foregroundStyle(.secondary)
                    } header: {
                        Text("Your Allergens")
                    }
                }

                Section {
                    if filteredQuickAddAllergens.isEmpty {
                        Text(quickAddAllergens.isEmpty ? "All common allergens have been added." : "No common allergens match this search.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(filteredQuickAddAllergens) { allergen in
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
            }
            .navigationTitle("Allergens")
            .searchable(text: $searchText, prompt: "Search allergens")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if !allergens.isEmpty {
                        EditButton()
                    }
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
                    AllergenEditorView()
                }
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
            .accessibilityLabel("Add \(allergen.name)")
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    AllergenListView()
        .modelContainer(for: Allergen.self, inMemory: true)
}
