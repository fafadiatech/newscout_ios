//
//  BookmarkVC.swift
//  NewsApp
//
//  Created by Jayashree on 08/01/19.
//  Copyright © 2019 Fafadia Tech. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialActivityIndicator
import NightNight
import SDWebImage

class BookmarkVC: UIViewController {
    @IBOutlet weak var bookmarkCV: UICollectionView!
    @IBOutlet weak var lblBookmark: UILabel!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var bookmarkResultTV: UITableView!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var lblNoBookmark: UILabel!
    @IBOutlet weak var btnTopNews: UIButton!
    let activityIndicator = MDCActivityIndicator()
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    let textSizeSelected = UserDefaults.standard.value(forKey: "textSize") as! Int
    var bookmarkedArticlesArr = [Article]()
    var nextURL = ""
    var ShowArticle = [NewsArticle]()
    var bookmarkArticles = [BookmarkArticles]()
    var imgWidth = ""
    var imgHeight = ""
    var statusBarOrientation: UIInterfaceOrientation = UIApplication.shared.statusBarOrientation
    var sortedData = [NewsArticle]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblNoBookmark.isHidden = true
        btnTopNews.layer.cornerRadius = 0.5 * btnTopNews.bounds.size.width
        bookmarkResultTV.tableFooterView = UIView(frame: .zero)
        NotificationCenter.default.addObserver(self, selector: #selector(darkModeEnabled(_:)), name: .darkModeEnabled, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(darkModeDisabled(_:)), name: .darkModeDisabled, object: nil)
        activityIndicator.cycleColors = [.blue]
        activityIndicator.frame = CGRect(x: view.frame.width/2, y: view.frame.height/2 - 100, width: 40, height: 40)
        activityIndicator.sizeToFit()
        activityIndicator.indicatorMode = .indeterminate
        activityIndicator.progress = 2.0
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad && statusBarOrientation.isPortrait{
            bookmarkResultTV.isHidden = true
            bookmarkCV.isHidden = false
        }
        else{
            bookmarkResultTV.isHidden = false
            bookmarkCV.isHidden = true
        }
        if UserDefaults.standard.value(forKey: "token") != nil {
            fetchBookmarkDataFromDB()
        }
        else{
            activityIndicator.stopAnimating()
            lblNoBookmark.text = "Login to see bookmark list"
            lblNoBookmark.isHidden = false
        }
        
        let darkModeStatus = UserDefaults.standard.value(forKey: "darkModeEnabled") as! Bool
        if darkModeStatus == true{
            bookmarkResultTV.backgroundColor = colorConstants.grayBackground3
            bookmarkCV.backgroundColor = colorConstants.grayBackground3
            lblNoBookmark.textColor = .white
        }else{
            bookmarkResultTV.backgroundColor = .white
            bookmarkCV.backgroundColor = .white
        }
        let refreshControl = UIRefreshControl()
        if UserDefaults.standard.value(forKey: "token") != nil{
            refreshControl.addTarget(self, action: #selector(refreshBookmarkedNews), for: .valueChanged)
            bookmarkResultTV.refreshControl = refreshControl
            refreshControl.attributedTitle = NSAttributedString(string: "Pull  to Refresh...")
        }
        if (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad){
            bookmarkResultTV.rowHeight = 190;
        }
        else {
            bookmarkResultTV.rowHeight = 129;
        }
        
        lblBookmark.textColor = colorConstants.whiteColor
        lblBookmark.font = FontConstants.viewTitleFont
        titleView.backgroundColor = colorConstants.redColor
    }
    
    @objc private func darkModeEnabled(_ notification: Notification) {
        NightNight.theme = .night
        bookmarkResultTV.backgroundColor = colorConstants.grayBackground3
        bookmarkCV.backgroundColor = colorConstants.grayBackground3
    }
    
    @objc private func darkModeDisabled(_ notification: Notification){
        NightNight.theme = .normal
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .darkModeEnabled, object: nil)
        NotificationCenter.default.removeObserver(self, name: .darkModeDisabled, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        changeFont()
        if bookmarkResultTV.isHidden == false{
            bookmarkResultTV.reloadData()
        }else{
            bookmarkCV.reloadData()
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func fetchBookmarkDataFromDB(){
        let result = DBManager().FetchLikeBookmarkFromDB()
        switch result {
        case .Success(let DBData) :
            ShowArticle = DBData
            if ShowArticle.count == 0{
                activityIndicator.stopAnimating()
                lblNoBookmark.text = "No bookmarks"
                lblNoBookmark.isHidden = false
            }
            if bookmarkResultTV.isHidden == false{
                bookmarkResultTV.reloadData()
            }else{
                bookmarkCV.reloadData()
            }
        case .Failure(let errorMsg) :
            print(errorMsg)
        }
    }
    
    func saveBookmarkDataInDB(url: String){
        DBManager().SaveBookmarkArticles(){response in
            if response == true{
                self.fetchBookmarkDataFromDB()
            }
        }
    }
    
    @IBAction func btnTopNewsActn(_ sender: Any) {
        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad{
            self.bookmarkCV?.scrollToItem(at: NSIndexPath(item: 0, section: 0) as IndexPath,
                                          at: .top,
                                          animated: true)
        }else{
            let indexPath = NSIndexPath(row: 0, section: 0)
            self.bookmarkResultTV.scrollToRow(at: indexPath as IndexPath, at: .top, animated: true)
        }
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
    
    func changeFont(){
        if textSizeSelected == 0{
            lblBookmark.font = FontConstants.NormalFontTitleMedium
        }
        else if textSizeSelected == 2{
            lblBookmark.font = FontConstants.LargeFontTitleMedium
        }
        else{
            lblBookmark.font = FontConstants.LargeFontTitleMedium
        }
    }
    
    func BookmarkAPICall(){
        APICall().BookmarkedArticlesAPI(url: APPURL.bookmarkedArticlesURL){ response in
            switch response {
            case .Success(let data) :
                if data.count > 0{
                    self.bookmarkedArticlesArr = data[0].body!.articles
                    if data[0].body!.next != nil{
                        self.nextURL = data[0].body!.next!
                    }
                    if data[0].body!.articles.count == 0{
                        self.activityIndicator.stopAnimating()
                        self.lblNoBookmark.text = "No bookmarks"
                        self.lblNoBookmark.isHidden = false
                    }else{
                        if self.bookmarkResultTV.isHidden == false{
                            self.bookmarkResultTV.reloadData()
                        }else{
                            self.bookmarkCV.reloadData()
                        }
                    }
                }
            case .Failure(let errormessage) :
                self.activityIndicator.startAnimating()
                print(errormessage)
            case .Change(let code) :
                print(code)
            }
        }
    }
    
    @objc func refreshBookmarkedNews(refreshControl: UIRefreshControl) {
        BookmarkAPICall()
        refreshControl.endRefreshing()
    }
    
    @IBAction func btnBackActn(_ sender: Any) {
        UserDefaults.standard.set("", forKey: "isSearch")
        self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
    }
    
}

extension BookmarkVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (ShowArticle.count != 0) ? ShowArticle.count : 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newsDetailvc:NewsDetailVC = storyboard.instantiateViewController(withIdentifier: "NewsDetailID") as! NewsDetailVC
        newsDetailvc.newsCurrentIndex = indexPath.row
        newsDetailvc.ShowArticle = sortedData
        UserDefaults.standard.set("bookmark", forKey: "isSearch")
        newsDetailvc.articleId = Int(sortedData[indexPath.row].article_id)
        present(newsDetailvc, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var currentArticle = NewsArticle()
        let cell = tableView.dequeueReusableCell(withIdentifier: "bookmarkResultID", for:indexPath) as! BookmarkTVCell
        let cellOdd = tableView.dequeueReusableCell(withIdentifier: "bookmarkZigzagID", for:indexPath) as! BookmarkZigzagTVCell
        imgWidth = String(describing : Int(cell.imgNews.frame.width))
        imgHeight = String(describing : Int(cell.imgNews.frame.height))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.timeZone = NSTimeZone.local
        sortedData.removeAll()
        let darkModeStatus = UserDefaults.standard.value(forKey: "darkModeEnabled") as! Bool
        let textSizeSelected = UserDefaults.standard.value(forKey: "textSize") as! Int
        var fullTxt = ""
        var dateSubString = ""
        var agoDate = ""
        sortedData = ShowArticle.sorted{ $0.published_on! > $1.published_on! }
        currentArticle = sortedData[indexPath.row]
        if indexPath.row % 2 != 0{
            cell.viewCellContainer.layer.cornerRadius = 10
            cell.viewCellContainer.layer.shadowColor = UIColor.black.cgColor
            cell.viewCellContainer.layer.shadowOffset = CGSize(width: 3, height: 3)
            cell.viewCellContainer.layer.shadowOpacity = 0.7
            cell.viewCellContainer.layer.shadowRadius = 4.0
            cell.imgNews.layer.cornerRadius = 10.0
            cell.imgNews.clipsToBounds = true
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            //display data from DB
            cell.lblNewsDescription.text = currentArticle.title
            
            if  darkModeStatus == true{
                cell.ViewCellBackground.backgroundColor = colorConstants.grayBackground2
                cell.lblSource.textColor = colorConstants.nightModeText
                cell.lblNewsDescription.textColor = colorConstants.nightModeText
                NightNight.theme =  .night
            }
            else{
                cell.ViewCellBackground.backgroundColor = .white
                cell.lblSource.textColor = colorConstants.blackColor
                cell.lblNewsDescription.textColor = colorConstants.blackColor
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
                cell.lblNewsDescription.font = FontConstants.smallFontHeadingBold
            }
            else if textSizeSelected == 2{
                cell.lblSource.font = FontConstants.LargeFontContent
                cell.lblNewsDescription.font = FontConstants.LargeFontHeadingBold
            }
            else{
                cell.lblSource.font =  FontConstants.NormalFontContent
                cell.lblNewsDescription.font = FontConstants.NormalFontHeadingBold
            }
            
            if cell.imgNews.image == nil{
                cell.imgNews.image = UIImage(named: AssetConstants.NoImage)
            }
            activityIndicator.stopAnimating()
            return cell
        }
        else{
            cellOdd.viewCellContainer.layer.cornerRadius = 10
            cellOdd.viewCellContainer.layer.shadowColor = UIColor.black.cgColor
            cellOdd.viewCellContainer.layer.shadowOffset = CGSize(width: 3, height: 3)
            cellOdd.viewCellContainer.layer.shadowOpacity = 0.7
            cellOdd.viewCellContainer.layer.shadowRadius = 4.0
            cellOdd.imgNews.layer.cornerRadius = 10.0
            cellOdd.imgNews.clipsToBounds = true
            cellOdd.selectionStyle = UITableViewCellSelectionStyle.none
            //display data from DB
            cellOdd.lblNewsDescription.text = currentArticle.title
            
            if  darkModeStatus == true{
                cellOdd.ViewCellBackground.backgroundColor = colorConstants.grayBackground2
                cellOdd.lblSource.textColor = colorConstants.nightModeText
                cellOdd.lblNewsDescription.textColor = colorConstants.nightModeText
                NightNight.theme =  .night
            }
            else{
                cellOdd.ViewCellBackground.backgroundColor = .white
                cellOdd.lblSource.textColor = colorConstants.blackColor
                cellOdd.lblNewsDescription.textColor = colorConstants.blackColor
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
                cellOdd.lblNewsDescription.font = FontConstants.smallFontHeadingBold
            }
            else if textSizeSelected == 2{
                cellOdd.lblSource.font = FontConstants.LargeFontContent
                cellOdd.lblNewsDescription.font = FontConstants.LargeFontHeadingBold
            }
            else{
                cellOdd.lblSource.font =  FontConstants.NormalFontContent
                cellOdd.lblNewsDescription.font = FontConstants.NormalFontHeadingBold
            }
            
            if cellOdd.imgNews.image == nil{
                cellOdd.imgNews.image = UIImage(named: AssetConstants.NoImage)
            }
            activityIndicator.stopAnimating()
            return cellOdd
        }
    }
    
    //check whether tableview scrolled up or down
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if targetContentOffset.pointee.y < scrollView.contentOffset.y {
            if nextURL != nil {
                APICall().BookmarkedArticlesAPI(url: nextURL){ response in
                    switch response {
                    case .Success(let data) :
                        if data.count > 0{
                            self.bookmarkedArticlesArr.append(contentsOf: data[0].body!.articles)
                            if data[0].body!.next != nil{
                                self.nextURL = data[0].body!.next!
                            }
                            else{
                                self.nextURL = ""
                                self.bookmarkResultTV.makeToast("No more news to show", duration: 1.0, position: .center)
                            }
                            if self.bookmarkResultTV.isHidden == false{
                                self.bookmarkResultTV.reloadData()
                            }else{
                                self.bookmarkCV.reloadData()
                            }
                        }
                    case .Failure(let errormessage) :
                        print(errormessage)
                    case .Change(let code):
                        print(code)
                    }
                }
            }
        }
    }
}

extension BookmarkVC: UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (ShowArticle.count > 0) ? self.ShowArticle.count : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newsDetailvc:NewsDetailVC = storyboard.instantiateViewController(withIdentifier: "NewsDetailID") as! NewsDetailVC
        newsDetailvc.newsCurrentIndex = indexPath.row
        newsDetailvc.ShowArticle = sortedData
        UserDefaults.standard.set("bookmark", forKey: "isSearch")
        newsDetailvc.articleId = Int(sortedData[indexPath.row].article_id)
        bookmarkResultTV.deselectRow(at: indexPath, animated: true)
        present(newsDetailvc, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BookmarkIpadID", for:indexPath) as! BookmarkCVCell
        imgWidth = String(describing : Int(cell.imgNews.frame.width))
        imgHeight = String(describing : Int(cell.imgNews.frame.height))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.timeZone = NSTimeZone.local
        let darkModeStatus = UserDefaults.standard.value(forKey: "darkModeEnabled") as! Bool
        let textSizeSelected = UserDefaults.standard.value(forKey: "textSize") as! Int
        var fullTxt = ""
        var dateSubString = ""
        var agoDate = ""
        //display data from DB
        sortedData.removeAll()
        sortedData = ShowArticle.sorted{ $0.published_on! > $1.published_on! }
        let currentArticle = sortedData[indexPath.row]
        cell.layer.cornerRadius = 10.0
        cell.clipsToBounds = true
        cell.imgNews.layer.cornerRadius = 10.0
        cell.imgNews.clipsToBounds = true
        cell.lblTitle.text = currentArticle.title
        cell.viewCellContainer.layer.masksToBounds = false
        cell.viewCellContainer.layer.cornerRadius = 10
        cell.viewCellContainer.layer.shadowColor = UIColor.black.cgColor
        cell.viewCellContainer.layer.shadowOffset = CGSize(width: 0, height: 5)
        cell.viewCellContainer.layer.shadowOpacity = 0.7
        cell.viewCellContainer.layer.shadowRadius = 4.0
        if  darkModeStatus == true{
            cell.backgroundColor = colorConstants.grayBackground2
            cell.containerView.backgroundColor = colorConstants.grayBackground2
            cell.lblSource.textColor = colorConstants.nightModeText
            cell.lblTitle.textColor = colorConstants.nightModeText
            NightNight.theme =  .night
        }
        else{
            cell.backgroundColor = .white
            cell.containerView.backgroundColor = .white
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
        return cell
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if (scrollView.bounds.maxY) == scrollView.contentSize.height{
            activityIndicator.startAnimating()
            
            if ShowArticle.count >= 20{
                if nextURL != nil {
                    self.activityIndicator.startAnimating()
                    APICall().BookmarkedArticlesAPI(url: nextURL){ response in
                        switch response {
                        case .Success(let data) :
                            if data.count > 0{
                                self.bookmarkedArticlesArr.append(contentsOf: data[0].body!.articles)
                                if data[0].body!.next != nil{
                                    self.nextURL = data[0].body!.next!
                                }
                                else{
                                    self.nextURL = ""
                                    self.bookmarkResultTV.makeToast("No more news to show", duration: 1.0, position: .center)
                                }
                                self.bookmarkCV.reloadData()
                            }
                        case .Failure(let errormessage) :
                            self.activityIndicator.startAnimating()
                            print(errormessage)
                        case .Change(let code):
                            print(code)
                        }
                    }
                    self.activityIndicator.stopAnimating()
                }
            }
            else{
                activityIndicator.stopAnimating()
            }
        }
    }
    
}

extension BookmarkVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionCellSize = bookmarkCV.frame.size.width
        return CGSize(width: collectionCellSize/3.4, height: collectionCellSize/2.4)
    }
}
