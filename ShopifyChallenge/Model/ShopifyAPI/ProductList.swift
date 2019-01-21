//
//  ProductList.swift
//  ShopifyChallenge
//
//  Created by Philip Tam on 2019-01-17.
//  Copyright © 2019 Philip Tam. All rights reserved.
//

import Foundation


/*
    ProductList structure helpers for JSON Decoding
 */

struct ProductList: Decodable {
    var products: [Product]
}

struct Product: Decodable {
    var id: Int
    var title: String
    var bodyHTML: String
    var vendor: String
    var productType: String
    var createdAt: String
    var handle: String
    var updatedAt: String
    var publishedAt: String
    var templateSuffix: String?
    var tags: String
    var scope: String
    var adminID: String
    var variants: [ProductVariant]
    var options: [ProductOption]
    var images: [ProductImage]
    var image: ProductImage
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case bodyHTML = "body_html"
        case vendor
        case productType = "product_type"
        case createdAt = "created_at"
        case handle
        case updatedAt = "updated_at"
        case publishedAt = "published_at"
        case templateSuffix = "template_suffix"
        case tags
        case scope = "published_scope"
        case adminID = "admin_graphql_api_id"
        case variants
        case options
        case images
        case image
    }
}

struct ProductVariant: Decodable {
    var id: Int
    var productID: Int
    var title: String
    var price: String
    var sku: String
    var position: Int
    var policy: String
    var comparePrice: String?
    var fulfillService: String
    var management: String?
    var option1: String?
    var option2: String?
    var option3: String?
    var createdAt: String
    var updatedAt: String
    var taxable: Bool
    var barcode: String?
    var grams: Int
    var imageID: String?
    var weight: Double
    var weightUnit: String
    var inventoryID: Int
    var inventoryQuan: Int
    var oldInventoryQuan: Int
    var shipping: Bool
    var adminID: String
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case productID = "product_id"
        case title = "title"
        case price = "price"
        case sku = "sku"
        case position = "position"
        case policy = "inventory_policy"
        case comparePrice = "compare_at_price"
        case fulfillService = "fulfillment_service"
        case management = "inventory_management"
        case option1 = "option1"
        case option2 = "option2"
        case option3 = "option3"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case taxable = "taxable"
        case barcode = "barcode"
        case grams = "grams"
        case imageID = "image_id"
        case weight = "weight"
        case weightUnit = "weight_unit"
        case inventoryID = "inventory_item_id"
        case inventoryQuan = "inventory_quantity"
        case oldInventoryQuan = "old_inventory_quantity"
        case shipping = "requires_shipping"
        case adminID = "admin_graphql_api_id"
    }
}

struct ProductOption: Decodable {
    var id: Int
    var productID: Int
    var name: String
    var position: Int
    var values: [String]
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case productID = "product_id"
        case name
        case position
        case values
    }
}

struct ProductImage: Decodable {
    var id: Int
    var productID: Int
    var position: Int
    var createdAt: String
    var updatedAt: String
    var alt: String?
    var width: Int
    var height: Int
    var src: String
    var variantIDs: [String?]
    var adminID: String
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case productID = "product_id"
        case position
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case alt
        case width
        case height
        case src
        case variantIDs = "variant_ids"
        case adminID = "admin_graphql_api_id"
    }
}
