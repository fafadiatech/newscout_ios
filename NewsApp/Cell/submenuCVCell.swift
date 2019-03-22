//
//  submenuCVCell.swift
//  NewsApp
//
//  Created by Jayashree on 01/03/19.
//  Copyright © 2019 Fafadia Tech. All rights reserved.
//

import UIKit
extension UIImageView {
    func setImageColor(color: UIColor) {
        let templateImage = self.image?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        self.image = templateImage
        self.tintColor = color
    }
}
class submenuCVCell: UICollectionViewCell {
    var shouldTintBackgroundWhenSelected = true // You can change default value

    @IBOutlet weak var lblMenu: UILabel!
    @IBOutlet weak var imgMenu: UIImageView!
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
            imgMenu.setImageColor(color: newValue ? colorConstants.redColor : UIColor.black)

        }
    }

//    override var isSelected: Bool {
//        didSet {
//            //self.contentView.backgroundColor = isSelected ? UIColor.blue : UIColor.yellow
//            //self.imgMenu.alpha = isSelected ? 0.75 : 1.0
//             lblMenu.textColor = isSelected ? colorConstants.redColor : UIColor.black
//        }
//    }

}
