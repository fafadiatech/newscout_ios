//
//  ClusterTVCell.swift
//  NewsApp
//
//  Created by Jayashree on 17/04/19.
//  Copyright © 2019 Fafadia Tech. All rights reserved.
//

import UIKit

class ClusterTVCell: UITableViewCell {
    @IBOutlet weak var viewCellContainer: UIView!
    @IBOutlet weak var ViewCellBackground: UIView!
    @IBOutlet weak var lblSource: UILabel!
    @IBOutlet weak var lblNewsHeading: UILabel!
    @IBOutlet weak var imgNews: UIImageView!
    @IBOutlet weak var lblCount: UILabel!
    
    @IBOutlet weak var imgCount: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

        
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
