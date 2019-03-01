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
import CoreData

class CategoryListVC: UIViewController {
    
    @IBOutlet weak var tableCategoryLIst: UITableView!
    let activityIndicator = MDCActivityIndicator()
    var tagData = [PeriodicTags]()
    var dailyTags = [PeriodicTags]()
    var monthlyTags = [PeriodicTags]()
    var weeklyTags = [PeriodicTags]()
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    var headerArr = ["Daily Tags", "Weekly Tags","Monthly Tags"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(darkModeEnabled(_:)), name: .darkModeEnabled, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(darkModeDisabled(_:)), name: .darkModeDisabled, object: nil)
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
        
        DBManager().saveTags()
        fetchTags()
    }
    
    func fetchTags(){
        var types = ["daily", "weekly", "monthly"]
        for type in types{
            let result = DBManager().fetchTags(type: type)
            switch(result){
            case .Success(let DBData) :
                if type == "daily"{
                    self.dailyTags = DBData
                }else if type == "weekly"{
                    self.weeklyTags = DBData
                }
                else if type == "monthly"{
                    self.monthlyTags = DBData
                }
                self.tableCategoryLIst.reloadData()
            case .Failure(let errorMsg) :
                print(errorMsg)
            }
        }
    }
    @objc private func darkModeEnabled(_ notification: Notification) {
        NightNight.theme = .night
        tableCategoryLIst.backgroundColor = colorConstants.grayBackground3
    }
    
    @objc private func darkModeDisabled(_ notification: Notification){
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension CategoryListVC:UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return headerArr.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return headerArr[section]
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int)  -> UIView? {
        let headerView = UIView()
        let headerLabel = UILabel(frame: CGRect(x: 8, y: 0 , width: tableView.bounds.size.width, height: tableView.bounds.size.height))
        headerLabel.text = self.tableView(self.tableCategoryLIst, titleForHeaderInSection: section)
        headerLabel.font = UIFont(name: AppFontName.bold, size: 21)
        headerLabel.sizeToFit()
        headerView.addSubview(headerLabel)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch (section) {
        case 0:
            return (dailyTags.count != 0) ? dailyTags.count : 0
        case 1:
            return (weeklyTags.count != 0) ? weeklyTags.count : 0
        default:
            return (monthlyTags.count != 0) ? monthlyTags.count : 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableCategoryLIst.dequeueReusableCell(withIdentifier: "CategoryListID", for:indexPath) as! CategoryListTVCell
        var textSizeSelected = UserDefaults.standard.value(forKey: "textSize") as! Int
        if (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone){
            if textSizeSelected == 0{
                cell.lblCategoryName.font = UIFont(name: AppFontName.regular, size: 18)
                cell.lblCount.font = UIFont(name: AppFontName.regular, size: 18)
            }
            else if textSizeSelected == 2{
                cell.lblCategoryName.font = UIFont(name: AppFontName.regular, size: 20)
                cell.lblCount.font = UIFont(name: AppFontName.regular, size: 20)
            }
            else{
                cell.lblCategoryName.font =  UIFont(name: AppFontName.regular, size: 22)
                cell.lblCount.font = UIFont(name: AppFontName.regular, size: 22)
            }
        }
        else{
            if textSizeSelected == 0{
                cell.lblCategoryName.font = UIFont(name: AppFontName.regular, size: 30)
                cell.lblCount.font = UIFont(name: AppFontName.regular, size: 30)
            }
            else if textSizeSelected == 2{
                cell.lblCategoryName.font = UIFont(name: AppFontName.regular, size: 34)
                cell.lblCount.font = UIFont(name: AppFontName.regular, size: 34)
            }
            else{
                cell.lblCategoryName.font =  UIFont(name: AppFontName.regular, size: 32)
                cell.lblCount.font = UIFont(name: AppFontName.regular, size: 32)
            }
        }
        let darkModeStatus = UserDefaults.standard.value(forKey: "darkModeEnabled") as! Bool
        if  darkModeStatus == true{
            cell.backgroundColor = colorConstants.grayBackground2
            cell.lblCategoryName.textColor = colorConstants.nightModeText
            cell.lblCount.textColor = colorConstants.nightModeText
            NightNight.theme =  .night
        }
        else{
            NightNight.theme =  .normal
        }
        switch (indexPath.section) {
        case 0:
            cell.lblCategoryName.text =  dailyTags[indexPath.row].tagName
            cell.lblCount.text =  String(dailyTags[indexPath.row].count)
        case 1:
            cell.lblCategoryName.text = weeklyTags[indexPath.row].tagName
            cell.lblCount.text =  String(weeklyTags[indexPath.row].count)
        default:
            cell.lblCategoryName.text = monthlyTags[indexPath.row].tagName
            cell.lblCount.text =  String(monthlyTags[indexPath.row].count)
        }
        activityIndicator.stopAnimating()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
}

extension CategoryListVC:IndicatorInfoProvider{
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Tags")
    }
}
