//
//  BundleExtension.swift
//  StripeExample
//
//  Created by Glenn Von Posadas on 5/21/20.
//  Copyright © 2020 GAM Dynamics. All rights reserved.
//

import Foundation

/// Category for `Bundle`
extension Bundle {
    /// Gets the name of the app - title under the icon.
    var displayName: String? {
        return object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ??
            object(forInfoDictionaryKey: "CFBundleName") as? String
    }
    
    /// Release version numner
    var releaseVersionNumber: String {
        return (infoDictionary?["CFBundleShortVersionString"] as? String) ?? ""
    }
    
    /// Build version number
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
    
    /// Custom/Pretty version number
    var releaseVersionNumberPretty: String {
        "Version \(releaseVersionNumber)"
    }
    
    /// The version from the server config
    var version: String {
        releaseVersionNumber
    }
    
    /// Get the Int version of the app.
    
    var versionInt: Int {
        if let buildVersion = Bundle.main.buildVersionNumber,
            let versionInt = Int("\(buildVersion)") {
            return versionInt
        }
        
        return 1
    }
}






