//
//  HomeiPadVC.swift
//  NewsApp
//
//  Created by Jayashree on 04/04/19.
//  Copyright © 2019 Fafadia Tech. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import Alamofire
import CoreData
import MaterialComponents.MaterialActivityIndicator
import SDWebImage
import NightNight

class HomeiPadVC: UIViewController {
    @IBOutlet weak var HomeNewsCV: UICollectionView!
    @IBOutlet weak var lblNonews: UILabel!
    @IBOutlet weak var btnTopNews: UIButton!
    var protocolObj : ScrollDelegate?
    var tabBarTitle: String = ""
    var ShowArticle = [NewsArticle]()
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    let activityIndicator = MDCActivityIndicator()
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
    var clusterArticles = [NewsArticle]()
    var trendingProtocol : TrendingBack?
    
    override func viewDidLoad(){
        super.viewDidLoad()
        trendingProtocol?.isTrendingTVLoaded(status: false)
        protocolObj?.isNavigate(status: true)
        lblNonews.isHidden = true
        btnTopNews.layer.cornerRadius = 0.5 * btnTopNews.bounds.size.width
        btnTopNews.clipsToBounds = true
        btnTopNews.backgroundColor = colorConstants.redColor
        NotificationCenter.default.addObserver(self, selector: #selector(darkModeEnabled(_:)), name: .darkModeEnabled, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(darkModeDisabled(_:)), name: .darkModeDisabled, object: nil)
        activityIndicator.cycleColors = [.blue]
        activityIndicator.frame = CGRect(x: view.frame.width/2, y: view.frame.height/2 - 100, width: 40, height: 40)
        activityIndicator.sizeToFit()
        activityIndicator.indicatorMode = .indeterminate
        activityIndicator.progress = 2.0
        view.addSubview(activityIndicator)
        self.activityIndicator.startAnimating()
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        print("path is :\(paths[0])")
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshNews), for: .valueChanged)
        HomeNewsCV.refreshControl = refreshControl
        refreshControl.attributedTitle = NSAttributedString(string: "Pull  to Refresh...")
        
        //change data on swipe
        if tabBarTitle != "Test" && tabBarTitle != "today"{
            isTrendingDetail = 0
            fetchSubmenuId(submenu: tabBarTitle)
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
        
        if tabBarTitle == "today"{
            isTrendingDetail = 1
            let records = DBManager().IsCoreDataEmpty(entity: "TrendingCategory")
            if records <= 0{
                DBManager().saveTrending{response in
                    self.fetchTrending()
                }
            }else{
                self.fetchTrending()
            }
        }
        //save and fetch like and bookmark data from DB
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
    
    @IBAction func btnTopNewsActn(_ sender: Any) {
        scrollToFirstRow()
    }
    
    func fetchTrending(){
        let result = DBManager().fetchTrendingArticle()
        switch result {
        case .Success(let DBData) :
            self.ShowArticle.removeAll()
            self.ShowArticle = DBData
            if self.ShowArticle.count > 0{
                self.lblNonews.isHidden = true
                self.HomeNewsCV.reloadData()
            }
            else{
                self.HomeNewsCV.reloadData()
                self.lblNonews.isHidden =  false
                self.activityIndicator.stopAnimating()
            }
        case .Failure(let errorMsg) :
            print(errorMsg)
        }
    }
    
    func fetchSubmenuId(submenu : String){
        let tagresult = DBManager().fetchsubmenuId(subMenuName: submenu)
        switch tagresult{
        case .Success(let id) :
            var url = APPURL.ArticleByIdURL + "\(id)"
            UserDefaults.standard.setValue(id, forKey: "subMenuId")
            UserDefaults.standard.setValue(url, forKey: "submenuURL")
        case .Failure(let error):
            print(error)
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
                self.HomeNewsCV.reloadData()
                scrollToFirstRow()
            }
            else{
                self.HomeNewsCV.reloadData()
                self.lblNonews.isHidden =  false
                self.activityIndicator.stopAnimating()
            }
        case .Failure(let errorMsg) :
            print(errorMsg)
        }
    }
    
    func scrollToFirstRow() {
        let indexPath = NSIndexPath(row: 0, section: 0)
        self.HomeNewsCV?.scrollToItem(at: NSIndexPath(item: 0, section: 0) as IndexPath,
                                      at: .top,
                                      animated: true)
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
    
    func fetchArticlesFromDB(){
        let result = DBManager().ArticlesfetchByCatId()
        switch result {
        case .Success(let DBData) :
            ShowArticle = DBData
            if ShowArticle.count > 0{
                lblNonews.isHidden = true
                self.HomeNewsCV.reloadData()
            }
            else{
                self.HomeNewsCV.reloadData()
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
        case .Failure(let errorMsg) : break
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
    
    @objc private func darkModeEnabled(_ notification: Notification) {
        NightNight.theme = .night
        HomeNewsCV.backgroundColor = colorConstants.backgroundGray
    }
    
    @objc private func darkModeDisabled(_ notification: Notification){
        NightNight.theme = .normal
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .darkModeEnabled, object: nil)
        NotificationCenter.default.removeObserver(self, name: .darkModeDisabled, object: nil)
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
    
    func saveTrending(){
        DBManager().saveTrending{response in
            if response == true{
                self.fetchTrending()
            }
        }
    }
    func retainClusterData(){
        if isTrendingDetail ==  2{
            ShowArticle = clusterArticles
            HomeNewsCV.reloadData()
        }
    }
    func filterNews(selectedTag : String){
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "NewsArticle")
        let managedContext =
            self.appDelegate?.persistentContainer.viewContext
        do {
            self.ShowArticle = (try managedContext?.fetch(fetchRequest))! as! [NewsArticle]
        }
        catch {
            print("error executing fetch request: \(error)")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isTrendingDetail == 0 {
            if Reachability.isConnectedToNetwork(){
                activityIndicator.startAnimating()
                if UserDefaults.standard.value(forKey: "submenuURL") != nil{
                    self.saveArticlesInDB()
                    fetchArticlesFromDB()
                }
            }else{
                coredataRecordCount = DBManager().IsCoreDataEmpty(entity: "NewsArticle")
                if self.coredataRecordCount != 0 {
                    self.fetchArticlesFromDB()
                }
                else{
                    activityIndicator.stopAnimating()
                }
            }
        }
        if isTrendingDetail == 1 {
            var records = DBManager().IsCoreDataEmpty(entity: "TrendingCategory")
            if records <= 0{
                DBManager().saveTrending{response in
                    self.fetchTrending()
                }
            }else{
                self.fetchTrending()
            }
        }
        else if isTrendingDetail == 2{
            retainClusterData()
        }
    }
    
    func FetchArticlesAPICall(){
        saveArticlesInDB()
    }
    
    func showMsg(title: String, msg : String){
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        if UI_USER_INTERFACE_IDIOM() == .pad
        {
            alertController.popoverPresentationController?.sourceView = self.view
            alertController.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        }
        let action1 = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc:LoginVC = storyboard.instantiateViewController(withIdentifier: "LoginID") as! LoginVC
            self.present(vc, animated: true, completion: nil)
        }
        
        alertController.addAction(action1)
        
        let action2 = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default) { (action:UIAlertAction) in
        }
        alertController.addAction(action2)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension HomeiPadVC: UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (ShowArticle.count > 0) ? self.ShowArticle.count : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
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
                newsDetailvc.ShowArticle = sortedData as! [NewsArticle]
                newsDetailvc.articleId = Int(sortedData[indexPath.row].article_id)
                present(newsDetailvc, animated: true, completion: nil)
            }
        }
        else{
            isTrendingDetail = 2
            trendingProtocol?.isTrendingTVLoaded(status: true)
            var id = UserDefaults.standard.array(forKey: "trendingArray") as! [Int]
            let selectedCluster = id[indexPath.row]
            fetchClusterIdArticles(clusterID: selectedCluster)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var currentArticle = NewsArticle()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.timeZone = NSTimeZone.local
        let darkModeStatus = UserDefaults.standard.value(forKey: "darkModeEnabled") as! Bool
        
        let textSizeSelected = UserDefaults.standard.value(forKey: "textSize") as! Int
        var sourceColor = UIColor()
        var fullTxt = ""
        var dateSubString = ""
        var agoDate = ""
        if  isTrendingDetail == 0 || isTrendingDetail == 2{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeIpadID", for:indexPath) as! HomeipadCVCell
            sortedData = ShowArticle.sorted{ $0.published_on! > $1.published_on! }
            currentArticle = sortedData[indexPath.row]
            //display data from DB
            cell.lblTitle.text = currentArticle.title
            
            if  darkModeStatus == true{
                cell.containerView.backgroundColor = colorConstants.grayBackground2
                cell.lblSource.textColor = colorConstants.nightModeText
                cell.lblTitle.textColor = colorConstants.nightModeText
                NightNight.theme =  .night
            }
            else{
                cell.lblSource.textColor = colorConstants.blackColor
                cell.lblTitle.textColor = colorConstants.blackColor
                NightNight.theme =  .normal
            }
            
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
                cell.lblTitle.font = FontConstants.smallFontHeadingBold
            }
            else if textSizeSelected == 2{
                cell.lblSource.font = FontConstants.LargeFontContent
                cell.lblTitle.font = FontConstants.LargeFontHeadingBold
            }
            else{
                cell.lblSource.font =  FontConstants.NormalFontContent
                cell.lblTitle.font = FontConstants.NormalFontHeadingBold
            }
            
            if cell.imgNews.image == nil{
                cell.imgNews.image = UIImage(named: AssetConstants.NoImage)
            }
            
            activityIndicator.stopAnimating()
            lblNonews.isHidden = true
            return cell
        }
        else{
            let cellCluster = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeIpadClusterID", for:indexPath) as! HomeiPadClusterCVCell
            currentArticle = ShowArticle[indexPath.row]
            //display data from DB
            cellCluster.lblTitle.text = currentArticle.title
            if  darkModeStatus == true{
                cellCluster.containerView.backgroundColor = colorConstants.grayBackground2
                cellCluster.lblSource.textColor = colorConstants.nightModeText
                cellCluster.lblTitle.textColor = colorConstants.nightModeText
                NightNight.theme =  .night
            }
            else{
                cellCluster.lblSource.textColor = colorConstants.blackColor
                cellCluster.lblTitle.textColor = colorConstants.blackColor
                NightNight.theme =  .normal
            }
            
            if ((currentArticle.published_on?.count)!) <= 20{
                if !(currentArticle.published_on?.contains("Z"))!{
                    currentArticle.published_on?.append("Z")
                }
                let newDate = dateFormatter.date(from: currentArticle.published_on!)
                if newDate != nil{
                    agoDate = try Helper().timeAgoSinceDate(newDate!)
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
                    agoDate = try Helper().timeAgoSinceDate(newDate!)
                    fullTxt = "\(agoDate)" + " via " + currentArticle.source!
                    let attributedWithTextColor: NSAttributedString = fullTxt.attributedStringWithColor([currentArticle.source!], color: UIColor.red)
                    cellCluster.lblSource.attributedText = attributedWithTextColor
                }
            }
            let imgURL = APPURL.imageServer + imgWidth + "x" + imgHeight + "/smart/" + currentArticle.imageURL!
            cellCluster.imgNews.sd_setImage(with: URL(string: imgURL), placeholderImage: nil, options: SDWebImageOptions.refreshCached)
            
            if textSizeSelected == 0{
                cellCluster.lblSource.font = FontConstants.smallFontContent
                cellCluster.lblTitle.font = FontConstants.smallFontHeadingBold
            }
            else if textSizeSelected == 2{
                cellCluster.lblSource.font = FontConstants.LargeFontContent
                cellCluster.lblTitle.font = FontConstants.LargeFontHeadingBold
            }
            else{
                cellCluster.lblSource.font =  FontConstants.NormalFontContent
                cellCluster.lblTitle.font = FontConstants.NormalFontHeadingBold
            }
            
            if cellCluster.imgNews.image == nil{
                cellCluster.imgNews.image = UIImage(named: AssetConstants.NoImage)
            }
            
            activityIndicator.stopAnimating()
            lblNonews.isHidden = true
            return cellCluster
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if (scrollView.bounds.maxY) == scrollView.contentSize.height{
            activityIndicator.startAnimating()
            if isTrendingDetail == 0 &&  tabBarTitle != "Test"{
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
    }
}

extension HomeiPadVC: IndicatorInfoProvider{
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: tabBarTitle, image: UIImage(named: AssetConstants.submenuBackground))
    }
}
extension HomeiPadVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionCellSize = HomeNewsCV.frame.size.width
        if isTrendingDetail == 0 || isTrendingDetail == 2{
            return CGSize(width: collectionCellSize/3.3, height: collectionCellSize/3)
        }else{
            return CGSize(width: collectionCellSize/2.15, height: collectionCellSize/2)
        }
    }
}
