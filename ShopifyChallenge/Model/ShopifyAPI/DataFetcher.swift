//
//  CollectionFetcher.swift
//  ShopifyChallenge
//
//  Created by Philip Tam on 2019-01-16.
//  Copyright © 2019 Philip Tam. All rights reserved.
//

import Alamofire
import Foundation

/*
 
 Data Fetcher
 - Fetches all of the necessary data from the Shopify URL and keeps them in variable
 - Fetches Collections
 - Fetches Collects
 - Fetches the Products
 - Handles all of the decoding
 
 */

class DataFetcher {
    
    // List of all Collections from URL
    public var collectionList: CollectionList?
    
    var collectMap: [Int: CollectList] = [:]
    
    // Key: Collection ID, Value: Product
    public var productByID: [Int: [Product]] = [:]
    
    // Singleton
    // a singleton is best because if the app is expanded into more than 2 views then it will be easier to access the products, collections, and collects.
    public static let shared: DataFetcher = DataFetcher()
    
    /*
     
     function: fetchCollection
     url: String
     completionHandler: @escaping (Bool, Error) -> () -> For later
     Makes a get reuqest to the URL and then upon success will decode the data from the response JSON into a collectionList.
    */

    public func fetchCollection(url: String, _ completionHandler: @escaping (Bool, Error?) -> () ) {
        // Alamofire session manager
        let manager = Alamofire.SessionManager.default
        
        // Make a get request with a JSOn encoding and get a json response.
        let request = manager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseJSON { response in
            // Handle success/error of response
            switch response.result {
            case .success:
                // Get the data of the response
                if let data = response.data {
                    // Calls the decode collection
                    self.decodeCollection(data: data, { (success, error) in
                        if success {
                            // success
                            completionHandler(true, nil)
                        } else {
                            // decoding failure
                            if let error = error {
                                print("Error while decoding data \(error)")
                                completionHandler(false, error)
                                return
                            }
                            completionHandler(false, nil)
                        }
                    })
                }
            case .failure:
                print("Response failure")
                completionHandler(false, response.error)
            }
        }
    }
    
    /*
    
    function: decodeCollection
    data: Data
    completionHandler: @escaping (Bool, Error) -> ()
    Decodes the JSON data into a CollectionList
    
     */
    
    private func decodeCollection(data: Data, _ completionHandler: (Bool, Error?) -> () ) {
        do {
            // Sets collectionList to the decodes CollectionList
            collectionList = try JSONDecoder().decode(CollectionList.self, from: data)
            completionHandler(true, nil)
        } catch {
            print("Error while decoding data \(error)")
            completionHandler(false, error)
        }
    }
    
    
    /*
     
     function: fetchCollect
     url: String
     collectID: Int  (The Collection ID that will be associated with the collectList)
     completionHandler: @escaping (Bool, Error, CollectList?) -> () -> For later
     Makes a get request to get the collects of each collection, once it has been called then the response will send back the json for the collects and run through the decode collect function to create the collectList for that collection and also associate the collectList to that collection ID.
     */

    
    public func fetchCollect(url: String, collectID: Int, _ completionHandler: @escaping (Bool, Error?, CollectList?) -> () ) {
        let manager = Alamofire.SessionManager.default
        
        let request = manager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseJSON { response in
            switch response.result {
            case .success:
                if let data = response.data {
                    self.decodeCollect(data: data, collectID: collectID, { (success, error, collectList) in
                        if success {
                            completionHandler(true, nil, collectList)
                        } else {
                            if let error = error {
                                print("Error while decoding data \(error)")
                                completionHandler(false, error, nil)
                                return
                            }
                            completionHandler(false, nil, nil)
                        }
                    })
                }
            case .failure:
                print("Failure")
                completionHandler(false, response.error, nil)
            }
        }
    }
    
    /*
     
     function: decodeCollect
     data: Data
     collectID:  Int  (The Collection ID that will be associated with the collectList)
     completionHandler: @escaping (Bool, Error) -> ()
     Decodes the JSON data into a CollectList and then adds it to the collectMap
     
     */
    
    private func decodeCollect(data: Data, collectID: Int, _ completionHandler: (Bool, Error?, CollectList?) -> () ) {
        do {
            let collectL = try JSONDecoder().decode(CollectList.self, from: data)
            collectMap[collectID] = collectL
            completionHandler(true, nil, collectL)
        } catch {
            print("Error while decoding data \(error)")
            completionHandler(false, error, nil)
        }
    }
    
    /*
     
     function: fetchProduct
     url: String
     collectID: Int  (The Collection ID that will be associated with the product array)
     completionHandler: @escaping (Bool, Error) -> () -> For later
     Makes a single get request to get all of the productsID that is found in the URL. The reponse will send back a JSOn and it will then be decoded in a productList. which will have a productArray inside.
     */
    
    public func fetchProduct(url: String, collectID: Int, _ completionHandler: @escaping (Bool, Error?) -> () ) {
        let manager = Alamofire.SessionManager.default
        
        let request = manager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseJSON { response in
            switch response.result {
            case .success:
                if let data = response.value as? [String: Any]{
                    print(data)
                }
                if let data = response.data {
                    self.decodeProduct(data: data, collectID: collectID, { (success, error) in
                        if success {
                            completionHandler(true, nil)
                        } else {
                            if let error = error {
                                print("Error while decoding data \(error)")
                                completionHandler(false, error)
                                return
                            }
                            completionHandler(false, nil)
                        }
                    })
                }
            case .failure:
                print("Failure")
                completionHandler(false, response.error)
            }
        }
    }
    
    
    /*
     
     function: decodeProduct
     data: Data
     collectID:  Int  (The Collection ID that will be associated with the productByID)
     completionHandler: @escaping (Bool, Error) -> ()
     Decodes the JSON data while checking for duplicates and null values.
     
     */
    
    private func decodeProduct(data: Data, collectID: Int,_ completionHandler: (Bool, Error?) -> () ) {
        do {
            
            let productList = try JSONDecoder().decode(ProductList.self, from: data)
            
            // Check if the productByID is null if it is set the productsArray to it.
            if productByID[collectID] == nil {
                productByID[collectID] = productList.products
            } else {
                // If not nil then check if the product is contained within productByID
                guard let productL = productByID[collectID] else {
                    print("Failed to get old productByID")
                    return
                }
                for product in productList.products {
                    // If it does not contain then append the product
                    if !productL.contains(where: { (proc) -> Bool in
                        proc.id == product.id
                    }) {
                        productByID[collectID]?.append(product)
                    }
                }
            }
            completionHandler(true, nil)
        } catch {
            print("Error while decoding data \(error)")
            completionHandler(false, error)
        }
    }
}
