import SwiftData
import SwiftUI
import UIKit

struct HistoryListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ScanHistoryEntry.createdAt, order: .reverse) private var entries: [ScanHistoryEntry]

    var body: some View {
        NavigationStack {
            Group {
                if entries.isEmpty {
                    ContentUnavailableView(
                        "No Saved Scans",
                        systemImage: "clock",
                        description: Text("Saved scan results will appear here so you can review them later.")
                    )
                } else {
                    List {
                        ForEach(entries) { entry in
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
                if !entries.isEmpty {
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
                modelContext.delete(entries[index])
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
    let entry: ScanHistoryEntry

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
    }
}

#Preview {
    HistoryListView()
        .modelContainer(for: [Allergen.self, ScanHistoryEntry.self], inMemory: true)
}
