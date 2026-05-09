import NaturalLanguage

enum AllergenScanLanguageDetector {
    static func detectLanguage(in textBlocks: [RecognizedTextBlock]) -> AllergenDisplayLanguage? {
        let combinedText = textBlocks
            .map(\.text)
            .joined(separator: "\n")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !combinedText.isEmpty else {
            return nil
        }

        let recognizer = NLLanguageRecognizer()
        recognizer.processString(combinedText)

        if let dominantLanguage = recognizer.dominantLanguage,
           let supportedLanguage = AllergenDisplayLanguage(naturalLanguage: dominantLanguage) {
            return supportedLanguage
        }

        let hypotheses = recognizer.languageHypotheses(withMaximum: 4)
        let bestSupportedLanguage = hypotheses
            .compactMap { language, confidence -> (AllergenDisplayLanguage, Double)? in
                guard let supportedLanguage = AllergenDisplayLanguage(naturalLanguage: language) else {
                    return nil
                }

                return (supportedLanguage, confidence)
            }
            .max { lhs, rhs in lhs.1 < rhs.1 }

        guard let bestSupportedLanguage, bestSupportedLanguage.1 >= 0.20 else {
            return nil
        }

        return bestSupportedLanguage.0
    }
}

extension AllergenDisplayLanguage {
    init?(naturalLanguage: NLLanguage) {
        switch naturalLanguage {
        case .english:
            self = .english
        case .french:
            self = .french
        case .spanish:
            self = .spanish
        case .german:
            self = .german
        case .italian:
            self = .italian
        case .portuguese:
            self = .portuguese
        case .dutch:
            self = .dutch
        case .polish:
            self = .polish
        default:
            return nil
        }
    }
}
