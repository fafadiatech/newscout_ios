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
    @IBOutlet weak var lblBookmark: UILabel!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var bookmarkResultTV: UITableView!
    @IBOutlet weak var btnBack: UIButton!
    let activityIndicator = MDCActivityIndicator()
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    let textSizeSelected = UserDefaults.standard.value(forKey: "textSize") as! Int
    var bookmarkedArticlesArr = [Article]()
    var nextURL = ""
    var ShowArticle = [NewsArticle]()
    var bookmarkArticles = [BookmarkArticles]()
    var imgWidth = ""
    var imgHeight = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        if UserDefaults.standard.value(forKey: "token") != nil || UserDefaults.standard.value(forKey: "FBToken") != nil || UserDefaults.standard.value(forKey: "googleToken") != nil{
            let coredataRecordCount = DBManager().IsCoreDataEmpty(entity: "BookmarkArticles")
            if coredataRecordCount != 0{
                fetchBookmarkDataFromDB()
            }else{
                saveBookmarkDataInDB(url : APPURL.bookmarkedArticlesURL)
            }
        }
        else{
            activityIndicator.stopAnimating()
            self.showMsg(title: "Please login to continue..", msg: "")
            self.view.makeToast("You need to login", duration: 1.0, position: .center)
        }
        let refreshControl = UIRefreshControl()
        if UserDefaults.standard.value(forKey: "token") != nil || UserDefaults.standard.value(forKey: "FBToken") != nil || UserDefaults.standard.value(forKey: "googleToken") != nil{
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
        bookmarkResultTV.reloadData()
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
                self.bookmarkResultTV.makeToast("No news found", duration: 3.0, position: .center)
            }
            self.bookmarkResultTV.reloadData()
        case .Failure(let errorMsg) :
            self.bookmarkResultTV.makeToast(errorMsg, duration: 1.0, position: .center)
        }
    }
    
    func saveBookmarkDataInDB(url: String){
        DBManager().SaveBookmarkArticles(){response in
            if response == true{
                self.fetchBookmarkDataFromDB()
            }
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
                        self.bookmarkResultTV.makeToast("There is not any article bookmarked yet...", duration: 1.0, position: .center)
                    }else{
                        self.bookmarkResultTV.reloadData()
                    }
                }
            case .Failure(let errormessage) :
                self.activityIndicator.startAnimating()
                self.bookmarkResultTV.makeToast(errormessage, duration: 2.0, position: .center)
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
        newsDetailvc.ShowArticle = ShowArticle
        UserDefaults.standard.set("bookmark", forKey: "isSearch")
        newsDetailvc.articleId = Int(ShowArticle[indexPath.row].article_id)
        present(newsDetailvc, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "bookmarkResultID", for:indexPath) as! BookmarkTVCell
        /*  let borderColor: UIColor = UIColor.lightGray
         cell.ViewCellBackground.layer.borderColor = borderColor.cgColor
         cell.ViewCellBackground.layer.borderWidth = 1
         cell.ViewCellBackground.layer.cornerRadius = 10.0
         cell.imgNews.layer.cornerRadius = 10.0
         cell.imgNews.clipsToBounds = true
         cell.lblSource.textColor = colorConstants.txtDarkGrayColor
         let dateFormatter = DateFormatter()
         dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
         dateFormatter.timeZone = NSTimeZone.local
         if ShowArticle.count != 0{
         let currentArticle = ShowArticle[indexPath.row]
         cell.lblSource.text = currentArticle.source
         let newDate = dateFormatter.date(from: currentArticle.published_on!)
         let agoDate = Helper().timeAgoSinceDate(newDate!)
         cell.lblNewsDescription.text = currentArticle.title
         cell.imgNews.sd_setImage(with: URL(string: currentArticle.imageURL!), placeholderImage: nil, options: SDWebImageOptions.refreshCached)
         }
         
         if textSizeSelected == 0{
         cell.lblSource.font = FontConstants.smallFontContent
         cell.lblNewsDescription.font = FontConstants.smallFontHeadingBold
         
         }
         else if textSizeSelected == 2{
         cell.lblSource.font = FontConstants.LargeFontContent
         cell.lblNewsDescription.font = FontConstants.LargeFontHeadingBold
         }
         else{
         cell.lblSource.font = FontConstants.NormalFontContent
         cell.lblNewsDescription.font = FontConstants.NormalFontHeadingBold
         }
         let darkModeStatus = UserDefaults.standard.value(forKey: "darkModeEnabled") as! Bool
         if  darkModeStatus == true{
         cell.ViewCellBackground.backgroundColor = colorConstants.grayBackground2
         cell.lblSource.textColor = colorConstants.nightModeText
         cell.lblNewsDescription.textColor = colorConstants.nightModeText
         NightNight.theme =  .night
         }
         else{
         NightNight.theme =  .normal
         }
         if cell.imgNews.image == nil{
         cell.imgNews.image = UIImage(named: AssetConstants.NoImage)
         }
         activityIndicator.stopAnimating()*/
        let cellOdd = tableView.dequeueReusableCell(withIdentifier: "bookmarkZigzagID", for:indexPath) as! BookmarkZigzagTVCell
        imgWidth = String(describing : Int(cell.imgNews.frame.width))
        imgHeight = String(describing : Int(cell.imgNews.frame.height))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.timeZone = NSTimeZone.local
        let darkModeStatus = UserDefaults.standard.value(forKey: "darkModeEnabled") as! Bool
        let textSizeSelected = UserDefaults.standard.value(forKey: "textSize") as! Int
        var sourceColor = UIColor()
        var fullTxt = ""
        var dateSubString = ""
        var agoDate = ""
        if indexPath.row % 2 != 0{
            
            cell.imgNews.layer.cornerRadius = 10.0
            cell.imgNews.clipsToBounds = true
            
            //display data from DB
            let currentArticle = ShowArticle[indexPath.row]
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
            //lblNonews.isHidden = true
            return cell
        }
        else{
            
            cellOdd.imgNews.layer.cornerRadius = 10.0
            cellOdd.imgNews.clipsToBounds = true
            //display data from DB
            let currentArticle = ShowArticle[indexPath.row]
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
            //lblNonews.isHidden = true
            return cellOdd
        }
    }
    
    //check whether tableview scrolled up or down
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if targetContentOffset.pointee.y < scrollView.contentOffset.y {
            if nextURL != "" {
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
                            self.bookmarkResultTV.reloadData()
                        }
                    case .Failure(let errormessage) :
                        self.activityIndicator.startAnimating()
                        self.bookmarkResultTV.makeToast(errormessage, duration: 2.0, position: .center)
                    case .Change(let code):
                        print(code)
                    }
                }
                self.activityIndicator.stopAnimating()
            }
        }
    }
}
