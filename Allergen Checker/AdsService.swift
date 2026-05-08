import Combine
import SwiftUI
import UIKit

#if canImport(GoogleMobileAds)
import GoogleMobileAds
#endif

@MainActor
final class AdsService: ObservableObject {
    @Published private(set) var showsAds = true

    private let scansPerInterstitial = 5
    private let interstitialCounterKey = "ads.interstitialScanCounter"

#if canImport(GoogleMobileAds)
    private var interstitialAd: InterstitialAd?
#endif

    func setAdsEnabled(_ enabled: Bool) {
        showsAds = enabled

        if !enabled {
            UserDefaults.standard.set(0, forKey: interstitialCounterKey)
        }
    }

    func configureOnLaunch() {
#if canImport(GoogleMobileAds)
        MobileAds.shared.start(completionHandler: nil)
        Task {
            await loadInterstitialAd()
        }
#endif
    }

    func registerCompletedScanAndPresentInterstitialIfNeeded() {
        guard showsAds else {
            return
        }

        let currentValue = UserDefaults.standard.integer(forKey: interstitialCounterKey) + 1
        UserDefaults.standard.set(currentValue, forKey: interstitialCounterKey)

        guard currentValue >= scansPerInterstitial else {
            return
        }

        UserDefaults.standard.set(0, forKey: interstitialCounterKey)

#if canImport(GoogleMobileAds)
        presentInterstitialIfReady()
#endif
    }

#if canImport(GoogleMobileAds)
    func loadInterstitialAd() async {
        guard showsAds else {
            return
        }

        do {
            interstitialAd = try await InterstitialAd.load(
                with: MonetizationConfig.Ads.interstitialUnitID,
                request: Request()
            )
        } catch {
            interstitialAd = nil
        }
    }

    private func presentInterstitialIfReady() {
        guard showsAds else {
            return
        }

        guard let interstitialAd, let rootViewController = UIApplication.shared.topMostViewController() else {
            Task {
                await loadInterstitialAd()
            }
            return
        }

        interstitialAd.present(from: rootViewController)
        self.interstitialAd = nil

        Task {
            await loadInterstitialAd()
        }
    }
#endif
}

struct AdsBannerContainer: View {
    @EnvironmentObject private var adsService: AdsService

    var body: some View {
        if adsService.showsAds {
#if canImport(GoogleMobileAds)
            BannerAdView(adUnitID: MonetizationConfig.Ads.bannerUnitID)
                .frame(height: 50)
#else
            EmptyView()
#endif
        }
    }
}

#if canImport(GoogleMobileAds)
private struct BannerAdView: UIViewRepresentable {
    let adUnitID: String

    func makeUIView(context: Context) -> BannerView {
        let view = BannerView(adSize: AdSizeBanner)
        view.adUnitID = adUnitID
        view.rootViewController = UIApplication.shared.topMostViewController()
        view.load(Request())
        return view
    }

    func updateUIView(_ uiView: BannerView, context: Context) {
        uiView.rootViewController = UIApplication.shared.topMostViewController()
    }
}
#endif

private extension UIApplication {
    func topMostViewController(
        base: UIViewController? = UIApplication.shared
            .connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first(where: \.isKeyWindow)?
            .rootViewController
    ) -> UIViewController? {
        if let navigationController = base as? UINavigationController {
            return topMostViewController(base: navigationController.visibleViewController)
        }

        if let tabBarController = base as? UITabBarController {
            return topMostViewController(base: tabBarController.selectedViewController)
        }

        if let presented = base?.presentedViewController {
            return topMostViewController(base: presented)
        }

        return base
    }
}
