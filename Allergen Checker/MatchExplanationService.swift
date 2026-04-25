import Foundation

protocol MatchExplaining {
    func explanation(for match: AllergenMatch) -> String
}

struct LocalMatchExplanationService: MatchExplaining {
    func explanation(for match: AllergenMatch) -> String {
        let confidence = Int((match.confidence * 100).rounded())

        if match.matchedTerm.localizedCaseInsensitiveCompare(match.allergenName) == .orderedSame {
            return "Vision found \"\(match.matchedTerm)\" in the ingredient text with \(confidence)% confidence."
        }

        return "Vision found \"\(match.matchedTerm)\", which you saved as an alias for \(match.allergenName), with \(confidence)% confidence."
    }
}
