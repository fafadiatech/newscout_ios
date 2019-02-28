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

class HomeParentVC: ButtonBarPagerTabStripViewController, FloatyDelegate{
    
    @IBOutlet weak var viewAppTitle: UIView!
    @IBOutlet weak var lblAppName: UILabel!
    @IBOutlet weak var sideMenuTV: UITableView!
    @IBOutlet weak var sideView: UIView!
    @IBOutlet weak var btnMenu: UIButton!
    @IBOutlet weak var viewSideContainer: UIView!
    var childrenVC = [UIViewController]()
    var categories = ["Sector Updates", "Regional Updates", "Finance", "Economics"]
    var isSideBarOpen : Bool = Bool()
    var jsonData : [Result] = []
    var expandData = [NSMutableDictionary]()
    var headingArr : [String] = []
    var subMenuArr = [[String]]()
    var submenu : [String] = []
    
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
        tap.cancelsTouchesInView = false
        viewSideContainer.isUserInteractionEnabled = true
        self.view.addSubview(viewSideContainer)
        
        jsonData = loadJson(filename: "navmenu")!
        var j = 0
        for _ in headingArr{
            self.expandData.append(["isOpen":"1","data": subMenuArr[j]])
            j = j + 1
        }
        
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
                for res in jsonData.body.results{
                    headingArr.append(res.heading.headingName)
                    submenu.removeAll()
                    for i in res.heading.submenu{
                        submenu.append(i.name)
                    }
                    subMenuArr.append(submenu)
                }
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
        for cat in categories
        {
            let childVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
            childVC.tabBarTitle = cat
            
            childrenVC.append(childVC)
        }
        //Append CategoryListVC in the end
        let childMore = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CategoryListID") as! CategoryListVC
        childrenVC.append(childMore)
        return childrenVC
    }
    
}


extension HomeParentVC: UITableViewDelegate, UITableViewDataSource{
       func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
          var url = APPURL.ArticlesByTagsURL + "tag=\(subMenuArr[indexPath.section][indexPath.row])"
        if jsonData[0].heading.headingName == headingArr[indexPath.section]{
            for temptag in jsonData[0].heading.submenu[indexPath.row].tags{
                url = url + "&tag=" + temptag.name
            }
        }
        let homeObj =  HomeVC()
        homeObj.saveArticlesInDB(url:url)
    UserDefaults.standard.set(subMenuArr[indexPath.section][indexPath.row], forKey: "selectedCategory")
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.expandData[section].value(forKey: "isOpen") as! String == "1"{
            return 0
        }else{
            let dataarray = self.expandData[section].value(forKey: "data") as! NSArray
            return dataarray.count
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.expandData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "menuID", for: indexPath) as! MenuTVCell
        let dataarray = self.expandData[indexPath.section].value(forKey: "data") as! NSArray
        cell.lblMenu.text = dataarray[indexPath.row] as? String
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?{
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
        headerView.backgroundColor = UIColor.gray
        let label = UILabel(frame: CGRect(x: 5, y: 10, width: headerView.frame.size.width , height: headerView.frame.size.height))
        label.text = headingArr[section]
        label.font = UIFont(name: AppFontName.bold, size: 21)
        label.sizeToFit()
        headerView.addSubview(label)
        headerView.tag = section + 100
        
        let tapgesture = UITapGestureRecognizer(target: self , action: #selector(self.sectionTapped(_:)))
        headerView.addGestureRecognizer(tapgesture)
        return headerView
    }
    
    @objc func sectionTapped(_ sender: UITapGestureRecognizer){
        if(self.expandData[(sender.view?.tag)! - 100].value(forKey: "isOpen") as! String == "1"){
            self.expandData[(sender.view?.tag)! - 100].setValue("0", forKey: "isOpen")
        }else{
            self.expandData[(sender.view?.tag)! - 100].setValue("1", forKey: "isOpen")
        }
        self.sideMenuTV.reloadSections(IndexSet(integer: (sender.view?.tag)! - 100), with: .automatic)
    }
    
}
