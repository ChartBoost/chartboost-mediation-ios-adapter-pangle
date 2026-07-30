// Copyright 2022-2026 Chartboost, Inc.
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file.

import ChartboostMediationSDK
import Foundation
import PAGAdSDK

/// The Chartboost Mediation Pangle adapter banner ad.
final class PangleAdapterBannerAd: PangleAdapterAd, PartnerBannerAd {
    /// The partner banner ad view to display.
    var view: UIView? { ad?.bannerView }

    /// The loaded partner ad banner size.
    var size: PartnerBannerSize?

    /// The Pangle SDK ad instance.
    private var ad: PAGBannerAd?

    /// Loads an ad.
    /// - parameter viewController: The view controller on which the ad will be presented on. Needed on load for some banners.
    /// - parameter completion: Closure to be performed once the ad has been loaded.
    func load(with viewController: UIViewController?, completion: @escaping (Error?) -> Void) {
        log(.loadStarted)

        // Fail if we cannot fit a fixed size banner in the requested size.
        guard
            let requestedSize = request.bannerSize,
            let pagAdSize = requestedSize.pagAdSize
        else {
            let error = error(.loadFailureInvalidBannerSize)
            log(.loadFailed(error))
            completion(error)
            return
        }

        let bannerRequest = PAGBannerRequest(bannerSize: pagAdSize)

        PAGBannerAd.load(withSlotID: request.partnerPlacement, request: bannerRequest) { [weak self] ad, partnerError in
            guard let self else { return }
            if let ad, partnerError == nil {   // It's possible that an error occurs, the ad cannot be shown, and yet `ad` is not nil
                ad.delegate = self
                ad.rootViewController = viewController
                self.ad = ad
                self.log(.loadSucceeded)
                self.size = PartnerBannerSize(size: ad.adSize.size, type: requestedSize.type)
                completion(nil)
            } else {
                let error = partnerError ?? self.error(.loadFailureUnknown)
                self.log(.loadFailed(error))
                completion(error)
            }
        }
    }
}

extension PangleAdapterBannerAd: PAGBannerAdDelegate {
    func adDidShow(_ ad: PAGAdProtocol) {
        log(.delegateCallIgnored)
    }

    func adDidClick(_ ad: PAGAdProtocol) {
        log(.didClick(error: nil))
        delegate?.didClick(self) ?? log(.delegateUnavailable)
    }

    func adDidDismiss(_ ad: PAGAdProtocol) {
        log(.delegateCallIgnored)
    }
}

extension BannerSize {
    fileprivate var pagAdSize: PAGBannerAdSize? {
        if self.type == .adaptive {
            return PAGInlineAdaptiveBannerAdSizeWithWidthAndMaxHeight(self.size.width, self.size.height)
        }
        switch self {
        case .standard:
            return kPAGBannerSize320x50
        case .medium:
            return kPAGBannerSize300x250
        case .leaderboard:
            return kPAGBannerSize728x90
        default:
            return nil
        }
    }
}
