//
//  PangleAdapter.swift
//  ChartboostHeliumAdapterPangle
//

import Foundation
import HeliumSdk
import PAGAdSDK
import UIKit

final class PangleAdapter: ModularPartnerAdapter {
    /// Get the version of the partner SDK.
    let partnerSDKVersion: String = PAGSdk.sdkVersion
    
    /// Get the version of the mediation adapter.
    let adapterVersion = "4.4.6.2.0"
    
    /// Get the internal name of the partner.
    let partnerIdentifier = "pangle"
    
    /// Get the external/official name of the partner.
    let partnerDisplayName = "Pangle"
    
    /// Storage of adapter instances.  Keyed by the request identifier.
    var adAdapters: [String: PartnerAdAdapter] = [:]

    /// The last value set on `setGDPRApplies(_:)`.
    private var gdprApplies = false

    /// The last value set on `setGDPRConsentStatus(_:)`.
    private var gdprStatus: GDPRConsentStatus = .unknown

    /// The last value set on `setUserSubjectToCOPPA(_)`.
    private var isSubjectToCOPPA = false

    /// The last value set on `setUserSubjectToCOPPA(_)`.
    private var hasGivenCCPAConsent = false

    /// Provides a new ad adapter in charge of communicating with a single partner ad instance.
    func makeAdAdapter(request: PartnerAdLoadRequest, partnerAdDelegate: PartnerAdDelegate) throws -> PartnerAdAdapter {
        switch request.format {
        case .interstitial:
            return PangleInterstitialAdAdapter(adapter: self, request: request, partnerAdDelegate: partnerAdDelegate)
        case .rewarded:
            return PangleRewardedAdAdapter(adapter: self, request: request, partnerAdDelegate: partnerAdDelegate)
        case .banner:
            return PangleBannerAdAdapter(adapter: self, request: request, partnerAdDelegate: partnerAdDelegate)
        }
    }

    /// Onitialize the partner SDK so that it's ready to request and display ads.
    /// - Parameters:
    ///   - configuration: The necessary initialization data provided by Helium.
    ///   - completion: Handler to notify Helium of task completion.
    func setUp(with configuration: PartnerConfiguration, completion: @escaping (Error?) -> Void) {
        log(.setUpStarted)

        guard let appID = configuration.appID, !appID.isEmpty else {
            let error = error(.missingSetUpParameter(key: .appIDKey))
            log(.setUpFailed(error))
            return completion(error)
        }

        // Identify Helium as the mediation source.
        // https://bytedance.feishu.cn/docs/doccnizmSHXvAcbT1dIYEthNlCg
        let extData =
            "[{\"name\":\"mediation\",\"value\":\"Helium\"},{\"name\":\"adapter_version\",\"value\":\"\(adapterVersion)\"}]"

        let config = PAGConfig.share()
        config.appID = appID
        config.userDataString = extData

        // privacy
        if gdprApplies {
            config.gdprConsent = gdprStatus == .granted ? .consent : .noConsent
            log(.privacyUpdated(setting: "'PAGConfig PAGGDPRConsentType'", value: config.gdprConsent))
        }
        config.childDirected = isSubjectToCOPPA ? .child : .nonChild
        log(.privacyUpdated(setting: "'PAGConfig PAGChildDirectedType'", value: config.childDirected))
        config.doNotSell = hasGivenCCPAConsent ? .sell : .notSell
        log(.privacyUpdated(setting: "'PAGConfig PAGDoNotSellType'", value: config.doNotSell))

        PAGSdk.start(with: config) { [weak self] success, error in
            guard let self = self else { return }
            if success {
                self.log(.setUpSucceded)
                completion(nil)
            }
            else {
                self.log(.setUpFailed(error))
                completion(error)
            }
        }
    }
    
    /// Compute and return a bid token for the bid request.
    /// - Parameters:
    ///   - request: The necessary data associated with the current bid request.
    ///   - completion: Handler to notify Helium of task completion.
    func fetchBidderInformation(request: PreBidRequest, completion: @escaping ([String : String]) -> Void) {
        log(.fetchBidderInfoStarted(request))
        log(.fetchBidderInfoSucceeded(request))
        completion([:])
    }
    
    /// Notify the partner SDK of GDPR applicability as determined by the Helium SDK.
    /// - Parameter applies: true if GDPR applies, false otherwise.
    func setGDPRApplies(_ applies: Bool) {
        gdprApplies = applies
    }
    
    /// Notify the partner SDK of the GDPR consent status as determined by the Helium SDK.
    /// - Parameter status: The user's current GDPR consent status.
    func setGDPRConsentStatus(_ status: GDPRConsentStatus) {
        gdprStatus = status
    }

    /// Notify the partner SDK of the COPPA subjectivity as determined by the Helium SDK.
    /// - Parameter isSubject: True if the user is subject to COPPA, false otherwise.
    func setUserSubjectToCOPPA(_ isSubject: Bool) {
        isSubjectToCOPPA = isSubject
    }
    
    /// Notify the partner SDK of the CCPA privacy String as supplied by the Helium SDK.
    /// - Parameters:
    ///   - hasGivenConsent: True if the user has given CCPA consent, false otherwise.
    ///   - privacyString: The CCPA privacy String.
    func setCCPAConsent(hasGivenConsent: Bool, privacyString: String?) {
        hasGivenCCPAConsent = hasGivenConsent
    }
}

/// Convenience extension to access Pangle credentials from the configuration.
private extension PartnerConfiguration {
    var appID: String? { credentials[.appIDKey] as? String }
}

private extension String {
    /// Pangle keys
    static let appIDKey = "application_id"
}
