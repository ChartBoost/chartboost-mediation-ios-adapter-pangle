//
//  PangleAdAdapter+Rewarded.swift
//  ChartboostHeliumAdapterPangle
//

import Foundation
import BUAdSDK
import HeliumSdk

final class PangleRewardedAdAdapter: PangleAdAdapter {

    /// Attempt to load an ad.
    /// - Parameters:
    ///   - viewController: The ViewController for ad presentation purposes.
    ///   - completion: The completion handler to notify Helium of ad load completion result.
    override func load(with viewController: UIViewController?, completion: @escaping (Result<PartnerAd, Error>) -> Void) {
        loadCompletion = completion

        let model = BURewardedVideoModel()
        let ad = BURewardedVideoAd(slotID: request.partnerPlacement, rewardedVideoModel: model)
        ad.delegate = self
        partnerAd = PartnerAd(ad: ad, details: [:], request: request)
        ad.loadData()
    }

    /// Attempt to show the currently loaded ad.
    /// - Parameters:
    ///   - viewController: The ViewController for ad presentation purposes.
    ///   - completion: The completion handler to notify Helium of ad show completion result.
    override func show(with viewController: UIViewController, completion: @escaping (Result<PartnerAd, Error>) -> Void) {
        guard let ad = partnerAd.ad as? BURewardedVideoAd else {
            let error = error(.showFailure(partnerAd), description: "Ad instance is nil/not an BURewardedVideoAd.")
            return completion((.failure(error)))
        }

        showCompletion = completion
        ad.show(fromRootViewController: viewController)
    }
}

extension PangleRewardedAdAdapter: BURewardedVideoAdDelegate {

    func rewardedVideoAdDidLoad(_ rewardedVideoAd: BURewardedVideoAd) {
        loadCompletion?(.success(partnerAd)) ?? log(.loadResultIgnored)
        loadCompletion = nil
    }

    func rewardedVideoAd(_ rewardedVideoAd: BURewardedVideoAd, didFailWithError error: Error?) {
        let error = self.error(.loadFailure(request), error: error)
        loadCompletion?(.failure(error)) ?? log(.loadResultIgnored)
        loadCompletion = nil
    }

    func rewardedVideoAdDidVisible(_ rewardedVideoAd: BURewardedVideoAd) {
        showCompletion?(.success(partnerAd)) ?? log(.showResultIgnored)
        showCompletion = nil
    }

    func rewardedVideoAdDidPlayFinish(_ rewardedVideoAd: BURewardedVideoAd, didFailWithError error: Error?) {
        guard let error = error else {
            return
        }
        showCompletion?(.failure(error)) ?? log(.loadResultIgnored)
        showCompletion = nil
    }

    func rewardedVideoAdDidClose(_ rewardedVideoAd: BURewardedVideoAd) {
        log(.didDismiss(partnerAd, error: nil))
        partnerAdDelegate?.didDismiss(partnerAd, error: nil) ?? log(.delegateUnavailable)
    }

    func rewardedVideoAdDidClick(_ rewardedVideoAd: BURewardedVideoAd) {
        log(.didClick(partnerAd, error: nil))
        partnerAdDelegate?.didClick(partnerAd) ?? log(.delegateUnavailable)
    }

    func rewardedVideoAdServerRewardDidSucceed(_ rewardedVideoAd: BURewardedVideoAd, verify: Bool) {
        guard verify else {
            return
        }
        let reward = Reward(amount: 1, label: nil)
        log(.didReward(partnerAd, reward: reward))
        partnerAdDelegate?.didReward(partnerAd, reward: reward) ?? log(.delegateUnavailable)
    }
}
