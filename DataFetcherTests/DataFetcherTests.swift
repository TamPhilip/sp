//
//  DataFetcherTests.swift
//  DataFetcherTests
//
//  Created by Philip Tam on 2019-01-17.
//  Copyright © 2019 Philip Tam. All rights reserved.
//

import XCTest
@testable import ShopifyChallenge

class DataFetcherTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func test_A_fetchCollection() {

        let promise = expectation(description: "Collection received")

        let url = "https://shopicruit.myshopify.com/admin/custom_collections.json?page=1&access_token=c32313df0d0ef512ca64d5b336a0d7c6"

        DataFetcher.shared.fetchCollection(url: url, { (success, error) in
            if let error = error {
                print("Error while getting collections \(error)")
                XCTFail("Failed to get the collections")
                return
            }
            if success {
                promise.fulfill()
            } else {
                XCTFail("Failed to get the collections")
            }
        })

        waitForExpectations(timeout: 15, handler: nil)

    }

    func test_B_fetchCollectProduct() {

        let promise = expectation(description: "get product URLS received")

        guard let collectionList  = DataFetcher.shared.collectionList else {
            XCTFail("Failed")
            return
        }

        var collectionURLs: [Int:String] = [:]

        for collection in collectionList.collections {
            let url = "https://shopicruit.myshopify.com/admin/collects.json?collection_id=\(collection.id)&page=1&access_token=c32313df0d0ef512ca64d5b336a0d7c6"
            collectionURLs[collection.id] = url
        }

        let dispatchGroup = DispatchGroup()
    

        for (id, url) in collectionURLs {
            dispatchGroup.enter()
            DataFetcher.shared.fetchCollect(url: url, collectID: id) { (success, error, collect) in
                if success {
                    guard let collect = collect else {
                        XCTFail("Failed")
                        return
                    }
                    
                    var productIDStr = ""

                    for col in collect.collects {
                        productIDStr.append("\(col.productID),")
                    }
                    
                    let url = "https://shopicruit.myshopify.com/admin/products.json?ids=\(productIDStr)&page=1&access_token=c32313df0d0ef512ca64d5b336a0d7c6"
                    
                    DataFetcher.shared.fetchProduct(url: url, collectID: id) { (success, error) in
                        if success {
                            print("Got Product")
                            dispatchGroup.leave()
                        } else {
                            if let error = error {
                                print("Error while fetching collect \(error)")
                                XCTFail("Failed")
                                return
                            }
                            XCTFail("Failed")
                        }
                    }
                } else {
                    if let error = error {
                        print("Error while fetching collect \(error)")
                        XCTFail("Failed")
                        return
                    }
                    XCTFail("Failed")
                }
            }
        }


        dispatchGroup.notify(queue: .main) {
            promise.fulfill()
        }

        waitForExpectations(timeout: 30, handler: nil)

        XCTAssert(DataFetcher.shared.productByID.count != 0)
    }
}
