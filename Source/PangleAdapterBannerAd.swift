// Copyright 2022-2023 Chartboost, Inc.
// 
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file.

//
//  PangleAdapterBannerAd.swift
//  ChartboostHeliumAdapterPangle
//

import Foundation
import PAGAdSDK
import HeliumSdk

/// The Helium Pangle adapter banner ad.
final class PangleAdapterBannerAd: PangleAdapterAd, PartnerAd {
    
    /// The partner ad view to display inline. E.g. a banner view.
    /// Should be nil for full-screen ads.
    var inlineView: UIView? { ad?.bannerView }
    
    /// The Pangle SDK ad instance.
    private var ad: PAGBannerAd?
    
    /// Loads an ad.
    /// - parameter viewController: The view controller on which the ad will be presented on. Needed on load for some banners.
    /// - parameter completion: Closure to be performed once the ad has been loaded.
    func load(with viewController: UIViewController?, completion: @escaping (Result<PartnerEventDetails, Error>) -> Void) {
        log(.loadStarted)
        
        let size = PAGAdSize(size: request.size ?? IABStandardAdSize)
        let bannerRequest = PAGBannerRequest(bannerSize: size)
        
        PAGBannerAd.load(withSlotID: request.partnerPlacement, request: bannerRequest) { [weak self] ad, partnerError in
            guard let self = self else { return }
            if let ad = ad, partnerError == nil {   // It's possible that an error occurs, the ad cannot be shown, and yet `ad` is not nil
                ad.delegate = self
                ad.rootViewController = viewController
                self.ad = ad
                self.log(.loadSucceeded)
                completion(.success([:]))
            } else {
                let error = partnerError ?? self.error(.loadFailureUnknown)
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
        // no-op
    }
}

extension PangleAdapterBannerAd: PAGBannerAdDelegate {
    
    func adDidShow(_ ad: PAGAdProtocol) {
        log(.delegateCallIgnored)
    }
    
    func adDidClick(_ ad: PAGAdProtocol) {
        log(.didClick(error: nil))
        delegate?.didClick(self, details: [:]) ?? log(.delegateUnavailable)
    }
    
    func adDidDismiss(_ ad: PAGAdProtocol) {
        log(.delegateCallIgnored)
    }
}
