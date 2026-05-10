import CoreGraphics
import Foundation
import Testing
@testable import Allergen_Checker

struct Allergen_CheckerTests {

    @MainActor
    @Test func normalizedSearchStringIsCaseAndDiacriticInsensitive() {
        let normalized = AllergenMatcher.normalizedSearchString("  Crème   Fraîche  ")

        #expect(normalized == "creme fraiche")
    }

    @MainActor
    @Test func matchesAllergenNameAndAliases() {
        let allergen = Allergen(name: "Milk", aliases: ["whey", "casein"])
        let textBlocks = [
            RecognizedTextBlock(
                text: "Ingredients: sugar, whey powder, cocoa",
                confidence: 0.93,
                boundingBox: CGRect(x: 0.1, y: 0.2, width: 0.4, height: 0.1)
            )
        ]

        let matches = AllergenMatcher.matches(in: textBlocks, allergens: [allergen])

        #expect(matches.count == 1)
        #expect(matches.first?.allergenName == "Milk")
        #expect(matches.first?.matchedTerm == "whey")
    }

    @MainActor
    @Test func wholeTermMatchingAvoidsPartialWords() {
        let allergen = Allergen(name: "Milk")
        let textBlocks = [
            RecognizedTextBlock(
                text: "Contains milkshake flavouring",
                confidence: 0.88,
                boundingBox: .zero
            )
        ]

        let matches = AllergenMatcher.matches(in: textBlocks, allergens: [allergen])

        #expect(matches.isEmpty)
    }

    @MainActor
    @Test func duplicateTermsOnlyMatchOncePerTextBlock() {
        let allergen = Allergen(name: "Milk", aliases: ["milk"])
        let textBlocks = [
            RecognizedTextBlock(
                text: "Contains milk",
                confidence: 0.91,
                boundingBox: .zero
            )
        ]

        let matches = AllergenMatcher.matches(in: textBlocks, allergens: [allergen])

        #expect(matches.count == 1)
    }

    @MainActor
    @Test func singularAllergenMatchesPluralText() {
        let allergen = Allergen(name: "Egg")
        let textBlocks = [
            RecognizedTextBlock(
                text: "Ingredients: eggs, flour, sugar",
                confidence: 0.95,
                boundingBox: .zero
            )
        ]

        let matches = AllergenMatcher.matches(in: textBlocks, allergens: [allergen])

        #expect(matches.count == 1)
        #expect(matches.first?.allergenName == "Egg")
    }

    @MainActor
    @Test func pluralAllergenMatchesSingularText() {
        let allergen = Allergen(name: "Peanuts")
        let textBlocks = [
            RecognizedTextBlock(
                text: "May contain peanut",
                confidence: 0.95,
                boundingBox: .zero
            )
        ]

        let matches = AllergenMatcher.matches(in: textBlocks, allergens: [allergen])

        #expect(matches.count == 1)
        #expect(matches.first?.allergenName == "Peanuts")
    }

    @MainActor
    @Test func phraseAllergenPluralizesLastWord() {
        let allergen = Allergen(name: "Tree nut")
        let textBlocks = [
            RecognizedTextBlock(
                text: "May contain tree nuts",
                confidence: 0.95,
                boundingBox: .zero
            )
        ]

        let matches = AllergenMatcher.matches(in: textBlocks, allergens: [allergen])

        #expect(matches.count == 1)
    }

    @MainActor
    @Test func translatedTermsAreOnlyUsedForDetectedLanguage() {
        let allergen = Allergen(name: "Eggs")
        let textBlocks = [
            RecognizedTextBlock(
                text: "Ingredients: oeufs, farine, sucre",
                confidence: 0.95,
                boundingBox: .zero
            )
        ]

        let englishMatches = AllergenMatcher.matches(in: textBlocks, allergens: [allergen])
        let frenchMatches = AllergenMatcher.matches(in: textBlocks, allergens: [allergen], detectedLanguage: .french)

        #expect(englishMatches.isEmpty)
        #expect(frenchMatches.count == 1)
        #expect(frenchMatches.first?.matchedTerm.lowercased() == "oeufs")
    }

    @MainActor
    @Test func frenchLigatureOeMatchesTranslatedEggTerms() {
        let allergen = Allergen(name: "Eggs")
        let textBlocks = [
            RecognizedTextBlock(
                text: "Ingredients: protéine d'œuf",
                confidence: 0.95,
                boundingBox: .zero
            )
        ]

        let matches = AllergenMatcher.matches(in: textBlocks, allergens: [allergen], detectedLanguage: .french)

        #expect(matches.count == 1)
    }

    @MainActor
    @Test func frenchOcrCeufVariantMatchesTranslatedEggTerms() {
        let allergen = Allergen(name: "Eggs")
        let textBlocks = [
            RecognizedTextBlock(
                text: "Ingredients: proteine de ceuf",
                confidence: 0.95,
                boundingBox: .zero
            )
        ]

        let matches = AllergenMatcher.matches(in: textBlocks, allergens: [allergen], detectedLanguage: .french)

        #expect(matches.count == 1)
    }

    @MainActor
    @Test func englishDefaultMatchingCoversAllCatalogAllergensAndAliases() {
        let catalogAllergens = CommonAllergenCatalog.allergens + CommonAllergenCatalog.eNumberIngredients

        for common in catalogAllergens {
            let allergen = Allergen(name: common.name, aliases: common.aliases)
            let terms = allergen.searchTerms

            for term in terms {
                let directMatches = matches(
                    allergen: allergen,
                    text: "Ingredients: \(term)",
                    detectedLanguage: .english
                )
                #expect(!directMatches.isEmpty, "\(common.name) term did not match directly: \(term)")

                if let englishVariant = englishInflectionVariant(for: term) {
                    let variantMatches = matches(
                        allergen: allergen,
                        text: "Ingredients: \(englishVariant)",
                        detectedLanguage: .english
                    )
                    #expect(!variantMatches.isEmpty, "\(common.name) term variant did not match: \(term) -> \(englishVariant)")
                }
            }
        }
    }

    @MainActor
    @Test func translatedMatchingCoversAllAvailableCatalogTranslationsAcrossLanguages() {
        let catalogAllergens = CommonAllergenCatalog.allergens + CommonAllergenCatalog.eNumberIngredients
        let targetLanguages = AllergenDisplayLanguage.allCases.filter { $0 != .english }

        var translationCountByLanguage: [AllergenDisplayLanguage: Int] = [:]
        for language in targetLanguages {
            translationCountByLanguage[language] = 0
        }

        for common in catalogAllergens {
            let allergen = Allergen(name: common.name, aliases: common.aliases)
            let terms = allergen.searchTerms

            for language in targetLanguages {
                for term in terms {
                    guard let translated = AllergenTranslationCatalog.translation(for: term, language: language) else {
                        continue
                    }

                    translationCountByLanguage[language, default: 0] += 1

                    let directMatches = matches(
                        allergen: allergen,
                        text: "Ingredients: \(translated)",
                        detectedLanguage: language
                    )
                    #expect(!directMatches.isEmpty, "\(common.name) translation did not match for \(language.name): \(translated)")

                    if let translatedVariant = nonEnglishInflectionVariant(for: translated) {
                        let variantMatches = matches(
                            allergen: allergen,
                            text: "Ingredients: \(translatedVariant)",
                            detectedLanguage: language
                        )
                        #expect(!variantMatches.isEmpty, "\(common.name) translation variant did not match for \(language.name): \(translated) -> \(translatedVariant)")
                    }
                }
            }
        }

        for language in targetLanguages {
            #expect((translationCountByLanguage[language] ?? 0) > 0, "No translations were exercised for \(language.name)")
        }
    }

    private func matches(
        allergen: Allergen,
        text: String,
        detectedLanguage: AllergenDisplayLanguage
    ) -> [AllergenMatch] {
        let block = RecognizedTextBlock(
            text: text,
            confidence: 0.99,
            boundingBox: .zero
        )

        return AllergenMatcher.matches(
            in: [block],
            allergens: [allergen],
            detectedLanguage: detectedLanguage
        )
    }

    private func englishInflectionVariant(for term: String) -> String? {
        guard var words = splitIntoWords(term), let lastWord = words.last else {
            return nil
        }

        guard lastWord.allSatisfy(\.isLetter) else {
            return nil
        }

        if let singular = singularizedEnglish(lastWord), singular != lastWord {
            words[words.count - 1] = singular
            return words.joined(separator: " ")
        }

        if let plural = pluralizedEnglish(lastWord), plural != lastWord {
            words[words.count - 1] = plural
            return words.joined(separator: " ")
        }

        return nil
    }

    private func nonEnglishInflectionVariant(for term: String) -> String? {
        guard var words = splitIntoWords(term), let lastWord = words.last else {
            return nil
        }

        guard lastWord.allSatisfy(\.isLetter), lastWord.count > 1 else {
            return nil
        }

        if lastWord.hasSuffix("s") {
            words[words.count - 1] = String(lastWord.dropLast())
        } else {
            words[words.count - 1] = lastWord + "s"
        }

        let variant = words.joined(separator: " ")
        return variant == term ? nil : variant
    }

    private func splitIntoWords(_ term: String) -> [String]? {
        let words = term
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .split(separator: " ")
            .map(String.init)

        return words.isEmpty ? nil : words
    }

    private func pluralizedEnglish(_ word: String) -> String? {
        guard !word.isEmpty else {
            return nil
        }

        if word.hasSuffix("y"), let previous = word.dropLast().last, !"aeiou".contains(previous) {
            return String(word.dropLast()) + "ies"
        }

        if word.hasSuffix("s") || word.hasSuffix("x") || word.hasSuffix("z") || word.hasSuffix("ch") || word.hasSuffix("sh") {
            return word + "es"
        }

        return word + "s"
    }

    private func singularizedEnglish(_ word: String) -> String? {
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
}
