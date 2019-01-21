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

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            let nib = UINib(nibName: "CollectionDetailCell", bundle: nil)
            tableView.register(nib, forCellReuseIdentifier: "CollectionDetailCell")
            
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
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
    @IBOutlet weak var descriptionView: UIView! {
        didSet {
            let upGes = UISwipeGestureRecognizer(target: self, action: #selector(lowerDescriptionHeight))
            upGes.direction = .up
            
            self.descriptionView.addGestureRecognizer(upGes)
            
        }
    }
    
    @IBOutlet weak var uniqueProductLabel: UILabel!
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var collectionImageView: UIImageView!
    @IBOutlet weak var descriptionlabel: UILabel!
    @IBOutlet weak var descriptionHeightConstraint: NSLayoutConstraint!
    
    var products: [Product] = []
    var collection: CustomCollection?
    var collectList: CollectList?
    var sum: Int = 0
 
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNav()
        setupDescriptionView()
        
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
        let productCountLabel = UILabel()
        productCountLabel.text = "QTY"
        productCountLabel.font = UIFont(name: "Helvetica", size: 14)!
        productCountLabel.sizeToFit()
        
        let rightItem = UIBarButtonItem(customView: productCountLabel)
        self.navigationItem.rightBarButtonItem = rightItem
        
        self.navigationItem.title = collection?.title.getStringRemoving(r: "collection")
    }
    
    
    func setupDescriptionView() {
        guard let collection = collection else {
            print("Collection Failed")
            return
        }
        
        if collection.bodyHtml == "" {
            descriptionlabel.text = "No Description"
        } else {
            
            descriptionlabel.text = collection.bodyHtml
        }
        
        
        guard let url = URL(string: collection.image.src) else {
            print("Image URL FAILED")
            return
        }
       
        collectionImageView.sd_setImage(with: url, completed: nil)
        
        uniqueProductLabel.text = "Unique Products: \(sum)"
    }
    
    func checkIfFetched(id: Int) -> Bool {
        
        guard let list =  DataFetcher.shared.productByID[id] else {
            return false
        }
        
        products = list
        
        if products.count > 0 {
            return true
        } else {
            return false
        }
    }
    
    func fetchProductList(id: Int, _ completionHandler: @escaping (Bool) -> ()) {
        
        guard let collectList = collectList else {
            print("COLLECT IS NIL")
            completionHandler(false)
            return
        }
        
        var productIDStr = ""
        
        for collect in collectList.collects {
            productIDStr.append("\(collect.productID),")
        }
        
        let productURL = "https://shopicruit.myshopify.com/admin/products.json?ids=\(productIDStr)&page=1&access_token=c32313df0d0ef512ca64d5b336a0d7c6"
        
        DataFetcher.shared.fetchProduct(url: productURL, collectID: id, { (success, error) in
            if success {
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


extension CollectionDetailController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return products.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
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
        
        let collectionT = collection.title.getStringRemoving(r: "collection")
        
        cell.collectionLabel.text = collectionT
        
        cell.titleLabel.text = product.title.getStringRemoving(r: collectionT)
        
        var sum = 0
        for variant in product.variants {
            sum += variant.inventoryQuan
        }
        
        cell.inventoryLabel.text = "\(sum)"
        
        guard let url = URL(string: product.image.src) else {return cell}
        guard let collectionURL = URL(string: collection.image.src) else {return cell}
        
        cell.productImageView.sd_setImage(with: url, completed: nil)
        
        DispatchQueue.global().async {
            let data = try? Data(contentsOf: collectionURL) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
            DispatchQueue.main.async {
                cell.collectionImageView.image = UIImage(data: data!)?.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: 0, bottom: -2, right: 0))
            }
        }
        
        cell.collectionImageView.layer.cornerRadius = cell.collectionImageView.frame.height / 2
        cell.collectionImageView.clipsToBounds = true
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath,  animated: true)
    }
}

extension CollectionDetailController {
    
    @objc func tapHeight() {
        if descriptionHeightConstraint.constant == 0 {
            increaseDescriptionHeight()
        } else {
            lowerDescriptionHeight()
        }
    }
    
    @objc func lowerDescriptionHeight() {
        UIView.animate(withDuration: 0.1) {
            self.collectionImageView.alpha = 0
            if let _ = self.descriptionlabel {
                self.descriptionlabel.alpha = 0
            }
            self.uniqueProductLabel.alpha = 0
        }
        UIView.animate(withDuration: 0.3) {
            self.arrowImageView.transform =  CGAffineTransform.identity
            self.descriptionHeightConstraint.constant = 0
            
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func increaseDescriptionHeight() {
        UIView.animate(withDuration: 0.3) {
            self.collectionImageView.alpha = 1
            if let _ = self.descriptionlabel {
                self.descriptionlabel.alpha = 1
            }
            self.uniqueProductLabel.alpha = 1
            self.arrowImageView.transform = CGAffineTransform(rotationAngle: .pi)
            
            self.descriptionHeightConstraint.constant = 110
            
            self.view.layoutIfNeeded()
        }
    }
}
