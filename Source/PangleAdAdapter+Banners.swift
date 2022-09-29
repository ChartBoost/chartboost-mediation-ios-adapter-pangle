//
//  PangleAdAdapter+Banners.swift
//  ChartboostHeliumAdapterPangle
//

import Foundation
import BUAdSDK
import HeliumSdk

final class PangleBannerAdAdapter: PangleAdAdapter {

    /// Flag to indicate if the banner has loaded, to help report show success/failure.
    private var isLoaded: Bool = false

    /// Attempt to load an ad.
    /// - Parameters:
    ///   - viewController: The ViewController for ad presentation purposes.
    ///   - completion: The completion handler to notify Helium of ad load completion result.
    override func load(with viewController: UIViewController?, completion: @escaping (Result<PartnerAd, Error>) -> Void) {
        loadCompletion = completion

        let request = self.request
        let size = request.size ?? IABStandardAdSize
        let viewController = viewController ?? UIViewController()
        DispatchQueue.main.async {
            let ad = BUNativeExpressBannerView(slotID: request.partnerPlacement, rootViewController: viewController, adSize: size)
            ad.frame = CGRect(origin: .zero, size: size)
            ad.delegate = self
            self.partnerAd = PartnerAd(ad: ad, details: [:], request: request)
            ad.loadAdData()
        }
    }

    /// Attempt to show the currently loaded ad.
    /// - Parameters:
    ///   - viewController: The ViewController for ad presentation purposes.
    ///   - completion: The completion handler to notify Helium of ad show completion result.
    override func show(with viewController: UIViewController, completion: @escaping (Result<PartnerAd, Error>) -> Void) {
        completion(.success(partnerAd))
    }
}

extension PangleBannerAdAdapter: BUNativeExpressBannerViewDelegate {

    func nativeExpressBannerAdViewDidLoad(_ bannerAdView: BUNativeExpressBannerView) {
        loadCompletion?(.success(partnerAd)) ?? log(.loadResultIgnored)
        loadCompletion = nil
    }

    func nativeExpressBannerAdView(_ bannerAdView: BUNativeExpressBannerView, didLoadFailWithError error: Error?) {
        let error = self.error(.loadFailure(request), error: error)
        loadCompletion?(.failure(error)) ?? log(.loadResultIgnored)
        loadCompletion = nil
    }

    func nativeExpressBannerAdViewDidClick(_ bannerAdView: BUNativeExpressBannerView) {
        log(.didClick(partnerAd, error: nil))
        partnerAdDelegate?.didClick(partnerAd) ?? log(.delegateUnavailable)
    }
}
