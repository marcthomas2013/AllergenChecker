import SwiftData
import SwiftUI

struct AllergenListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Allergen.name) private var allergens: [Allergen]

    @State private var searchText = ""
    @State private var isAddingAllergen = false

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
            Group {
                if allergens.isEmpty {
                    ContentUnavailableView(
                        "No Allergens Yet",
                        systemImage: "exclamationmark.shield",
                        description: Text("Add the ingredients you need to avoid, including any aliases you want the scanner to recognise.")
                    )
                } else if filteredAllergens.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                } else {
                    List {
                        ForEach(filteredAllergens) { allergen in
                            NavigationLink {
                                AllergenEditorView(allergen: allergen)
                            } label: {
                                AllergenRow(allergen: allergen)
                            }
                        }
                        .onDelete(perform: deleteAllergens)
                    }
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

#Preview {
    AllergenListView()
        .modelContainer(for: Allergen.self, inMemory: true)
}
