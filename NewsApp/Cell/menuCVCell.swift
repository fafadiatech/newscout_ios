//
//  menuCVCell.swift
//  sampleSubmenuCV
//
//  Created by Jayashree on 15/05/19.
//  Copyright © 2019 Fafadia Tech. All rights reserved.
//

import UIKit

class menuCVCell: UICollectionViewCell {
     var shouldTintBackgroundWhenSelected = true
    @IBOutlet var lblMenu: UILabel!
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
