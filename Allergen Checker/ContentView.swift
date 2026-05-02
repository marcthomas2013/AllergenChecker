import SwiftUI
import SwiftData

struct ContentView: View {
    @Query private var allergens: [Allergen]
    @AppStorage("lastAcknowledgedSafetyDisclaimerVersion") private var lastAcknowledgedSafetyDisclaimerVersion = ""
    @State private var selectedTab: AppTab = .scan
    @State private var isShowingSafetyDisclaimer = false

    private var currentAppVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "unknown"

        return "\(version)-\(build)"
    }

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

            AllergenSummaryView()
                .tabItem {
                    Label("My Allergies", systemImage: "person.text.rectangle")
                }
                .tag(AppTab.summary)

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

            if lastAcknowledgedSafetyDisclaimerVersion != currentAppVersion {
                isShowingSafetyDisclaimer = true
            }
        }
        .alert(SafetyDisclaimer.title, isPresented: $isShowingSafetyDisclaimer) {
            Button("I Understand", role: .cancel) {
                lastAcknowledgedSafetyDisclaimerVersion = currentAppVersion
            }
        } message: {
            Text(SafetyDisclaimer.message)
        }
    }
}

enum SafetyDisclaimer {
    static let title = "Important Safety Notice"
    static let message = "Allergen Checker is an aid and is not a guarantee that results are 100% accurate. You must always confirm ingredients and allergen information yourself. The developer accepts no responsibility for any mistakes."
}

private enum AppTab {
    case scan
    case allergens
    case summary
    case history
}

#Preview {
    ContentView()
        .modelContainer(for: [Allergen.self, ScanHistoryEntry.self], inMemory: true)
}
