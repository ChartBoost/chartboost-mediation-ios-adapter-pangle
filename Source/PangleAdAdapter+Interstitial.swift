//
//  PangleAdAdapter+Interstitial.swift
//  ChartboostHeliumAdapterPangle
//

import Foundation
import PAGAdSDK
import HeliumSdk

final class PangleInterstitialAdAdapter: PangleAdAdapter {

    /// Attempt to load an ad.
    /// - Parameters:
    ///   - viewController: The ViewController for ad presentation purposes.
    ///   - completion: The completion handler to notify Helium of ad load completion result.
    override func load(with viewController: UIViewController?, completion: @escaping (Result<PartnerAd, Error>) -> Void) {
        let interstitialRequest = PAGInterstitialRequest()
        PAGLInterstitialAd.load(withSlotID: request.partnerPlacement, request: interstitialRequest) { [weak self] ad, error in
            guard let self = self else { return }
            if let error = error {
                completion(.failure(error))
            }
            else {
                let partnerAd = PartnerAd(ad: ad, details: [:], request: self.request)
                self.partnerAd = partnerAd
                completion(.success(partnerAd))
            }
        }
    }

    /// Attempt to show the currently loaded ad.
    /// - Parameters:
    ///   - viewController: The ViewController for ad presentation purposes.
    ///   - completion: The completion handler to notify Helium of ad show completion result.
    override func show(with viewController: UIViewController, completion: @escaping (Result<PartnerAd, Error>) -> Void) {
        guard let ad = partnerAd.ad as? PAGLInterstitialAd else {
            let error = error(.showFailure(partnerAd), description: "Ad instance is nil/not an PAGLInterstitialAd.")
            return completion((.failure(error)))
        }

        showCompletion = completion

        ad.delegate = self
        ad.present(fromRootViewController: viewController)
    }
}

extension PangleInterstitialAdAdapter: PAGLInterstitialAdDelegate {
    func adDidShow(_ ad: PAGAdProtocol) {
        showCompletion?(.success(partnerAd)) ?? log(.showResultIgnored)
        showCompletion = nil
    }

    func adDidClick(_ ad: PAGAdProtocol) {
        log(.didClick(partnerAd, error: nil))
        partnerAdDelegate?.didClick(partnerAd) ?? log(.delegateUnavailable)
    }

    func adDidDismiss(_ ad: PAGAdProtocol) {
        log(.didDismiss(partnerAd, error: nil))
        partnerAdDelegate?.didDismiss(partnerAd, error: nil) ?? log(.delegateUnavailable)
    }
}
