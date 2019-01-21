//
//  CustomCollectionCell.swift
//  ShopifyChallenge
//
//  Created by Philip Tam on 2019-01-18.
//  Copyright © 2019 Philip Tam. All rights reserved.
//

import UIKit

class CustomCollectionCell: UITableViewCell {

    @IBOutlet weak var collectionImageView: UIImageView!
    @IBOutlet weak var collectionLabel: UILabel!
    @IBOutlet weak var productCountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
