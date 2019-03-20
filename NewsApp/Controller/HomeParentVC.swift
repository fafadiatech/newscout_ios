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
    
    @IBOutlet weak var menuCV: UICollectionView!
    @IBOutlet weak var viewAppTitle: UIView!
    @IBOutlet weak var lblAppName: UILabel!
    var childrenVC = [UIViewController]()
    var jsonData : [Result] = []
    var expandData = [NSMutableDictionary]()
    var headingArr : [String] = []
    var subMenuArr = [[String]]()
    var submenu : [String] = []
    var HeadingRow = 0
    var subMenuRow = 0
    var tagArr : [String] = []
    var submenuIndexArr = [[String]]()

    override func viewDidLoad() {
        super.viewDidLoad()
        if UserDefaults.standard.value(forKey: "daily") == nil{
            UserDefaults.standard.set(false, forKey: "daily")
        }
        if UserDefaults.standard.value(forKey: "breaking") == nil{
            UserDefaults.standard.set(false, forKey: "breaking")
        }
        if UserDefaults.standard.value(forKey: "personalised") == nil{
             UserDefaults.standard.set(false, forKey: "personalised")
        }
        sendDeviceDetails()
        settings.style.buttonBarItemsShouldFillAvailiableWidth = false
        saveFetchMenu()
        NotificationCenter.default.addObserver(self, selector: #selector(darkModeEnabled(_:)), name: .darkModeEnabled, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(darkModeDisabled(_:)), name: .darkModeDisabled, object: nil)
        lblAppName.font = FontConstants.appFont
        viewAppTitle.backgroundColor = colorConstants.redColor
        lblAppName.textColor = colorConstants.whiteColor
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
        
        floaty.addItem("  Search  ", icon: UIImage(named: AssetConstants.search)!) { item in
            floaty.autoCloseOnTap = true
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let searchvc:SearchVC = storyboard.instantiateViewController(withIdentifier: "SearchID") as! SearchVC
            self.present(searchvc, animated: true, completion: nil)
        }
        
        floaty.addItem("  Settings  ", icon: UIImage(named: AssetConstants.settings)!) { item in
            floaty.autoCloseOnTap = true
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let settingvc:SettingsVC = storyboard.instantiateViewController(withIdentifier: "SettingsID") as! SettingsVC
            self.present(settingvc, animated: true, completion: nil)
        }
        
        floaty.addItem("  Bookmark  ", icon: UIImage(named: AssetConstants.bookmark)!) { item in
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
    
    func sendDeviceDetails(){
        if UserDefaults.standard.value(forKey: "deviceToken") != nil{
            let id = UserDefaults.standard.value(forKey: "deviceToken") as! String
            let param = ["device_id" : id,
                         "device_name": "ios"]
            APICall().deviceAPI(param : param){(status,response) in
                print(status,response)
            }
        }
    }
    
    func saveFetchMenu(){
        var coredataRecordCount = DBManager().IsCoreDataEmpty(entity: "MenuHeadings")
        if coredataRecordCount != 0 {
           fetchMenuFromDB()
        }
        else{
        DBManager().saveMenu(){response in
            if response == true{
                self.fetchMenuFromDB()
            }
        }
        }
    }
    
    func fetchMenuFromDB(){
        let result = DBManager().fetchMenu()
        switch result {
        case .Success(let headingData) :
            for i in headingData{
                self.headingArr.append(i.headingName!)
            }
            self.menuCV.reloadData()
            for heading in headingData{
                let subresult = DBManager().fetchSubMenu(headingId: Int(heading.headingId))
                
                switch subresult{
                case .Success(let subMenuData) :
                    self.submenu.removeAll()
                    for sub in subMenuData{
                        self.submenu.append(sub.subMenuName!)
                    }
                    self.subMenuArr.append(self.submenu)
                    self.fetchsubMenuTags(submenu: self.subMenuArr[self.HeadingRow][self.subMenuRow])
                      UserDefaults.standard.set(self.subMenuArr[self.HeadingRow][self.subMenuRow], forKey: "submenu")
                    self.reloadPagerTabStripView()
                    
                case .Failure(let error):
                    print(error)
                    
                }
            }
        case .Failure(let error) :
            print(error)
        }
    }
    
    func fetchsubMenuTags(submenu : String){
        let tagresult = DBManager().fetchMenuTags(subMenuName: submenu)
        switch tagresult{
        case .Success(let tagData) :
            tagArr.removeAll()
            for tag in tagData{
                tagArr.append(tag.hashTagName!)
            }
             UserDefaults.standard.setValue(tagArr, forKey: "subMenuTags")
        case .Failure(let error):
            print(error)
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
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        
        //Clear children viewcontrollers
        childrenVC.removeAll()
        if headingArr.count > 0{
        for cat in subMenuArr[HeadingRow]
        {
            let childVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
            childVC.tabBarTitle = cat
            
            childrenVC.append(childVC)
        }
        }
        else{
            let childVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
            childVC.tabBarTitle = "Test"
            
            childrenVC.append(childVC)
        }
        return childrenVC
    }
  
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
           if (collectionView == buttonBarView) {
            return super.collectionView(collectionView,layout: UICollectionViewLayout.init(), sizeForItemAtIndexPath : indexPath)
        }
           else{
         let size: CGSize = headingArr[indexPath.row].size(withAttributes: nil)
           // return CGSize(width:menuCV.frame.size.width/2, height: menuCV.frame.size.height)
            if (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad){
                 return CGSize(width: size.width + 180.0, height: menuCV.bounds.size.height)
            }else{
           
            return CGSize(width: size.width + 100.0, height: menuCV.bounds.size.height)
            }
        }
        
        }


  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (collectionView == buttonBarView) {
            return super.collectionView(collectionView, numberOfItemsInSection: section)
        }
        else{
            
            return headingArr.count != 0 ? headingArr.count  : 0
           }
        }
   
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView ==  menuCV {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "subMenuID", for: indexPath) as! submenuCVCell
            cell.lblMenu.text = headingArr[indexPath.row].localizedCapitalized
            return cell
        }
         else   {
            return super.collectionView(collectionView, cellForItemAt: indexPath)
        }
    }
  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if (collectionView == buttonBarView) {
        subMenuRow = indexPath.row
        UserDefaults.standard.set(subMenuArr[HeadingRow][indexPath.row], forKey: "submenu")
        fetchsubMenuTags(submenu: subMenuArr[HeadingRow][indexPath.row])
        var url = APPURL.ArticlesByTagsURL
        for tag in tagArr {
            url = url + "&tag=" + tag
        }
        if tagArr.count > 0{
        UserDefaults.standard.set(url, forKey: "submenuURL")
        }
        else{
            UserDefaults.standard.set("", forKey: "submenuURL")
        }
        return super.collectionView(collectionView,didSelectItemAt: indexPath)
        
    }
    else{
          HeadingRow = indexPath.row
//         fetchsubMenuTags(submenu: subMenuArr[HeadingRow][0])
//        var url = APPURL.ArticlesByTagsURL
//        for tag in tagArr {
//            url = url + "&tag=" + tag
//        }
//        print("url to get tag is: \(url)")
//        UserDefaults.standard.set(url, forKey: "submenuURL")
        reloadPagerTabStripView()
    }
    }
}



