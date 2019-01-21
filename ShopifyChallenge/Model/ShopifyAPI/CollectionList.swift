//
//  CollectionList.swift
//  ShopifyChallenge
//
//  Created by Philip Tam on 2019-01-17.
//  Copyright © 2019 Philip Tam. All rights reserved.
//

import Foundation

// Root of JSON
struct CollectionList: Decodable {
    
    // Array of all of the custom collections
    var collections: [CustomCollection]
    
    // Coding Keys (Title in JSON)
    enum CodingKeys: String, CodingKey {
        case collections = "custom_collections"
    }
}


struct CustomCollection: Decodable {
    var id: Int
    var template: String
    var handle: String
    var title: String
    var bodyHtml: String
    var sortOrder: String
    var scope: String
    var adminID: String
    var updatedAt: String
    var image: CollectionImage
    
    
    enum CodingKeys : String, CodingKey {
        case id = "id"
        case updatedAt = "updated_at"
        case title
        case handle
        case image
        case bodyHtml = "body_html"
        case template = "template_suffix"
        case sortOrder = "sort_order"
        case scope = "published_scope"
        case adminID = "admin_graphql_api_id"
        
    }
}

struct CollectionImage: Decodable {
    var createdAt: String
    var alt: String?
    var height: Int
    var width: Int
    var src: String
    
    enum CodingKeys: String, CodingKey {
        case createdAt = "created_at"
        case alt
        case height
        case width
        case src
    }
}
