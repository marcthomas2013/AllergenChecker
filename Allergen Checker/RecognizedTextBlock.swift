import CoreGraphics
import Foundation

struct RecognizedTextBlock: Identifiable, Hashable {
    let id = UUID()
    let text: String
    let confidence: Float
    let boundingBox: CGRect
}

struct AllergenMatch: Identifiable, Hashable {
    let id = UUID()
    let allergenName: String
    let matchedTerm: String
    let recognizedText: String
    let confidence: Float
    let boundingBox: CGRect
}
