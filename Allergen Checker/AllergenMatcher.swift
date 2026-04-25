import Foundation

struct AllergenMatcher {
    static func matches(in textBlocks: [RecognizedTextBlock], allergens: [Allergen]) -> [AllergenMatch] {
        var matches: [AllergenMatch] = []
        var seenMatches = Set<String>()

        for block in textBlocks {
            let searchableText = normalizedSearchString(block.text)

            for allergen in allergens {
                for term in allergen.searchTerms {
                    let searchableTerm = normalizedSearchString(term)

                    guard !searchableTerm.isEmpty, containsWholeTerm(searchableTerm, in: searchableText) else {
                        continue
                    }

                    let matchKey = "\(allergen.name)|\(searchableTerm)|\(block.id)"
                    guard seenMatches.insert(matchKey).inserted else {
                        continue
                    }

                    matches.append(
                        AllergenMatch(
                            allergenName: allergen.name,
                            matchedTerm: term,
                            recognizedText: block.text,
                            confidence: block.confidence,
                            boundingBox: block.boundingBox
                        )
                    )
                }
            }
        }

        return matches.sorted {
            if $0.allergenName.localizedCaseInsensitiveCompare($1.allergenName) == .orderedSame {
                return $0.matchedTerm.localizedCaseInsensitiveCompare($1.matchedTerm) == .orderedAscending
            }

            return $0.allergenName.localizedCaseInsensitiveCompare($1.allergenName) == .orderedAscending
        }
    }

    static func normalizedSearchString(_ value: String) -> String {
        value
            .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
            .lowercased()
            .replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func containsWholeTerm(_ term: String, in text: String) -> Bool {
        let escapedTerm = NSRegularExpression.escapedPattern(for: term)
        let pattern = #"(?<![\p{L}\p{N}])"# + escapedTerm + #"(?![\p{L}\p{N}])"#
        let range = NSRange(text.startIndex..<text.endIndex, in: text)

        return (try? NSRegularExpression(pattern: pattern))
            .map { !$0.matches(in: text, range: range).isEmpty } ?? false
    }
}
