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
    var childrenVC = [UIViewController]()
    var categories : [String] = [] //= ["For You"]

    
    override func viewDidLoad() {
        settings.style.buttonBarItemsShouldFillAvailiableWidth = false
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(darkModeEnabled(_:)), name: .darkModeEnabled, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(darkModeDisabled(_:)), name: .darkModeDisabled, object: nil)
      //  self.reloadPagerTabStripView()
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
        }
        else{
            buttonBarView.backgroundColor = .white
            buttonBarView.selectedBar.backgroundColor = .red
            
        }
       
        lblAppName.text = Constants.AppName
        let floaty = Floaty()
        floaty.itemButtonColor = colorConstants.redColor
        floaty.buttonColor = colorConstants.redColor
        floaty.plusColor = .black
        
        floaty.addItem("Search", icon: UIImage(named: "newsearch")!) { item in
            floaty.autoCloseOnTap = true
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let searchvc:SearchVC = storyboard.instantiateViewController(withIdentifier: "SearchID") as! SearchVC
            self.present(searchvc, animated: true, completion: nil)
        }
        
        floaty.addItem("Settings", icon: UIImage(named: "settings")!) { item in
            floaty.autoCloseOnTap = true
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let settingvc:SettingsVC = storyboard.instantiateViewController(withIdentifier: "SettingsID") as! SettingsVC
            self.present(settingvc, animated: true, completion: nil)
        }
        
        floaty.addItem("Bookmark", icon: UIImage(named: "bookmark")!) { item in
            floaty.autoCloseOnTap = true
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let bookmarkvc:BookmarkVC = storyboard.instantiateViewController(withIdentifier: "BookmarkID") as! BookmarkVC
            self.present(bookmarkvc, animated: true, completion: nil)
        }
        self.view.addSubview(floaty)
        // buttonBarView.backgroundColor = colorConstants.whiteColor
        changeCurrentIndexProgressive = {[weak self](oldCell:ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage:CGFloat, changeCurrentIndex:Bool, animated:Bool)-> Void in
            
            guard changeCurrentIndex == true else {return}
            let darkModeStatus = UserDefaults.standard.value(forKey: "darkModeEnabled") as! Bool
            if  darkModeStatus == true{
                oldCell?.label.textColor = colorConstants.whiteColor
                oldCell?.label.backgroundColor = colorConstants.grayBackground1
                newCell?.label.textColor =  colorConstants.whiteColor
                oldCell?.backgroundColor = colorConstants.grayBackground1
                newCell?.backgroundColor = colorConstants.grayBackground1
                self!.buttonBarView.selectedBar.backgroundColor = .red
                
            }
            else{
                oldCell?.label.textColor = colorConstants.blackColor
                oldCell?.label.backgroundColor = colorConstants.whiteColor
                newCell?.label.textColor =  colorConstants.redColor
                oldCell?.backgroundColor = colorConstants.whiteColor
                newCell?.backgroundColor = colorConstants.whiteColor
                self!.buttonBarView.selectedBar.backgroundColor = .red
            }
            
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .darkModeEnabled, object: nil)
        NotificationCenter.default.removeObserver(self, name: .darkModeDisabled, object: nil)
    }
    
    @objc private func darkModeEnabled(_ notification: Notification) {
        // Write your dark mode code here
        NightNight.theme = .night
        buttonBarView.backgroundColor = colorConstants.grayBackground1
        buttonBarView.selectedBar.backgroundColor = .white
    }
    
    @objc private func darkModeDisabled(_ notification: Notification) {
        // Write your non-dark mode code here
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
        //Create children viewcontrolles based on categories passed from CategoryListVC
        print(categories)
        categories = UserDefaults.standard.array(forKey: "categories") as! [String]
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
        print(UserDefaults.standard.set(categories, forKey: "categories"))
        print("ParentCatArr: \(categories)")
        self.reloadPagerTabStripView()
    }
    
    func deleteCategory(currentCategory: String) {
        // ParentCatArr.remove(at:currentCategory)
        categories = categories.filter{$0 != currentCategory}
        UserDefaults.standard.set(categories, forKey: "categories")
        print(categories)
        print(UserDefaults.standard.set(categories, forKey: "categories"))
        self.reloadPagerTabStripView()
    }
}
