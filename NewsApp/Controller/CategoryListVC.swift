//
//  CategoryListVC.swift
//  NewsApp
//
//  Created by Jayashree on 05/10/18.
//  Copyright © 2018 Fafadia Tech. All rights reserved.
//

import UIKit
import XLPagerTabStrip

protocol categoryListProtocol {
    func updateCategoryList(catName: String)
    func deleteCategory(currentCategory: String)
}

class CategoryListVC: UIViewController {
    
    @IBOutlet weak var tableCategoryLIst: UITableView!
    var protocolObj : categoryListProtocol?
    var catArr = ["ALL NEWS", "TRENDING", "TOP STORIES","NEWS", "TECHNOLOGY", "SPORTS", "POLITICS", "BUSINESS", "CELEBRITY", "NEWS", "INDIAN PARLIAMENT", "INDIAN RELIGION"]

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func btnBackAction(_ sender: Any) {
        self.dismiss(animated:false)
    }
    
    @objc func deleteCat(sender: UIButton)
    {
        let indexPath = sender.tag
        var selectedCategory = catArr[indexPath]
        protocolObj?.deleteCategory(currentCategory: selectedCategory)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc:HomeParentVC = storyboard.instantiateViewController(withIdentifier: "HomeParentID") as! HomeParentVC
        present(vc, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension CategoryListVC:UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return catArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableCategoryLIst.dequeueReusableCell(withIdentifier: "CategoryListID", for:indexPath) as! CategoryListTVCell
        cell.lblCategoryName.text = catArr[indexPath.row]
        cell.btnDelete.tag = indexPath.row
        if ParentCatArr.contains(catArr[indexPath.row]){
            cell.btnDelete.isHidden = false
        }
        else{
            cell.btnDelete.isHidden = true
        }
        cell.btnDelete.addTarget(self, action: #selector(deleteCat), for: .touchUpInside)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryListID", for: indexPath) as! CategoryListTVCell
        var selectedCat = catArr[indexPath.row]
        if !ParentCatArr.contains(selectedCat)
        {
            protocolObj?.updateCategoryList(catName: selectedCat)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc:HomeParentVC = storyboard.instantiateViewController(withIdentifier: "HomeParentID") as! HomeParentVC
            present(vc, animated: true, completion: nil)
        }
        else{
            let alertController = UIAlertController(title: "Category is already added..", message: "", preferredStyle: .alert)
            
            let action1 = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in }
            
            alertController.addAction(action1)
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
}

extension CategoryListVC:IndicatorInfoProvider{
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "MORE")
    }
}

