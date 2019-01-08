//
//  BookmarkTVCell.swift
//  NewsApp
//
//  Created by Jayashree on 08/01/19.
//  Copyright © 2019 Fafadia Tech. All rights reserved.
//

import UIKit

class BookmarkTVCell: UITableViewCell {
    @IBOutlet weak var lblSource: UILabel!
    @IBOutlet weak var lblNewsDescription: UILabel!
    @IBOutlet weak var lbltimeAgo: UILabel!
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
