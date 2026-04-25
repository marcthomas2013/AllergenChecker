import SwiftData
import SwiftUI

struct AllergenEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    private let allergen: Allergen?

    @State private var name: String
    @State private var aliasesText: String
    @State private var notes: String

    init(allergen: Allergen? = nil) {
        self.allergen = allergen
        _name = State(initialValue: allergen?.name ?? "")
        _aliasesText = State(initialValue: allergen?.aliases.joined(separator: ", ") ?? "")
        _notes = State(initialValue: allergen?.notes ?? "")
    }

    private var isNewAllergen: Bool {
        allergen == nil
    }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var aliases: [String] {
        aliasesText
            .split(whereSeparator: { $0 == "," || $0 == "\n" })
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    var body: some View {
        Form {
            Section("Allergen") {
                TextField("Name", text: $name)
                    .textInputAutocapitalization(.words)

                TextField("Aliases or related ingredients", text: $aliasesText, axis: .vertical)
                    .lineLimit(2...5)
                    .textInputAutocapitalization(.never)

                Text("Separate aliases with commas or new lines.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("Notes") {
                TextField("Optional notes", text: $notes, axis: .vertical)
                    .lineLimit(3...8)
            }
        }
        .navigationTitle(isNewAllergen ? "New Allergen" : "Edit Allergen")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if isNewAllergen {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }

            ToolbarItem(placement: .confirmationAction) {
                Button("Save", action: save)
                    .disabled(trimmedName.isEmpty)
            }
        }
    }

    private func save() {
        let now = Date()

        if let allergen {
            allergen.name = trimmedName
            allergen.aliases = aliases
            allergen.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
            allergen.updatedAt = now
        } else {
            modelContext.insert(
                Allergen(
                    name: trimmedName,
                    aliases: aliases,
                    notes: notes.trimmingCharacters(in: .whitespacesAndNewlines),
                    createdAt: now,
                    updatedAt: now
                )
            )
        }

        dismiss()
    }
}

#Preview {
    NavigationStack {
        AllergenEditorView()
    }
    .modelContainer(for: Allergen.self, inMemory: true)
}
