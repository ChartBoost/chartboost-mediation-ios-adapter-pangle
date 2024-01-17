// Copyright 2022-2023 Chartboost, Inc.
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file.

import ChartboostMediationSDK
import Foundation
import PAGAdSDK
import UIKit

/// The Chartboost Mediation Pangle adapter.
final class PangleAdapter: PartnerAdapter {
    
    /// The version of the partner SDK.
    let partnerSDKVersion: String = PAGSdk.sdkVersion
    
    /// The version of the adapter.
    /// It should have either 5 or 6 digits separated by periods, where the first digit is Chartboost Mediation SDK's major version, the last digit is the adapter's build version, and intermediate digits are the partner SDK's version.
    /// Format: `<Chartboost Mediation major version>.<Partner major version>.<Partner minor version>.<Partner patch version>.<Partner build version>.<Adapter build version>` where `.<Partner build version>` is optional.
    let adapterVersion = "4.5.7.0.7.0"
    
    /// The partner's unique identifier.
    let partnerIdentifier = "pangle"
    
    /// The human-friendly partner name.
    let partnerDisplayName = "Pangle"
    
    /// The designated initializer for the adapter.
    /// Chartboost Mediation SDK will use this constructor to create instances of conforming types.
    /// - parameter storage: An object that exposes storage managed by the Chartboost Mediation SDK to the adapter.
    /// It includes a list of created `PartnerAd` instances. You may ignore this parameter if you don't need it.
    init(storage: PartnerAdapterStorage) {}
    
    /// Does any setup needed before beginning to load ads.
    /// - parameter configuration: Configuration data for the adapter to set up.
    /// - parameter completion: Closure to be performed by the adapter when it's done setting up. It should include an error indicating the cause for failure or `nil` if the operation finished successfully.
    func setUp(with configuration: PartnerConfiguration, completion: @escaping (Error?) -> Void) {
        log(.setUpStarted)
        
        // Fail early if credentials are missing.
        guard let appID = configuration.appID, !appID.isEmpty else {
            let error = error(.initializationFailureInvalidCredentials, description: "Missing \(String.appIDKey)")
            log(.setUpFailed(error))
            return completion(error)
        }
        
        // Identify Chartboost Mediation as the mediation source.
        // https://bytedance.feishu.cn/docs/doccnizmSHXvAcbT1dIYEthNlCg
        let extData =
            "[{\"name\":\"mediation\",\"value\":\"Chartboost\"},{\"name\":\"adapter_version\",\"value\":\"\(adapterVersion)\"}]"
        
        let config = PAGConfig.share()
        config.appID = appID
        config.userDataString = extData
        
        PAGSdk.start(with: config) { [self] success, error in
            if success {
                log(.setUpSucceded)
                completion(nil)
            } else {
                let error = error ?? self.error(.partnerError)
                log(.setUpFailed(error))
                completion(error)
            }
        }
    }
    
    /// Fetches bidding tokens needed for the partner to participate in an auction.
    /// - parameter request: Information about the ad load request.
    /// - parameter completion: Closure to be performed with the fetched info.
    func fetchBidderInformation(request: PreBidRequest, completion: @escaping ([String : String]?) -> Void) {
        // Pangle does not currently provide any bidding token
        completion(nil)
    }
    
    /// Indicates if GDPR applies or not and the user's GDPR consent status.
    /// - parameter applies: `true` if GDPR applies, `false` if not, `nil` if the publisher has not provided this information.
    /// - parameter status: One of the `GDPRConsentStatus` values depending on the user's preference.
    func setGDPR(applies: Bool?, status: GDPRConsentStatus) {
        // See PAGConfig.gdprConsent documentation on PAGConfig.h
        if applies == true {
            let gpdrConsent: PAGGDPRConsentType = status == .granted ? .consent : .noConsent
            PAGConfig.share().gdprConsent = gpdrConsent
            log(.privacyUpdated(setting: "gdprConsent", value: gpdrConsent.rawValue))
        }
    }
    
    /// Indicates if the user is subject to COPPA or not.
    /// - parameter isChildDirected: `true` if the user is subject to COPPA, `false` otherwise.
    func setCOPPA(isChildDirected: Bool) {
        // See PAGConfig.childDirected documentation on PAGConfig.h
        let childDirected: PAGChildDirectedType = isChildDirected ? .child : .nonChild
        PAGConfig.share().childDirected = childDirected
        log(.privacyUpdated(setting: "childDirected", value: childDirected.rawValue))
    }
    
    /// Indicates the CCPA status both as a boolean and as an IAB US privacy string.
    /// - parameter hasGivenConsent: A boolean indicating if the user has given consent.
    /// - parameter privacyString: An IAB-compliant string indicating the CCPA status.
    func setCCPA(hasGivenConsent: Bool, privacyString: String) {
        // See PAGConfig.doNotSell documentation on PAGConfig.h
        let doNotSell: PAGDoNotSellType = hasGivenConsent ? .sell : .notSell
        PAGConfig.share().doNotSell = doNotSell
        log(.privacyUpdated(setting: "doNotSell", value: doNotSell.rawValue))
    }
    
    /// Creates a new ad object in charge of communicating with a single partner SDK ad instance.
    /// Chartboost Mediation SDK calls this method to create a new ad for each new load request. Ad instances are never reused.
    /// Chartboost Mediation SDK takes care of storing and disposing of ad instances so you don't need to.
    /// `invalidate()` is called on ads before disposing of them in case partners need to perform any custom logic before the object gets destroyed.
    /// If, for some reason, a new ad cannot be provided, an error should be thrown.
    /// - parameter request: Information about the ad load request.
    /// - parameter delegate: The delegate that will receive ad life-cycle notifications.
    func makeAd(request: PartnerAdLoadRequest, delegate: PartnerAdDelegate) throws -> PartnerAd {
        // This partner supports multiple loads for the same partner placement.
        switch request.format {
        case .interstitial:
            return PangleAdapterInterstitialAd(adapter: self, request: request, delegate: delegate)
        case .rewarded:
            return PangleAdapterRewardedAd(adapter: self, request: request, delegate: delegate)
        case .banner:
            return PangleAdapterBannerAd(adapter: self, request: request, delegate: delegate)
        default:
            // Not using the `.adaptiveBanner` case directly to maintain backward compatibility with Chartboost Mediation 4.0
            if request.format.rawValue == "adaptive_banner" {
                return PangleAdapterBannerAd(adapter: self, request: request, delegate: delegate)
            } else {
                throw error(.loadFailureUnsupportedAdFormat)
            }
        }
    }
}

/// Convenience extension to access Pangle credentials from the configuration.
private extension PartnerConfiguration {
    var appID: String? { credentials[.appIDKey] as? String }
}

private extension String {
    /// Pangle app ID credentials key
    static let appIDKey = "application_id"
}
