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
import NightNight

protocol CategoryListProtocol {
    func updateCategoryList(catName: String)
    func deleteCategory(currentCategory: String)
}

class CategoryListVC: UIViewController {
    
    @IBOutlet weak var tableCategoryLIst: UITableView!
    var protocolObj : CategoryListProtocol?
    var showCategory = [Category]()
    var CategoryData = [CategoryList]()
    var selectedCat = ""
    let activityIndicator = MDCActivityIndicator()
    var  categories : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(darkModeEnabled(_:)), name: .darkModeEnabled, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(darkModeDisabled(_:)), name: .darkModeDisabled, object: nil)
        categories = UserDefaults.standard.array(forKey: "categories") as! [String]
        activityIndicator.cycleColors = [.blue]
        activityIndicator.frame = CGRect(x: view.frame.width/2, y: view.frame.height/2 - 100, width: 40, height: 40)
        activityIndicator.sizeToFit()
        activityIndicator.indicatorMode = .indeterminate
        activityIndicator.progress = 2.0
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        if (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad){
            tableCategoryLIst.rowHeight = 70;
        }
        else {
            tableCategoryLIst.rowHeight = 50;
        }
        let coredataRecordCount = DBManager().IsCategoryDataEmpty()
        if coredataRecordCount != 0{
            fetchCategoryFromDB()
        }
        else{
            saveCategoryInDB()
        }
    }
    
    @objc private func darkModeEnabled(_ notification: Notification) {
        NightNight.theme = .night
        tableCategoryLIst.backgroundColor = colorConstants.grayBackground3
    }
    
    @objc private func darkModeDisabled(_ notification: Notification) {
        NightNight.theme = .normal
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .darkModeEnabled, object: nil)
        NotificationCenter.default.removeObserver(self, name: .darkModeDisabled, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func btnBackAction(_ sender: Any) {
        self.dismiss(animated:false)
    }
    
    func fetchCategoryFromDB(){
        let result = DBManager().FetchCategoryFromDB()
        switch result {
        case .Success(let DBData) :
            self.showCategory = DBData
            self.tableCategoryLIst.reloadData()
        case .Failure(let errorMsg) :
            self.tableCategoryLIst.makeToast(errorMsg, duration: 2.0, position: .center)
        }
    }
    
    func saveCategoryInDB(){
        DBManager().SaveCategoryDB{response in
            if response == true{
                self.fetchCategoryFromDB()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension CategoryListVC:UITableViewDelegate, UITableViewDataSource{
    func SaveRemoveCategoryAPICall(type: String){
        APICall().saveRemoveCategoryAPI(category: selectedCat, type: type){response in
            switch response {
            case .Success(let msg) :
                self.tableCategoryLIst.makeToast(msg, duration: 2.0, position: .center)
            case .Failure(let error) :
                self.tableCategoryLIst.makeToast(error, duration: 2.0, position: .center)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (showCategory.count != 0) ? self.showCategory.count : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableCategoryLIst.dequeueReusableCell(withIdentifier: "CategoryListID", for:indexPath) as! CategoryListTVCell
        let catData = showCategory[indexPath.row]
        var textSizeSelected = UserDefaults.standard.value(forKey: "textSize") as! Int
        if (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone){
            if textSizeSelected == 0{
                cell.lblCategoryName.font = UIFont(name: AppFontName.bold, size: 18)
            }
            else if textSizeSelected == 2{
                cell.lblCategoryName.font = UIFont(name: AppFontName.bold, size: 20)
            }
            else{
                cell.lblCategoryName.font =  UIFont(name: AppFontName.bold, size: 22)
            }
        }
        else{
            if textSizeSelected == 0{
                cell.lblCategoryName.font = UIFont(name: AppFontName.bold, size: 30)
            }
            else if textSizeSelected == 2{
                cell.lblCategoryName.font = UIFont(name: AppFontName.bold, size: 34)
            }
            else{
                cell.lblCategoryName.font =  UIFont(name: AppFontName.bold, size: 32)
            }
        }
        
        cell.lblCategoryName.text = catData.title
       
        if categories.contains(catData.title!){
             cell.imgDelete.isHidden = false
        }
        else{
            cell.imgDelete.isHidden = true
        }
        if cell.lblCategoryName.text == "Trending"{
            if UserDefaults.standard.value(forKey: "token") == nil{
                cell.isUserInteractionEnabled = false
                cell.imgDelete.isHidden = true
            }
        }
        let darkModeStatus = UserDefaults.standard.value(forKey: "darkModeEnabled") as! Bool
        if  darkModeStatus == true{
            cell.backgroundColor = colorConstants.grayBackground2
            cell.lblCategoryName.textColor = colorConstants.nightModeText
            NightNight.theme =  .night
        }
        else{
            NightNight.theme =  .normal
        }
        activityIndicator.stopAnimating()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCat = showCategory[indexPath.row].title!
        
        if !categories.contains(selectedCat){
            protocolObj?.updateCategoryList(catName: selectedCat)
            SaveRemoveCategoryAPICall(type: "save")
            let Homevc = HomeVC()
            Homevc.selectedCategory = selectedCat
        }
        else{
            protocolObj?.deleteCategory(currentCategory: selectedCat)
            SaveRemoveCategoryAPICall(type: "delete")
            categories = UserDefaults.standard.array(forKey: "categories") as! [String]
            tableCategoryLIst.reloadData()
        }
    }
}

extension CategoryListVC:IndicatorInfoProvider{
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Categories")
    }
}
