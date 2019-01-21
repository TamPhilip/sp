//
//  CollectionDetailCell.swift
//  ShopifyChallenge
//
//  Created by Philip Tam on 2019-01-18.
//  Copyright © 2019 Philip Tam. All rights reserved.
//

import UIKit

class CollectionDetailCell: UITableViewCell {

    @IBOutlet weak var productImageView: UIImageView! {
        didSet {
            productImageView.clipsToBounds = true
        }
    }
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectionLabel: UILabel!
    @IBOutlet weak var collectionImageView: UIImageView!
    @IBOutlet weak var inventoryLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
    
    override func draw(_ rect: CGRect) {
        productImageView.layer.cornerRadius = self.productImageView.frame.height / 2
    }
    
}
