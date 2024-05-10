// Copyright 2022-2024 Chartboost, Inc.
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file.

import ChartboostMediationSDK
import Foundation
import PAGAdSDK

@objc public class PangleAdapterConfiguration: NSObject, PartnerAdapterConfiguration {

    /// The version of the partner SDK.
    @objc public static var partnerSDKVersion: String {
        PAGSdk.sdkVersion
    }

    /// The version of the adapter.
    /// It should have either 5 or 6 digits separated by periods, where the first digit is Chartboost Mediation SDK's major version, the last digit is the adapter's build version, and intermediate digits are the partner SDK's version.
    /// Format: `<Chartboost Mediation major version>.<Partner major version>.<Partner minor version>.<Partner patch version>.<Partner build version>.<Adapter build version>` where `.<Partner build version>` is optional.
    @objc public static let adapterVersion = "5.5.9.0.0.0"

    /// The partner's unique identifier.
    @objc public static let partnerID = "pangle"

    /// The human-friendly partner name.
    @objc public static let partnerDisplayName = "Pangle"

    /// Use to manually set the consent status on the Pangle SDK.
    /// This is generally unnecessary as the Mediation SDK will set the consent status automatically based on the latest consent info.
    @objc public static func setGDPRConsentOverride(_ consent: PAGGDPRConsentType) {
        isGDPRConsentOverriden = true
        PAGConfig.share().gdprConsent = consent
        log("GDPR consent override set to \(consent)")
    }

    /// Use to manually set the consent status on the Pangle SDK.
    /// This is generally unnecessary as the Mediation SDK will set the consent status automatically based on the latest consent info.
    @objc public static func setDoNotSellOverride(_ doNotSell: PAGDoNotSellType) {
        isDoNotSellOverriden = true
        PAGConfig.share().doNotSell = doNotSell
        log("Do not sell override set to \(doNotSell)")
    }

    /// Internal flag that indicates if the GDPR consent has been overriden by the publisher.
    static private(set) var isGDPRConsentOverriden = false

    /// Internal flag that indicates if the DoNotSell consent has been overriden by the publisher.
    static private(set) var isDoNotSellOverriden = false
}
