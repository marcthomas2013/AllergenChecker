import SwiftData
import SwiftUI
import UIKit

struct HistoryListView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("selectedAllergyProfileID") private var selectedProfileID = AllergyProfileOption.defaultID

    @Query(sort: \AllergyProfile.name) private var profiles: [AllergyProfile]
    @Query(sort: \ScanHistoryEntry.createdAt, order: .reverse) private var entries: [ScanHistoryEntry]

    private var selectedProfile: AllergyProfileOption {
        AllergyProfileSelection.selectedOption(storedID: selectedProfileID, profiles: profiles)
    }

    private var selectedProfileUUID: UUID? {
        selectedProfile.profileID
    }

    private var filteredEntries: [ScanHistoryEntry] {
        entries.filter { $0.profileID == selectedProfileUUID }
    }

    var body: some View {
        NavigationStack {
            Group {
                if filteredEntries.isEmpty {
                    ContentUnavailableView(
                        "No Saved Scans",
                        systemImage: "clock",
                        description: Text("Saved scan results for \(selectedProfile.name) will appear here so you can review them later.")
                    )
                } else {
                    List {
                        ForEach(filteredEntries) { entry in
                            NavigationLink {
                                HistoryDetailView(entry: entry)
                            } label: {
                                HistoryRow(entry: entry)
                            }
                        }
                        .onDelete(perform: deleteEntries)
                    }
                }
            }
            .navigationTitle("History")
            .toolbar {
                ToolbarItem(placement: .principal) {
                    AllergyProfilePicker(profiles: profiles, selectedProfileID: $selectedProfileID)
                }

                if !filteredEntries.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        EditButton()
                    }
                }
            }
        }
    }

    private func deleteEntries(at offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(filteredEntries[index])
            }
        }
    }
}

private struct HistoryRow: View {
    let entry: ScanHistoryEntry

    var body: some View {
        HStack(spacing: 12) {
            thumbnail

            VStack(alignment: .leading, spacing: 6) {
                Text(entry.createdAt, format: Date.FormatStyle(date: .abbreviated, time: .shortened))
                    .font(.headline)

                Label(matchSummary, systemImage: entry.matchCount > 0 ? "exclamationmark.triangle.fill" : "checkmark.shield.fill")
                    .font(.subheadline)
                    .foregroundStyle(entry.matchCount > 0 ? .red : .green)

                if !entry.recognizedTextPreview.isEmpty {
                    Text(entry.recognizedTextPreview)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }
        }
        .padding(.vertical, 4)
    }

    private var matchSummary: String {
        entry.matchCount == 1 ? "1 possible match" : "\(entry.matchCount) possible matches"
    }

    @ViewBuilder
    private var thumbnail: some View {
        if let image = UIImage(data: entry.imageData) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 64, height: 64)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        } else {
            RoundedRectangle(cornerRadius: 10)
                .fill(.secondary.opacity(0.2))
                .frame(width: 64, height: 64)
                .overlay {
                    Image(systemName: "photo")
                        .foregroundStyle(.secondary)
                }
        }
    }
}

private struct HistoryDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Allergen.name) private var allergens: [Allergen]

    let entry: ScanHistoryEntry

    @State private var rescanError: String?
    @State private var didRescan = false

    private var profileAllergens: [Allergen] {
        allergens.filter { $0.profileID == entry.profileID }
    }

    var body: some View {
        Group {
            if let result = try? entry.scanResult() {
                ScanResultView(result: result, allowsSaving: false)
            } else {
                ContentUnavailableView(
                    "Scan Could Not Be Loaded",
                    systemImage: "exclamationmark.triangle",
                    description: Text("The saved image or scan results are no longer readable.")
                )
            }
        }
        .navigationTitle(entry.createdAt.formatted(date: .abbreviated, time: .shortened))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    rescan()
                } label: {
                    Label("Rescan", systemImage: "arrow.triangle.2.circlepath")
                }
                .disabled(profileAllergens.isEmpty)
            }
        }
        .safeAreaInset(edge: .bottom) {
            if didRescan {
                Label("History updated using this person's current allergens.", systemImage: "checkmark.circle.fill")
                    .font(.caption)
                    .foregroundStyle(.green)
                    .padding(10)
                    .background(.regularMaterial, in: Capsule())
                    .padding(.bottom, 8)
            }
        }
        .alert("Could Not Rescan", isPresented: Binding(
            get: { rescanError != nil },
            set: { if !$0 { rescanError = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(rescanError ?? "The saved scan could not be rescanned.")
        }
    }

    private func rescan() {
        do {
            try entry.rescan(using: profileAllergens)
            try modelContext.save()

            withAnimation {
                didRescan = true
            }

            Task {
                try? await Task.sleep(for: .seconds(2))
                withAnimation {
                    didRescan = false
                }
            }
        } catch {
            rescanError = error.localizedDescription
        }
    }
}

#Preview {
    HistoryListView()
        .modelContainer(for: [AllergyProfile.self, Allergen.self, ScanHistoryEntry.self], inMemory: true)
}
