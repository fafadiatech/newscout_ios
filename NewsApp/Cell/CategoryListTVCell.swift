//
//  CategoryListTVCell.swift
//  NewsApp
//
//  Created by Jayashree on 05/10/18.
//  Copyright © 2018 Fafadia Tech. All rights reserved.
//

import UIKit

class CategoryListTVCell: UITableViewCell {
    
    @IBOutlet weak var lblCategoryName: UILabel!
    @IBOutlet weak var btnDelete: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
