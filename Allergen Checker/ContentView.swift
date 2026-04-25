import SwiftUI
import SwiftData

struct ContentView: View {
    @Query private var allergens: [Allergen]
    @State private var selectedTab: AppTab = .scan

    var body: some View {
        TabView(selection: $selectedTab) {
            ScanView()
                .tabItem {
                    Label("Scan", systemImage: "camera.viewfinder")
                }
                .tag(AppTab.scan)

            AllergenListView()
                .tabItem {
                    Label("Allergens", systemImage: "list.bullet.clipboard")
                }
                .tag(AppTab.allergens)

            HistoryListView()
                .tabItem {
                    Label("History", systemImage: "clock")
                }
                .tag(AppTab.history)
        }
        .onAppear {
            if allergens.isEmpty {
                selectedTab = .scan
            }
        }
    }
}

private enum AppTab {
    case scan
    case allergens
    case history
}

#Preview {
    ContentView()
        .modelContainer(for: [Allergen.self, ScanHistoryEntry.self], inMemory: true)
}
