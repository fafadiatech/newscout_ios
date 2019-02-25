//
//  HomeParentVC.swift
//  NewsApp
//
//  Created by Prasen on 09/10/18.
//  Copyright © 2018 Fafadia Tech. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import Floaty
import NightNight

struct ExpandableNames {
    var isExpanded : Bool
    var names : [String]
}

struct Contact {
    let names : String
}
class HomeParentVC: ButtonBarPagerTabStripViewController, FloatyDelegate{
    
    @IBOutlet weak var viewAppTitle: UIView!
    @IBOutlet weak var lblAppName: UILabel!
    @IBOutlet weak var sideMenuTV: UITableView!
    @IBOutlet weak var sideView: UIView!
    @IBOutlet weak var btnMenu: UIButton!
    @IBOutlet weak var viewSideContainer: UIView!
    var childrenVC = [UIViewController]()
    var categories : [String] = []
    let arr = ["abc", "xyz", "pqr"]
    var isSideBarOpen : Bool = Bool()
    var jsonData : [Result] = []
    
    override func viewDidLoad() {
        isSideBarOpen = false
        viewSideContainer.isHidden = true
        sideView.isHidden = true
        sideMenuTV.isHidden = true
        settings.style.buttonBarItemsShouldFillAvailiableWidth = false
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(darkModeEnabled(_:)), name: .darkModeEnabled, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(darkModeDisabled(_:)), name: .darkModeDisabled, object: nil)
        lblAppName.font = FontConstants.appFont
        viewAppTitle.backgroundColor = colorConstants.redColor
        lblAppName.textColor = colorConstants.whiteColor
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        
        viewSideContainer.addGestureRecognizer(tap)
        
        viewSideContainer.isUserInteractionEnabled = true
        
        self.view.addSubview(viewSideContainer)

         jsonData = loadJson(filename: "navmenu")!
         categories = UserDefaults.standard.array(forKey: "categories") as! [String]
//        for  res in jsonData{
//            if !categories.contains(res.heading.headingName){
//            categories.append(res.heading.headingName)
//            }
//        }
   //     self.reloadPagerTabStripView()
        if UserDefaults.standard.value(forKey: "textSize") == nil{
            UserDefaults.standard.set(1, forKey: "textSize")
        }
        
        let darkModeStatus = UserDefaults.standard.value(forKey: "darkModeEnabled") as! Bool
        if  darkModeStatus == true{
            buttonBarView.backgroundColor = colorConstants.grayBackground1
            buttonBarView.selectedBar.backgroundColor = colorConstants.redColor
            buttonBarView.backgroundView?.backgroundColor = colorConstants.grayBackground1
        }
        else{
            buttonBarView.backgroundColor = .white
            buttonBarView.backgroundView?.backgroundColor = .white
            buttonBarView.selectedBar.backgroundColor = .red
            
        }
        
        lblAppName.text = Constants.AppName
        let floaty = Floaty()
        floaty.itemButtonColor = colorConstants.redColor
        floaty.buttonColor = colorConstants.redColor
        floaty.plusColor = .black
        
        floaty.addItem("Search", icon: UIImage(named: AssetConstants.search)!) { item in
            floaty.autoCloseOnTap = true
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let searchvc:SearchVC = storyboard.instantiateViewController(withIdentifier: "SearchID") as! SearchVC
            self.present(searchvc, animated: true, completion: nil)
        }
        
        floaty.addItem("Settings", icon: UIImage(named: AssetConstants.settings)!) { item in
            floaty.autoCloseOnTap = true
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let settingvc:SettingsVC = storyboard.instantiateViewController(withIdentifier: "SettingsID") as! SettingsVC
            self.present(settingvc, animated: true, completion: nil)
        }
        
        floaty.addItem("Bookmark", icon: UIImage(named: AssetConstants.bookmark)!) { item in
            floaty.autoCloseOnTap = true
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let bookmarkvc:BookmarkVC = storyboard.instantiateViewController(withIdentifier: "BookmarkID") as! BookmarkVC
            self.present(bookmarkvc, animated: true, completion: nil)
        }
        self.view.addSubview(floaty)
        changeCurrentIndexProgressive = {[weak self](oldCell:ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage:CGFloat, changeCurrentIndex:Bool, animated:Bool)-> Void in
            guard changeCurrentIndex == true else {return}
            let darkModeStatus = UserDefaults.standard.value(forKey: "darkModeEnabled") as! Bool
            if  darkModeStatus == true{
                oldCell?.label.textColor = colorConstants.whiteColor
                oldCell?.label.backgroundColor = colorConstants.grayBackground1
                newCell?.label.backgroundColor = colorConstants.grayBackground1
                newCell?.label.textColor =  colorConstants.whiteColor
                oldCell?.backgroundColor = colorConstants.grayBackground1
                newCell?.backgroundColor = colorConstants.grayBackground1
            }
            else{
                oldCell?.label.textColor = colorConstants.blackColor
                oldCell?.label.backgroundColor = colorConstants.whiteColor
                newCell?.label.backgroundColor = colorConstants.whiteColor
                newCell?.label.textColor =  colorConstants.redColor
                oldCell?.backgroundColor = colorConstants.whiteColor
                newCell?.backgroundColor = colorConstants.whiteColor
            }
        }
    }
    
    func loadJson(filename fileName: String) -> [Result]?
    {
        if let url = Bundle.main.url(forResource: fileName, withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let jsonData = try decoder.decode(Menu.self, from: data)
                
                print("jsondata: \(jsonData)")
                
                return jsonData.body.results
            } catch {
                print("error:\(error)")
            }
        }
        return nil
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        if isSideBarOpen{
            sideMenuTV.isHidden = true
            sideView.isHidden = true
            isSideBarOpen = false
            viewSideContainer.isHidden = true
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .darkModeEnabled, object: nil)
        NotificationCenter.default.removeObserver(self, name: .darkModeDisabled, object: nil)
    }
    
    @objc private func darkModeEnabled(_ notification: Notification) {
        NightNight.theme = .night
        buttonBarView.backgroundColor = colorConstants.grayBackground1
        buttonBarView.selectedBar.backgroundColor = .red
    }
    
    @objc private func darkModeDisabled(_ notification: Notification) {
        NightNight.theme = .normal
        buttonBarView.backgroundColor = colorConstants.whiteColor
        buttonBarView.selectedBar.backgroundColor = .red
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    @IBAction func btnMenuActn(_ sender: Any) {
       sideMenuTV.reloadData()
        self.view.bringSubview(toFront: sideView)
        if !isSideBarOpen{
            viewSideContainer.isHidden = false
            isSideBarOpen = true
            sideView.isHidden = false
            sideMenuTV.isHidden = false
        }
    }
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        
        //Clear children viewcontrollers
        childrenVC.removeAll()
        
        categories = UserDefaults.standard.array(forKey: "categories") as! [String]
        for  res in jsonData{
            categories.append(res.heading.headingName)
        }
        UserDefaults.standard.set(categories, forKey: "categories")
        for cat in categories
        {
            let childVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
            childVC.tabBarTitle = cat
            
            childrenVC.append(childVC)
        }
        //Append CategoryListVC in the end
        let childMore = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CategoryListID") as! CategoryListVC
        childMore.protocolObj = self
        childrenVC.append(childMore)
        return childrenVC
    }
    
}

extension HomeParentVC:CategoryListProtocol{
    
    func updateCategoryList(catName: String) {
        categories.append(catName)
        UserDefaults.standard.set(categories, forKey: "categories")
        self.reloadPagerTabStripView()
    }
    
    func deleteCategory(currentCategory: String) {
        categories = categories.filter{$0 != currentCategory}
        UserDefaults.standard.set(categories, forKey: "categories")
        self.reloadPagerTabStripView()
    }
}
extension HomeParentVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return jsonData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: "menuID", for:indexPath) as! MenuTVCell
        cell.lblMenu.text = jsonData[indexPath.row].heading.headingName
        return cell
    }
    
    
}
