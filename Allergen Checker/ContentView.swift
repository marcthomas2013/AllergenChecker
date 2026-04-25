import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            AllergenListView()
                .tabItem {
                    Label("Allergens", systemImage: "list.bullet.clipboard")
                }

            ScanView()
                .tabItem {
                    Label("Scan", systemImage: "camera.viewfinder")
                }

            HistoryListView()
                .tabItem {
                    Label("History", systemImage: "clock")
                }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Allergen.self, ScanHistoryEntry.self], inMemory: true)
}
