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

class HomeParentVC: ButtonBarPagerTabStripViewController, FloatyDelegate {
    var vc = [UIViewController]()
    
       var isReload = false
    override func viewDidLoad() {
        settings.style.buttonBarItemsShouldFillAvailiableWidth = false
       
        super.viewDidLoad()
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
    override func reloadPagerTabStripView() {
        isReload = true
        if arc4random() % 2 == 0 {
            pagerBehaviour = .progressive(skipIntermediateViewControllers: arc4random() % 2 == 0, elasticIndicatorLimit: arc4random() % 2 == 0 )
        } else {
            pagerBehaviour = .common(skipIntermediateViewControllers: arc4random() % 2 == 0)
        }
        super.reloadPagerTabStripView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //reloadPagerTabStripView()

    }
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        var i = 0
        while i < VCcount - 1
        {
            let child_1 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeVC")
            i = i + 1
            vc.append(child_1)
        }
        var childMore = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CategoryListID")
         vc.append(childMore)
    
//        let child_1 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeVC")
//        let child_2 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeVC")
//        let child_3 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeVC")
//        let child_4 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeVC")
//        let cat = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeVC")
//  return [child_1, child_2, child_3, child_4, cat]
        print(vc)
        return vc
      
    }

}
