//
//  ReorderCollectionViewCell.swift
//  JSReorderableCollectionViewDemo
//
//  Created by JSilver on 12/09/2019.
//  Copyright © 2019 JSilver. All rights reserved.
//

import UIKit

class ReorderCollectionViewCell: UICollectionViewCell {
    @IBOutlet var textLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.cornerRadius = 10
    }

}
