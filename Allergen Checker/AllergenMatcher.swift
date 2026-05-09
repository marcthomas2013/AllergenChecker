import Foundation

struct AllergenMatcher {
    static func matches(
        in textBlocks: [RecognizedTextBlock],
        allergens: [Allergen],
        detectedLanguage: AllergenDisplayLanguage = .english
    ) -> [AllergenMatch] {
        var matches: [AllergenMatch] = []
        var seenMatches = Set<String>()

        for block in textBlocks {
            let searchableText = normalizedSearchString(block.text)

            for allergen in allergens {
                for term in localizedSearchTerms(for: allergen, language: detectedLanguage) {
                    let searchableTerm = normalizedSearchString(term)
                    let searchableVariants = termVariants(for: searchableTerm, language: detectedLanguage)

                    guard !searchableTerm.isEmpty,
                          searchableVariants.contains(where: { containsWholeTerm($0, in: searchableText) }) else {
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

    private static func localizedSearchTerms(for allergen: Allergen, language: AllergenDisplayLanguage) -> [String] {
        var terms = allergen.searchTerms

        if language != .english {
            if let translatedName = translatedTerm(for: allergen.name, language: language) {
                terms.append(translatedName)
            }

            for alias in allergen.aliases {
                if let translatedAlias = translatedTerm(for: alias, language: language) {
                    terms.append(translatedAlias)
                }
            }
        }

        var uniqueTerms: [String] = []
        var seen = Set<String>()

        for term in terms {
            let normalized = normalizedSearchString(term)
            guard !normalized.isEmpty, seen.insert(normalized).inserted else {
                continue
            }

            uniqueTerms.append(term)
        }

        return uniqueTerms
    }

    private static func termVariants(for term: String, language: AllergenDisplayLanguage) -> [String] {
        guard language == .english else {
            return nonEnglishTermVariants(for: term)
        }

        var variants = [term]

        if let plural = variant(of: term, using: pluralizedWord) {
            variants.append(plural)
        }

        if let singular = variant(of: term, using: singularizedWord) {
            variants.append(singular)
        }

        return Array(Set(variants))
    }

    private static func translatedTerm(for term: String, language: AllergenDisplayLanguage) -> String? {
        if let directTranslation = AllergenTranslationCatalog.translation(for: term, language: language) {
            return directTranslation
        }

        let normalized = normalizedSearchString(term)
        guard !normalized.isEmpty else {
            return nil
        }

        if let singular = singularizedWord(normalized),
           let singularTranslation = AllergenTranslationCatalog.translation(for: singular, language: language) {
            return singularTranslation
        }

        if let plural = pluralizedWord(normalized),
           let pluralTranslation = AllergenTranslationCatalog.translation(for: plural, language: language) {
            return pluralTranslation
        }

        return nil
    }

    private static func nonEnglishTermVariants(for term: String) -> [String] {
        var variants = [term]

        if term.hasSuffix("s"), term.count > 1 {
            variants.append(String(term.dropLast()))
        } else {
            variants.append(term + "s")
        }

        return Array(Set(variants))
    }

    private static func variant(of term: String, using transform: (String) -> String?) -> String? {
        var words = term.split(separator: " ").map(String.init)

        guard let lastWord = words.last, let transformed = transform(lastWord), transformed != lastWord else {
            return nil
        }

        words[words.count - 1] = transformed
        return words.joined(separator: " ")
    }

    private static func pluralizedWord(_ word: String) -> String? {
        guard !word.isEmpty else {
            return nil
        }

        if word.hasSuffix("y"), let previous = word.dropLast().last, !isVowel(previous) {
            return String(word.dropLast()) + "ies"
        }

        if word.hasSuffix("s") || word.hasSuffix("x") || word.hasSuffix("z") || word.hasSuffix("ch") || word.hasSuffix("sh") {
            return word + "es"
        }

        return word + "s"
    }

    private static func singularizedWord(_ word: String) -> String? {
        guard word.count > 1 else {
            return nil
        }

        if word.hasSuffix("ies"), word.count > 3 {
            return String(word.dropLast(3)) + "y"
        }

        if word.hasSuffix("ses") || word.hasSuffix("xes") || word.hasSuffix("zes") || word.hasSuffix("ches") || word.hasSuffix("shes") {
            return String(word.dropLast(2))
        }

        if word.hasSuffix("s"), !word.hasSuffix("ss") {
            return String(word.dropLast())
        }

        return nil
    }

    private static func isVowel(_ character: Character) -> Bool {
        "aeiou".contains(character)
    }

    private static func containsWholeTerm(_ term: String, in text: String) -> Bool {
        let escapedTerm = NSRegularExpression.escapedPattern(for: term)
        let pattern = #"(?<![\p{L}\p{N}])"# + escapedTerm + #"(?![\p{L}\p{N}])"#
        let range = NSRange(text.startIndex..<text.endIndex, in: text)

        return (try? NSRegularExpression(pattern: pattern))
            .map { !$0.matches(in: text, range: range).isEmpty } ?? false
    }
}
