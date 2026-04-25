# Allergen Checker

Allergen Checker is an iOS app for keeping a personal list of ingredients you are allergic to and scanning ingredient labels for possible matches.

The app stores your allergens on device, uses Apple Vision to extract text from ingredient label photos, and highlights any matched allergen text on the scanned image.

## Features

- Maintain a personal allergen list.
- Add, edit, delete, and search allergens.
- Store aliases or related ingredient names for each allergen.
- Scan ingredient labels from the camera or photo library.
- Run on-device OCR using Apple Vision.
- Match recognized ingredient text against saved allergen names and aliases.
- Show possible allergen warnings with recognized text snippets and OCR confidence.
- Highlight matched text areas on the scanned image.

## How It Works

1. Add allergens in the `Allergens` tab.
2. Include aliases for ingredient names that should also trigger a warning, such as `whey` or `casein` for milk.
3. Open the `Scan` tab.
4. Take a photo of an ingredient label or choose one from the photo library.
5. The app extracts text from the image on device.
6. The matcher compares recognized text with saved allergen names and aliases.
7. If a match is found, the app shows a warning and highlights the matched OCR region on the image.

The app treats results as possible matches, not medical certainty. OCR quality depends on lighting, focus, label angle, and text clarity.

## Architecture

The app is built with SwiftUI and SwiftData.

- `Allergen.swift`: SwiftData model for saved allergens, aliases, notes, and timestamps.
- `AllergenListView.swift`: allergen list, search, deletion, and navigation.
- `AllergenEditorView.swift`: form for creating and editing allergens.
- `ScanView.swift`: camera/photo input and scan orchestration.
- `ImagePicker.swift`: camera wrapper around `UIImagePickerController`.
- `OCRService.swift`: Apple Vision text recognition.
- `RecognizedTextBlock.swift`: OCR text and match result data structures.
- `AllergenMatcher.swift`: text normalization, alias matching, whole-term matching, and duplicate suppression.
- `MatchExplanationService.swift`: local explanation text for each match.
- `ScanResultView.swift`: scan result summary, recognized text, and image highlight overlay.

## Privacy

All allergen storage, OCR, and matching currently happen on device. The app does not require a server or cloud OCR service for the MVP.

The app requests camera and photo library access only so it can scan ingredient label images.

## Development

Open the project in Xcode:

```sh
open "Allergen Checker.xcodeproj"
```

Build from the command line:

```sh
xcodebuild -project "Allergen Checker.xcodeproj" -scheme "Allergen Checker" -destination 'generic/platform=iOS Simulator' build
```

Run unit tests:

```sh
xcodebuild test -project "Allergen Checker.xcodeproj" -scheme "Allergen Checker" -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.4' -only-testing:"Allergen CheckerTests"
```

## Current Limitations

- Matching is based on saved allergen names and aliases, not a medical ingredient database.
- Highlight boxes depend on Vision OCR bounding boxes and may be imprecise on curved, blurry, or angled labels.
- The camera path must be tested on a physical device because simulator camera support is limited.
- AI-style ingredient interpretation is not connected to a cloud service yet, but the explanation/matching layer is separated so it can be extended later.
