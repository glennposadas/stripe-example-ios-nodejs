//
//  API.swift
//  StripeExample
//
//  Created by Glenn Von Posadas on 5/22/20.
//  Copyright © 2020 GAM Dynamics. All rights reserved.
//

import Foundation
import Moya

let authServiceProvider = MoyaProvider<AuthService>(
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


enum AuthService {
    case loginWithEmail(email: String, password: String)
    case registerUser(email: String, password: String, name: String, address: String)
}

// MARK: - TargetType Protocol Implementationm

extension AuthService: TargetType {
    var baseURL: URL {
        return URL(string: baseURLString)!
    }
    
    var path: String {
        switch self {
        case .loginWithEmail    : return "/oauth/signin"
        case .registerUser      : return "/oauth/signup"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .loginWithEmail    : return .post
        case .loginWithFacebook : return .post
        case .registerUser      : return .post
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
                    "password": password
                    "name": name,
                    "address": address
                ], encoding: URLEncoding.httpBody
            )
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
}



