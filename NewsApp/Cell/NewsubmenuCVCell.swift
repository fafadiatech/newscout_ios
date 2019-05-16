//
//  NewsubmenuCVCell.swift
//  NewsApp
//
//  Created by Jayashree on 16/05/19.
//  Copyright © 2019 Fafadia Tech. All rights reserved.
//

import UIKit

class NewsubmenuCVCell: UICollectionViewCell {
     var shouldTintBackgroundWhenSelected = true
    @IBOutlet var lblSubmenu: UILabel!
    
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
            lblSubmenu.textColor = newValue ? colorConstants.redColor : UIColor.black
        }
    }
}
