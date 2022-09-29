//
//  PangleAdapterConfiguration.swift
//  ChartboostHeliumAdapterPangle
//

import BUAdSDK

/// A list of externally configurable properties pertaining to the partner SDK that can be retrieved and set by publishers.
public class PangleAdapterConfiguration {
    
    /// Flag that can optionally be set to enable the partner's verbose logging.
    /// Disabled by default.
    public static var verboseLogging: Bool = false {
        didSet {
            BUAdSDKManager.setLoglevel(.verbose)
        }
    }

    /// Append any other properties that publishers can configure.
}
