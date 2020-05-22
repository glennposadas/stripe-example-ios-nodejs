//
//  Item.swift
//  StripeExample
//
//  Created by Glenn Von Posadas on 5/23/20.
//  Copyright © 2020 GAM Dynamics. All rights reserved.
//

import Foundation

final class Item: Codable {
    
    let createdAt : String
    let descriptionField : String
    let id : Int
    let photoURL : String
    let price : Float
    let title : String
    let updatedAt : String
    
    enum CodingKeys: String, CodingKey {
        case createdAt = "createdAt"
        case descriptionField = "description"
        case id = "id"
        case photoURL = "photoURL"
        case price = "price"
        case title = "title"
        case updatedAt = "updatedAt"
    }
}
