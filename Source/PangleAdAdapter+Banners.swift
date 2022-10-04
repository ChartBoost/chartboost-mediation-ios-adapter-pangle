//
//  PangleAdAdapter+Banners.swift
//  ChartboostHeliumAdapterPangle
//

import Foundation
import PAGAdSDK
import HeliumSdk

final class PangleBannerAdAdapter: PangleAdAdapter {

    /// Flag to indicate if the banner has loaded, to help report show success/failure.
    private var isLoaded: Bool = false

    /// Attempt to load an ad.
    /// - Parameters:
    ///   - viewController: The ViewController for ad presentation purposes.
    ///   - completion: The completion handler to notify Helium of ad load completion result.
    override func load(with viewController: UIViewController?, completion: @escaping (Result<PartnerAd, Error>) -> Void) {
        let size = PAGAdSize(size: request.size ?? IABStandardAdSize)
        let bannerRequest = PAGBannerRequest(bannerSize: size)
        DispatchQueue.main.async {
            PAGBannerAd.load(withSlotID: self.request.partnerPlacement, request: bannerRequest) { [weak self] ad, error in
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
    }

    /// Attempt to show the currently loaded ad.
    /// - Parameters:
    ///   - viewController: The ViewController for ad presentation purposes.
    ///   - completion: The completion handler to notify Helium of ad show completion result.
    override func show(with viewController: UIViewController, completion: @escaping (Result<PartnerAd, Error>) -> Void) {
        guard let ad = partnerAd.ad as? PAGBannerAd else {
            let error = error(.showFailure(partnerAd), description: "Ad instance is nil/not an PAGBannerAd.")
            return completion((.failure(error)))
        }

        guard let view = viewController.view else {
            let error = error(.showFailure(partnerAd), description: "viewcontroller does not have a root view.")
            return completion((.failure(error)))
        }

        showCompletion = completion

        ad.delegate = self
        ad.rootViewController = viewController

        let bannerView = ad.bannerView
        let size = request.size ?? IABStandardAdSize
        bannerView.frame = CGRect(
            x: (view.frame.size.width - size.width)/2,
            y: view.frame.size.height - size.height,
            width: size.width,
            height: size.height
        )
        view.addSubview(bannerView)
    }
}

extension PangleBannerAdAdapter: PAGBannerAdDelegate {
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
