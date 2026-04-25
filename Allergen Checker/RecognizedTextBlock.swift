import CoreGraphics
import Foundation

struct RecognizedTextBlock: Identifiable, Hashable {
    let id: UUID
    let text: String
    let confidence: Float
    let boundingBox: CGRect

    init(id: UUID = UUID(), text: String, confidence: Float, boundingBox: CGRect) {
        self.id = id
        self.text = text
        self.confidence = confidence
        self.boundingBox = boundingBox
    }
}

struct AllergenMatch: Identifiable, Hashable {
    let id: UUID
    let allergenName: String
    let matchedTerm: String
    let recognizedText: String
    let confidence: Float
    let boundingBox: CGRect

    init(
        id: UUID = UUID(),
        allergenName: String,
        matchedTerm: String,
        recognizedText: String,
        confidence: Float,
        boundingBox: CGRect
    ) {
        self.id = id
        self.allergenName = allergenName
        self.matchedTerm = matchedTerm
        self.recognizedText = recognizedText
        self.confidence = confidence
        self.boundingBox = boundingBox
    }
}
