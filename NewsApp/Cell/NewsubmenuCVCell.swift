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
    @IBOutlet weak var imgSubmenuBackground: UIImageView!
    let bottomLine = CALayer()
    
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
             bottomLine.frame = CGRect(x: 0.0, y: self.frame.height - 2, width: self.frame.width, height: 1.0)
            lblSubmenu.textColor = newValue ? colorConstants.redColor : UIColor.black
          //  self.backgroundColor = newValue ? colorConstants.cardNormalBackground : .white
          //  bottomLine.backgroundColor = newValue ? UIColor.red.cgColor : UIColor.white.cgColor
           // self.layer.addSublayer(bottomLine)
        }
    }
    
    /*
    
     
    
     if cell.isSelected{
     cell.backgroundColor = .lightGray
     bottomLine.backgroundColor = UIColor.red.cgColor
     }
     //            else{
     //                bottomLine.backgroundColor = UIColor.lightGray.cgColor
     //            }
     
     
     
     
 */
}
