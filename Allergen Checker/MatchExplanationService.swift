import Foundation

protocol MatchExplaining {
    func explanation(for match: AllergenMatch) -> String
}

struct LocalMatchExplanationService: MatchExplaining {
    func explanation(for match: AllergenMatch) -> String {
        let confidence = displayConfidencePercentage(for: match.confidence)

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

    private func displayConfidencePercentage(for confidence: Float) -> Int {
        let roundedPercentage = Int((confidence * 100).rounded())
        return min(99, max(0, roundedPercentage))
    }
}
