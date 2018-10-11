//
//  CategoryListVC.swift
//  NewsApp
//
//  Created by Jayashree on 05/10/18.
//  Copyright © 2018 Fafadia Tech. All rights reserved.
//

import UIKit
import XLPagerTabStrip
class CategoryListVC: UIViewController, UITableViewDelegate, UITableViewDataSource, IndicatorInfoProvider {
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "home")
        //return IndicatorInfo(title: "home")
    }
    
    //outlet
    @IBOutlet weak var tableCategoryLIst: UITableView!
    
    var catArr = ["NEWS", "TECHNOLOGY", "SPORTS", "POLITICS", "BUSINESS", "CELEBRITY", "NEWS", "INDIAN PARLIAMENT", "INDIAN RELIGION"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    //HIde status bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
    @IBAction func btnBackAction(_ sender: Any) {
        self.dismiss(animated:false)
    }
    //Tableview methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return catArr.count
    }
 
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = tableCategoryLIst.dequeueReusableCell(withIdentifier: "CategoryListID", for:indexPath) as! CategoryListTVCell
        cell.lblCategoryName.text = catArr[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        var selectedCat = catArr[indexPath.row]
        print("selectedCat: \(selectedCat)")
        
        var obj = ButtonBarPagerTabStripViewController()
        VCcount = VCcount + 1
        isCategoryAdded = 1
        obj.titleArr.append(selectedCat)
        print(obj.titleArr)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc:HomeParentVC = storyboard.instantiateViewController(withIdentifier: "HomeParentID") as! HomeParentVC
        present(vc, animated: true, completion: nil)
    
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
