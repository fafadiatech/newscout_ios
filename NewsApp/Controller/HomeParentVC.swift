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
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    func saveFetchMenu(){
        DBManager().saveMenu(){response in
            if response == true{
                let result = DBManager().fetchMenu()
                switch result {
                case .Success(let headingData) :
                    for i in headingData{
                        self.headingArr.append(i.headingName!)
                    }
                      self.menuCV.reloadData()
                    print("headingData: \(headingData)")
                    print("headingArr: \(self.headingArr)")
                    for heading in headingData{
                        let subresult = DBManager().fetchSubMenu(headingId: Int(heading.headingId))
                       
                        switch subresult{
                        case .Success(let subMenuData) :
                            self.submenu.removeAll()
                            for sub in subMenuData{
                                self.submenu.append(sub.subMenuName!)
                                print("submenu: \(self.submenu)")
                                
                            }
                            self.subMenuArr.append(self.submenu)
                            print("subMenuArr: \(self.subMenuArr)")
                            self.fetchTags(submenu: self.subMenuArr[self.HeadingRow][self.subMenuRow])
                            self.reloadPagerTabStripView()
                        
                        case .Failure(let error):
                            print(error)
                            
                        }
                    }
                case .Failure(let error) :
                    print(error)
                }
            }
        }
    }
    func fetchTags(submenu : String){
        let tagresult = DBManager().fetchMenuTags(subMenuName: submenu)
        switch tagresult{
        case .Success(let tagData) :
            tagArr.removeAll()
            for tag in tagData{
                tagArr.append(tag.hashTagName!)
            }
             UserDefaults.standard.setValue(tagArr, forKey: "subMenuTags")
            print("tagData is of \(submenu) is : \(tagData.debugDescription)")
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
                        print("submenu: \(submenu)")
                    }
                    subMenuArr.append(submenu)
                }
                print("subMenuArr: \(subMenuArr)")
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
        //Append CategoryListVC in the end
//        let childMore = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CategoryListID") as! CategoryListVC
//        childrenVC.append(childMore)
        return childrenVC
    }
   
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
           if (collectionView == buttonBarView) {
            return super.collectionView(collectionView,layout: UICollectionViewFlowLayout.init(), sizeForItemAtIndexPath : indexPath)
        }
           else{
        
           // return CGSize(width:menuCV.frame.size.width/2, height: menuCV.frame.size.height)

            let size: CGSize = headingArr[indexPath.row].size(withAttributes: nil)
            return CGSize(width: size.width + 100.0, height: menuCV.bounds.size.height)
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
            if (indexPath.row == 0){
                menuCV.selectItem(at: indexPath, animated: true, scrollPosition: UICollectionViewScrollPosition.centeredHorizontally)
                cell.lblMenu.textColor = colorConstants.redColor
            }
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
        fetchTags(submenu: subMenuArr[HeadingRow][indexPath.row])
        print("tag array : \(tagArr)")
        var newURL = "https://api.myjson.com/bins/1f3gca"
        UserDefaults.standard.set(newURL, forKey: "submenuURL")
        return super.collectionView(collectionView,didSelectItemAt: indexPath)
        /*var url = APPURL.ArticlesByTagsURL2 + "tag=\(subMenuArr[HeadingRow][indexPath.row].lowercased())"
         for tag in tagArr {
         url = url + "&tag=" + tag
         }
         print("url to get tag is: \(url)")*/
    }
    else{
          HeadingRow = indexPath.row
     
        reloadPagerTabStripView()
      
        
    }
    }
}



