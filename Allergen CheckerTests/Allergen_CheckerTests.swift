import CoreGraphics
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

}
