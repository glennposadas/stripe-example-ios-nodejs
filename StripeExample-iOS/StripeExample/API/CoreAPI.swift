//
//  CoreAPI.swift
//  StripeExample
//
//  Created by Glenn Von Posadas on 5/22/20.
//  Copyright © 2020 GAM Dynamics. All rights reserved.
//

import Alamofire
import Moya
import UIKit

/// The max items per page in every network calls.
public let MAX_DATA_PER_PAGE: Int = 20

public let baseURLStringLIVE = "http://localhost:3000"
public let apiVersionLIVE = "/api"

public let baseURLString = baseURLStringLIVE + apiVersionLIVE

/// The constants for networking is stored in the file `CoreService.swift`.
class CoreAPI {
    
    /// Determines if each managers call the API verbosely.
    static var verbose: Bool = false
    
    /// Generates a bearer token.
    class func getBearerToken() -> String? {
        if let authModel = AppDefaults.getObjectWithKey(.authModel, type: AuthModel.self) {
            return "Bearer " + authModel.token
        }
        
        return nil
    }
    
    class func JSONResponseDataFormatter(_ data: Data) -> String {
        do {
            let dataAsJSON = try JSONSerialization.jsonObject(with: data)
            let prettyData = try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
            return String(data: prettyData, encoding: .utf8) ?? String(data: data, encoding: .utf8) ?? ""
        } catch {
            return String(data: data, encoding: .utf8) ?? ""
        }
    }
    
    /// Generates required headers for all API endpoints.
    class func getHeaders() -> [String : String] {
        return [
            "Content-type"  : "application/json",
            "X-EMOJO-Country" : "PH",
            "User-Agent"    : "Emojo User App/\(Bundle.main.version) Build #\(Bundle.main.buildVersionNumber ?? "") (iOS/\(UIDevice.current.systemVersion)) CFNetwork/672.1.13",
            "X-EMOJO-Platform": "IOS",
            "Authorization" : CoreAPI.getBearerToken() ?? ""
        ]
    }
}


