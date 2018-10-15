//
//  SearchResultTVCell.swift
//  NewsApp
//
//  Created by Jayashree on 24/09/18.
//  Copyright © 2018 Fafadia Tech. All rights reserved.
//

import UIKit

class SearchResultTVCell: UITableViewCell {
    
    @IBOutlet weak var lblSource: UILabel!
    @IBOutlet weak var lblNewsDescription: UILabel!
    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var lbltimeAgo: UILabel!
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
