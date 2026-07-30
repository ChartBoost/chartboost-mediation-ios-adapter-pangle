// Copyright 2022-2026 Chartboost, Inc.
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file.

import ChartboostMediationSDK
import Foundation
import PAGAdSDK

/// The Chartboost Mediation Pangle adapter rewarded ad.
final class PangleAdapterRewardedAd: PangleAdapterAd, PartnerFullscreenAd {
    /// The Pangle SDK ad instance.
    private var ad: PAGRewardedAd?

    /// Loads an ad.
    /// - parameter viewController: The view controller on which the ad will be presented on. Needed on load for some banners.
    /// - parameter completion: Closure to be performed once the ad has been loaded.
    func load(with viewController: UIViewController?, completion: @escaping (Error?) -> Void) {
        log(.loadStarted)

        PAGRewardedAd.load(withSlotID: request.partnerPlacement, request: PAGRewardedRequest()) { [weak self] ad, partnerError in
            guard let self else { return }
            if let ad, partnerError == nil {   // It's possible that an error occurs, the ad cannot be shown, and yet `ad` is not nil
                ad.delegate = self
                self.ad = ad
                self.log(.loadSucceeded)
                completion(nil)
            } else {
                let error = partnerError ?? self.error(.loadFailureUnknown)
                self.log(.loadFailed(error))
                completion(error)
            }
        }
    }

    /// Shows a loaded ad.
    /// Chartboost Mediation SDK will always call this method from the main thread.
    /// - parameter viewController: The view controller on which the ad will be presented on.
    /// - parameter completion: Closure to be performed once the ad has been shown.
    func show(with viewController: UIViewController, completion: @escaping (Error?) -> Void) {
        log(.showStarted)

        // Fail early if no ad is loaded
        guard let ad else {
            let error = error(.showFailureAdNotReady)
            log(.showFailed(error))
            completion(error)
            return
        }

        showCompletion = completion

        ad.delegate = self
        ad.present(fromRootViewController: viewController)
    }
}

extension PangleAdapterRewardedAd: PAGRewardedAdDelegate {
    func adDidShow(_ ad: PAGAdProtocol) {
        log(.showSucceeded)
        showCompletion?(nil) ?? log(.showResultIgnored)
        showCompletion = nil
    }

    func adDidClick(_ ad: PAGAdProtocol) {
        log(.didClick(error: nil))
        delegate?.didClick(self) ?? log(.delegateUnavailable)
    }

    func adDidDismiss(_ ad: PAGAdProtocol) {
        log(.didDismiss(error: nil))
        delegate?.didDismiss(self, error: nil) ?? log(.delegateUnavailable)
    }

    func rewardedAd(_ rewardedAd: PAGRewardedAd, userDidEarnReward rewardModel: PAGRewardModel) {
        log(.didReward)
        delegate?.didReward(self) ?? log(.delegateUnavailable)
    }
}
