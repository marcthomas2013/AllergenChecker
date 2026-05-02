import Foundation
import SwiftData

@Model
final class AllergyProfile {
    var id: UUID
    var name: String
    var createdAt: Date

    init(id: UUID = UUID(), name: String, createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
    }
}

struct AllergyProfileOption: Identifiable, Hashable {
    static let defaultID = "default"

    let id: String
    let profileID: UUID?
    let name: String

    var allergiesTitle: String {
        if profileID == nil {
            return String(localized: "My Allergies")
        }

        return String(format: String(localized: "%@'s Allergies"), name)
    }
}

enum AllergyProfileSelection {
    static func options(from profiles: [AllergyProfile]) -> [AllergyProfileOption] {
        [
            AllergyProfileOption(
                id: AllergyProfileOption.defaultID,
                profileID: nil,
                name: String(localized: "Me")
            )
        ] + profiles.map { profile in
            AllergyProfileOption(
                id: profile.id.uuidString,
                profileID: profile.id,
                name: profile.name
            )
        }
    }

    static func selectedOption(storedID: String, profiles: [AllergyProfile]) -> AllergyProfileOption {
        let options = options(from: profiles)

        return options.first { $0.id == storedID } ?? options[0]
    }

    static func profileID(from storedID: String, profiles: [AllergyProfile]) -> UUID? {
        selectedOption(storedID: storedID, profiles: profiles).profileID
    }
}
