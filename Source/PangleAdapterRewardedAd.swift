//
//  PangleAdapterRewardedAd.swift
//  ChartboostHeliumAdapterPangle
//

import Foundation
import PAGAdSDK
import HeliumSdk

/// The Helium Pangle adapter rewarded ad.
final class PangleAdapterRewardedAd: PangleAdapterAd, PartnerAd {
    
    /// The partner ad view to display inline. E.g. a banner view.
    /// Should be nil for full-screen ads.
    var inlineView: UIView? { nil }
    
    /// The Pangle SDK ad instance.
    private var ad: PAGRewardedAd?
    
    /// Loads an ad.
    /// - parameter viewController: The view controller on which the ad will be presented on. Needed on load for some banners.
    /// - parameter completion: Closure to be performed once the ad has been loaded.
    func load(with viewController: UIViewController?, completion: @escaping (Result<PartnerEventDetails, Error>) -> Void) {
        log(.loadStarted)
        
        PAGRewardedAd.load(withSlotID: request.partnerPlacement, request: PAGRewardedRequest()) { [weak self] ad, partnerError in
            guard let self = self else { return }
            if let ad = ad, partnerError == nil {   // It's possible that an error occurs, the ad cannot be shown, and yet `ad` is not nil
                ad.delegate = self
                self.ad = ad
                self.log(.loadSucceeded)
                completion(.success([:]))
            } else {
                let error = self.error(.loadFailureException, error: partnerError)
                self.log(.loadFailed(error))
                completion(.failure(error))
            }
        }
    }
    
    /// Shows a loaded ad.
    /// It will never get called for banner ads. You may leave the implementation blank for that ad format.
    /// - parameter viewController: The view controller on which the ad will be presented on.
    /// - parameter completion: Closure to be performed once the ad has been shown.
    func show(with viewController: UIViewController, completion: @escaping (Result<PartnerEventDetails, Error>) -> Void) {
        log(.showStarted)
        
        // Fail early if no ad is loaded
        guard let ad = ad else {
            let error = error(.showFailureAdNotReady)
            log(.showFailed(error))
            return completion(.failure(error))
        }
        
        showCompletion = completion
        
        ad.delegate = self
        ad.present(fromRootViewController: viewController)
    }
}

extension PangleAdapterRewardedAd: PAGRewardedAdDelegate {
    
    func adDidShow(_ ad: PAGAdProtocol) {
        log(.showSucceeded)
        showCompletion?(.success([:])) ?? log(.showResultIgnored)
        showCompletion = nil
    }
    
    func adDidClick(_ ad: PAGAdProtocol) {
        log(.didClick(error: nil))
        delegate?.didClick(self, details: [:]) ?? log(.delegateUnavailable)
    }
    
    func adDidDismiss(_ ad: PAGAdProtocol) {
        log(.didDismiss(error: nil))
        delegate?.didDismiss(self, details: [:], error: nil) ?? log(.delegateUnavailable)
    }
    
    func rewardedAd(_ rewardedAd: PAGRewardedAd, userDidEarnReward rewardModel: PAGRewardModel) {
        log(.didReward)
        delegate?.didReward(self, details: [:]) ?? log(.delegateUnavailable)
    }
}
