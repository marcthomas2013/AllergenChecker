import Foundation

enum MonetizationConfig {
    enum Subscription {
        // Replace these with your App Store Connect product identifiers.
        static let monthlyProductID = "uk.co.thethomashouse.allergenchecker.adremoval.monthly"
        static let annualProductID = "uk.co.thethomashouse.allergenchecker.removeads.annual"
        static let productIDs: Set<String> = [monthlyProductID, annualProductID]
    }

    enum Ads {
        // Test ad units from Google. Replace before production release.
        static let appID = "ca-app-pub-3940256099942544~1458002511"
        static let bannerUnitID = "ca-app-pub-3940256099942544/2435281174"
        static let interstitialUnitID = "ca-app-pub-3940256099942544/4411468910"
    }
}
