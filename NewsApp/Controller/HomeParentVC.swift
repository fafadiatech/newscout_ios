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

class HomeParentVC: ButtonBarPagerTabStripViewController, FloatyDelegate,categoryListProtocol {
    var vc = [UIViewController]()
    
    override func viewDidLoad() {
        settings.style.buttonBarItemsShouldFillAvailiableWidth = false
       super.viewDidLoad()
        buttonBarView.backgroundColor = .gray
        let floaty = Floaty()
        floaty.itemTitleColor = .blue
        
        // floaty.buttonImage = UIImage(named: "floatingMenu")
        floaty.addItem("Search", icon: UIImage(named: "search")!) { item in
            floaty.autoCloseOnTap = true
            isSearch = true
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
        // Do any additional setup after loading the view.
        buttonBarView.selectedBar.backgroundColor = .orange
        buttonBarView.backgroundColor = UIColor(red: 7/255, green: 185/255, blue: 155/255, alpha: 1)
        
    }
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    func updateCategoryList(catName: String) {
        ParentCatArr.append(catName)
        print("ParentCatArr: \(ParentCatArr)")
    }
    
    func deleteCategory(currentCategory: String) {
       // ParentCatArr.remove(at:currentCategory)
        ParentCatArr = ParentCatArr.filter{$0 != currentCategory}
        
        print(ParentCatArr)
    }
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        var i = 0
        while i < ParentCatArr.count
        {
            let child_1 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
           vc.append(child_1)
            child_1.tabBarTitle = ParentCatArr[i]
             i = i + 1
        }
       
        var childMore = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CategoryListID") as! CategoryListVC
        childMore.protocolObj = self
         vc.append(childMore)
        print(vc)
        return vc
      
    }

}
