//
//  sourceTVCell.swift
//  NewsApp
//
//  Created by Jayashree on 27/03/19.
//  Copyright © 2019 Fafadia Tech. All rights reserved.
//

import UIKit

class sourceTVCell: UITableViewCell {
    @IBOutlet weak var lblSource: UILabel!
    @IBOutlet weak var lblNewsDescription: UILabel!
    @IBOutlet weak var imgNews: UIImageView!
    @IBOutlet weak var ViewCellBackground: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
