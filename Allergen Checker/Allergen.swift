import Foundation
import SwiftData

@Model
final class Allergen {
    var name: String
    var aliases: [String]
    var notes: String
    var createdAt: Date
    var updatedAt: Date

    init(
        name: String,
        aliases: [String] = [],
        notes: String = "",
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.name = name
        self.aliases = aliases
        self.notes = notes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var searchTerms: [String] {
        ([name] + aliases)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
}
