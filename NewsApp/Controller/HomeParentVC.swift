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
import MaterialComponents.MaterialActivityIndicator

class HomeParentVC: ButtonBarPagerTabStripViewController, FloatyDelegate{
    
    @IBOutlet weak var lblAppName: UILabel!
    var childrenVC = [UIViewController]()
    let activityIndicator = MDCActivityIndicator()
    var VCIndex = 0
    var categories = ["FOR YOU"]
    
    override func viewDidLoad() {
        settings.style.buttonBarItemsShouldFillAvailiableWidth = false
        super.viewDidLoad()
        if UserDefaults.standard.value(forKey: "textSize") == nil{
            UserDefaults.standard.set(1, forKey: "textSize")
        }
        lblAppName.text = Constants.AppName
        activityIndicator.cycleColors = [.blue]
        activityIndicator.frame = CGRect(x: 166, y: 150, width: 40, height: 40)
        activityIndicator.sizeToFit()
        activityIndicator.indicatorMode = .indeterminate
        activityIndicator.progress = 2.0
        view.addSubview(activityIndicator)
        
        // To make the activity indicator appear:
        //activityIndicator.startAnimating()
        
        // To make the activity indicator disappear:
        // activityIndicator.stopAnimating()
        
        let floaty = Floaty()
        floaty.itemTitleColor = .blue
        floaty.buttonColor = themeColor.commonColor
        floaty.plusColor = .black
        
        floaty.addItem("Profile", icon: UIImage(named: "profile")!) { item in
            
            floaty.autoCloseOnTap = true
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let searchvc:ProfileVC
                = storyboard.instantiateViewController(withIdentifier: "ProfileID") as! ProfileVC
            self.present(searchvc, animated: true, completion: nil)
        }
        floaty.addItem("Search", icon: UIImage(named: "search")!) { item in
            floaty.autoCloseOnTap = true
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let searchvc:SearchVC = storyboard.instantiateViewController(withIdentifier: "SearchID") as! SearchVC
            searchvc.isSearch = true
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
            let searchvc:SearchVC = storyboard.instantiateViewController(withIdentifier: "SearchID") as! SearchVC
            searchvc.isSearch = false
            self.present(searchvc, animated: true, completion: nil)
        }
        self.view.addSubview(floaty)
        buttonBarView.selectedBar.backgroundColor = .black
        buttonBarView.backgroundColor = themeColor.commonColor
        //UIColor(red: 7/255, green: 185/255, blue: 155/255, alpha: 1
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
    }
}
