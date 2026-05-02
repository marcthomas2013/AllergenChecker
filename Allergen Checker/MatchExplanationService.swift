import Foundation

protocol MatchExplaining {
    func explanation(for match: AllergenMatch) -> String
}

struct LocalMatchExplanationService: MatchExplaining {
    func explanation(for match: AllergenMatch) -> String {
        let confidence = Int((match.confidence * 100).rounded())

        if match.matchedTerm.localizedCaseInsensitiveCompare(match.allergenName) == .orderedSame {
            return String(
                format: String(localized: "Vision found \"%@\" in the ingredient text with %d%% confidence."),
                match.matchedTerm,
                confidence
            )
        }

        return String(
            format: String(localized: "Vision found \"%@\", which you saved as an alias for %@, with %d%% confidence."),
            match.matchedTerm,
            match.allergenName,
            confidence
        )
    }
}
