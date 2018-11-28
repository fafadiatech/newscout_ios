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

class HomeParentVC: ButtonBarPagerTabStripViewController, FloatyDelegate{
    
    @IBOutlet weak var viewAppTitle: UIView!
    @IBOutlet weak var lblAppName: UILabel!
    var childrenVC = [UIViewController]()
    var categories = ["For You"]
    
    override func viewDidLoad() {
        settings.style.buttonBarItemsShouldFillAvailiableWidth = false
        super.viewDidLoad()
        lblAppName.font = FontConstants.appFont
        viewAppTitle.backgroundColor = colorConstants.redColor
        lblAppName.textColor = colorConstants.whiteColor
        if UserDefaults.standard.value(forKey: "textSize") == nil{
            UserDefaults.standard.set(1, forKey: "textSize")
        }
        lblAppName.text = Constants.AppName
        let floaty = Floaty()
        floaty.itemButtonColor = colorConstants.redColor
        floaty.itemTitleColor =  .black
        floaty.buttonColor = colorConstants.redColor
        floaty.plusColor = .black
    
        floaty.addItem("Search", icon: UIImage(named: "search")!) { item in
            floaty.autoCloseOnTap = true
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let searchvc:SearchVC = storyboard.instantiateViewController(withIdentifier: "SearchID") as! SearchVC
            searchvc.isSearch = true
            self.present(searchvc, animated: true, completion: nil)
        }
        
        floaty.addItem("Settings", icon: UIImage(named: "settings3")!) { item in
            
            floaty.autoCloseOnTap = true
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let settingvc:SettingsVC = storyboard.instantiateViewController(withIdentifier: "SettingsID") as! SettingsVC
            self.present(settingvc, animated: true, completion: nil)
        }
        
        floaty.addItem("Bookmark", icon: UIImage(named: "book")!) { item in
            floaty.autoCloseOnTap = true
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let searchvc:SearchVC = storyboard.instantiateViewController(withIdentifier: "SearchID") as! SearchVC
            searchvc.isSearch = false
            self.present(searchvc, animated: true, completion: nil)
        }
        self.view.addSubview(floaty)
        buttonBarView.selectedBar.backgroundColor = .red
        buttonBarView.backgroundColor = colorConstants.whiteColor
        
        changeCurrentIndexProgressive = {[weak self](oldCell:ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage:CGFloat, changeCurrentIndex:Bool, animated:Bool)-> Void in
            
            guard changeCurrentIndex == true else {return}
            oldCell?.label.textColor = colorConstants.blackColor
            newCell?.label.textColor =  colorConstants.redColor
        }
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
    override func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        super.scrollViewDidEndScrollingAnimation(scrollView)
        notifyChildOfPresentation(in: scrollView) //only triggered when the segmented control is tapped
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        notifyChildOfPresentation(in: scrollView) //only triggered by a pan gesture transition
    }
    
    func notifyChildOfPresentation(in scrollView: UIScrollView?) {
        let presentedViewController = viewControllers[currentIndex]
        
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
