//
//  ParentViewController.swift
//  NewsApp
//
//  Created by Jayashree on 15/05/19.
//  Copyright © 2019 Fafadia Tech. All rights reserved.
//

import UIKit
import CoreData
import MaterialComponents.MaterialActivityIndicator
import SDWebImage
import NightNight

extension UIView {
    func dropShadow(scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: -1, height: 1)
        layer.shadowRadius = 1
        
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    func dropShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offSet
        layer.shadowRadius = radius
        
        layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
}

protocol CellDelegate {
    func colCategorySelected(_ indexPath : IndexPath, _ sortedData : [NewsArticle] )
}
protocol trendingDetailClicked {
    func isTrendingDetailedOpened(status: Bool)
}

class ParentViewController: UIViewController {
    @IBOutlet weak var submenuLeading: NSLayoutConstraint!
    @IBOutlet weak var containerCVTop: NSLayoutConstraint!
    @IBOutlet weak var containerCV: UICollectionView!
    @IBOutlet weak var btnImgNightMode: UIButton!
    @IBOutlet weak var btnNightMode: UIButton!
    @IBOutlet weak var viewNightMode: UIView!
    @IBOutlet weak var viewMyBookmark: UIView!
    @IBOutlet weak var btnBookmark: UIButton!
    @IBOutlet weak var btnImgBookmark: UIButton!
    @IBOutlet weak var btnImgSettings: UIButton!
    @IBOutlet weak var btnSettings: UIButton!
    @IBOutlet weak var viewSettings: UIView!
    @IBOutlet weak var viewOptions: UIView!
    @IBOutlet var viewAppTitle: UIView!
    @IBOutlet var lblAppTitle: UILabel!
    @IBOutlet var btnBack: UIButton!
    @IBOutlet var btnOptionMenu: UIButton!
    @IBOutlet var btnSearch: UIButton!
    @IBOutlet var menuCV: UICollectionView!
    @IBOutlet var submenuCV: UICollectionView!
    @IBOutlet weak var lblNonews: UILabel!
    
    let activityIndicator = MDCActivityIndicator()
    var headingArr : [String] = []
    var headingIds : [Int] = []
    var subMenuArr = [[String]]()
    var submenu : [String] = []
    var HeadingRow = 0
    var subMenuRow = 0
    var submenuIndexArr = [[String]]()
    var submenuID = 0
    var protocolObj : ScrollDelegate?
    var tabBarTitle: String = ""
    var ShowArticle = [NewsArticle]()
    var prevTrendingData = [NewsArticle]()
    var clusterArticles = [NewsArticle]()
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    var pageNum = 0
    var coredataRecordCount = 0
    var currentCategory = "All News"
    var nextURL = ""
    var lastContentOffset: CGFloat = 0
    var articlesArr = [Article]()
    var selectedCategory = ""
    var tagArr : [String] = []
    var sortedData = [NewsArticle]()
    var isAPICalled = false
    var imgWidth = ""
    var imgHeight = ""
    var cellHeight:CGFloat = CGFloat()
    var isTrendingDetail = 0
    var submenuName = ""
    var menuName = ""
    var isSwipeLeft = false
    var currentIndexPath: IndexPath?
    var menuIndexPath: IndexPath?
    var index = 0
    var newShowArticle = [[NewsArticle]]()
    var headingName = "Trending"
    var isSwipe = false
    var menuImgSize = CGFloat()
    var headingImg = [AssetConstants.trending, AssetConstants.sector, AssetConstants.regional, AssetConstants.finance, AssetConstants.economy, AssetConstants.misc]
    var submenuImgArr = [[AssetConstants.banking, AssetConstants.retail,AssetConstants.retail, AssetConstants.tech, AssetConstants.transport, AssetConstants.energy, AssetConstants.food, AssetConstants.manufacturing, AssetConstants.fintech, AssetConstants.media],
                         [AssetConstants.us, AssetConstants.china, AssetConstants.asia, AssetConstants.japan, AssetConstants.india, AssetConstants.appLogo],
                         [AssetConstants.recession, AssetConstants.personal_finance, AssetConstants.funding, AssetConstants.ipo, AssetConstants.appLogo],
                         [AssetConstants.appLogo, AssetConstants.appLogo, AssetConstants.appLogo, AssetConstants.appLogo,  AssetConstants.appLogo,  AssetConstants.appLogo,  AssetConstants.appLogo],
                         [AssetConstants.appLogo, AssetConstants.appLogo, AssetConstants.appLogo, AssetConstants.appLogo, AssetConstants.appLogo, AssetConstants.appLogo, AssetConstants.appLogo, AssetConstants.appLogo, AssetConstants.crypto, AssetConstants.appLogo, AssetConstants.appLogo, AssetConstants.appLogo]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped(gestureRecognizer:)))
        viewAppTitle.addGestureRecognizer(tapRecognizer)
        tapRecognizer.delegate = self as UIGestureRecognizerDelegate
        activityIndicator.cycleColors = [.blue]
        let screen = UIScreen.main.bounds
        activityIndicator.frame = CGRect(x: screen.size.width/2, y: screen.size.height/2 - 100, width: 40, height: 40)
        activityIndicator.sizeToFit()
        activityIndicator.indicatorMode = .indeterminate
        activityIndicator.progress = 2.0
        view.addSubview(activityIndicator)
        self.activityIndicator.startAnimating()
        DispatchQueue.global(qos: .userInitiated).async {
            self.saveFetchMenu()
            self.saveTrending()
        }
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
        }
        if Platform.isSimulator {
            if UserDefaults.standard.value(forKey: "deviceToken") == nil{
                UserDefaults.standard.set("41ea0aaa15323ae5012992392e4edd6b8a6ee4547a8dc6fd1f3b31aab9839208", forKey: "deviceToken")
            }
        }
        
        if UserDefaults.standard.value(forKey: "isTextSizeChanged") == nil{
            UserDefaults.standard.set(false, forKey: "isTextSizeChanged")
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
        if let flowLayout = containerCV?.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.minimumLineSpacing = 0
        }
        HideButtonBarView()
        sendDeviceDetails()
        btnBack.isHidden = true
        lblNonews.isHidden = true
        lblAppTitle.text = Constants.AppName
        lblAppTitle.font = FontConstants.appFont
        viewAppTitle.backgroundColor = colorConstants.redColor
        lblAppTitle.textColor = colorConstants.whiteColor
        
        if UserDefaults.standard.value(forKey: "textSize") == nil{
            UserDefaults.standard.set(1, forKey: "textSize")
        }
        NotificationCenter.default.addObserver(self, selector: #selector(darkModeEnabled(_:)), name: .darkModeEnabled, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(darkModeDisabled(_:)), name: .darkModeDisabled, object: nil)
        let darkModeStatus = UserDefaults.standard.value(forKey: "darkModeEnabled") as! Bool
        if  darkModeStatus == true{
            changeTheme()
        }
        
        viewOptions.isHidden = true
        viewOptions.layer.borderWidth = 0.5
        viewOptions.layer.borderColor =  UIColor.darkGray.cgColor
        
        var paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        print("path is :\(paths[0])")
        
        if UserDefaults.standard.value(forKey: "token") != nil{
            if Reachability.isConnectedToNetwork(){
                saveBookmarkDataInDB(url : APPURL.bookmarkedArticlesURL)
                saveLikeDataInDB()
            }
            else{
                let BookmarkRecordCount = DBManager().IsCoreDataEmpty(entity: "BookmarkArticles")
                let LikeRecordCount = DBManager().IsCoreDataEmpty(entity: "LikeDislike")
                if BookmarkRecordCount != 0 || LikeRecordCount != 0{
                    fetchBookmarkDataFromDB()
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewOptions.isHidden = true
        let textSizeChanged = UserDefaults.standard.value(forKey: "isTextSizeChanged") as! Bool
        if textSizeChanged == true{
            containerCV.reloadData()
        }
    }
    
    func sendDeviceDetails(){
        if UserDefaults.standard.value(forKey: "deviceToken") != nil{
            let id = UserDefaults.standard.value(forKey: "deviceToken") as! String
            let param = ["device_id" : id,
                         "device_name": Constants.platform]
            APICall().deviceAPI(param : param){(status,response) in
                print(status,response)
            }
        }
    }
    
    @objc func tapped(gestureRecognizer: UITapGestureRecognizer) {
        if viewOptions.isHidden == false{
            viewOptions.isHidden = true
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func resetTheme(){
        self.activityIndicator.startAnimating()
        btnBookmark.setTitleColor(.black, for: UIControlState.normal)
        btnNightMode.setTitleColor(.black, for: UIControlState.normal)
        btnSettings.setTitleColor(.black, for: UIControlState.normal)
        viewNightMode.backgroundColor = colorConstants.txtlightGrayColor
        viewSettings.backgroundColor = colorConstants.txtlightGrayColor
        viewMyBookmark.backgroundColor = colorConstants.txtlightGrayColor
        viewOptions.backgroundColor = colorConstants.whiteColor
        btnImgNightMode.setImage(nil, for: .normal)
        btnImgNightMode.setImage(UIImage(named: AssetConstants.moon), for: .normal)
        btnImgBookmark.setImage(UIImage(named:AssetConstants.bookmark), for: .normal)
        btnOptionMenu.setImage(UIImage(named:AssetConstants.menuWhite), for: .normal)
        btnSearch.setImage(UIImage(named:AssetConstants.searchWhite), for: .normal)
        submenuCV.backgroundColor = colorConstants.whiteColor
        menuCV.backgroundColor = .white
        submenuCV.reloadData()
        containerCV.reloadData()
        activityIndicator.stopAnimating()
    }
    
    func changeTheme(){
        viewNightMode.backgroundColor = colorConstants.grayBackground1
        viewMyBookmark.backgroundColor = colorConstants.grayBackground1
        viewSettings.backgroundColor = colorConstants.grayBackground1
        btnBookmark.setTitleColor(.white, for: UIControlState.normal)
        btnNightMode.setTitleColor(.white, for: UIControlState.normal)
        btnSettings.setTitleColor(.white, for: UIControlState.normal)
        btnImgNightMode.setImage(UIImage(named: AssetConstants.whiteMoon), for: .normal)
        btnImgBookmark.setImage(UIImage(named:AssetConstants.Bookmark_white), for: .normal)
        menuCV.backgroundColor = colorConstants.MenugrayBackground
        submenuCV.backgroundColor = colorConstants.grayBackground1
        containerCV.backgroundColor =  colorConstants.backgroundGray
        viewOptions.backgroundColor = colorConstants.txtlightGrayColor
        submenuCV.reloadData()
        containerCV.reloadData()
    }
    
    @objc private func darkModeEnabled(_ notification: Notification){
        self.activityIndicator.startAnimating()
        NightNight.theme = .night
        changeTheme()
        activityIndicator.stopAnimating()
    }
    
    @objc private func darkModeDisabled(_ notification: Notification) {
        resetTheme()
        NightNight.theme = .normal
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .darkModeEnabled, object: nil)
        NotificationCenter.default.removeObserver(self, name: .darkModeDisabled, object: nil)
    }
    
    func HideButtonBarView(){
        submenuCV.isHidden = true
        if containerCVTop != nil{
            NSLayoutConstraint.deactivate([containerCVTop])
            containerCVTop = NSLayoutConstraint (item: containerCV,
                                                 attribute: NSLayoutConstraint.Attribute.top,
                                                 relatedBy: NSLayoutConstraint.Relation.equal,
                                                 toItem: menuCV,
                                                 attribute: NSLayoutConstraint.Attribute.bottom,
                                                 multiplier: 1,
                                                 constant: 0)
            NSLayoutConstraint.activate([containerCVTop])
        }
    }
    
    func unhideButtonBarView(){
        submenuCV.isHidden = false
        if containerCVTop != nil{
            NSLayoutConstraint.deactivate([containerCVTop])
            containerCVTop = NSLayoutConstraint (item: containerCV as Any,
                                                 attribute: NSLayoutConstraint.Attribute.top,
                                                 relatedBy: NSLayoutConstraint.Relation.equal,
                                                 toItem: submenuCV,
                                                 attribute: NSLayoutConstraint.Attribute.bottom,
                                                 multiplier: 1,
                                                 constant: 0)
            NSLayoutConstraint.activate([containerCVTop])
        }
    }
    
    func retainClusterData(){
        if isTrendingDetail ==  2{
            ShowArticle = clusterArticles
        }
    }
    
    func saveTrending(){
        DBManager().saveTrending{response in
            if response == true{
                self.fetchTrending()
            }
        }
    }
    
    func fetchTrending(){
        activityIndicator.startAnimating()
        let result = DBManager().fetchTrendingArticle()
        switch result {
        case .Success(let DBData) :
            self.ShowArticle.removeAll()
            prevTrendingData.removeAll()
            SwipeIndex.shared.newShowArticle.removeAll()
            self.ShowArticle = DBData
            prevTrendingData = DBData
            
            if self.ShowArticle.count > 0{
                SwipeIndex.shared.newShowArticle.append(ShowArticle)
                self.lblNonews.isHidden = true
                containerCV.reloadData()
            }
            else{
                self.activityIndicator.stopAnimating()
            }
        case .Failure(let errorMsg) :
            print(errorMsg)
        }
    }
    
    //fetch articles of selected cluster
    func fetchClusterIdArticles(clusterID: Int){
        let result = DBManager().fetchClusterArticles(trendingId: clusterID)
        switch result {
        case .Success(let DBData) :
            self.clusterArticles = DBData
            if self.clusterArticles.count > 0{
                self.lblNonews.isHidden = true
                ShowArticle = DBData
            }
            else{
                self.activityIndicator.stopAnimating()
            }
        case .Failure(let errorMsg) :
            print(errorMsg)
        }
    }
    
    func saveFetchMenu(){
        let coredataRecordCount = DBManager().IsCoreDataEmpty(entity: "MenuHeadings")
        
        if coredataRecordCount > 0 {
            if Reachability.isConnectedToNetwork(){
                DBManager().deleteAllData(entity: "MenuHeadings")
                DBManager().deleteAllData(entity: "HeadingSubMenu")
                DBManager().deleteAllData(entity: "MenuHashTag")
                DBManager().saveMenu(){response in
                    if response == true{
                        self.fetchMenuFromDB()
                    }
                }
            }
            else{
                self.fetchMenuFromDB()
            }
        }else{
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
                self.headingIds.append(Int(i.headingId))
            }
            headingArr.insert("Trending", at: 0)
            headingIds.insert(00, at: 0)
            isTrendingDetail = 1
            
            self.menuCV.reloadData()
            menuIndexPath = NSIndexPath(row: 0, section: 0) as IndexPath
            menuCV.selectItem(at: menuIndexPath, animated: true, scrollPosition: [])
            for heading in headingData{
                let subresult = DBManager().fetchSubMenu(headingId: Int(heading.headingId))
                
                switch subresult{
                case .Success(let subMenuData) :
                    self.submenu.removeAll()
                    for sub in subMenuData{
                        self.submenu.append(sub.subMenuName!)
                    }
                    
                    self.subMenuArr.append(self.submenu)
                    self.fetchSubmenuId(submenu:self.subMenuArr[self.HeadingRow][self.subMenuRow] )
                    UserDefaults.standard.set(self.subMenuArr[self.HeadingRow][self.subMenuRow], forKey: "submenu")
                    
                case .Failure(let error):
                    print(error)
                }
            }
            
        case .Failure(let error) :
            print(error)
        }
        DispatchQueue.global(qos: .userInitiated).async {
            self.SaveAllSubmenuNews()
        }
        HideButtonBarView()
    }
    
    func loadFirstNews(){
        if submenuName == ""{
            coredataRecordCount = DBManager().IsCoreDataEmpty(entity: "NewsArticle")
            if self.coredataRecordCount > 0 {
                self.fetchArticlesFromDB()
            }
            else{
                if Reachability.isConnectedToNetwork(){
                    activityIndicator.startAnimating()
                    if UserDefaults.standard.value(forKey: "submenuURL") != nil{
                        self.saveArticlesInDB()
                    }
                }else{
                    activityIndicator.stopAnimating()
                    lblNonews.isHidden = true
                }
            }
        }
    }
    
    func fetchSubmenuId(submenu : String){
        let tagresult = DBManager().fetchsubmenuId(subMenuName: submenu)
        switch tagresult{
        case .Success(let id) :
            let url = APPURL.ArticleByIdURL + "\(id)"
            UserDefaults.standard.setValue(id, forKey: "subMenuId")
            UserDefaults.standard.setValue(url, forKey: "submenuURL")
        case .Failure(let error):
            print(error)
        }
    }
    
    func fetchArticlesFromDB(){
        activityIndicator.startAnimating()
        ShowArticle.removeAll()
        let result = DBManager().ArticlesfetchByCatId()
        switch result {
        case .Success(let DBData) :
            if DBData.count > 0{
                ShowArticle = DBData
            }
            else{
                DispatchQueue.global(qos: .userInitiated).async {
                    self.fetchArticlesFromDB()
                }
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                }
            }
        case .Failure(let errorMsg) :
            print(errorMsg)
        }
    }
    
    func saveArticlesInDB(){
        var subMenuURL = ""
        if UserDefaults.standard.value(forKey: "submenuURL") != nil{
            subMenuURL =  UserDefaults.standard.value(forKey: "submenuURL") as! String
        }
        DBManager().SaveDataDB(nextUrl: subMenuURL ){
            response in
            if response == true{
            }
        }
    }
    
    func fetchBookmarkDataFromDB(){
        let result = DBManager().FetchLikeBookmarkFromDB()
        switch result {
        case .Success(let DBData) :
            if DBData.count == 0{
                activityIndicator.stopAnimating()
            }
        case .Failure( _) : break
        }
    }
    
    func saveBookmarkDataInDB(url: String){
        DBManager().SaveBookmarkArticles(){response in
            if response == true{
                self.fetchBookmarkDataFromDB()
            }
        }
    }
    
    func saveLikeDataInDB(){
        DBManager().SaveLikeDislikeArticles(){response in
            if response == true{
                self.fetchBookmarkDataFromDB()
            }
        }
    }
    
    @IBAction func btnSettingsActn(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let settingvc:SettingsVC = storyboard.instantiateViewController(withIdentifier: "SettingsID") as! SettingsVC
        self.present(settingvc, animated: false, completion: nil)
    }
    
    @IBAction func btnMyBookmarkActn(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let bookmarkvc:BookmarkVC = storyboard.instantiateViewController(withIdentifier: "BookmarkID") as! BookmarkVC
        self.present(bookmarkvc, animated: false, completion: nil)
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
    
    @IBAction func btnOptionMenuActn(_ sender: Any) {
        if viewOptions.isHidden == true{
            viewOptions.isHidden = false
        }else{
            viewOptions.isHidden = true
        }
    }
    
    @IBAction func btnSearchMenuActn(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let searchvc:SearchVC = storyboard.instantiateViewController(withIdentifier: "SearchID") as! SearchVC
        self.present(searchvc, animated: true, completion: nil)
    }
    
    @IBAction func btnBackActn(_ sender: Any) {
        isTrendingDetail = 1
        ShowArticle = prevTrendingData
        containerCV.reloadData()
        btnBack.isHidden = true
    }
}

extension ParentViewController: trendingDetailClicked {
    func isTrendingDetailedOpened(status: Bool){
        if status == true{
            btnBack.isHidden = false
        }
    }
}
extension ParentViewController : UICollectionViewDelegate, UICollectionViewDataSource, CellDelegate{
    
    /*  func scrollViewDidScroll(_ scrollView: UIScrollView) {
     print(scrollView.contentOffset.x)
     submenuLeading.constant = scrollView.contentOffset.x / CGFloat(subMenuArr[HeadingRow].count)
     submenuCV.submenuLeading.constant = scrollView.contentOffset.x
     menuBar.horizontalBarLeftAnchorConstraint?.constant = scrollView.contentOffset.x / 4
     }*/
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if scrollView == containerCV{
            if headingName != "Trending"{
                isSwipe = true
                let index = Int(targetContentOffset.pointee.x / submenuCV.frame.width)
                let indexPath = IndexPath(item: index, section: 0)
                submenuCV.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
                /*  SwipeIndex.shared.currentIndex = subMenuRow + 1
                 containerCV.reloadData()
                 self.currentIndexPath = indexPath
                 
                 subMenuRow = indexPath.row
                 submenuName = subMenuArr[HeadingRow][subMenuRow]
                 UserDefaults.standard.set(subMenuArr[HeadingRow][subMenuRow], forKey: "submenu")
                 
                 reloadSubmenuNews()*/
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == menuCV{
            return headingArr.count
        }else if collectionView == containerCV{
            if isTrendingDetail == 1{
                return 1
            }else{
                return (subMenuArr.count > 0) ? subMenuArr[HeadingRow].count : 0
            }
        }
        else{
            return (subMenuArr.count > 0) ? subMenuArr[HeadingRow].count : 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let darkModeStatus = UserDefaults.standard.value(forKey: "darkModeEnabled") as! Bool
        if collectionView == menuCV {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "menuID", for:indexPath) as! menuCVCell
            cell.lblMenu.text = headingArr[indexPath.item]
            cell.imgMenu.image =  UIImage(named: headingImg[indexPath.row])
            return cell
        }
        else if collectionView == containerCV{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "containerID", for:indexPath) as! ContainerCVCell
            cell.newShowArticle.removeAll()
            cell.selectedObj = self as CellDelegate
            cell.trendingClickedObj = self as trendingDetailClicked
            if  darkModeStatus == true{
                cell.newsCV.backgroundColor = colorConstants.txtlightGrayColor
                cell.backgroundColor = colorConstants.grayBackground3
            }else{
                cell.newsCV.backgroundColor = .white
                cell.backgroundColor = .white
            }
            if isTrendingDetail == 1{
                cell.isTrending = true
                cell.newShowArticle.append(prevTrendingData)
                cell.newsCV.reloadData()
            }
            else{
                if submenuCV.isHidden == false{
                    cell.isTrending = false
                    if isSwipe == true{
                        cell.submenuCOunt = indexPath.row
                    }
                    else{
                        cell.submenuCOunt = subMenuRow
                    }
                    fetchSubMenuNews()
                    
                    cell.newShowArticle = newShowArticle
                    cell.newsCV.reloadData()
                    if newShowArticle[cell.submenuCOunt].count > 0{
                        cell.newsCV?.scrollToItem(at: NSIndexPath(row: 0, section: 0) as IndexPath,
                                                  at: .top,
                                                  animated: false)
                    }
                }
                else{
                    cell.isTrending = true
                    fetchSubMenuNews()
                    cell.newShowArticle = newShowArticle
                    cell.newsCV.reloadData()
                    cell.newsCV?.scrollToItem(at: NSIndexPath(row: 0, section: 0) as IndexPath,
                                              at: .top,
                                              animated: false)
                }
            }
            activityIndicator.stopAnimating()
            return cell
        }
        else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "submenuID", for:indexPath) as! NewsubmenuCVCell
            cell.lblSubmenu.layer.borderWidth = 1.0
            cell.lblSubmenu.layer.cornerRadius = 18
            cell.lblSubmenu.layer.masksToBounds = true
            cell.lblSubmenu.text = subMenuArr[HeadingRow][indexPath.row]
            
            if  darkModeStatus == true{
                cell.backgroundColor = colorConstants.grayBackground1
                cell.lblSubmenu.backgroundColor = .white
            }
            else{
                cell.backgroundColor = .white
            }
            containerCV.reloadData()
            activityIndicator.stopAnimating()
            return cell
        }
    }
    
    //didselect for newsCV
    func colCategorySelected(_ indexPath : IndexPath, _ sortedData : [NewsArticle]){
        viewOptions.isHidden = true
        btnBack.isHidden = false
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newsDetailvc:NewsDetailVC = storyboard.instantiateViewController(withIdentifier: "NewsDetailID") as! NewsDetailVC
        
        if isTrendingDetail == 0{
            UserDefaults.standard.set("home", forKey: "isSearch")
        }else{
            UserDefaults.standard.set("cluster", forKey: "isSearch")
        }
        if isTrendingDetail == 0 || isTrendingDetail == 2{
            if sortedData.count > 0 {
                newsDetailvc.newsCurrentIndex = indexPath.row
                newsDetailvc.ShowArticle = sortedData
                newsDetailvc.articleId = Int(sortedData[indexPath.row].article_id)
                present(newsDetailvc, animated: true, completion: nil)
            }
        }
        else{
            var id = UserDefaults.standard.array(forKey: "trendingArray") as! [Int]
            let selectedCluster = id[indexPath.row]
            fetchClusterIdArticles(clusterID: selectedCluster)
            isTrendingDetail = 2
        }
        if isTrendingDetail == 2 {
            btnBack.isHidden = false
        }else{
            btnBack.isHidden = true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewOptions.isHidden = true
        if collectionView == menuCV{
            index = 0
            headingName = headingArr[indexPath.row]
            if headingArr[indexPath.row] != "Trending"{
                //currentIndexPath = NSIndexPath(row: 0, section: 0) as IndexPath
                //set first row selected by default
                isTrendingDetail = 0
                HeadingRow = indexPath.row - 1
                unhideButtonBarView()
                submenuCV.reloadData()
                subMenuRow = 0
                submenuName = subMenuArr[HeadingRow][subMenuRow]
                UserDefaults.standard.set(subMenuArr[self.HeadingRow], forKey: "submenuArr")
                submenuCV.selectItem(at: IndexPath(row: 0 , section: 0), animated: false, scrollPosition: [])
                submenuCV.scrollToItem(at: IndexPath(row: 0 , section: 0), at: .centeredHorizontally, animated: true)
                btnBack.isHidden = true
                SaveSubmenuNews()
                containerCV.reloadData()
                containerCV.selectItem(at: IndexPath(row: 0 , section: 0), animated: false, scrollPosition: [])
                containerCV.scrollToItem(at: IndexPath(row: 0 , section: 0), at: .centeredHorizontally, animated: true)
            }
            else{
                HideButtonBarView()
                index = subMenuRow
                isTrendingDetail = 1
                if prevTrendingData.count > 0{
                    DispatchQueue.global(qos: .userInitiated).async {
                        self.ShowArticle = self.prevTrendingData
                    }
                    DispatchQueue.main.async {
                        self.containerCV.reloadData()
                    }
                }else{
                    self.fetchTrending()
                }
            }
        }
        else if collectionView == submenuCV{
            //            let indexPath = IndexPath(item: index, section: 0)
            //            submenuCV.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
            //            submenuCV.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            //      SwipeIndex.shared.currentIndex = indexPath.row
            isSwipe = false
            self.currentIndexPath = indexPath
            subMenuRow = indexPath.row
            submenuName = subMenuArr[HeadingRow][subMenuRow]
            UserDefaults.standard.set(subMenuArr[HeadingRow][subMenuRow], forKey: "submenu")
            reloadSubmenuNews()
            containerCV.reloadData()
        }
    }
    
    func fetchSubMenuNews(){
        newShowArticle.removeAll()
        index = 0
        if submenuCV.isHidden == false{
            while index < subMenuArr[HeadingRow].count{
                submenuName = subMenuArr[HeadingRow][index]
                UserDefaults.standard.set(subMenuArr[HeadingRow][index], forKey: "submenu")
                fetchSubmenuId(submenu: subMenuArr[HeadingRow][index])
                fetchArticlesFromDB()
                index = index + 1
                newShowArticle.append(ShowArticle)
            }
        }
        else{
            newShowArticle.removeAll()
            newShowArticle.append(ShowArticle)
        }
        SwipeIndex.shared.newShowArticle = newShowArticle
    }
    
    func SaveAllSubmenuNews(){
        for head in 0...headingArr.count - 2 {
            var index = 0
            while index < subMenuArr[head].count {
                UserDefaults.standard.set(subMenuArr[head][index], forKey: "submenu")
                fetchSubmenuId(submenu: subMenuArr[head][index])
                coredataRecordCount = DBManager().IsCoreDataEmpty(entity: "NewsArticle")
                if Reachability.isConnectedToNetwork(){
                    activityIndicator.startAnimating()
                    if UserDefaults.standard.value(forKey: "submenuURL") != nil{
                        self.saveArticlesInDB()
                    }
                }else{
                    lblNonews.isHidden = true
                }
                index = index + 1
            }
        }
    }
    
    func SaveSubmenuNews(){
        while index < subMenuArr[HeadingRow].count {
            UserDefaults.standard.set(subMenuArr[HeadingRow][index], forKey: "submenu")
            fetchSubmenuId(submenu: subMenuArr[HeadingRow][index])
            coredataRecordCount = DBManager().IsCoreDataEmpty(entity: "NewsArticle")
            if Reachability.isConnectedToNetwork(){
                activityIndicator.startAnimating()
                if UserDefaults.standard.value(forKey: "submenuURL") != nil{
                    self.saveArticlesInDB()
                }
            }else{
                lblNonews.isHidden = true
            }
            index = index + 1
        }
    }
    
    func reloadSubmenuNews(){
        lblNonews.isHidden = true
        UserDefaults.standard.set(subMenuArr[HeadingRow][subMenuRow], forKey: "submenu")
        fetchSubmenuId(submenu: subMenuArr[HeadingRow][subMenuRow])
        coredataRecordCount = DBManager().IsCoreDataEmpty(entity: "NewsArticle")
        if Reachability.isConnectedToNetwork(){
            if UserDefaults.standard.value(forKey: "submenuURL") != nil{
                self.saveArticlesInDB()
            }
        }else{
            lblNonews.isHidden = true
        }
    }
}

extension ParentViewController: TrendingBack{
    func isTrendingTVLoaded(status: Bool) {
        if status == true{
            btnBack.isHidden = false
        }else{
            btnBack.isHidden = true
        }
    }
}

extension ParentViewController: ScrollDelegate{
    func isNavigate(status: Bool) {
        if status == true{
            viewOptions.isHidden = true
        }
    }
}

extension ParentViewController : UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view!.superview!.superclass! .isSubclass(of: UIButton.self) {
            return false
        }
        return true
    }
}

extension ParentViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var CVSize = CGFloat()
        if collectionView == menuCV{
            let label = UILabel(frame: CGRect.zero)
            label.text = headingArr[indexPath.item]
            label.sizeToFit()
            if (UIDevice.current.userInterfaceIdiom != UIUserInterfaceIdiom.pad){
                CVSize = label.intrinsicContentSize.width + 80
            }else{
                CVSize = label.intrinsicContentSize.width + 90
            }
            return CGSize(width:CVSize , height: 60)
        }
        else if collectionView ==  submenuCV{
            let label = UILabel(frame: CGRect.zero)
            label.text = subMenuArr[HeadingRow][indexPath.item]
            label.sizeToFit()
            CVSize = label.frame.width + 60.0
            return CGSize(width:CVSize , height: 40)
        }
        else{
            let screen = UIScreen.main.bounds
            let bottomPadding = view.safeAreaInsets.bottom
            let topPadding = view.safeAreaInsets.top
            
            if submenuCV.isHidden == true {
                let totalHeight = viewAppTitle.frame.size.height + menuCV.frame.size.height + bottomPadding + topPadding
                return CGSize(width: screen.size.width, height: screen.size.height - totalHeight)
            }else{
                let totalHeight = viewAppTitle.frame.size.height + menuCV.frame.size.height + submenuCV.frame.size.height + bottomPadding + topPadding
                return CGSize(width: screen.size.width, height: screen.size.height - totalHeight)
            }
        }
    }
}
