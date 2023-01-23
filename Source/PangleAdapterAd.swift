// Copyright 2022-2023 Chartboost, Inc.
// 
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file.

//
//  PangleAdapterAd.swift
//  ChartboostHeliumAdapterPangle
//

import Foundation
import UIKit
import HeliumSdk
import BUAdSDK

/// Base class for Helium Pangle adapter ads.
class PangleAdapterAd: NSObject {
    
    /// The partner adapter that created this ad.
    let adapter: PartnerAdapter
    
    /// The ad load request associated to the ad.
    /// It should be the one provided on `PartnerAdapter.makeAd(request:delegate:)`.
    let request: PartnerAdLoadRequest
        
    /// The partner ad delegate to send ad life-cycle events to.
    /// It should be the one provided on `PartnerAdapter.makeAd(request:delegate:)`.
    weak var delegate: PartnerAdDelegate?
        
    /// The completion handler to notify Helium of ad show completion result.
    var showCompletion: ((Result<PartnerEventDetails, Error>) -> Void)?
    
    /// Create a new instance of the adapter.
    /// - Parameters:
    ///   - adapter: The current adapter instance
    ///   - request: The current AdLoadRequest containing data relevant to the curent ad request
    ///   - partnerAdDelegate: The partner ad delegate to notify Helium of ad lifecycle events.
    init(adapter: PartnerAdapter, request: PartnerAdLoadRequest, delegate: PartnerAdDelegate) {
        self.adapter = adapter
        self.request = request
        self.delegate = delegate
    }
}
