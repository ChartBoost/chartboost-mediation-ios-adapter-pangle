// Copyright 2022-2024 Chartboost, Inc.
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file.

import PAGAdSDK
import ChartboostMediationSDK
import Foundation
import UIKit

/// Base class for Chartboost Mediation Pangle adapter ads.
class PangleAdapterAd: NSObject {
    
    /// The partner adapter that created this ad.
    let adapter: PartnerAdapter
    
    /// Extra ad information provided by the partner.
    var details: PartnerDetails = [:]

    /// The ad load request associated to the ad.
    /// It should be the one provided on ``PartnerAdapter/makeBannerAd(request:delegate:)`` or ``PartnerAdapter/makeFullscreenAd(request:delegate:)``.
    let request: PartnerAdLoadRequest
        
    /// The partner ad delegate to send ad life-cycle events to.
    /// It should be the one provided on ``PartnerAdapter/makeBannerAd(request:delegate:)`` or ``PartnerAdapter/makeFullscreenAd(request:delegate:)``.
    weak var delegate: PartnerAdDelegate?
        
    /// The completion handler to notify Chartboost Mediation of ad show completion result.
    var showCompletion: ((Result<PartnerDetails, Error>) -> Void)?
    
    /// Create a new instance of the adapter.
    /// - Parameters:
    ///   - adapter: The current adapter instance
    ///   - request: The current AdLoadRequest containing data relevant to the curent ad request
    ///   - partnerAdDelegate: The partner ad delegate to notify Chartboost Mediation of ad lifecycle events.
    init(adapter: PartnerAdapter, request: PartnerAdLoadRequest, delegate: PartnerAdDelegate) {
        self.adapter = adapter
        self.request = request
        self.delegate = delegate
    }
}
