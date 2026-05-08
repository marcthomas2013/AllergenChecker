import CloudKit
import Combine
import CoreData
import Foundation
import SwiftData
import SwiftUI

enum CloudSyncPhase: Equatable {
    case idle
    case checking
    case syncing(String)
    case synced(Date)
    case unavailable(String)
    case failed(String)
}

enum CloudSyncReason {
    case appOpened
    case appClosing
    case cloudKitEvent

    var message: String {
        switch self {
        case .appOpened:
            return String(localized: "Syncing iCloud data...")
        case .appClosing:
            return String(localized: "Saving changes to iCloud...")
        case .cloudKitEvent:
            return String(localized: "Updating iCloud data...")
        }
    }
}

@MainActor
final class CloudSyncMonitor: ObservableObject {
    nonisolated static let containerIdentifier = "iCloud.uk.co.thethomashouse.Allergen-Checker"

    @Published private(set) var phase: CloudSyncPhase = .idle

    private let container: CKContainer
    private var eventTask: Task<Void, Never>?
    private var hideTask: Task<Void, Never>?

    init(container: CKContainer = CKContainer(identifier: CloudSyncMonitor.containerIdentifier)) {
        self.container = container
    }

    deinit {
        eventTask?.cancel()
        hideTask?.cancel()
    }

    func startMonitoringCloudKitEvents() {
        guard eventTask == nil else {
            return
        }

        eventTask = Task { [weak self] in
            for await notification in NotificationCenter.default.notifications(
                named: NSPersistentCloudKitContainer.eventChangedNotification
            ) {
                await self?.handleCloudKitEvent(notification)
            }
        }
    }

    func synchronize(context: ModelContext, reason: CloudSyncReason) async {
        show(.checking)

        guard await isICloudAvailable() else {
            show(.unavailable(String(localized: "iCloud sync is unavailable. Check iCloud Drive is enabled.")))
            scheduleHide(after: .seconds(5))
            return
        }

        show(.syncing(reason.message))

        do {
            if context.hasChanges {
                try context.save()
            }

            scheduleSynced()
        } catch {
            show(.failed(error.localizedDescription))
            scheduleHide(after: .seconds(6))
        }
    }

    private func handleCloudKitEvent(_ notification: Notification) {
        guard let event = notification.userInfo?[NSPersistentCloudKitContainer.eventNotificationUserInfoKey] as? NSPersistentCloudKitContainer.Event else {
            return
        }

        if event.endDate == nil {
            show(.syncing(CloudSyncReason.cloudKitEvent.message))
            return
        }

        if let error = event.error {
            show(.failed(error.localizedDescription))
            scheduleHide(after: .seconds(6))
        } else {
            scheduleSynced()
        }
    }

    private func isICloudAvailable() async -> Bool {
        do {
            return try await container.accountStatus() == .available
        } catch {
            return false
        }
    }

    private func scheduleSynced() {
        show(.synced(Date()))
        scheduleHide(after: .seconds(3))
    }

    private func show(_ phase: CloudSyncPhase) {
        hideTask?.cancel()
        withAnimation {
            self.phase = phase
        }
    }

    private func scheduleHide(after seconds: Duration) {
        hideTask?.cancel()
        hideTask = Task { [weak self] in
            try? await Task.sleep(for: seconds)
            await self?.hide()
        }
    }

    private func hide() {
        withAnimation {
            phase = .idle
        }
    }
}
