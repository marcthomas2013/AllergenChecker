import AudioToolbox
import PhotosUI
import SwiftData
import SwiftUI
import UIKit

struct ScanView: View {
    @EnvironmentObject private var adsService: AdsService
    @AppStorage("selectedAllergyProfileID") private var selectedProfileID = AllergyProfileOption.defaultID
    @AppStorage(ScanFeedbackSoundCatalog.positiveStorageKey) private var positiveSoundOptionID = ScanFeedbackSoundCatalog.defaultPositiveOptionID
    @AppStorage(ScanFeedbackSoundCatalog.negativeStorageKey) private var negativeSoundOptionID = ScanFeedbackSoundCatalog.defaultNegativeOptionID

    @Query(sort: \AllergyProfile.name) private var profiles: [AllergyProfile]
    @Query(sort: \Allergen.name) private var allergens: [Allergen]

    @State private var selectedPhoto: PhotosPickerItem?
    @State private var isAddingAllergen = false
    @State private var isShowingCamera = false
    @State private var isScanning = false
    @State private var scanResult: ScanResult?
    @State private var errorMessage: String?

    private let ocrService = OCRService()

    private var selectedProfile: AllergyProfileOption {
        AllergyProfileSelection.selectedOption(storedID: selectedProfileID, profiles: profiles)
    }

    private var selectedProfileUUID: UUID? {
        selectedProfile.profileID
    }

    private var profileAllergens: [Allergen] {
        allergens.filter { $0.profileID == selectedProfileUUID }
    }

    var body: some View {
        NavigationStack {
            Group {
                if profileAllergens.isEmpty {
                    noAllergensView
                } else if let scanResult {
                    ScanResultView(result: scanResult, profileID: selectedProfileUUID)
                } else {
                    scanPrompt
                }
            }
            .navigationTitle("Scan Label")
            .toolbar {
                if scanResult != nil {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("New Scan") {
                            self.scanResult = nil
                            selectedPhoto = nil
                            errorMessage = nil
                        }
                    }
                }

                ToolbarItem(placement: .principal) {
                    AllergyProfilePicker(profiles: profiles, selectedProfileID: $selectedProfileID)
                        .disabled(scanResult != nil)
                }
            }
            .overlay {
                if isScanning {
                    ZStack {
                        Color.black.opacity(0.2)
                            .ignoresSafeArea()

                        ProgressView("Scanning ingredients...")
                            .padding()
                            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                    }
                }
            }
            .alert("Scan Failed", isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage ?? "Something went wrong while scanning the image.")
            }
            .sheet(isPresented: $isShowingCamera) {
                ImagePicker(sourceType: .camera) { image in
                    scan(image)
                }
            }
            .sheet(isPresented: $isAddingAllergen) {
                NavigationStack {
                    AllergenEditorView(profileID: selectedProfileUUID)
                }
            }
            .onChange(of: selectedPhoto) { _, newValue in
                guard let newValue else {
                    return
                }

                Task {
                    await loadAndScanPhoto(newValue)
                }
            }
        }
    }

    private var noAllergensView: some View {
        VStack(spacing: 20) {
            ContentUnavailableView(
                "Add Allergens First",
                systemImage: "list.bullet.clipboard",
                description: Text("Save the ingredients \(selectedProfile.name) needs to avoid before scanning a label.")
            )

            Button {
                isAddingAllergen = true
            } label: {
                Label("Add Allergen", systemImage: "plus")
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }

    private var scanPrompt: some View {
        VStack(spacing: 24) {
            Image(systemName: "text.viewfinder")
                .font(.system(size: 64))
                .foregroundStyle(.tint)

            VStack(spacing: 8) {
                Text("Scan an ingredient label")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Choose a clear photo or take one now. The app will extract text on device and compare it with \(selectedProfile.name)'s saved allergens.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 12) {
                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                    Label("Choose Photo", systemImage: "photo")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                Button {
                    isShowingCamera = true
                } label: {
                    Label("Take Photo", systemImage: "camera")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .disabled(!UIImagePickerController.isSourceTypeAvailable(.camera))
            }
            .controlSize(.large)

            allergenSearchSummary
        }
        .padding()
    }

    private var allergenSearchSummary: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Searching for", systemImage: "magnifyingglass")
                .font(.headline)

            Text(searchSummaryText)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var searchSummaryText: String {
        profileAllergens
            .map { allergen in
                if allergen.aliases.isEmpty {
                    return allergen.name
                }

                return "\(allergen.name) (\(allergen.aliases.joined(separator: ", ")))"
            }
            .joined(separator: "; ")
    }

    private func loadAndScanPhoto(_ item: PhotosPickerItem) async {
        do {
            guard let data = try await item.loadTransferable(type: Data.self),
                  let image = UIImage(data: data) else {
                throw OCRServiceError.missingCGImage
            }

            scan(image)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func scan(_ image: UIImage) {
        isScanning = true
        errorMessage = nil

        Task {
            do {
                let textBlocks = try await ocrService.recognizeText(in: image)
                let matches = AllergenMatcher.matches(in: textBlocks, allergens: profileAllergens)

                scanResult = ScanResult(
                    image: image,
                    textBlocks: textBlocks,
                    matches: matches
                )
                playFeedback(for: matches)
                adsService.registerCompletedScanAndPresentInterstitialIfNeeded()
            } catch {
                errorMessage = error.localizedDescription
            }

            isScanning = false
        }
    }

    private func playFeedback(for matches: [AllergenMatch]) {
        let feedbackGenerator = UINotificationFeedbackGenerator()
        feedbackGenerator.prepare()

        if matches.isEmpty {
            let positiveSound = ScanFeedbackSoundCatalog.positiveOption(for: positiveSoundOptionID)
            ScanFeedbackPlayer.play(positiveSound)
            feedbackGenerator.notificationOccurred(.success)
        } else {
            let negativeSound = ScanFeedbackSoundCatalog.negativeOption(for: negativeSoundOptionID)
            ScanFeedbackPlayer.play(negativeSound)
            feedbackGenerator.notificationOccurred(.warning)
        }
    }
}

struct ScanResult {
    let image: UIImage
    let textBlocks: [RecognizedTextBlock]
    let matches: [AllergenMatch]
}

#Preview {
    ScanView()
        .modelContainer(for: [AllergyProfile.self, Allergen.self, ScanHistoryEntry.self], inMemory: true)
}
