//
//  ChildViewController.swift
//  NewsApp
//
//  Created by Jayashree on 01/03/19.
//  Copyright © 2019 Fafadia Tech. All rights reserved.
//

import UIKit
import Foundation
import XLPagerTabStrip

class ChildViewController:  UIViewController, IndicatorInfoProvider {


        var childrenVC = [UIViewController]()
        var itemInfo: IndicatorInfo = "submenu"
        var categories = ["cat1", "cat2", "cat3", "cat4"]
    
        init(itemInfo: IndicatorInfo) {
            self.itemInfo = itemInfo
            super.init(nibName: nil, bundle: nil)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = "XLPagerTabStrip"
            
            view.addSubview(label)
            view.backgroundColor = .white
            let childMore = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CategoryListID") as! CategoryListVC
            view.addSubview(childMore.view)
            view.addConstraint(NSLayoutConstraint(item: label, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0))
            view.addConstraint(NSLayoutConstraint(item: label, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: -50))
        }

        
        // MARK: - IndicatorInfoProvider
        func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
            return itemInfo
        }
    }

    
