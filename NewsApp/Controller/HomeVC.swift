//
//  ViewController.swift
//  NewsApp
//
//  Created by Jayashri on 22/09/18.
//  Copyright © 2018 Fafadia Tech. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import Alamofire
import CoreData
import MaterialComponents.MaterialActivityIndicator
import SDWebImage
import NightNight

protocol ScrollDelegate{
    func isNavigate(status: Bool)
}
extension String {
    func attributedStringWithColor(_ strings: [String], color: UIColor, characterSpacing: UInt? = nil) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: self)
        for string in strings {
            let range = (self as NSString).range(of: string)
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
        }
        
        guard let characterSpacing = characterSpacing else {return attributedString}
        
        attributedString.addAttribute(NSAttributedString.Key.kern, value: characterSpacing, range: NSRange(location: 0, length: attributedString.length))
        
        return attributedString
    }
}
class HomeVC: UIViewController{
    
    @IBOutlet weak var HomeNewsTV: UITableView!
    @IBOutlet weak var lblNonews: UILabel!
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
    
    override func viewDidLoad(){
        super.viewDidLoad()
        HomeNewsTV.tableFooterView = UIView(frame: .zero)
        protocolObj?.isNavigate(status: true)
        lblNonews.isHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(darkModeEnabled(_:)), name: .darkModeEnabled, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(darkModeDisabled(_:)), name: .darkModeDisabled, object: nil)
        activityIndicator.cycleColors = [.blue]
        activityIndicator.frame = CGRect(x: view.frame.width/2, y: view.frame.height/2 - 100, width: 40, height: 40)
        activityIndicator.sizeToFit()
        activityIndicator.indicatorMode = .indeterminate
        activityIndicator.progress = 2.0
        view.addSubview(activityIndicator)
        self.activityIndicator.startAnimating()
        var paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        print("path is :\(paths[0])")
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshNews), for: .valueChanged)
        HomeNewsTV.refreshControl = refreshControl
        refreshControl.attributedTitle = NSAttributedString(string: "Pull  to Refresh...")
        if (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad){
            HomeNewsTV.rowHeight = 190;
        }
        else {
            HomeNewsTV.rowHeight = 129;
        }
        
        //change data on swipe
        fetchsubMenuTags(submenu: tabBarTitle)
        var url = APPURL.ArticlesByTagsURL
        for tag in tagArr {
            url = url + "&tag=" + tag
        }
        if tagArr.count > 0{
            UserDefaults.standard.set(url, forKey: "submenuURL")
        }else{
            UserDefaults.standard.set("", forKey: "submenuURL")
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
        coredataRecordCount = DBManager().IsCoreDataEmpty(entity: "NewsArticle")
        if self.coredataRecordCount != 0 {
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
        let result = DBManager().ArticlesfetchByTags()
        switch result {
        case .Success(let DBData) :
            ShowArticle = DBData
            if ShowArticle.count != 0{
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
            self.fetchArticlesFromDB()
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
        HomeNewsTV.backgroundColor = colorConstants.backgroundGray
    }
    
    @objc private func darkModeDisabled(_ notification: Notification){
        NightNight.theme = .normal
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .darkModeEnabled, object: nil)
        NotificationCenter.default.removeObserver(self, name: .darkModeDisabled, object: nil)
    }
    
    @objc func refreshNews(refreshControl: UIRefreshControl) {
        saveArticlesInDB()
        refreshControl.endRefreshing()
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

extension HomeVC: UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (ShowArticle.count > 0) ? self.ShowArticle.count : 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newsDetailvc:NewsDetailVC = storyboard.instantiateViewController(withIdentifier: "NewsDetailID") as! NewsDetailVC
        newsDetailvc.newsCurrentIndex = indexPath.row
        newsDetailvc.ShowArticle = sortedData as! [NewsArticle]
        newsDetailvc.articleId = Int(sortedData[indexPath.row].article_id)
        UserDefaults.standard.set("home", forKey: "isSearch")
        present(newsDetailvc, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeNewsTVCellID", for:indexPath) as! HomeNewsTVCell
        let cellOdd = tableView.dequeueReusableCell(withIdentifier: "HomeImgTVCellID", for:indexPath) as! HomeImgTVCell
        imgWidth = String(describing : Int(cell.imgNews.frame.width))
        imgHeight = String(describing : Int(cell.imgNews.frame.height))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.timeZone = NSTimeZone.local
        let darkModeStatus = UserDefaults.standard.value(forKey: "darkModeEnabled") as! Bool
        sortedData = ShowArticle.sorted{ $0.published_on! > $1.published_on! }
        let textSizeSelected = UserDefaults.standard.value(forKey: "textSize") as! Int
        var sourceColor = UIColor()
        var fullTxt = ""
        var dateSubString = ""
        var agoDate = ""
        if indexPath.row % 2 != 0{
            
            cell.imgNews.layer.cornerRadius = 10.0
            cell.imgNews.clipsToBounds = true
            
            //display data from DB
            let currentArticle = sortedData[indexPath.row]
            cell.lblNewsHeading.text = currentArticle.title
            
            if  darkModeStatus == true{
                cell.ViewCellBackground.backgroundColor = colorConstants.grayBackground2
                cell.lblSource.textColor = colorConstants.nightModeText
                cell.lblNewsHeading.textColor = colorConstants.nightModeText
                NightNight.theme =  .night
            }
            else{
                cell.ViewCellBackground.backgroundColor = .white
                cell.lblSource.textColor = colorConstants.blackColor
                cell.lblNewsHeading.textColor = colorConstants.blackColor
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
            
            cellOdd.imgNews.layer.cornerRadius = 10.0
            cellOdd.imgNews.clipsToBounds = true
            //display data from DB
            let currentArticle = sortedData[indexPath.row]
            cellOdd.lblNewsHeading.text = currentArticle.title
            
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
          protocolObj?.isNavigate(status: true)
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
    
}

extension HomeVC: IndicatorInfoProvider{
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: tabBarTitle)
    }
}
