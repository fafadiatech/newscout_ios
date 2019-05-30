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
    
    // OUTPUT 1
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
    
    // OUTPUT 2
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
protocol ScrollToTopDelegate{
    func topSelected(status: Bool)
}
class ParentViewController: UIViewController {
    
    @IBOutlet var mainViewLeading: UIView!
    @IBOutlet weak var submenuLeading: NSLayoutConstraint!
    @IBOutlet weak var containerCVTop: NSLayoutConstraint!
    @IBOutlet weak var containerCV: UICollectionView!
    @IBOutlet weak var btnTopNews: UIButton!
    @IBOutlet weak var HomeCVLeading: NSLayoutConstraint!
    @IBOutlet weak var HomeNewsTVLeading: NSLayoutConstraint!
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
    @IBOutlet var HomeNewsTV: UITableView!
    @IBOutlet var menuCV: UICollectionView!
    @IBOutlet var submenuCV: UICollectionView!
    @IBOutlet weak var lblNonews: UILabel!
    @IBOutlet weak var HomeNewsTVTop: NSLayoutConstraint!
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
    var scrollToTopObj : ScrollToTopDelegate?
    
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
    var headingImg = [AssetConstants.sector, AssetConstants.regional, AssetConstants.finance, AssetConstants.economy, AssetConstants.misc, AssetConstants.sector]
    var submenuImgArr = [[AssetConstants.banking, AssetConstants.retail,AssetConstants.retail, AssetConstants.tech, AssetConstants.transport, AssetConstants.energy, AssetConstants.food, AssetConstants.manufacturing, AssetConstants.fintech, AssetConstants.media],
                         [AssetConstants.us, AssetConstants.china, AssetConstants.asia, AssetConstants.japan, AssetConstants.india, AssetConstants.appLogo],
                         [AssetConstants.recession, AssetConstants.personal_finance, AssetConstants.funding, AssetConstants.ipo, AssetConstants.appLogo],
                         [AssetConstants.appLogo, AssetConstants.appLogo, AssetConstants.appLogo, AssetConstants.appLogo,  AssetConstants.appLogo,  AssetConstants.appLogo,  AssetConstants.appLogo],
                         [AssetConstants.appLogo, AssetConstants.appLogo, AssetConstants.appLogo, AssetConstants.appLogo, AssetConstants.appLogo, AssetConstants.appLogo, AssetConstants.appLogo, AssetConstants.appLogo, AssetConstants.crypto, AssetConstants.appLogo, AssetConstants.appLogo, AssetConstants.appLogo]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        HomeNewsTV.tableFooterView = UIView(frame: .zero)
        HomeNewsTV.isHidden = true
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped(gestureRecognizer:)))
        viewAppTitle.addGestureRecognizer(tapRecognizer)
        tapRecognizer.delegate = self as UIGestureRecognizerDelegate
        activityIndicator.cycleColors = [.blue]
        activityIndicator.frame = CGRect(x: view.frame.width/2, y: view.frame.height/2 - 100, width: 40, height: 40)
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
            //self.activityIndicator.stopAnimating()
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
            print("stup called")
        }
        HideButtonBarView()
        btnTopNews.layer.cornerRadius = 0.5 * btnTopNews.bounds.size.width
        btnTopNews.clipsToBounds = true
        btnTopNews.backgroundColor = colorConstants.redColor
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
        //Add a left swipe gesture recognizer
        var recognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipeLeft(_:)))
        recognizer.direction = .left
        HomeNewsTV.addGestureRecognizer(recognizer)
        
        //Add a right swipe gesture recognizer
        recognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipeRight(_:)))
        recognizer.delegate = self as? UIGestureRecognizerDelegate
        recognizer.direction = .right
        HomeNewsTV.addGestureRecognizer(recognizer)
        var paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        print("path is :\(paths[0])")
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshNews), for: .valueChanged)
        HomeNewsTV.refreshControl = refreshControl
        refreshControl.attributedTitle = NSAttributedString(string: "Pull  to Refresh...")
        
        
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
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewOptions.isHidden = true
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let index = self.HomeNewsTV.indexPathForSelectedRow{
            self.HomeNewsTV.deselectRow(at: index, animated: false)
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
        viewOptions.backgroundColor = colorConstants.txtlightGrayColor
        btnImgNightMode.setImage(nil, for: .normal)
        btnImgNightMode.setImage(UIImage(named: AssetConstants.moon), for: .normal)
        btnImgBookmark.setImage(UIImage(named:AssetConstants.bookmark), for: .normal)
        btnOptionMenu.setImage(UIImage(named:AssetConstants.menuWhite), for: .normal)
        btnSearch.setImage(UIImage(named:AssetConstants.searchWhite), for: .normal)
        submenuCV.backgroundColor = colorConstants.whiteColor
        HomeNewsTV.reloadData()
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
        menuCV.backgroundColor = colorConstants.subTVgrayBackground
        submenuCV.backgroundColor = colorConstants.txtlightGrayColor
        HomeNewsTV.backgroundColor =  colorConstants.backgroundGray
        viewOptions.backgroundColor = colorConstants.txtlightGrayColor
        HomeNewsTV.reloadData()
        submenuCV.reloadData()
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

    @objc func canPresentPageAt(indexPath: IndexPath) -> Bool {
        
        if indexPath.row < 0 || indexPath.row >= subMenuArr[HeadingRow].count {
            print("You are trying to go to a non existing page")
            return false
        } else {
            print("If you haven't implemented a VC for page 4 it will crash here")
            return true;
        }
    }
    
    @objc func handleSwipeLeft(_ gestureRecognizer: UISwipeGestureRecognizer?) {
        let location: CGPoint? = gestureRecognizer?.location(in: HomeNewsTV)
        let indexPath: IndexPath? = HomeNewsTV.indexPathForRow(at: location ?? CGPoint.zero)
        if indexPath != nil {
            isSwipeLeft = true
            if isTrendingDetail == 0{
                swipeActn()
            }
        }
    }
    
    @objc func handleSwipeRight(_ gestureRecognizer: UISwipeGestureRecognizer?) {
        let location: CGPoint? = gestureRecognizer?.location(in: HomeNewsTV)
        let indexPath: IndexPath? = HomeNewsTV.indexPathForRow(at: location ?? CGPoint.zero)
        if indexPath != nil {
            isSwipeLeft = false
            if isTrendingDetail == 0{
                swipeActn()
            }
        }
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
    func swipeActn(){
        lblNonews.isHidden = true
        activityIndicator.startAnimating()
        let transition = CATransition()
        transition.duration = 0.9
        guard let indexPath = self.currentIndexPath else {
            return
        }
        var newIndex = indexPath
        transition.type = kCATransitionMoveIn
        
        
        if isSwipeLeft == true{
            if subMenuRow < subMenuArr[HeadingRow].count - 1{
                subMenuRow = subMenuRow + 1
                
                newIndex = IndexPath(row: newIndex.row+1, section: newIndex.section)
                transition.subtype = kCATransitionFromRight
            }
        }else{
            if subMenuRow > 0 {
                subMenuRow = subMenuRow - 1
                newIndex = IndexPath(row: newIndex.row-1, section: self.currentIndexPath!.section)
                transition.subtype = kCATransitionFromLeft
            }
        }
        
        if canPresentPageAt(indexPath: newIndex) {
            self.submenuCV.selectItem(at: newIndex, animated: false, scrollPosition: UICollectionViewScrollPosition.centeredHorizontally)
            self.collectionView(self.submenuCV, didSelectItemAt: newIndex)
        } else {
            print("You are tying to navigate to an invalid page")
        }
        HomeNewsTV.window!.layer.add(transition, forKey: kCATransition)
        UserDefaults.standard.set(subMenuArr[HeadingRow][subMenuRow], forKey: "submenu")
        fetchSubmenuId(submenu: subMenuArr[HeadingRow][subMenuRow])
        coredataRecordCount = DBManager().IsCoreDataEmpty(entity: "NewsArticle")
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
    
    @objc func refreshNews(refreshControl: UIRefreshControl) {
        activityIndicator.startAnimating()
        DispatchQueue.global(qos: .userInitiated).async {
            if self.isTrendingDetail == 0{
                self.saveArticlesInDB()
            }
            else if self.isTrendingDetail == 1{
                self.saveTrending()
            }
        }
        DispatchQueue.main.async {
            refreshControl.endRefreshing()
            self.activityIndicator.stopAnimating()
        }
    }
    func retainClusterData(){
        if isTrendingDetail ==  2{
            ShowArticle = clusterArticles
            HomeNewsTV.reloadData()
        }
    }
    func saveTrending(){
        DBManager().saveTrending{response in
            if response == true{
                //self.fetchTrending()
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
            self.ShowArticle = DBData
            prevTrendingData = DBData
            if self.ShowArticle.count > 0{
                self.lblNonews.isHidden = true
                self.HomeNewsTV.reloadData()
                containerCV.reloadData()
            }
            else{
                self.HomeNewsTV.reloadData()
                self.lblNonews.isHidden =  false
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
                self.HomeNewsTV.reloadData()
                scrollToFirstRow()
            }
            else{
                self.HomeNewsTV.reloadData()
                self.lblNonews.isHidden =  false
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
        
        //        submenuCV.reloadData()
        //        currentIndexPath = NSIndexPath(row: 0, section: 0) as IndexPath
        //        submenuCV.selectItem(at: currentIndexPath, animated: true, scrollPosition: [])
        //        loadFirstNews()
        SaveSubmenuNews()
        HideButtonBarView()
        fetchTrending()
        
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
        ShowArticle.removeAll()
        let result = DBManager().ArticlesfetchByCatId()
        switch result {
        case .Success(let DBData) :
            ShowArticle = DBData
            //            if ShowArticle.count > 0{
            //                lblNonews.isHidden = true
            //                self.HomeNewsTV.reloadData()
            //                containerCV.reloadData()
            //                scrollToFirstRow()
            //            }
            //            else{
            //                self.HomeNewsTV.reloadData()
            //                containerCV.reloadData()
            //                lblNonews.isHidden =  false
            //                activityIndicator.stopAnimating()
        //            }
        case .Failure(let errorMsg) :
            print(errorMsg)
        }
    }
    
    func saveArticlesInDB(){
        var subMenuURL = ""
        if UserDefaults.standard.value(forKey: "submenuURL") != nil{
            subMenuURL =  UserDefaults.standard.value(forKey: "submenuURL") as! String
        }
        DBManager().SaveDataDB(nextUrl: subMenuURL ){response in
            if response == true{
                // self.fetchArticlesFromDB()
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
        self.present(settingvc, animated: true, completion: nil)
    }
    
    @IBAction func btnMyBookmarkActn(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let bookmarkvc:BookmarkVC = storyboard.instantiateViewController(withIdentifier: "BookmarkID") as! BookmarkVC
        self.present(bookmarkvc, animated: true, completion: nil)
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
    
    @IBAction func btnTopNewsActn(_ sender: Any) {
        //scrollToTopObj?.topSelected(status: true)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
      //  scrollToFirstRow()
    }
    
    @IBAction func btnBackActn(_ sender: Any) {
        isTrendingDetail = 1
        activityIndicator.startAnimating()
        ShowArticle = prevTrendingData
        HomeNewsTV.reloadData()
        //fetchTrending()
        
        btnBack.isHidden = true
    }
    
}

extension ParentViewController : UICollectionViewDelegate, UICollectionViewDataSource, CellDelegate{
    //     func scrollViewDidScroll(_ scrollView: UIScrollView) {
    //
    //        print(scrollView.contentOffset.x)
    //       // submenuLeading.constant = scrollView.contentOffset.x / CGFloat(subMenuArr[HeadingRow].count)
    //        //submenuCV.submenuLeading.constant = scrollView.contentOffset.x
    //       // menuBar.horizontalBarLeftAnchorConstraint?.constant = scrollView.contentOffset.x / 4
    //    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    
        if headingName != "Trending"{
            isSwipe = true
            let index = Int(targetContentOffset.pointee.x / submenuCV.frame.width)
            let indexPath = IndexPath(item: index, section: 0)
            submenuCV.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
            //  self.currentIndexPath = indexPath
            
            //       subMenuRow = indexPath.row
            //        submenuName = subMenuArr[HeadingRow][subMenuRow]
            //        UserDefaults.standard.set(subMenuArr[HeadingRow][subMenuRow], forKey: "submenu")
            
            // reloadSubmenuNews()
            containerCV.reloadData()
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
        var currentArticle = NewsArticle()
        if collectionView == menuCV {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "menuID", for:indexPath) as! menuCVCell
            cell.lblMenu.text = headingArr[indexPath.item]
            cell.imgMenu.image =  UIImage(named: headingImg[indexPath.row])
            return cell
        }
        else if collectionView == containerCV{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "containerID", for:indexPath) as! ContainerCVCell
            cell.newShowArticle.removeAll()
            scrollToTopObj?.topSelected(status: false)
            cell.selectedObj = self as! CellDelegate
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
            }
            else{
                cell.isTrending = true
                fetchSubMenuNews()
                cell.newShowArticle = newShowArticle
                cell.newsCV.reloadData()
            }
            activityIndicator.stopAnimating()
            return cell
        }
        else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "submenuID", for:indexPath) as! NewsubmenuCVCell
            let darkModeStatus = UserDefaults.standard.value(forKey: "darkModeEnabled") as! Bool
            
            cell.lblSubmenu.layer.borderWidth = 1.0
            cell.lblSubmenu.layer.cornerRadius = 20
            cell.lblSubmenu.layer.masksToBounds = true
            cell.lblSubmenu.text = subMenuArr[HeadingRow][indexPath.row]
            //cell.imgSubmenuBackground.image = UIImage(named: submenuImgArr[HeadingRow][indexPath.row] )
            
            
            
            if  darkModeStatus == true{
                cell.backgroundColor = colorConstants.txtlightGrayColor
            }
            else{
                cell.backgroundColor = .white
            }
            containerCV.reloadData()
            return cell
        }
    }
    
    //didselect for newsCV
    func colCategorySelected(_ indexPath : IndexPath, _ sortedData : [NewsArticle]){
        viewOptions.isHidden = true
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
        activityIndicator.startAnimating()
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
                submenuCV.selectItem(at: IndexPath(row: 0 , section: 0), animated: false, scrollPosition: [])
                submenuCV.scrollToItem(at: IndexPath(row: 0 , section: 0), at: .centeredHorizontally, animated: true)
                btnBack.isHidden = true
                SaveSubmenuNews()
                
                // reloadSubmenuNews()
                containerCV.reloadData()
                containerCV.selectItem(at: IndexPath(row: 0 , section: 0), animated: false, scrollPosition: [])
                containerCV.scrollToItem(at: IndexPath(row: 0 , section: 0), at: .centeredHorizontally, animated: true)
            }else{
                activityIndicator.startAnimating()
                HideButtonBarView()
                index = subMenuRow
                isTrendingDetail = 1
                if prevTrendingData.count > 0{
                    ShowArticle = prevTrendingData
                    HomeNewsTV.reloadData()
                    containerCV.reloadData()
                }else{
                    fetchTrending()
                }
            }
        }
        else if collectionView == submenuCV{
            //            let indexPath = IndexPath(item: index, section: 0)
            //            submenuCV.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
            //            submenuCV.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            isSwipe = false
            self.currentIndexPath = indexPath
            subMenuRow = indexPath.row
            submenuName = subMenuArr[HeadingRow][subMenuRow]
            UserDefaults.standard.set(subMenuArr[HeadingRow][subMenuRow], forKey: "submenu")
            
            reloadSubmenuNews()
            fetchSubMenuNews()
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
        activityIndicator.startAnimating()
        UserDefaults.standard.set(subMenuArr[HeadingRow][subMenuRow], forKey: "submenu")
        fetchSubmenuId(submenu: subMenuArr[HeadingRow][subMenuRow])
        coredataRecordCount = DBManager().IsCoreDataEmpty(entity: "NewsArticle")
        if Reachability.isConnectedToNetwork(){
            activityIndicator.startAnimating()
            if UserDefaults.standard.value(forKey: "submenuURL") != nil{
                self.saveArticlesInDB()
            }
            
        }else{
            lblNonews.isHidden = true
        }
    }
}

extension ParentViewController: UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (ShowArticle.count > 0) ? self.ShowArticle.count : 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewOptions.isHidden = true
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
    
    func scrollToFirstRow() {
        let indexPath = NSIndexPath(row: 0, section: 0)
        self.HomeNewsTV.scrollToRow(at: indexPath as IndexPath, at: .top, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var currentArticle = NewsArticle()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.timeZone = NSTimeZone.local
        let darkModeStatus = UserDefaults.standard.value(forKey: "darkModeEnabled") as! Bool
        sortedData.removeAll()
        let textSizeSelected = UserDefaults.standard.value(forKey: "textSize") as! Int
        var sourceColor = UIColor()
        var fullTxt = ""
        var dateSubString = ""
        var agoDate = ""
        if  isTrendingDetail == 0 || isTrendingDetail == 2{
            sortedData = ShowArticle.sorted{ $0.published_on! > $1.published_on! }
            currentArticle = sortedData[indexPath.row]
            if indexPath.row % 2 != 0{
                let cell = tableView.dequeueReusableCell(withIdentifier: "HomeNewsTVCellID", for:indexPath) as! HomeNewsTVCell
                imgWidth = String(describing : Int(cell.imgNews.frame.width))
                imgHeight = String(describing : Int(cell.imgNews.frame.height))
                
                
                cell.clipsToBounds = true
                cell.imgNews.layer.cornerRadius = 10.0
                cell.imgNews.clipsToBounds = true
                cell.viewCellContainer.layer.cornerRadius = 10
                cell.viewCellContainer.layer.shadowColor = UIColor.black.cgColor
                cell.viewCellContainer.layer.shadowOffset = CGSize(width: 3, height: 3)
                cell.viewCellContainer.layer.shadowOpacity = 0.7
                cell.viewCellContainer.layer.shadowRadius = 4.0
                //display data from DB
                cell.lblNewsHeading.text = currentArticle.title
                
                if  darkModeStatus == true{
                    cell.ViewCellBackground.backgroundColor = colorConstants.grayBackground2
                    cell.lblSource.textColor = colorConstants.nightModeText
                    cell.lblNewsHeading.textColor = colorConstants.nightModeText
                    
                }
                else{
                    cell.ViewCellBackground.backgroundColor = .white
                    cell.lblSource.textColor = colorConstants.blackColor
                    cell.lblNewsHeading.textColor = colorConstants.blackColor
                    
                }
                
                if ((currentArticle.published_on?.count)!) <= 20{
                    if !(currentArticle.published_on?.contains("Z"))!{
                        currentArticle.published_on?.append("Z")
                    }
                    let newDate = dateFormatter.date(from: currentArticle.published_on!)
                    if newDate != nil{
                        agoDate = Helper().timeAgoSinceDate(newDate!)
                        fullTxt = "\(agoDate)" + " via " + currentArticle.source!
                        let attributedWithTextColor: NSAttributedString = fullTxt.attributedStringWithColor([currentArticle.source!], color: UIColor.red)
                        cell.lblSource.attributedText = attributedWithTextColor
                    }
                }
                else{
                    dateSubString = String(currentArticle.published_on!.prefix(19))
                    if !(dateSubString.contains("Z")){
                        dateSubString.append("Z")
                    }
                    let newDate = dateFormatter.date(from: dateSubString
                    )
                    if newDate != nil{
                        agoDate = Helper().timeAgoSinceDate(newDate!)
                        fullTxt = "\(agoDate)" + " via " + currentArticle.source!
                        let attributedWithTextColor: NSAttributedString = fullTxt.attributedStringWithColor([currentArticle.source!], color: UIColor.red)
                        cell.lblSource.attributedText = attributedWithTextColor
                    }
                }
                let imgURL = APPURL.imageServer + imgWidth + "x" + imgHeight + "/smart/" + currentArticle.imageURL!
                cell.imgNews.sd_setImage(with: URL(string: imgURL), placeholderImage: nil, options: SDWebImageOptions.refreshCached)
                
                if textSizeSelected == 0{
                    cell.lblSource.font = FontConstants.smallFontContent
                    cell.lblNewsHeading.font = FontConstants.smallFontHeadingBold
                }
                else if textSizeSelected == 2{
                    cell.lblSource.font = FontConstants.LargeFontContent
                    cell.lblNewsHeading.font = FontConstants.LargeFontHeadingBold
                }
                else{
                    cell.lblSource.font =  FontConstants.NormalFontContent
                    cell.lblNewsHeading.font = FontConstants.NormalFontHeadingBold
                }
                
                if cell.imgNews.image == nil{
                    cell.imgNews.image = UIImage(named: AssetConstants.NoImage)
                }
                
                activityIndicator.stopAnimating()
                lblNonews.isHidden = true
                return cell
            }
            else{
                
                let cellOdd = tableView.dequeueReusableCell(withIdentifier: "HomeImgTVCellID", for:indexPath) as! HomeImgTVCell
                cellOdd.layer.cornerRadius = 10.0
                cellOdd.clipsToBounds = true
                
                
                cellOdd.imgNews.layer.cornerRadius = 10.0
                cellOdd.imgNews.clipsToBounds = true
                //display data from DB
                cellOdd.viewCellContainer.layer.cornerRadius = 10
                cellOdd.viewCellContainer.layer.shadowColor = UIColor.black.cgColor
                cellOdd.viewCellContainer.layer.shadowOffset = CGSize(width: 3, height: 3)
                cellOdd.viewCellContainer.layer.shadowOpacity = 0.7
                cellOdd.viewCellContainer.layer.shadowRadius = 4.0
                
                cellOdd.lblNewsHeading.text = currentArticle.title
                cellOdd.imgNews.layer.cornerRadius = 10.0
                cellOdd.imgNews.clipsToBounds = true
                cellOdd.viewCellContainer.layer.cornerRadius = 10.0
                
                if  darkModeStatus == true{
                    cellOdd.ViewCellBackground.backgroundColor = colorConstants.grayBackground2
                    cellOdd.lblSource.textColor = colorConstants.nightModeText
                    cellOdd.lblNewsHeading.textColor = colorConstants.nightModeText
                    NightNight.theme =  .night
                }
                else{
                    cellOdd.ViewCellBackground.backgroundColor = .white
                    cellOdd.lblSource.textColor = colorConstants.blackColor
                    cellOdd.lblNewsHeading.textColor = colorConstants.blackColor
                    NightNight.theme =  .normal
                }
                
                if ((currentArticle.published_on?.count)!) <= 20{
                    if !(currentArticle.published_on?.contains("Z"))!{
                        currentArticle.published_on?.append("Z")
                    }
                    let newDate = dateFormatter.date(from: currentArticle.published_on!)
                    if newDate != nil{
                        agoDate = Helper().timeAgoSinceDate(newDate!)
                        fullTxt = "\(agoDate)" + " via " + currentArticle.source!
                        let attributedWithTextColor: NSAttributedString = fullTxt.attributedStringWithColor([currentArticle.source!], color: UIColor.red)
                        cellOdd.lblSource.attributedText = attributedWithTextColor
                    }
                }
                else{
                    dateSubString = String(currentArticle.published_on!.prefix(19))
                    if !(dateSubString.contains("Z")){
                        dateSubString.append("Z")
                    }
                    let newDate = dateFormatter.date(from: dateSubString
                    )
                    if newDate != nil{
                        agoDate = Helper().timeAgoSinceDate(newDate!)
                        fullTxt = "\(agoDate)" + " via " + currentArticle.source!
                        let attributedWithTextColor: NSAttributedString = fullTxt.attributedStringWithColor([currentArticle.source!], color: UIColor.red)
                        cellOdd.lblSource.attributedText = attributedWithTextColor
                    }
                }
                let imgURL = APPURL.imageServer + imgWidth + "x" + imgHeight + "/smart/" + currentArticle.imageURL!
                cellOdd.imgNews.sd_setImage(with: URL(string: imgURL), placeholderImage: nil, options: SDWebImageOptions.refreshCached)
                if textSizeSelected == 0{
                    cellOdd.lblSource.font = FontConstants.smallFontContent
                    cellOdd.lblNewsHeading.font = FontConstants.smallFontHeadingBold
                }
                else if textSizeSelected == 2{
                    cellOdd.lblSource.font = FontConstants.LargeFontContent
                    cellOdd.lblNewsHeading.font = FontConstants.LargeFontHeadingBold
                }
                else{
                    cellOdd.lblSource.font =  FontConstants.NormalFontContent
                    cellOdd.lblNewsHeading.font = FontConstants.NormalFontHeadingBold
                }
                
                if cellOdd.imgNews.image == nil{
                    cellOdd.imgNews.image = UIImage(named: AssetConstants.NoImage)
                }
                
                activityIndicator.stopAnimating()
                lblNonews.isHidden = true
                return cellOdd
            }
        }
        else {
            currentArticle = ShowArticle[indexPath.row]
            let cellCluster = tableView.dequeueReusableCell(withIdentifier: "ClusterTVCellID", for:indexPath) as! ClusterTVCell
            let count = DBManager().showCount(articleId: Int(currentArticle.article_id))
            imgWidth = String(describing : Int(cellCluster.imgNews.frame.width))
            imgHeight = String(describing : Int(cellCluster.imgNews.frame.height))
            cellCluster.imgNews.layer.cornerRadius = 10.0
            cellCluster.imgNews.clipsToBounds = true
            
            //display data from DB
            cellHeight = 350
            cellCluster.viewCellContainer.layer.cornerRadius = 10
            cellCluster.viewCellContainer.layer.shadowColor = UIColor.black.cgColor
            cellCluster.viewCellContainer.layer.shadowOffset = CGSize(width: 3, height: 3)
            cellCluster.viewCellContainer.layer.shadowOpacity = 0.7
            cellCluster.viewCellContainer.layer.shadowRadius = 4.0
            cellCluster.lblNewsHeading.text = currentArticle.title
            
            if  darkModeStatus == true{
                cellCluster.ViewCellBackground.backgroundColor = colorConstants.grayBackground2
                cellCluster.lblSource.textColor = colorConstants.nightModeText
                cellCluster.lblNewsHeading.textColor = colorConstants.nightModeText
                NightNight.theme =  .night
            }
            else{
                cellCluster.ViewCellBackground.backgroundColor = .white
                cellCluster.lblSource.textColor = colorConstants.blackColor
                cellCluster.lblNewsHeading.textColor = colorConstants.blackColor
                NightNight.theme =  .normal
            }
            if (currentArticle.published_on?.count)! <= 20 {
                if !(currentArticle.published_on?.contains("Z"))!{
                    currentArticle.published_on?.append("Z")
                }
                let newDate = dateFormatter.date(from: currentArticle.published_on!)
                if newDate != nil{
                    agoDate = Helper().timeAgoSinceDate(newDate!)
                    fullTxt = "\(agoDate)" + " via " + currentArticle.source!
                    let attributedWithTextColor: NSAttributedString = fullTxt.attributedStringWithColor([currentArticle.source!], color: UIColor.red)
                    cellCluster.lblSource.attributedText = attributedWithTextColor
                }
            }
            else{
                dateSubString = String(currentArticle.published_on!.prefix(19))
                if !(dateSubString.contains("Z")){
                    dateSubString.append("Z")
                }
                let newDate = dateFormatter.date(from: dateSubString
                )
                if newDate != nil{
                    agoDate = Helper().timeAgoSinceDate(newDate!)
                    fullTxt = "\(agoDate)" + " via " + currentArticle.source!
                    let attributedWithTextColor: NSAttributedString = fullTxt.attributedStringWithColor([currentArticle.source!], color: UIColor.red)
                    cellCluster.lblSource.attributedText = attributedWithTextColor
                }
            }
            let imgURL = APPURL.imageServer + imgWidth + "x" + imgHeight + "/smart/" + currentArticle.imageURL!
            cellCluster.imgNews.sd_setImage(with: URL(string: imgURL), placeholderImage: nil, options: SDWebImageOptions.refreshCached)
            cellCluster.lblCount.text = String(count)
            if textSizeSelected == 0{
                cellCluster.lblSource.font = FontConstants.smallFontContent
                cellCluster.lblNewsHeading.font = FontConstants.smallFontHeadingBold
                cellCluster.lblCount.font = FontConstants.smallFontHeadingBold
            }
            else if textSizeSelected == 2{
                cellCluster.lblSource.font = FontConstants.LargeFontContent
                cellCluster.lblNewsHeading.font = FontConstants.LargeFontHeadingBold
                cellCluster.lblCount.font = FontConstants.LargeFontHeadingBold
            }
            else{
                cellCluster.lblSource.font =  FontConstants.NormalFontContent
                cellCluster.lblNewsHeading.font = FontConstants.NormalFontHeadingBold
                cellCluster.lblCount.font = FontConstants.NormalFontHeadingBold
            }
            
            if cellCluster.imgNews.image == nil{
                cellCluster.imgNews.image = UIImage(named: AssetConstants.NoImage)
            }
            
            activityIndicator.stopAnimating()
            lblNonews.isHidden = true
            return cellCluster
        }
    }
    
    //    func scrollViewDidScroll(_ scrollView: UIScrollView) {
    //        // protocolObj?.isNavigate(status: true)
    //        //HomeCVLeading.constant = scrollView.contentOffset.x
    //    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            var submenu = UserDefaults.standard.value(forKey: "submenu") as! String
            if ShowArticle.count >= 20{
                if isAPICalled == false{
                    let result =  DBManager().FetchNextURL(category: submenu)
                    switch result {
                    case .Success(let DBData) :
                        let nextURL = DBData
                        
                        if nextURL.count != 0{
                            isAPICalled = false
                            if nextURL[0].category == submenu {
                                let nexturl = nextURL[0].nextURL
                                UserDefaults.standard.set(nexturl, forKey: "submenuURL")
                                self.saveArticlesInDB()
                            }
                        }
                        else{
                            isAPICalled = true
                            activityIndicator.stopAnimating()
                        }
                    case .Failure(let errorMsg) :
                        print(errorMsg)
                    }
                }
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height:CGFloat = CGFloat()
        if  isTrendingDetail == 0 || isTrendingDetail == 2{
            height = 157 //137
        }
        else{
            height = 285 //255
        }
        return height
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
            CVSize = label.frame.width + 100.0
            return CGSize(width:CVSize , height: 60)
        }
        else if collectionView ==  submenuCV{
            let label = UILabel(frame: CGRect.zero)
            label.text = subMenuArr[HeadingRow][indexPath.item]
            label.sizeToFit()
            CVSize = label.frame.width + 80.0
            return CGSize(width:CVSize , height: 40)
        }
        else{
            let screen = UIScreen.main.bounds
            let totalHeight = viewAppTitle.frame.size.height + menuCV.frame.size.height + submenuCV.frame.size.height
            return CGSize(width: screen.size.width, height: screen.size.height - totalHeight)
            
        }
    }
}
