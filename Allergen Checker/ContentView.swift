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
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Allergen.self, inMemory: true)
}
