//
//  submenuCVCell.swift
//  NewsApp
//
//  Created by Jayashree on 01/03/19.
//  Copyright © 2019 Fafadia Tech. All rights reserved.
//

import UIKit

class submenuCVCell: UICollectionViewCell {
    var shouldTintBackgroundWhenSelected = true // You can change default value

    @IBOutlet weak var lblMenu: UILabel!

    override var isHighlighted: Bool {
        willSet {
            onSelected(newValue)
        }
    }
    override var isSelected: Bool {
        willSet {
            onSelected(newValue)
        }
    }
    func onSelected(_ newValue: Bool) {
        guard selectedBackgroundView == nil else { return }
        if shouldTintBackgroundWhenSelected {
            lblMenu.textColor = newValue ? colorConstants.redColor : UIColor.black
        }
    }

    

}
