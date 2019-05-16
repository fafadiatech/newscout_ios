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

class ParentViewController: UIViewController {
    
    @IBOutlet var viewAppTitle: UIView!
    @IBOutlet var lblAppTitle: UILabel!
    @IBOutlet var btnBack: UIButton!
    @IBOutlet var btnOptionMenu: UIButton!
    @IBOutlet var btnSearch: UIButton!
    @IBOutlet var HomeNewsTV: UITableView!
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
    var trendingProtocol : TrendingBack?
    var tabBarTitle: String = ""
    var ShowArticle = [NewsArticle]()
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
    var isSwipeLeft = false
    var currentIndexPath: IndexPath?
    var menuIndexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnBack.isHidden = true
        lblNonews.isHidden = true
        lblAppTitle.text = Constants.AppName
        lblAppTitle.font = FontConstants.appFont
        viewAppTitle.backgroundColor = colorConstants.redColor
        lblAppTitle.textColor = colorConstants.whiteColor
        activityIndicator.cycleColors = [.blue]
        activityIndicator.frame = CGRect(x: view.frame.width/2, y: view.frame.height/2 - 100, width: 40, height: 40)
        activityIndicator.sizeToFit()
        activityIndicator.indicatorMode = .indeterminate
        activityIndicator.progress = 2.0
        view.addSubview(activityIndicator)
        self.activityIndicator.startAnimating()
        if UserDefaults.standard.value(forKey: "textSize") == nil{
            UserDefaults.standard.set(1, forKey: "textSize")
        }
        saveFetchMenu()
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
    override var prefersStatusBarHidden: Bool {
        return true
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
            swipeActn()
        }
    }
    
    @objc func handleSwipeRight(_ gestureRecognizer: UISwipeGestureRecognizer?) {
        let location: CGPoint? = gestureRecognizer?.location(in: HomeNewsTV)
        let indexPath: IndexPath? = HomeNewsTV.indexPathForRow(at: location ?? CGPoint.zero)
        if indexPath != nil {
             isSwipeLeft = false
            swipeActn()
        }
    }
  
  
    func swipeActn(){
        lblNonews.isHidden = true
        activityIndicator.startAnimating()
        guard let indexPath = self.currentIndexPath else {
            return
        }
        var newIndex = indexPath
        if isSwipeLeft == true{
            if subMenuRow < subMenuArr[HeadingRow].count - 1{
        subMenuRow = subMenuRow + 1
                 newIndex = IndexPath(row: newIndex.row+1, section: newIndex.section)
            }
        }else{
            if subMenuRow > 0 {
            subMenuRow = subMenuRow - 1
                newIndex = IndexPath(row: newIndex.row-1, section: self.currentIndexPath!.section)
            }
        }
        
        if canPresentPageAt(indexPath: newIndex) {
            self.submenuCV.selectItem(at: newIndex, animated: true, scrollPosition: UICollectionViewScrollPosition.centeredHorizontally)
            self.collectionView(self.submenuCV, didSelectItemAt: newIndex)
        } else {
            print("You are tying to navigate to an invalid page")
        }
        
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
          //  if self.isTrendingDetail == 0{
                self.saveArticlesInDB()
//            }
//            else if self.isTrendingDetail == 1{
//                self.saveTrending()
//            }
        }
        DispatchQueue.main.async {
            refreshControl.endRefreshing()
            self.activityIndicator.stopAnimating()
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
        submenuCV.reloadData()
        currentIndexPath = NSIndexPath(row: 0, section: 0) as IndexPath
        submenuCV.selectItem(at: currentIndexPath, animated: true, scrollPosition: [])
        loadFirstNews()
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
        let result = DBManager().ArticlesfetchByCatId()
        switch result {
        case .Success(let DBData) :
            ShowArticle = DBData
            if ShowArticle.count > 0{
                lblNonews.isHidden = true
                self.HomeNewsTV.reloadData()
            }
            else{
                self.HomeNewsTV.reloadData()
                lblNonews.isHidden =  false
                activityIndicator.stopAnimating()
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
        DBManager().SaveDataDB(nextUrl: subMenuURL ){response in
            if response == true{
                self.fetchArticlesFromDB()
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
    
    @IBAction func btnOptionMenuActn(_ sender: Any) {
    }
    @IBAction func btnSearchMenuActn(_ sender: Any) {
    }
    @IBAction func btnBackActn(_ sender: Any) {
        self.dismiss(animated: false)
    }
}

extension ParentViewController : UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == menuCV{
            return headingArr.count
        }else{
            return (subMenuArr.count > 0) ? subMenuArr[HeadingRow].count : 0
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == menuCV {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "menuID", for:indexPath) as! menuCVCell
            cell.lblMenu.text = headingArr[indexPath.item]
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "submenuID", for:indexPath) as! NewsubmenuCVCell
           
            cell.lblSubmenu.text = subMenuArr[HeadingRow][indexPath.row]
            submenuName = subMenuArr[HeadingRow][indexPath.row]
            return cell
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == menuCV{
            HeadingRow = indexPath.row
           // currentIndexPath = NSIndexPath(row: 0, section: 0) as IndexPath
            //set first row selected by default
            submenuCV.reloadData()
            subMenuRow = 0
            submenuName = subMenuArr[HeadingRow][subMenuRow]
            submenuCV.selectItem(at: currentIndexPath, animated: true, scrollPosition: [])
            reloadSubmenuNews()
        }else{
             self.currentIndexPath = indexPath
            subMenuRow = indexPath.row
            submenuName = subMenuArr[HeadingRow][subMenuRow]
           reloadSubmenuNews()
          
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
            activityIndicator.stopAnimating()
            lblNonews.isHidden = true
        }
    }
}

extension ParentViewController: UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (ShowArticle.count > 0) ? self.ShowArticle.count : 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newsDetailvc:NewsDetailVC = storyboard.instantiateViewController(withIdentifier: "NewsDetailID") as! NewsDetailVC
            UserDefaults.standard.set("home", forKey: "isSearch")
            if sortedData.count > 0 {
                newsDetailvc.newsCurrentIndex = indexPath.row
                newsDetailvc.ShowArticle = sortedData as! [NewsArticle]
                newsDetailvc.articleId = Int(sortedData[indexPath.row].article_id)
                present(newsDetailvc, animated: true, completion: nil)
       
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
        
            sortedData = ShowArticle.sorted{ $0.published_on! > $1.published_on! }
            currentArticle = sortedData[indexPath.row]
            if indexPath.row % 2 != 0{
                let cell = tableView.dequeueReusableCell(withIdentifier: "HomeNewsTVCellID", for:indexPath) as! HomeNewsTVCell
                imgWidth = String(describing : Int(cell.imgNews.frame.width))
                imgHeight = String(describing : Int(cell.imgNews.frame.height))
                cell.imgNews.layer.cornerRadius = 10.0
                cell.imgNews.clipsToBounds = true
                
                //display data from DB
                cell.lblNewsHeading.text = currentArticle.title
                
                if ((currentArticle.published_on?.count)!) <= 20{
                    if !(currentArticle.published_on?.contains("Z"))!{
                        currentArticle.published_on?.append("Z")
                    }
                    let newDate = dateFormatter.date(from: currentArticle.published_on!)
                    if newDate != nil{
                        agoDate = try Helper().timeAgoSinceDate(newDate!)
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
                        agoDate = try Helper().timeAgoSinceDate(newDate!)
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
                cellOdd.imgNews.layer.cornerRadius = 10.0
                cellOdd.imgNews.clipsToBounds = true
                //display data from DB
                
                cellOdd.lblNewsHeading.text = currentArticle.title
                
                
                if ((currentArticle.published_on?.count)!) <= 20{
                    if !(currentArticle.published_on?.contains("Z"))!{
                        currentArticle.published_on?.append("Z")
                    }
                    let newDate = dateFormatter.date(from: currentArticle.published_on!)
                    if newDate != nil{
                        agoDate = try Helper().timeAgoSinceDate(newDate!)
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
                        agoDate = try Helper().timeAgoSinceDate(newDate!)
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
       // protocolObj?.isNavigate(status: true)
    }
    
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
            height = 137
        return height
    }
}

