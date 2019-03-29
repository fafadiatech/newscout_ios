//
//  HomeImgTVCell.swift
//  NewsApp
//
//  Created by Jayashri on 29/03/19.
//  Copyright © 2019 Fafadia Tech. All rights reserved.
//

import UIKit

class HomeImgTVCell: UITableViewCell {
    @IBOutlet weak var ViewCellBackground: UIView!
    @IBOutlet weak var lblSource: UILabel!
    @IBOutlet weak var lblNewsHeading: UILabel!
    @IBOutlet weak var imgNews: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
