import SwiftUI
import SwiftData
import UIKit

struct ScanResultView: View {
    @Environment(\.modelContext) private var modelContext

    let result: ScanResult
    var profileID: UUID? = nil
    var allowsSaving = true

    private let explanationService = LocalMatchExplanationService()

    @State private var isSaved = false
    @State private var saveError: String?

    private var hasMatches: Bool {
        !result.matches.isEmpty
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                statusCard

                safetyWarningCard

                ZoomableHighlightedImageView(
                    image: result.image,
                    matches: result.matches
                )
                .frame(maxWidth: .infinity)
                .frame(height: 360)
                .clipShape(RoundedRectangle(cornerRadius: 16))

                if hasMatches {
                    matchesSection
                }

                recognizedTextSection
            }
            .padding()
        }
        .alert("Could Not Save Scan", isPresented: Binding(
            get: { saveError != nil },
            set: { if !$0 { saveError = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(saveError ?? "The scan could not be saved.")
        }
    }

    private var statusCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(
                hasMatches ? String(localized: "Possible allergen found") : String(localized: "No saved allergens found"),
                systemImage: hasMatches ? "exclamationmark.triangle.fill" : "checkmark.shield.fill"
            )
            .font(.title3)
            .fontWeight(.semibold)
            .foregroundStyle(hasMatches ? .red : .green)

            Text(hasMatches
                 ? String(localized: "Review the highlighted label areas before deciding whether the product is safe for you.")
                 : String(localized: "No text matched your saved allergen names or aliases."))
                .foregroundStyle(.secondary)

            if allowsSaving {
                Button {
                    saveScan()
                } label: {
                    Label(isSaved ? String(localized: "Saved to History") : String(localized: "Save Scan to History"), systemImage: isSaved ? "checkmark.circle.fill" : "square.and.arrow.down")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(isSaved)
                .padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var safetyWarningCard: some View {
        Label {
            VStack(alignment: .leading, spacing: 6) {
                Text(SafetyDisclaimer.title)
                    .font(.headline)

                Text(SafetyDisclaimer.message)
                    .font(.subheadline)
            }
        } icon: {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.title2)
        }
        .foregroundStyle(.orange)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.orange.opacity(0.16), in: RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.orange, lineWidth: 1)
        }
        .accessibilityElement(children: .combine)
    }

    private func saveScan() {
        do {
            let entry = try ScanHistoryEntry(result: result, profileID: profileID)
            modelContext.insert(entry)
            try modelContext.save()
            isSaved = true
        } catch {
            saveError = error.localizedDescription
        }
    }

    private var matchesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Matches")
                .font(.headline)

            ForEach(result.matches) { match in
                VStack(alignment: .leading, spacing: 6) {
                    Text(match.allergenName)
                        .font(.headline)

                    Text(explanationService.explanation(for: match))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Text("Recognized text: \(match.recognizedText)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.red.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    private var recognizedTextSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recognized Text")
                .font(.headline)

            if result.textBlocks.isEmpty {
                Text("No ingredient text was recognized. Try another photo with better lighting and a straighter label.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(result.textBlocks) { block in
                    HStack(alignment: .top) {
                        Text(block.text)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Text("\(Int((block.confidence * 100).rounded()))%")
                            .font(.caption)
                            .foregroundStyle(block.confidence < 0.5 ? .orange : .secondary)
                    }
                    .font(.subheadline)
                    .padding(.vertical, 4)
                }
            }
        }
    }
}

private struct ZoomableHighlightedImageView: View {
    let image: UIImage
    let matches: [AllergenMatch]

    @State private var scale: CGFloat = 1
    @State private var lastScale: CGFloat = 1
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                HighlightedImageView(image: image, matches: matches)
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .scaleEffect(scale)
                    .offset(offset)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .contentShape(Rectangle())
            .clipped()
            .gesture(
                MagnificationGesture()
                    .onChanged { value in
                        scale = min(max(lastScale * value, 1), 6)
                    }
                    .onEnded { _ in
                        lastScale = scale
                        if scale == 1 {
                            offset = .zero
                            lastOffset = .zero
                        }
                    }
            )
            .simultaneousGesture(
                DragGesture()
                    .onChanged { value in
                        guard scale > 1 else {
                            return
                        }

                        offset = CGSize(
                            width: lastOffset.width + value.translation.width,
                            height: lastOffset.height + value.translation.height
                        )
                    }
                    .onEnded { _ in
                        lastOffset = offset
                    }
            )
            .onTapGesture(count: 2) {
                withAnimation {
                    scale = 1
                    lastScale = 1
                    offset = .zero
                    lastOffset = .zero
                }
            }
            .overlay(alignment: .bottomTrailing) {
                Label("Pinch to zoom", systemImage: "plus.magnifyingglass")
                    .font(.caption)
                    .padding(8)
                    .background(.regularMaterial, in: Capsule())
                    .padding(8)
            }
        }
    }
}

private struct HighlightedImageView: View {
    let image: UIImage
    let matches: [AllergenMatch]

    var body: some View {
        GeometryReader { proxy in
            let imageRect = fittedImageRect(imageSize: image.size, containerSize: proxy.size)

            ZStack(alignment: .topLeading) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: proxy.size.width, height: proxy.size.height)

                ForEach(matches) { match in
                    let highlightRect = convertVisionRect(match.boundingBox, in: imageRect)

                    RoundedRectangle(cornerRadius: 4)
                        .stroke(.red, lineWidth: 3)
                        .background(Color.red.opacity(0.18))
                        .frame(width: highlightRect.width, height: highlightRect.height)
                        .position(x: highlightRect.midX, y: highlightRect.midY)
                        .accessibilityLabel(Text("Highlighted match for \(match.allergenName)"))
                }
            }
        }
        .background(Color.black.opacity(0.06), in: RoundedRectangle(cornerRadius: 16))
    }

    private func fittedImageRect(imageSize: CGSize, containerSize: CGSize) -> CGRect {
        guard imageSize.width > 0, imageSize.height > 0, containerSize.width > 0, containerSize.height > 0 else {
            return .zero
        }

        let scale = min(containerSize.width / imageSize.width, containerSize.height / imageSize.height)
        let size = CGSize(width: imageSize.width * scale, height: imageSize.height * scale)
        let origin = CGPoint(
            x: (containerSize.width - size.width) / 2,
            y: (containerSize.height - size.height) / 2
        )

        return CGRect(origin: origin, size: size)
    }

    private func convertVisionRect(_ boundingBox: CGRect, in imageRect: CGRect) -> CGRect {
        CGRect(
            x: imageRect.minX + boundingBox.minX * imageRect.width,
            y: imageRect.minY + (1 - boundingBox.maxY) * imageRect.height,
            width: boundingBox.width * imageRect.width,
            height: boundingBox.height * imageRect.height
        )
    }
}
