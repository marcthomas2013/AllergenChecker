//
//  Allergen_CheckerApp.swift
//  Allergen Checker
//
//  Created by Marc Thomas on 25/04/2026.
//

import SwiftUI
import SwiftData

@main
struct Allergen_CheckerApp: App {
    @StateObject private var cloudSyncMonitor = CloudSyncMonitor()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            AllergyProfile.self,
            Allergen.self,
            ScanHistoryEntry.self,
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .private(CloudSyncMonitor.containerIdentifier)
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(cloudSyncMonitor)
        }
        .modelContainer(sharedModelContainer)
    }
}
