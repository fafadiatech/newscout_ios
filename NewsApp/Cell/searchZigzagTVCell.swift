//
//  searchZigzagTVCell.swift
//  NewsApp
//
//  Created by Jayashree on 01/04/19.
//  Copyright © 2019 Fafadia Tech. All rights reserved.
//

import UIKit

class searchZigzagTVCell: UITableViewCell {
    @IBOutlet weak var lblSource: UILabel!
    @IBOutlet weak var lblNewsDescription: UILabel!
    @IBOutlet weak var imgNews: UIImageView!
    @IBOutlet weak var ViewCellBackground: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
