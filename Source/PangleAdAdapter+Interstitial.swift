//
//  PangleAdAdapter+Interstitial.swift
//  ChartboostHeliumAdapterPangle
//

import Foundation
import BUAdSDK
import HeliumSdk

final class PangleInterstitialAdAdapter: PangleAdAdapter {

    /// Attempt to load an ad.
    /// - Parameters:
    ///   - viewController: The ViewController for ad presentation purposes.
    ///   - completion: The completion handler to notify Helium of ad load completion result.
    override func load(with viewController: UIViewController?, completion: @escaping (Result<PartnerAd, Error>) -> Void) {
        loadCompletion = completion

        let ad = BUFullscreenVideoAd(slotID: request.partnerPlacement)
        ad.delegate = self
        partnerAd = PartnerAd(ad: ad, details: [:], request: request)
        ad.loadData()
    }

    /// Attempt to show the currently loaded ad.
    /// - Parameters:
    ///   - viewController: The ViewController for ad presentation purposes.
    ///   - completion: The completion handler to notify Helium of ad show completion result.
    override func show(with viewController: UIViewController, completion: @escaping (Result<PartnerAd, Error>) -> Void) {
        guard let ad = partnerAd.ad as? BUFullscreenVideoAd else {
            let error = error(.showFailure(partnerAd), description: "Ad instance is nil/not an BUFullscreenVideoAd.")
            return completion((.failure(error)))
        }

        showCompletion = completion
        ad.show(fromRootViewController: viewController)
    }
}

extension PangleInterstitialAdAdapter: BUFullscreenVideoAdDelegate {

    func fullscreenVideoMaterialMetaAdDidLoad(_ fullscreenVideoAd: BUFullscreenVideoAd) {
        loadCompletion?(.success(partnerAd)) ?? log(.loadResultIgnored)
        loadCompletion = nil
    }

    func fullscreenVideoAd(_ fullscreenVideoAd: BUFullscreenVideoAd, didFailWithError error: Error?) {
        let error = self.error(.loadFailure(request), error: error)
        loadCompletion?(.failure(error)) ?? log(.loadResultIgnored)
        loadCompletion = nil
    }

    func fullscreenVideoAdDidVisible(_ fullscreenVideoAd: BUFullscreenVideoAd) {
        showCompletion?(.success(partnerAd)) ?? log(.showResultIgnored)
        showCompletion = nil
    }

    func fullscreenVideoAdDidPlayFinish(_ fullscreenVideoAd: BUFullscreenVideoAd, didFailWithError error: Error?) {
        guard let error = error else {
            return
        }
        showCompletion?(.failure(error)) ?? log(.loadResultIgnored)
        showCompletion = nil
    }

    func fullscreenVideoAdDidClose(_ fullscreenVideoAd: BUFullscreenVideoAd) {
        log(.didDismiss(partnerAd, error: nil))
        partnerAdDelegate?.didDismiss(partnerAd, error: nil) ?? log(.delegateUnavailable)
    }

    func fullscreenVideoAdDidClick(_ fullscreenVideoAd: BUFullscreenVideoAd) {
        log(.didClick(partnerAd, error: nil))
        partnerAdDelegate?.didClick(partnerAd) ?? log(.delegateUnavailable)
    }
}
