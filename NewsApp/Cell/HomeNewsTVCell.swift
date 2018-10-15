//
//  HomeNewsTVCell.swift
//  NewsApp
//
//  Created by Jayashri on 22/09/18.
//  Copyright © 2018 Fafadia Tech. All rights reserved.
//

import UIKit

class HomeNewsTVCell: UITableViewCell {
    
    @IBOutlet weak var ViewCellBackground: UIView!
    @IBOutlet weak var lblSource: UILabel!
    @IBOutlet weak var lblNewsHeading: UILabel!
    @IBOutlet weak var lblTimesAgo: UILabel!
    @IBOutlet weak var imgNews: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        ViewCellBackground.frame = UIEdgeInsetsInsetRect(contentView.frame, UIEdgeInsetsMake(15, 16, 15, 16))
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
