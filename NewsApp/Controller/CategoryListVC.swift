//
//  CategoryListVC.swift
//  NewsApp
//
//  Created by Jayashree on 05/10/18.
//  Copyright © 2018 Fafadia Tech. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import MaterialComponents.MaterialActivityIndicator
protocol CategoryListProtocol {
    func updateCategoryList(catName: String)
    func deleteCategory(currentCategory: String)
}

class CategoryListVC: UIViewController {
    
    @IBOutlet weak var tableCategoryLIst: UITableView!
    var protocolObj : CategoryListProtocol?
    var showCategory = [Category]()
    var CategoryData = [CategoryList]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        APICall().loadCategoriesAPI{ response in
            switch response {
            case .Success(let data) :
                self.CategoryData = data
                self.tableCategoryLIst.reloadData()
            case .Failure(let errormessage) :
                print(errormessage)
            }
        }
        /*  let coredataRecordCount = DBManager().IsCategoryDataEmpty()
         if coredataRecordCount != 0{
         let result = DBManager().FetchCategoryFromDB()
         switch result {
         case .Success(let DBData) :
         self.showCategory = DBData
         self.categoryCount = self.showCategory.count
         self.tableCategoryLIst.reloadData()
         case .Failure(let errorMsg) :
         print(errorMsg)
         }
         }
         else{
         DBManager().SaveCategoryDB{response in
         if response == true{
         let result = DBManager().FetchCategoryFromDB()
         switch result {
         case .Success(let DBData) :
         self.showCategory = DBData
         self.categoryCount = self.showCategory.count
         self.tableCategoryLIst.reloadData()
         case .Failure(let errorMsg) :
         print(errorMsg)
         }
         }
         }
         }*/
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        APICall().loadCategoriesAPI{ response in
            switch response {
            case .Success(let data) :
                self.CategoryData = data
                self.tableCategoryLIst.reloadData()
            case .Failure(let errormessage) :
                print(errormessage)
            }
        }
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func btnBackAction(_ sender: Any) {
        self.dismiss(animated:false)
    }
    
    @objc func deleteCat(sender: UIButton){
        let indexPath = sender.tag
        let selectedCategory = CategoryData[0].categories[indexPath].title!
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
        return (CategoryData.count != 0) ? self.CategoryData[0].categories.count : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableCategoryLIst.dequeueReusableCell(withIdentifier: "CategoryListID", for:indexPath) as! CategoryListTVCell
        let catData = CategoryData[0].categories[indexPath.row]
        if textSizeSelected == 0{
            cell.lblCategoryName.font = Constants.smallFont
        }
        else if textSizeSelected == 2{
            cell.lblCategoryName.font = Constants.LargeFont
        }
        else{
            cell.lblCategoryName.font =  Constants.NormalFont
        }
        cell.lblCategoryName.text = catData.title
        cell.btnDelete.tag = indexPath.row
        if categories.contains(catData.title!){
            cell.btnDelete.isHidden = false
        }
        else{
            cell.btnDelete.isHidden = true
        }
        cell.btnDelete.addTarget(self, action: #selector(deleteCat), for: .touchUpInside)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCat = CategoryData[0].categories[indexPath.row].title!
        if !categories.contains(selectedCat){
            protocolObj?.updateCategoryList(catName: selectedCat)
            var Homevc = HomeVC()
            Homevc.selectedCategory = selectedCat
        }
        else{
            self.view.makeToast("Category is already added..", duration: 1.0, position: .center)
        }
    }
}

extension CategoryListVC:IndicatorInfoProvider{
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "MORE")
    }
}

