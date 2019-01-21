//
//  ViewController.swift
//  ShopifyChallenge
//
//  Created by Philip Tam on 2019-01-15.
//  Copyright © 2019 Philip Tam. All rights reserved.
//

import UIKit
import ChameleonFramework

class CustomCollectionController: UIViewController {
    
    // Table View
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            
            let nib = UINib(nibName: "CustomCollectionCell", bundle: nil)
            tableView.register(nib, forCellReuseIdentifier:  "CustomCollectionCell")
        }
    }
    
    // Variables to send to the CollectionDetailsController
    var collectToSend: CollectList?
    var collectionToSend: CustomCollection?
    var sumToSend: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UI Setup
        setupNav()
        
        // Fetch the collections
        fetchCollections()
    }
    
    func setupNav() {
        
        //  Left Bar Item Label Setup
        let productCountLabel = UILabel()
        productCountLabel.text = "Unique Product"
        productCountLabel.numberOfLines = 2
        productCountLabel.font = UIFont(name: "Helvetica-Light", size: 14)!
        
        // Sets the size so that it fits the navigation bar
        productCountLabel.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        
        let rightItem = UIBarButtonItem(customView: productCountLabel)
        self.navigationItem.rightBarButtonItem = rightItem
        
        // Navigation Controller Setup
        self.navigationItem.title = "Custom Collections"
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.tintColor = UIColor.black
        navigationController?.view.backgroundColor = UIColor.black
        
        // Shadow
        navigationController?.navigationBar.layer.masksToBounds = false
        navigationController?.navigationBar.layer.shadowColor = UIColor.lightGray.cgColor
        navigationController?.navigationBar.layer.shadowOpacity = 0.8
        navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        navigationController?.navigationBar.layer.shadowRadius = 1
        
        // Font Setup && Text Color
        guard let font = UIFont(name: "Helvetica-Light", size: 21) else {return}
        
        let textAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.foregroundColor: UIColor.black,   NSAttributedString.Key.font: font as Any]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
    }
    
    
    // Fetch the Collections
    func fetchCollections() {
        
        // Custom Collection URL
        let challengeURL = "https://shopicruit.myshopify.com/admin/custom_collections.json?page=1&access_token=c32313df0d0ef512ca64d5b336a0d7c6"
        
        
        // Fetch the Collections from the URL
        DataFetcher.shared.fetchCollection(url: challengeURL) { (success, error) in
            if success {
                // Success so collectionList is created
                DataFetcher.shared.collectionList?.collections.forEach({ (collection) in
                    
                    // From Collection List fetch from each collection their collectList
                    let collectURL = "https://shopicruit.myshopify.com/admin/collects.json?collection_id=\(collection.id)&page=1&access_token=c32313df0d0ef512ca64d5b336a0d7c6"
                    
                    // Fetch Collects from each Collection
                    DataFetcher.shared.fetchCollect(url: collectURL, collectID: collection.id) { (success, error, collectList) in
                        if success {
                            // Once it has been fetched reload tableView
                            self.tableView.reloadData()
                        } else {
                            if let error = error {
                                print("Error while fetching collect \(error)")
                            } else {
                                print("No error but failed to fetch collect")
                            }
                        }
                    }
                })
            } else {
                if let error = error {
                    print("Error while fetching data: \(error)")
                    return
                }
                print("No error failure")
            }
        }
    }
    
    // Gets the Product Count on the Right of the Cell
    private func getProductCount(indexPath: IndexPath) -> Int {
        guard let collection = DataFetcher.shared.collectionList?.collections[indexPath.row] else {return 0}
        guard let collectList = DataFetcher.shared.collectMap[collection.id] else {return 0}
        var sum = 0
        var check: [Collect] = []
        for collect in collectList.collects {
            if !check.contains(where: { (c) -> Bool in
                c.id == collect.id
            }) {
                check.append(collect)
                sum += 1
            }
        }
        return sum
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToDetails" {
            // Send all of the necessary data to the CollectionDetailsController
            guard let dest = segue.destination as? CollectionDetailController else {return}
            dest.collection = collectionToSend
            dest.collectList = collectToSend
            dest.sum = sumToSend
        }
    }
}


/*
    TableView Delegate and Datasource methods
 */

extension CustomCollectionController: UITableViewDataSource, UITableViewDelegate {
    
    // Collection Count
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DataFetcher.shared.collectionList?.collections.count ?? 0
    }
    
    // Sets up the UI for the Cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let model = tableView.dequeueReusableCell(withIdentifier: "CustomCollectionCell", for: indexPath)
        guard let cell = model as? CustomCollectionCell else {return model}
        
        guard let collection = DataFetcher.shared.collectionList?.collections[indexPath.row] else {return cell }
        
        // Collection Title
        cell.collectionLabel.text = collection.title.getStringRemoving(r: "collection")
        
        
        // Collection Image
        guard let url = URL(string: collection.image.src) else {return cell}

        cell.collectionImageView.sd_setImage(with: url, completed: nil)
        
        cell.collectionImageView.layer.cornerRadius = cell.collectionImageView.frame.height / 2
        
        
        // Count
        cell.productCountLabel.text = "\(getProductCount(indexPath: indexPath))"
        
        
        return cell
    }
    
    // Height for Row
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    /*
        Once Selected a tableviwe sets the collectionToSend, collectToSend, sumToSend
        performSegue to CollectionDetailsController
     */
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let collection = DataFetcher.shared.collectionList?.collections[indexPath.row] else {
            print("Failed to get collection")
            return
        }
        
        collectionToSend = collection
        collectToSend = DataFetcher.shared.collectMap[collection.id]
        sumToSend = getProductCount(indexPath: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "goToDetails", sender: self)
    }
    
}



