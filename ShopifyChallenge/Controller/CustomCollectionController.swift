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
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            
            let nib = UINib(nibName: "CustomCollectionCell", bundle: nil)
            tableView.register(nib, forCellReuseIdentifier:  "CustomCollectionCell")
        }
    }
    
    var collectToSend: CollectList?
    var collectionToSend: CustomCollection?
    var sumToSend: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNav()
        fetchCollections()
    }
    
    func setupNav() {
        
        let productCountLabel = UILabel()
        productCountLabel.text = "Unique Product"
        productCountLabel.numberOfLines = 2
        productCountLabel.font = UIFont(name: "Helvetica-Light", size: 14)!
        productCountLabel.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        
        let rightItem = UIBarButtonItem(customView: productCountLabel)
        self.navigationItem.rightBarButtonItem = rightItem
        
        self.navigationItem.title = "Custom Collections"
        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.backgroundColor = UIColor.white
        navigationController?.view.backgroundColor = UIColor.black
        
        // Shadow
        navigationController?.navigationBar.layer.masksToBounds = false
        navigationController?.navigationBar.layer.shadowColor = UIColor.lightGray.cgColor
        navigationController?.navigationBar.layer.shadowOpacity = 0.8
        navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        navigationController?.navigationBar.layer.shadowRadius = 1
        
        // Font
        guard let font = UIFont(name: "Helvetica-Light", size: 21) else {return}
        
        let textAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.foregroundColor: UIColor.black,   NSAttributedString.Key.font: font as Any]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
    }
    
    func fetchCollections() {
        
        let challengeURL = "https://shopicruit.myshopify.com/admin/custom_collections.json?page=1&access_token=c32313df0d0ef512ca64d5b336a0d7c6"
        
        DataFetcher.shared.fetchCollection(url: challengeURL) { (success, error) in
            if success {
                DataFetcher.shared.collectionList?.collections.forEach({ (collection) in
                    
                    let collectURL = "https://shopicruit.myshopify.com/admin/collects.json?collection_id=\(collection.id)&page=1&access_token=c32313df0d0ef512ca64d5b336a0d7c6"
                    DataFetcher.shared.fetchCollect(url: collectURL, collectID: collection.id) { (success, error, collectList) in
                        if success {
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
}

extension CustomCollectionController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DataFetcher.shared.collectionList?.collections.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let model = tableView.dequeueReusableCell(withIdentifier: "CustomCollectionCell", for: indexPath)
        guard let cell = model as? CustomCollectionCell else {return model}
        
        guard let collection = DataFetcher.shared.collectionList?.collections[indexPath.row] else {return cell }
        
        cell.collectionLabel.text = collection.title.getStringRemoving(r: "collection")
        
        guard let url = URL(string: collection.image.src) else {return cell}

        cell.collectionImageView.sd_setImage(with: url, completed: nil)
        
        cell.collectionImageView.layer.cornerRadius = cell.collectionImageView.frame.height / 2
        
        cell.productCountLabel.text = "\(getProductCount(indexPath: indexPath))"
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let collection = DataFetcher.shared.collectionList?.collections[indexPath.row] else {
            print("Failed to get collection")
            return
        }
        
        collectionToSend = collection
        collectToSend = DataFetcher.shared.collectList[collection.id]
        sumToSend = getProductCount(indexPath: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
        
        performSegue(withIdentifier: "goToDetails", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToDetails" {
            guard let dest = segue.destination as? CollectionDetailController else {return}
            dest.collection = collectionToSend
            dest.collectList = collectToSend
            dest.sum = sumToSend
        }
    }
    
    private func getProductCount(indexPath: IndexPath) -> Int {
        guard let collection = DataFetcher.shared.collectionList?.collections[indexPath.row] else {return 0}
        guard let collectList = DataFetcher.shared.collectList[collection.id] else {return 0}
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
}



