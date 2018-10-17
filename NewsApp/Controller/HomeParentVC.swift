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
    
    var childrenVC = [UIViewController]()
    override func viewDidLoad() {
        settings.style.buttonBarItemsShouldFillAvailiableWidth = false
        super.viewDidLoad()
        let floaty = Floaty()
        floaty.itemTitleColor = .blue
        floaty.buttonColor = commonColor
        floaty.plusColor = .black
        
        floaty.addItem("Profile", icon: UIImage(named: "profile")!) { item in
            
            floaty.autoCloseOnTap = true
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let searchvc:ProfileVC
                = storyboard.instantiateViewController(withIdentifier: "ProfileID") as! ProfileVC
            self.present(searchvc, animated: true, completion: nil)
        }
        floaty.addItem("Search", icon: UIImage(named: "search")!) { item in
            isSearch = true
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
            isSearch = false
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let settingvc:SearchVC = storyboard.instantiateViewController(withIdentifier: "SearchID") as! SearchVC
            self.present(settingvc, animated: true, completion: nil)
        }
        self.view.addSubview(floaty)
        buttonBarView.selectedBar.backgroundColor = .black
        buttonBarView.backgroundColor = commonColor
        //UIColor(red: 7/255, green: 185/255, blue: 155/255, alpha: 1
    }
  
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
   
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        
        //Clear children viewcontrollers
        childrenVC.removeAll()
        
        //Create children viewcontrolles based on categories passed from CategoryListVC
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
        let catObj = CategoryListVC()
        print("ParentCatArr: \(categories)")
        self.reloadPagerTabStripView()
    }
    
    func deleteCategory(currentCategory: String) {
        // ParentCatArr.remove(at:currentCategory)
        categories = categories.filter{$0 != currentCategory}
        print(categories)
    }
}
