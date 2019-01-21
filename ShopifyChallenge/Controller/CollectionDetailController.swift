//
//  CollectionDetailController.swift
//  ShopifyChallenge
//
//  Created by Philip Tam on 2019-01-15.
//  Copyright © 2019 Philip Tam. All rights reserved.
//

import UIKit
import SDWebImage

class CollectionDetailController: UIViewController {
    
    //Table View
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            let nib = UINib(nibName: "CollectionDetailCell", bundle: nil)
            tableView.register(nib, forCellReuseIdentifier: "CollectionDetailCell")
            
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    // Details Views (Top View where it will display the text show or hide)
    @IBOutlet weak var detailsView: UIView! {
        didSet {
            let tapGes = UITapGestureRecognizer(target: self, action: #selector(tapHeight))
            self.detailsView.addGestureRecognizer(tapGes)
            let downGes = UISwipeGestureRecognizer(target: self, action: #selector(increaseDescriptionHeight))
            downGes.direction = .down
            self.detailsView.addGestureRecognizer(downGes)
            let upGes = UISwipeGestureRecognizer(target: self, action: #selector(lowerDescriptionHeight))
            upGes.direction = .up
            
            self.detailsView.addGestureRecognizer(upGes)
        }
    }
    
    // MARK: Description Label Outlets
    @IBOutlet weak var descriptionView: UIView! {
        didSet {
            let upGes = UISwipeGestureRecognizer(target: self, action: #selector(lowerDescriptionHeight))
            upGes.direction = .up
            
            self.descriptionView.addGestureRecognizer(upGes)
            
        }
    }
    
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var uniqueProductLabel: UILabel!
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var collectionImageView: UIImageView!
    @IBOutlet weak var descriptionlabel: UILabel!
    @IBOutlet weak var descriptionHeightConstraint: NSLayoutConstraint!
    
    // Tableview helper
    var products: [Product] = []
    
    // From the sent values
    var collection: CustomCollection?
    var collectList: CollectList?
    var sum: Int = 0
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup UI
        setupNav()
        setupDescriptionView()
        
        // Setup Product Fetching
        guard let id = collection?.id else {
            print("ID is not initialized")
            return
        }
        
        if !checkIfFetched(id: id) {
            print("To Fetch")
            fetchProductList(id: id) { (success) in
                if success {
                    print("Fetched")
                    self.tableView.reloadData()
                } else {
                    print("Failed")
                }
            }
        }
    }
    
    func setupNav() {
        // Right Label
        let productCountLabel = UILabel()
        productCountLabel.text = "QTY"
        productCountLabel.font = UIFont(name: "Helvetica", size: 14)!
        productCountLabel.sizeToFit()
        
        let rightItem = UIBarButtonItem(customView: productCountLabel)
        self.navigationItem.rightBarButtonItem = rightItem
        
        // Title
        self.navigationItem.title = collection?.title.getStringRemoving(r: "collection")
    }
    
    // Setups the Description Card (View)
    func setupDescriptionView() {
        guard let collection = collection else {
            print("Collection Failed")
            return
        }
        
        // Checks if there is a description if not indicate there is no description
        if collection.bodyHtml == "" {
            descriptionlabel.text = "No Description"
        } else {
            
            descriptionlabel.text = collection.bodyHtml
        }
        
        // Sets the Collection Image
        guard let url = URL(string: collection.image.src) else {
            print("Image URL FAILED")
            return
        }
       
        collectionImageView.sd_setImage(with: url, completed: nil)
        
        uniqueProductLabel.text = "Unique Products: \(sum)"
    }
    
    // Check if the products have been fetched if not then fetch them, if yes then it means that they re in product by ID
    func checkIfFetched(id: Int) -> Bool {
        
        guard let list =  DataFetcher.shared.productByID[id] else {
            return false
        }
        
        // Sets the Products
        products = list
        
        if products.count > 0 {
            return true
        } else {
            return false
        }
    }
    
    // Fetch the product by creating a single URL to access the necessary product JSON
    func fetchProductList(id: Int, _ completionHandler: @escaping (Bool) -> ()) {
        
        guard let collectList = collectList else {
            print("COLLECT IS NIL")
            completionHandler(false)
            return
        }
        
        // URL creation
        var productIDStr = ""
        
        for collect in collectList.collects {
            productIDStr.append("\(collect.productID),")
        }
        
        let productURL = "https://shopicruit.myshopify.com/admin/products.json?ids=\(productIDStr)&page=1&access_token=c32313df0d0ef512ca64d5b336a0d7c6"
        
        // Fetch the Product JSON and also associating the collection ID to those specific products (Product Array)
        DataFetcher.shared.fetchProduct(url: productURL, collectID: id, { (success, error) in
            if success {
                // Sets the products helper to the products of the collectionID
                self.products = DataFetcher.shared.productByID[id] ?? []
                completionHandler(success)
            } else {
                if let error = error {
                    print("Error while fetching product list \(error)")
                }
            }
        })
        
      
    }

}

/*
    MARK: TableView delegate and datasource methods
 */


extension CollectionDetailController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return products.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    // Cell UI Editing
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = tableView.dequeueReusableCell(withIdentifier: "CollectionDetailCell", for: indexPath)
        guard let cell = model as? CollectionDetailCell else {
            print("Cell Problem")
            return model
        }
        
        let product = products[indexPath.item]
        
        guard let collection = collection else {
            print("Collection problem")
            return cell
        }
        
        
        // create title removing redundant "collection" word
        let collectionT = collection.title.getStringRemoving(r: "collection")
        
        cell.collectionLabel.text = collectionT
        
        // create title removing redundant collection key word from every word"
        cell.titleLabel.text = product.title.getStringRemoving(r: collectionT)
        
        // Sums all fo the inventory quantity of each variant and set it to the inventoryLabel
        var sum = 0
        for variant in product.variants {
            sum += variant.inventoryQuan
        }
        
        cell.inventoryLabel.text = "\(sum)"
        
        
        // Image Setting
        guard let url = URL(string: product.image.src) else {return cell}
        guard let collectionURL = URL(string: collection.image.src) else {return cell}
        
        // Sets the productImageView with sdweb because it will facilitate cell changing
        cell.productImageView.sd_setImage(with: url, completed: nil)
        
        //Sets the image of the collectionImageView with UIEdgeInsets because it will adjust the height
        DispatchQueue.global().async {
            let data = try? Data(contentsOf: collectionURL)
            DispatchQueue.main.async {
                cell.collectionImageView.image = UIImage(data: data!)?.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: 0, bottom: -2, right: 0))
            }
        }
        
        // Rounding the imageView
        cell.collectionImageView.layer.cornerRadius = cell.collectionImageView.frame.height / 2
        cell.collectionImageView.clipsToBounds = true
        
        return cell
    }
    
    // Deselect the row (UI Purpose)
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath,  animated: true)
    }
}


// MARK: Details Expansion Functions
extension CollectionDetailController {
    
    // Expands or hides the descriptionView by changing its height depending on its current height
    @objc func tapHeight() {
        if descriptionHeightConstraint.constant == 0 {
            increaseDescriptionHeight()
        } else {
            lowerDescriptionHeight()
        }
    }
    
    // If lowering handle the hiding of the description View
    @objc func lowerDescriptionHeight() {
        // Changes the title of the label
        self.detailsLabel.text = "Show details"
        
        // Hides the views inside of the descriptionView to smoothen out the animation
        UIView.animate(withDuration: 0.1) {
            self.collectionImageView.alpha = 0
            if let _ = self.descriptionlabel {
                self.descriptionlabel.alpha = 0
            }
            self.uniqueProductLabel.alpha = 0
        }
        
        // Changes the height, and the arrow direction
        UIView.animate(withDuration: 0.3) {
            self.arrowImageView.transform =  CGAffineTransform.identity
            self.descriptionHeightConstraint.constant = 0
            
            // Will layout the constraint animations
            self.view.layoutIfNeeded()
        }
    }
    
    // If increasing handle the show of the description View
    @objc func increaseDescriptionHeight() {
        // Changes the title of the label
        self.detailsLabel.text = "Hide details"
        UIView.animate(withDuration: 0.3) {
            
            // Unhides the views inside of the descriptionView
            self.collectionImageView.alpha = 1
            if let _ = self.descriptionlabel {
                self.descriptionlabel.alpha = 1
            }
            
            // Changes the height, and the arrow direction
            self.uniqueProductLabel.alpha = 1
            self.arrowImageView.transform = CGAffineTransform(rotationAngle: .pi)
            
            self.descriptionHeightConstraint.constant = 110
            
            // Will layout the constraint animations
            self.view.layoutIfNeeded()
        }
    }
}
