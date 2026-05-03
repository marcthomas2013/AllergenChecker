---
layout: default
title: Allergen Checker
---

<style>
  .hero {
    padding: 2rem;
    border-radius: 24px;
    background: linear-gradient(135deg, #f1f7ff 0%, #fff8f0 100%);
    border: 1px solid #e6edf5;
    margin: 1.5rem 0 2rem;
  }

  .hero h1 {
    margin-top: 0;
    font-size: clamp(2.25rem, 8vw, 4.5rem);
    letter-spacing: -0.06em;
    line-height: 0.95;
  }

  .hero p {
    max-width: 48rem;
    font-size: 1.15rem;
    color: #394150;
  }

  .button-row {
    display: flex;
    flex-wrap: wrap;
    gap: 0.75rem;
    margin-top: 1.25rem;
  }

  .button {
    display: inline-block;
    padding: 0.75rem 1rem;
    border-radius: 999px;
    font-weight: 700;
    text-decoration: none;
    border: 1px solid #ccd7e2;
  }

  .button.primary {
    background: #0a66c2;
    border-color: #0a66c2;
    color: white;
  }

  .button.secondary {
    background: white;
    color: #17324d;
  }

  .grid {
    display: grid;
    gap: 1rem;
    grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
    margin: 1.25rem 0 2rem;
  }

  .card {
    padding: 1rem;
    border: 1px solid #e5e7eb;
    border-radius: 18px;
    background: #fff;
    box-shadow: 0 10px 30px rgba(15, 23, 42, 0.06);
  }

  .card h3 {
    margin-top: 0;
  }

  .screenshot-grid {
    display: grid;
    gap: 1rem;
    grid-template-columns: repeat(auto-fit, minmax(210px, 1fr));
    margin: 1.25rem 0 2rem;
  }

  figure {
    margin: 0;
  }

  figure img {
    width: 100%;
    border-radius: 24px;
    border: 1px solid #d9e2ec;
    box-shadow: 0 18px 45px rgba(15, 23, 42, 0.14);
    background: #f8fafc;
  }

  figcaption {
    margin-top: 0.65rem;
    color: #52606d;
    font-size: 0.95rem;
  }

  .notice {
    padding: 1rem;
    border-radius: 16px;
    border: 1px solid #f6c56f;
    background: #fff8e8;
  }
</style>

<section class="hero">
  <p><strong>Allergen Checker for iPhone</strong></p>
  <h1>Check ingredient labels against the foods and additives you need to avoid.</h1>
  <p>
    Allergen Checker helps you save a personal allergy profile, scan a product label with the camera or photo library, and review possible matches highlighted directly on the label image.
  </p>
  <div class="button-row">
    <a class="button primary" href="#screenshots">View screenshots</a>
    <a class="button secondary" href="privacy-policy.html">Read privacy policy</a>
  </div>
</section>

## Why It Is Useful

Reading ingredient labels can be slow, especially when names vary between products, countries, and brands. Allergen Checker gives you a focused second pass: it compares recognised label text with the allergens, related ingredients, and aliases you have saved for yourself or someone you shop for.

It is designed for everyday moments like checking a new snack, reviewing a product while travelling, keeping separate allergy lists for different people, or saving a scan so you can look again later.

<div class="grid">
  <div class="card">
    <h3>Faster label checks</h3>
    <p>Scan a clear photo of an ingredient label and let on-device text recognition find possible matches.</p>
  </div>
  <div class="card">
    <h3>Personal allergy profiles</h3>
    <p>Save allergens, aliases, related ingredients, and notes for different people.</p>
  </div>
  <div class="card">
    <h3>Useful for travel</h3>
    <p>Show a simple "My Allergies" list and translate supported allergen names into French, Spanish, German, Italian, Portuguese, Dutch, or Polish.</p>
  </div>
  <div class="card">
    <h3>Private by design</h3>
    <p>Allergen storage, label OCR, matching, and scan history currently happen on device.</p>
  </div>
</div>

## How The App Works

1. Add the allergens or ingredients you need to avoid.
2. Add aliases that should also trigger a warning, such as `whey` or `casein` for milk.
3. Take a photo of a product label or choose one from your photo library.
4. The app extracts label text on device using Apple Vision.
5. Recognised text is compared with your saved allergen names and aliases.
6. Possible matches are shown in a result summary and highlighted on the scanned image.
7. Save useful scans to history and rescan them later against the person's current allergy list.

## Screenshots

A quick tour of the app's main screens, using the App Store screenshots from `docs/AppStoreScreens/iPhone17ProMax/`.

<div id="screenshots" class="screenshot-grid">
  <figure>
    <img src="AppStoreScreens/iPhone17ProMax/ScanLabel.png" alt="Allergen Checker scan label screen">
    <figcaption><strong>Scan labels:</strong> choose a photo or use the camera to scan ingredients.</figcaption>
  </figure>
  <figure>
    <img src="AppStoreScreens/iPhone17ProMax/ScanResult.png" alt="Allergen Checker possible allergen match result">
    <figcaption><strong>Review matches:</strong> possible allergens are called out and highlighted on the label.</figcaption>
  </figure>
  <figure>
    <img src="AppStoreScreens/iPhone17ProMax/AllergySetup.png" alt="Allergen Checker saved allergen setup screen">
    <figcaption><strong>Build your list:</strong> save allergens, aliases, notes, and related ingredients.</figcaption>
  </figure>
  <figure>
    <img src="AppStoreScreens/iPhone17ProMax/MyAllergies.png" alt="Allergen Checker allergy summary list">
    <figcaption><strong>Show your allergies:</strong> keep a clear list ready for travel, restaurants, or shopping.</figcaption>
  </figure>
  <figure>
    <img src="AppStoreScreens/iPhone17ProMax/MyAllergiesFrench.png" alt="Allergen Checker allergy list translated into French">
    <figcaption><strong>Translate for travel:</strong> show supported allergen names in another language when you need to explain what to avoid.</figcaption>
  </figure>
  <figure>
    <img src="AppStoreScreens/iPhone17ProMax/ScanResult-2.png" alt="Allergen Checker scan result detail screen">
    <figcaption><strong>Save and review:</strong> keep useful scans in history so you can revisit the recognised text and matches later.</figcaption>
  </figure>
</div>

## Main Features

- Scan ingredient labels using the camera or photo library.
- Use on-device text recognition for ingredient labels.
- Highlight possible allergen matches on the scanned image.
- Save allergens, related ingredients, aliases, and notes.
- Quick add common UK and EU major allergens.
- Quick add E-number ingredients and additives.
- Create and manage allergy profiles for different people.
- Save scan results to history for later review.
- Rescan saved history using the person's current allergens.
- Translate allergy lists into supported languages for travel.

## Built For Real-World Checking

Allergen Checker is useful because it understands that allergy checking is personal. One person may need to avoid milk, while another also wants aliases like `whey`, `casein`, or a specific additive to trigger a warning. The app keeps those saved terms close at hand, then applies them consistently whenever you scan.

The history feature also helps when a label needs a closer look later. Saved scans include the image, recognised text, possible matches, and scan date, and they can be rescanned when someone's allergy list changes.

## Privacy And Safety

Allergen Checker does not require a developer-operated server. Saved allergy profiles, allergens, aliases, notes, scan images, recognised text, and history are stored locally on your device.

<div class="notice">
  <strong>Important safety notice:</strong> Allergen Checker is a helpful aid, not a medical device and not a guarantee that results are complete or accurate. Always check product packaging, ingredient information, and allergen advice carefully before deciding whether a product is safe for you.
</div>

For more detail, read the [privacy policy](privacy-policy.html).
