// Copyright 2022-2026 Chartboost, Inc.
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file.

import ChartboostMediationSDK
import Foundation
import PAGAdSDK
import UIKit

/// The Chartboost Mediation Pangle adapter.
final class PangleAdapter: PartnerAdapter {
    /// The adapter configuration type that contains adapter and partner info.
    /// It may also be used to expose custom partner SDK options to the publisher.
    var configuration: PartnerAdapterConfiguration.Type { PangleAdapterConfiguration.self }

    /// The designated initializer for the adapter.
    /// Chartboost Mediation SDK will use this constructor to create instances of conforming types.
    /// - parameter storage: An object that exposes storage managed by the Chartboost Mediation SDK to the adapter.
    /// It includes a list of created `PartnerAd` instances. You may ignore this parameter if you don't need it.
    init(storage: PartnerAdapterStorage) {}

    /// Does any setup needed before beginning to load ads.
    /// - parameter configuration: Configuration data for the adapter to set up.
    /// - parameter completion: Closure to be performed by the adapter when it's done setting up. It should include an error indicating
    /// the cause for failure or `nil` if the operation finished successfully.
    func setUp(with configuration: PartnerConfiguration, completion: @escaping (Result<PartnerDetails, Error>) -> Void) {
        log(.setUpStarted)

        // Fail early if credentials are missing.
        guard let appID = configuration.appID, !appID.isEmpty else {
            let error = error(.initializationFailureInvalidCredentials, description: "Missing \(String.appIDKey)")
            log(.setUpFailed(error))
            completion(.failure(error))
            return
        }

        // Apply initial consents
        setConsents(configuration.consents, modifiedKeys: Set(configuration.consents.keys))

        // Identify Chartboost Mediation as the mediation source.
        // https://bytedance.feishu.cn/docs/doccnizmSHXvAcbT1dIYEthNlCg
        let extData =
            "[{\"name\":\"mediation\",\"value\":\"Chartboost\"},{\"name\":\"adapter_version\",\"value\":\"\(self.configuration.adapterVersion)\"}]"

        let config = PAGConfig.share()
        config.appID = appID
        config.userDataString = extData

        PAGSdk.start(with: config) { [self] success, error in
            if success {
                log(.setUpSucceded)
                completion(.success([:]))
            } else {
                let error = error ?? self.error(.partnerError)
                log(.setUpFailed(error))
                completion(.failure(error))
            }
        }
    }

    /// Fetches bidding tokens needed for the partner to participate in an auction.
    /// - parameter request: Information about the ad load request.
    /// - parameter completion: Closure to be performed with the fetched info.
    func fetchBidderInformation(request: PartnerAdPreBidRequest, completion: @escaping (Result<[String: String], Error>) -> Void) {
        // Pangle does not currently provide any bidding token
        log(.fetchBidderInfoNotSupported)
        completion(.success([:]))
    }

    /// Indicates that the user consent has changed.
    /// - parameter consents: The new consents value, including both modified and unmodified consents.
    /// - parameter modifiedKeys: A set containing all the keys that changed.
    func setConsents(_ consents: [ConsentKey: ConsentValue], modifiedKeys: Set<ConsentKey>) {
        // Note: As of Pangle SDK 7.9.0, GDPR consent is handled automatically via TCFv2 strings
        // stored in NSUserDefaults. The explicit gdprConsent API has been removed.

        // See PAGConfig.PAConsent documentation on PAGConfig.h
        // Ignore if the consent status has been directly set by publisher via the configuration class.
        if !PangleAdapterConfiguration.isPAConsentOverridden && modifiedKeys.contains(ConsentKeys.ccpaOptIn) {
            let consent = consents[ConsentKeys.ccpaOptIn]
            switch consent {
            case ConsentValues.granted:
                PAGConfig.share().paConsent = .consent
                log(.privacyUpdated(setting: "paConsent", value: PAGPAConsentType.consent.rawValue))
            case ConsentValues.denied:
                PAGConfig.share().paConsent = .noConsent
                log(.privacyUpdated(setting: "paConsent", value: PAGPAConsentType.noConsent.rawValue))
            default:
                break   // do nothing
            }
        }
    }

    /// Indicates that the user is underage signal has changed.
    /// - parameter isUserUnderage: `true` if the user is underage as determined by the publisher, `false` otherwise.
    func setIsUserUnderage(_ isUserUnderage: Bool) {
        // As of Pangle 7.1.0.7, this method no longer has any effect.
    }

    /// Creates a new banner ad object in charge of communicating with a single partner SDK ad instance.
    /// Chartboost Mediation SDK calls this method to create a new ad for each new load request. Ad instances are never reused.
    /// Chartboost Mediation SDK takes care of storing and disposing of ad instances so you don't need to.
    /// ``PartnerAd/invalidate()`` is called on ads before disposing of them in case partners need to perform any custom logic before the
    /// object gets destroyed.
    /// If, for some reason, a new ad cannot be provided, an error should be thrown.
    /// Chartboost Mediation SDK will always call this method from the main thread.
    /// - parameter request: Information about the ad load request.
    /// - parameter delegate: The delegate that will receive ad life-cycle notifications.
    func makeBannerAd(request: PartnerAdLoadRequest, delegate: PartnerAdDelegate) throws -> PartnerBannerAd {
        // This partner supports multiple loads for the same partner placement.
        PangleAdapterBannerAd(adapter: self, request: request, delegate: delegate)
    }

    /// Creates a new ad object in charge of communicating with a single partner SDK ad instance.
    /// Chartboost Mediation SDK calls this method to create a new ad for each new load request. Ad instances are never reused.
    /// Chartboost Mediation SDK takes care of storing and disposing of ad instances so you don't need to.
    /// ``PartnerAd/invalidate()`` is called on ads before disposing of them in case partners need to perform any custom logic before the
    /// object gets destroyed.
    /// If, for some reason, a new ad cannot be provided, an error should be thrown.
    /// - parameter request: Information about the ad load request.
    /// - parameter delegate: The delegate that will receive ad life-cycle notifications.
    func makeFullscreenAd(request: PartnerAdLoadRequest, delegate: PartnerAdDelegate) throws -> PartnerFullscreenAd {
        // This partner supports multiple loads for the same partner placement.
        switch request.format {
        case PartnerAdFormats.interstitial:
            return PangleAdapterInterstitialAd(adapter: self, request: request, delegate: delegate)
        case PartnerAdFormats.rewarded:
            return PangleAdapterRewardedAd(adapter: self, request: request, delegate: delegate)
        default:
            throw error(.loadFailureUnsupportedAdFormat)
        }
    }
}

/// Convenience extension to access Pangle credentials from the configuration.
extension PartnerConfiguration {
    fileprivate var appID: String? { credentials[.appIDKey] as? String }
}

extension String {
    /// Pangle app ID credentials key
    fileprivate static let appIDKey = "application_id"
}
