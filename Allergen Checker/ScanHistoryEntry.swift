import CoreGraphics
import Foundation
import SwiftData
import UIKit

@Model
final class ScanHistoryEntry {
    var profileID: UUID? = nil
    var createdAt: Date = Date()
    @Attribute(.externalStorage) var imageData: Data = Data()
    var textBlocksData: Data = Data()
    var matchesData: Data = Data()
    var detectedLanguageCode: String = AllergenDisplayLanguage.english.rawValue
    var matchCount: Int = 0
    var recognizedTextPreview: String = ""

    init(result: ScanResult, profileID: UUID? = nil, createdAt: Date = Date()) throws {
        self.profileID = profileID
        self.createdAt = createdAt
        self.imageData = result.image.jpegData(compressionQuality: 0.9) ?? Data()
        self.textBlocksData = try JSONEncoder().encode(result.textBlocks.map(ScanTextBlockSnapshot.init))
        self.matchesData = try JSONEncoder().encode(result.matches.map(ScanMatchSnapshot.init))
        self.detectedLanguageCode = result.detectedLanguage.rawValue
        self.matchCount = result.matches.count
        self.recognizedTextPreview = result.textBlocks
            .map(\.text)
            .joined(separator: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func scanResult() throws -> ScanResult {
        guard let image = UIImage(data: imageData) else {
            throw ScanHistoryError.invalidImageData
        }

        let textBlocks = try recognizedTextBlocks()
        let matches = try JSONDecoder()
            .decode([ScanMatchSnapshot].self, from: matchesData)
            .map(\.allergenMatch)
        let detectedLanguage = AllergenDisplayLanguage(rawValue: detectedLanguageCode) ?? .english

        return ScanResult(image: image, textBlocks: textBlocks, matches: matches, detectedLanguage: detectedLanguage)
    }

    func rescan(using allergens: [Allergen]) throws {
        let textBlocks = try recognizedTextBlocks()
        let language = AllergenDisplayLanguage(rawValue: detectedLanguageCode)
            ?? AllergenScanLanguageDetector.detectLanguage(in: textBlocks)
            ?? .english
        let matches = AllergenMatcher.matches(in: textBlocks, allergens: allergens, detectedLanguage: language)

        matchesData = try JSONEncoder().encode(matches.map(ScanMatchSnapshot.init))
        detectedLanguageCode = language.rawValue
        matchCount = matches.count
    }

    private func recognizedTextBlocks() throws -> [RecognizedTextBlock] {
        try JSONDecoder()
            .decode([ScanTextBlockSnapshot].self, from: textBlocksData)
            .map(\.recognizedTextBlock)
    }
}

enum ScanHistoryError: LocalizedError {
    case invalidImageData

    var errorDescription: String? {
        "This saved scan image could not be loaded."
    }
}

private struct ScanTextBlockSnapshot: Codable {
    let id: UUID
    let text: String
    let confidence: Float
    let boundingBox: CodableRect

    init(_ block: RecognizedTextBlock) {
        self.id = block.id
        self.text = block.text
        self.confidence = block.confidence
        self.boundingBox = CodableRect(block.boundingBox)
    }

    var recognizedTextBlock: RecognizedTextBlock {
        RecognizedTextBlock(
            id: id,
            text: text,
            confidence: confidence,
            boundingBox: boundingBox.cgRect
        )
    }
}

private struct ScanMatchSnapshot: Codable {
    let id: UUID
    let allergenName: String
    let matchedTerm: String
    let recognizedText: String
    let confidence: Float
    let boundingBox: CodableRect

    init(_ match: AllergenMatch) {
        self.id = match.id
        self.allergenName = match.allergenName
        self.matchedTerm = match.matchedTerm
        self.recognizedText = match.recognizedText
        self.confidence = match.confidence
        self.boundingBox = CodableRect(match.boundingBox)
    }

    var allergenMatch: AllergenMatch {
        AllergenMatch(
            id: id,
            allergenName: allergenName,
            matchedTerm: matchedTerm,
            recognizedText: recognizedText,
            confidence: confidence,
            boundingBox: boundingBox.cgRect
        )
    }
}

private struct CodableRect: Codable {
    let x: Double
    let y: Double
    let width: Double
    let height: Double

    init(_ rect: CGRect) {
        self.x = rect.origin.x
        self.y = rect.origin.y
        self.width = rect.size.width
        self.height = rect.size.height
    }

    var cgRect: CGRect {
        CGRect(x: x, y: y, width: width, height: height)
    }
}
