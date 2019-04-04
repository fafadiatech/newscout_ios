//
//  HomeParentVC.swift
//  NewsApp
//
//  Created by Prasen on 09/10/18.
//  Copyright © 2018 Fafadia Tech. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import NightNight
import MaterialComponents.MaterialActivityIndicator
extension UISwitch {
    
    func set(width: CGFloat, height: CGFloat) {
        
        let standardHeight: CGFloat = 31
        let standardWidth: CGFloat = 51
        
        let heightRatio = height / standardHeight
        let widthRatio = width / standardWidth
        
        transform = CGAffineTransform(scaleX: widthRatio, y: heightRatio)
    }
}
class HomeParentVC: ButtonBarPagerTabStripViewController{
    
    @IBOutlet weak var btnSettingsNav: UIButton!
    @IBOutlet weak var btnBookmark: UIButton!
    @IBOutlet weak var viewNightMode: UIView!
    @IBOutlet weak var viewBookmark: UIView!
    @IBOutlet weak var viewSettings: UIView!
    @IBOutlet weak var btnSearch: UIButton!
    @IBOutlet weak var viewOptions: UIView!
    @IBOutlet weak var btnSettings: UIButton!
    @IBOutlet weak var menuCV: UICollectionView!
    @IBOutlet weak var viewAppTitle: UIView!
    @IBOutlet weak var lblAppName: UILabel!
    @IBOutlet weak var btnNightMode: UIButton!
    @IBOutlet weak var btnNightModeImg: UIButton!
    @IBOutlet weak var btnBookmarkImg: UIButton!
    @IBOutlet weak var btnSettingImg: UIButton!
    
    let activityIndicator = MDCActivityIndicator()
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
    var headingImg = [AssetConstants.sector, AssetConstants.regional, AssetConstants.finance, AssetConstants.economy, AssetConstants.misc]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewOptions.isHidden = true
        menuCV.allowsMultipleSelection = false
        viewOptions.layer.borderWidth = 0.5
        viewOptions.layer.borderColor =  UIColor.darkGray.cgColor
        
        activityIndicator.frame = CGRect(x: view.frame.width/2, y: view.frame.height/2 - 100, width: 40, height: 40)
        activityIndicator.sizeToFit()
        activityIndicator.indicatorMode = .indeterminate
        activityIndicator.progress = 2.0
        view.addSubview(activityIndicator)
        
        let switchStatus = UserDefaults.standard.value(forKey: "darkModeEnabled") as! Bool
        if UserDefaults.standard.value(forKey: "deviceToken") == nil{
            UserDefaults.standard.set("41ea0aaa15323ae5012992392e4edd6b8a6ee4547a8dc6fd1f3b31aab9839208", forKey: "deviceToken")
        }
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
            changeTheme()
        }
        else{
            buttonBarView.backgroundColor = .white
            buttonBarView.backgroundView?.backgroundColor = .white
            buttonBarView.selectedBar.backgroundColor = .red
        }
        lblAppName.text = Constants.AppName
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
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped(gestureRecognizer:)))
        viewAppTitle.addGestureRecognizer(tapRecognizer)
        tapRecognizer.delegate = self as UIGestureRecognizerDelegate
    }
    @objc func tapped(gestureRecognizer: UITapGestureRecognizer) {
        if viewOptions.isHidden == false{
            viewOptions.isHidden = true
        }
    }
    
    func changeTheme(){
        viewNightMode.backgroundColor = colorConstants.grayBackground1
        viewBookmark.backgroundColor = colorConstants.grayBackground1
        viewSettings.backgroundColor = colorConstants.grayBackground1
        btnBookmark.setTitleColor(.white, for: UIControlState.normal)
        btnNightMode.setTitleColor(.white, for: UIControlState.normal)
        btnSettingsNav.setTitleColor(.white, for: UIControlState.normal)
        btnNightModeImg.setImage(UIImage(named: AssetConstants.whiteMoon), for: .normal)
        btnBookmarkImg.setImage(UIImage(named:AssetConstants.Bookmark_white), for: .normal)
        menuCV.backgroundColor = colorConstants.subTVgrayBackground
        viewOptions.backgroundColor = colorConstants.txtlightGrayColor
        buttonBarView.backgroundColor = colorConstants.grayBackground1
        buttonBarView.backgroundView?.backgroundColor = colorConstants.grayBackground1
        buttonBarView.selectedBar.backgroundColor = .red
        reloadPagerTabStripView()
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
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .darkModeEnabled, object: nil)
        NotificationCenter.default.removeObserver(self, name: .darkModeDisabled, object: nil)
    }
    
    @objc private func darkModeEnabled(_ notification: Notification){
        self.activityIndicator.startAnimating()
        NightNight.theme = .night
        changeTheme()
        activityIndicator.stopAnimating()
    }
    
    @objc private func darkModeDisabled(_ notification: Notification) {
        self.activityIndicator.startAnimating()
        NightNight.theme = .normal
        buttonBarView.backgroundColor = colorConstants.whiteColor
        buttonBarView.selectedBar.backgroundColor = .red
        btnBookmark.setTitleColor(.black, for: UIControlState.normal)
        btnNightMode.setTitleColor(.black, for: UIControlState.normal)
        btnSettingsNav.setTitleColor(.black, for: UIControlState.normal)
        viewNightMode.backgroundColor = colorConstants.txtlightGrayColor
        viewSettings.backgroundColor = colorConstants.txtlightGrayColor
        viewBookmark.backgroundColor = colorConstants.txtlightGrayColor
        viewOptions.backgroundColor = colorConstants.txtlightGrayColor
        btnNightModeImg.setImage(nil, for: .normal)
        btnNightModeImg.setImage(UIImage(named: AssetConstants.moon), for: .normal)
        btnBookmarkImg.setImage(UIImage(named:AssetConstants.bookmark), for: .normal)
        reloadPagerTabStripView()
        activityIndicator.stopAnimating()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewOptions.isHidden = true
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
                childVC.protocolObj = self
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
                let label = UILabel(frame: CGRect.zero)
                label.text = headingArr[indexPath.item]
                label.sizeToFit()
                return CGSize(width: label.frame.size.width + 100.0, height: menuCV.bounds.size.height)
                // return CGSize(width: size.width + 100.0, height: menuCV.bounds.size.height)
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (collectionView == buttonBarView) {
            return super.collectionView(collectionView, numberOfItemsInSection: section)
        }
        else{
            return headingArr.count
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView ==  menuCV {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "subMenuID", for: indexPath) as! submenuCVCell
            let darkModeStatus = UserDefaults.standard.value(forKey: "darkModeEnabled") as! Bool
            cell.lblMenu.text = headingArr[indexPath.row].localizedCapitalized
            cell.imgMenu.image =  UIImage(named: headingImg[indexPath.row])
            return cell
        }
        else   {
            return super.collectionView(collectionView, cellForItemAt: indexPath)
        }
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewOptions.isHidden = true
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
            reloadPagerTabStripView()
            
        }
    }
    
    @IBAction func btnSettingsOptions(_ sender: Any) {
        if viewOptions.isHidden == true{
            viewOptions.isHidden = false
        }else{
            viewOptions.isHidden = true
        }
    }
    @IBAction func btnSettingsActn(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let settingvc:SettingsVC = storyboard.instantiateViewController(withIdentifier: "SettingsID") as! SettingsVC
        self.present(settingvc, animated: true, completion: nil)
    }
    
    @IBAction func btnNightModeActn(_ sender: Any) {
        let Status = UserDefaults.standard.value(forKey: "darkModeEnabled") as! Bool
        if Status == false {
            UserDefaults.standard.setValue(true, forKey: "darkModeEnabled")
            NotificationCenter.default.post(name: .darkModeEnabled, object: nil)
        }
        else {
            UserDefaults.standard.setValue(false, forKey: "darkModeEnabled")
            NotificationCenter.default.post(name: .darkModeDisabled, object: nil)
        }
    }
    
    @IBAction func btnBookmarkActn(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let bookmarkvc:BookmarkVC = storyboard.instantiateViewController(withIdentifier: "BookmarkID") as! BookmarkVC
        self.present(bookmarkvc, animated: true, completion: nil)
    }
    
    @IBAction func btnSeachActn(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let searchvc:SearchVC = storyboard.instantiateViewController(withIdentifier: "SearchID") as! SearchVC
        self.present(searchvc, animated: true, completion: nil)
    }
}

extension HomeParentVC : UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view!.superview!.superclass! .isSubclass(of: UIButton.self) {
            return false
        }
        return true
    }
}
extension HomeParentVC: ScrollDelegate{
    func isNavigate(status: Bool) {
        if status == true{
            viewOptions.isHidden = true
        }
    }
}

