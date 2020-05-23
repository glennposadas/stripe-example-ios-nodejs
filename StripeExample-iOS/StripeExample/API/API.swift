//
//  API.swift
//  StripeExample
//
//  Created by Glenn Von Posadas on 5/22/20.
//  Copyright © 2020 GAM Dynamics. All rights reserved.
//

import Foundation
import Moya
import Stripe

class API: NSObject {
    static let provider = MoyaProvider<AuthService>(
        plugins: [
            NetworkLoggerPlugin(
                configuration: .init(
                    formatter: .init(
                        responseData: CoreAPI.JSONResponseDataFormatter
                    ),
                    logOptions: .verbose
                )
            )
        ]
    )
    
    static let shared = API()
    
    enum AuthService: TargetType {
        case loginWithEmail(email: String, password: String)
        case registerUser(email: String, password: String, name: String, address: String)
        case getItems
        case createStripeCustKey(apiVersion: String)
        case createPaymentIntent(allParams: [String : Any])
        
        var baseURL: URL {
            return URL(string: baseURLString)!
        }
        
        var path: String {
            switch self {
            case .loginWithEmail     : return "/oauth/signin"
            case .registerUser       : return "/oauth/signup"
            case .getItems           : return "/items"
            case .createStripeCustKey: return "/ephemeral_keys"
            case .createPaymentIntent: return "/create_payment_intent"
            }
        }
        
        var method: Moya.Method {
            switch self {
            case .loginWithEmail     : return .post
            case .registerUser       : return .post
            case .getItems           : return .get
            case .createStripeCustKey: return .post
            case .createPaymentIntent: return .post
            }
        }
        
        var sampleData: Data { Data() }
        
        var task: Task {
            switch self {
            case let .loginWithEmail(email, password):
                return .requestParameters(
                    parameters: [
                        "email": email,
                        "password": password
                    ], encoding: URLEncoding.httpBody
                )
                
            case let .registerUser(email, password, name, address):
                return .requestParameters(
                    parameters: [
                        "email": email,
                        "password": password,
                        "name": name,
                        "address": address
                    ], encoding: URLEncoding.httpBody
                )
                
            case .getItems:
                return .requestPlain
                
            case let .createStripeCustKey(apiVersion):
                return .requestParameters(
                    parameters: [
                        "api_version": apiVersion
                    ], encoding: URLEncoding.httpBody
                )
                
            case let .createPaymentIntent(allParams):
                return .requestParameters(parameters: allParams, encoding: JSONEncoding.default)
            }
        }
        
        var headers: [String : String]? {
            switch self {
            case .getItems:
                return CoreAPI.getHeaders()
            default:
                return nil
            }
        }
    }
}

// MARK: - STPCustomerEphemeralKeyProvider

extension API: STPCustomerEphemeralKeyProvider {
    /// The fucntion accessible from checkout.
    func createPaymentIntent(for item: Item, completion: @escaping ((Result<String, Error>) -> Void)) {
        var allParams: [String: Any] = [
            "metadata": [
                "payment_request_id": "B3E611D1-5FA1-4410-9CEC-00958A5126CB",
            ],
        ]
        
        allParams["products"] = item.title
        allParams["country"] = "Philippines"
        
        API.provider.request(.createPaymentIntent(allParams: allParams)) { (result) in
            switch result {
            case let .success(response):
                guard let json = ((try? JSONSerialization.jsonObject(with: response.data, options: []) as? [String : Any]) as [String : Any]??),
                    let secret = json?["secret"] as? String else {
                        completion(.failure(NSError(domain: "aaaa", code: 300, userInfo: nil)))
                        return
                }
                
                completion(.success(secret))
                
            default:
                UIViewController.current()?.alert(title: "PAYMENT ERROR!", okayButtonTitle: "OK", withBlock: nil)
            }

        }
    }
    
    /// The actual protocol of `STPCustomerEphemeralKeyProvider`.
    func createCustomerKey(withAPIVersion apiVersion: String, completion: @escaping STPJSONResponseCompletionBlock) {
        API.provider.request(.createStripeCustKey(apiVersion: apiVersion)) { (result) in
            switch result {
            case let .success(response):
                guard let json = ((try? JSONSerialization.jsonObject(with: response.data, options: []) as? [String : Any]) as [String : Any]??) else {
                    completion(nil, NSError(domain: "aaaa", code: 300, userInfo: nil))
                    return
                }
                
                completion(json, nil)
                
            default:
                UIViewController.current()?.alert(title: "Error STRIPE key", okayButtonTitle: "OK", withBlock: nil)
            }
        }
    }
}
