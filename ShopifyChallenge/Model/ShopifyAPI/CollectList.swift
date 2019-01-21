//
//  Product.swift
//  ShopifyChallenge
//
//  Created by Philip Tam on 2019-01-16.
//  Copyright © 2019 Philip Tam. All rights reserved.
//

import Foundation
import UIKit
import Alamofire


/*
    Collect structure helpers for JSON Decoding
 */

struct CollectList: Decodable {
    var collects: [Collect]
}

struct Collect: Decodable {
    var id: Int
    var collectionID: Int
    var productID: Int
    var featured: Bool
    var createdAt: String
    var updatedAt: String
    var position: Int
    var sortValue: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case featured
        case position
        case collectionID = "collection_id"
        case productID = "product_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case sortValue = "sort_value"
    }
}
