//
//  HomeiPadVC.swift
//  NewsApp
//
//  Created by Jayashree on 04/04/19.
//  Copyright © 2019 Fafadia Tech. All rights reserved.
//

import UIKit
import XLPagerTabStrip
class HomeiPadVC: UIViewController {
var tabBarTitle: String = ""
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension HomeiPadVC: IndicatorInfoProvider{
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: tabBarTitle)
    }
}
