import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject private var cloudSyncMonitor: CloudSyncMonitor
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @EnvironmentObject private var adsService: AdsService

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
            AdInsetContent {
                ScanView()
            }
                .tabItem {
                    Label("Scan", systemImage: "camera.viewfinder")
                }
                .tag(AppTab.scan)

            AdInsetContent {
                AllergenListView()
            }
                .tabItem {
                    Label("Allergens", systemImage: "list.bullet.clipboard")
                }
                .tag(AppTab.allergens)

            AdInsetContent {
                AllergenSummaryView()
            }
                .tabItem {
                    Label("My Allergies", systemImage: "person.text.rectangle")
                }
                .tag(AppTab.summary)

            AdInsetContent {
                HistoryListView()
            }
                .tabItem {
                    Label("History", systemImage: "clock")
                }
                .tag(AppTab.history)

            AdInsetContent {
                SettingsView()
            }
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(AppTab.settings)
        }
        .safeAreaInset(edge: .top) {
            CloudSyncIndicator(phase: cloudSyncMonitor.phase)
        }
        .onAppear {
            if allergens.isEmpty {
                selectedTab = .scan
            }

            if lastAcknowledgedSafetyDisclaimerVersion != currentAppVersion {
                isShowingSafetyDisclaimer = true
            }

            adsService.setAdsEnabled(!subscriptionManager.hasActiveSubscription)
        }
        .task {
            cloudSyncMonitor.startMonitoringCloudKitEvents()
            await requestCloudSync(reason: .appOpened)
        }
        .onChange(of: subscriptionManager.hasActiveSubscription) { _, isSubscribed in
            adsService.setAdsEnabled(!isSubscribed)
        }
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .active:
                Task {
                    await requestCloudSync(reason: .appOpened)
                    await subscriptionManager.refreshSubscriptionStatus()
                }
            case .inactive, .background:
                Task {
                    await requestCloudSync(reason: .appClosing)
                }
            @unknown default:
                break
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

    private func requestCloudSync(reason: CloudSyncReason) async {
        await cloudSyncMonitor.synchronize(context: modelContext, reason: reason)
    }
}

private struct CloudSyncIndicator: View {
    let phase: CloudSyncPhase

    var body: some View {
        if let status = indicatorStatus {
            HStack(spacing: 8) {
                if status.showsProgress {
                    ProgressView()
                        .controlSize(.small)
                } else {
                    Image(systemName: status.systemImage)
                        .foregroundStyle(status.tint)
                }

                Text(status.message)
                    .font(.caption)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.regularMaterial, in: Capsule())
            .padding(.top, 6)
            .accessibilityElement(children: .combine)
            .accessibilityLabel(Text(status.message))
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }

    private var indicatorStatus: CloudSyncIndicatorStatus? {
        switch phase {
        case .idle:
            return nil
        case .checking:
            return CloudSyncIndicatorStatus(
                message: String(localized: "Checking iCloud..."),
                systemImage: "icloud",
                tint: .secondary,
                showsProgress: true
            )
        case .syncing(let message):
            return CloudSyncIndicatorStatus(
                message: message,
                systemImage: "icloud.and.arrow.up",
                tint: .blue,
                showsProgress: true
            )
        case .synced:
            return CloudSyncIndicatorStatus(
                message: String(localized: "iCloud sync complete"),
                systemImage: "checkmark.icloud.fill",
                tint: .green,
                showsProgress: false
            )
        case .unavailable(let message):
            return CloudSyncIndicatorStatus(
                message: message,
                systemImage: "icloud.slash",
                tint: .orange,
                showsProgress: false
            )
        case .failed(let message):
            return CloudSyncIndicatorStatus(
                message: String(format: String(localized: "iCloud sync failed: %@"), message),
                systemImage: "exclamationmark.icloud",
                tint: .red,
                showsProgress: false
            )
        }
    }
}

private struct CloudSyncIndicatorStatus {
    let message: String
    let systemImage: String
    let tint: Color
    let showsProgress: Bool
}

enum SafetyDisclaimer {
    static let title = String(localized: "Important Safety Notice")
    static let message = String(localized: "Allergen Checker is an aid and is not a guarantee that results are 100% accurate. You must always confirm ingredients and allergen information yourself. The developer accepts no responsibility for any mistakes.")
}

private enum AppTab {
    case scan
    case allergens
    case summary
    case history
    case settings
}

#Preview {
    ContentView()
        .modelContainer(for: [AllergyProfile.self, Allergen.self, ScanHistoryEntry.self], inMemory: true)
        .environmentObject(CloudSyncMonitor())
        .environmentObject(SubscriptionManager())
        .environmentObject(AdsService())
}
