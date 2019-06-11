//
//  SearchVC.swift
//  NewsApp
//
//  Created by Jayashri on 25/09/18.
//  Copyright © 2018 Fafadia Tech. All rights reserved.
//

import UIKit
import Alamofire
import CoreData
import NightNight
import MaterialComponents.MaterialActivityIndicator
import SDWebImage

class SearchVC: UIViewController {
    @IBOutlet weak var searchResultTV: UITableView!
    @IBOutlet weak var btnSearch: UIButton!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblNoNews: UILabel!
    @IBOutlet weak var searchResultCV: UICollectionView!
    @IBOutlet weak var btnTopNews: UIButton!
    @IBOutlet weak var autoSuggestionView: UIView!
    @IBOutlet weak var autoSuggestionTV: UITableView!
    let activityIndicator = MDCActivityIndicator()
    //variables
    var isResultLoaded = false
    var Searchresults = [SearchArticles]()
    var nextURL = ""
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    let textSizeSelected = UserDefaults.standard.value(forKey: "textSize") as! Int
    var searchArticlesArr = [Article]()
    var recordCount = 0
    var coredataRecordCount = 0
    var imgWidth = ""
    var imgHeight = ""
    var statusBarOrientation: UIInterfaceOrientation = UIApplication.shared.statusBarOrientation
    var keywordArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchResultTV.tableFooterView = UIView(frame: .zero)
        btnTopNews.layer.cornerRadius = 0.5 * btnTopNews.bounds.size.width
        if UserDefaults.standard.value(forKey: "searchTxt") != nil{
            txtSearch.text = (UserDefaults.standard.value(forKey: "searchTxt") as! String)
        }
         if Searchresults.count <= 0{
            if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad && statusBarOrientation.isPortrait{
            searchResultTV.isHidden = true
            searchResultCV.isHidden = false
            }else{
            searchResultTV.isHidden = false
            searchResultCV.isHidden = true
            }
         }    
        let darkModeStatus = UserDefaults.standard.value(forKey: "darkModeEnabled") as! Bool
        if darkModeStatus == true{
            searchResultCV.backgroundColor = colorConstants.grayBackground3
            searchResultTV.backgroundColor = colorConstants.grayBackground3
        }else{
            searchResultTV.backgroundColor = .white
            searchResultCV.backgroundColor = .white
        }
        txtSearch.addTarget(self, action: #selector(self.textFieldDidChange), for: UIControlEvents.editingChanged)
        lblNoNews.isHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(darkModeEnabled(_:)), name: .darkModeEnabled, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(darkModeDisabled(_:)), name: .darkModeDisabled, object: nil)
        activityIndicator.cycleColors = [.blue]
        activityIndicator.frame = CGRect(x: view.frame.width/2, y: view.frame.height/2 - 30, width: 40, height: 40)
        activityIndicator.sizeToFit()
        activityIndicator.indicatorMode = .indeterminate
        activityIndicator.progress = 2.0
        view.addSubview(activityIndicator)
        titleView.backgroundColor = colorConstants.redColor
        txtSearch.font = FontConstants.NormalFontContent
        lblTitle.textColor = colorConstants.whiteColor
        lblTitle.font = FontConstants.viewTitleFont
        if (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad){
            searchResultTV.rowHeight = 190;
        }
        else {
            searchResultTV.rowHeight = 129;
        }
    }
    
    @objc func textFieldDidChange(textField: UITextField) {
        fecthSerchedKeywords()
    }
    
    @objc private func darkModeEnabled(_ notification: Notification){
        NightNight.theme = .night
        searchResultTV.backgroundColor = colorConstants.grayBackground3
        searchResultCV.backgroundColor = colorConstants.grayBackground3
    }
    
    @objc private func darkModeDisabled(_ notification: Notification) {
        NightNight.theme = .normal
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .darkModeEnabled, object: nil)
        NotificationCenter.default.removeObserver(self, name: .darkModeDisabled, object: nil)
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        changeFont()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    func changeFont(){
        if textSizeSelected == 0{
            lblTitle.font = FontConstants.NormalFontTitleMedium
            txtSearch.font = FontConstants.NormalFontTitleMedium
        }
        else if textSizeSelected == 2{
            lblTitle.font = FontConstants.LargeFontTitleMedium
            txtSearch.font = FontConstants.LargeFontTitleMedium
        }
        else{
            lblTitle.font = FontConstants.LargeFontTitleMedium
            txtSearch.font = FontConstants.LargeFontTitleMedium
        }
    }
    
    @IBAction func btnSearchAction(_ sender: Any) {
        UserDefaults.standard.set("", forKey: "searchTxt")
        UserDefaults.standard.set("", forKey: "isSearch")
        self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
    }
    
    func fetchBookmarkDataFromDB(){
        let result = DBManager().FetchSearchLikeBookmarkFromDB()
        switch result {
        case .Success(let DBData) :
            if DBData.count == 0{
                if searchResultTV.isHidden == false{
                    searchResultTV.reloadData()
                }else{
                    searchResultCV.reloadData()
                }
            }
        case .Failure( _) : break
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func btnTopNewsActn(_ sender: Any) {
        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad{
            self.searchResultCV?.scrollToItem(at: NSIndexPath(item: 0, section: 0) as IndexPath,
                                              at: .top,
                                              animated: true)
        }else{
            let indexPath = NSIndexPath(row: 0, section: 0)
            self.searchResultTV.scrollToRow(at: indexPath as IndexPath, at: .top, animated: true)
        }
    }
    
    func saveArticlesInDB(url: String){
        DBManager().SaveSearchDataDB(nextUrl: url){response in
            if response == true{
                self.fetchArticlesFromDB()
                if UserDefaults.standard.value(forKey: "token") != nil{
                    
                    let BookmarkRecordCount = DBManager().IsCoreDataEmpty(entity: "BookmarkArticles")
                    let LikeRecordCount = DBManager().IsCoreDataEmpty(entity: "LikeDislike")
                    if BookmarkRecordCount > 0 || LikeRecordCount > 0{
                        self.fetchBookmarkDataFromDB()
                    }
                }
            }
            else{
                self.activityIndicator.stopAnimating()
                self.lblNoNews.isHidden = false
            }
        }
    }
    
    func fecthSerchedKeywords(){
        if txtSearch.text!.count < 2{
            var result = DBManager().fetchSearchHistory()
            keywordArray.removeAll()
            switch result {
            case .Success(let DBData) :
                if DBData.count > 0{
                    for i in DBData{
                        keywordArray.append(i.keyword!)
                    }
                    isResultLoaded = true
                }
                recordCount = keywordArray.count
                searchResultTV.reloadData()
            case .Failure( _) :
                self.searchResultTV.makeToast("Please try again later", duration: 2.0, position: .center)
            }
        }else{
            let result = DBManager().fetchResult(keyword: txtSearch.text!)
            keywordArray.removeAll()
            switch result {
            case .Success(let DBData) :
                for i in DBData{
                    keywordArray.append(i.title!)
                }
                recordCount = keywordArray.count
                isResultLoaded = true
                searchResultTV.reloadData()
                
            case .Failure( _) :
                self.searchResultTV.makeToast("Please try again later", duration: 2.0, position: .center)
            }
        }
    }
}

extension SearchVC: UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isResultLoaded == false{
            return 147
        }else{
            return 60
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recordCount > 0 ? recordCount : 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isResultLoaded == false{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let newsDetailvc:NewsDetailVC = storyboard.instantiateViewController(withIdentifier: "NewsDetailID") as! NewsDetailVC
            newsDetailvc.newsCurrentIndex = indexPath.row
            newsDetailvc.SearchArticle = Searchresults
            newsDetailvc.articleId = Int(Searchresults[indexPath.row].article_id)
            UserDefaults.standard.set("search", forKey: "isSearch")
            present(newsDetailvc, animated: true, completion: nil)
            searchResultTV.deselectRow(at: indexPath, animated: true)
        }else{
            txtSearch.text = keywordArray[indexPath.row]
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.timeZone = NSTimeZone.local
        let darkModeStatus = UserDefaults.standard.value(forKey: "darkModeEnabled") as! Bool
        let textSizeSelected = UserDefaults.standard.value(forKey: "textSize") as! Int
        var sourceColor = UIColor()
        var fullTxt = ""
        var dateSubString = ""
        var agoDate = ""
        if isResultLoaded == false{
            if indexPath.row % 2 != 0{
                let cell = tableView.dequeueReusableCell(withIdentifier: "search", for:indexPath) as! SearchResultTVCell
                cell.viewCellContainer.layer.cornerRadius = 10
                cell.viewCellContainer.layer.shadowColor = UIColor.black.cgColor
                cell.viewCellContainer.layer.shadowOffset = CGSize(width: 3, height: 3)
                cell.viewCellContainer.layer.shadowOpacity = 0.7
                cell.viewCellContainer.layer.shadowRadius = 4.0
                cell.imgNews.layer.cornerRadius = 10.0
                cell.imgNews.clipsToBounds = true
                imgWidth = String(describing : Int(cell.imgNews.frame.width))
                imgHeight = String(describing : Int(cell.imgNews.frame.height))
                //display data from DB
                var currentArticle = Searchresults[indexPath.row]
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
                return cell
            }
            else{
                let cellOdd = tableView.dequeueReusableCell(withIdentifier: "searchZigzagID", for:indexPath) as! searchZigzagTVCell
                cellOdd.imgNews.layer.cornerRadius = 10.0
                cellOdd.imgNews.clipsToBounds = true
                cellOdd.viewCellContainer.layer.cornerRadius = 10
                cellOdd.viewCellContainer.layer.shadowColor = UIColor.black.cgColor
                cellOdd.viewCellContainer.layer.shadowOffset = CGSize(width: 3, height: 3)
                cellOdd.viewCellContainer.layer.shadowOpacity = 0.7
                cellOdd.viewCellContainer.layer.shadowRadius = 4.0
                //display data from DB
                var currentArticle = Searchresults[indexPath.row]
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
                return cellOdd
            }
        }
        else{
            let cellWord = tableView.dequeueReusableCell(withIdentifier: "suggestID", for:indexPath) as! searchSuggestionTVCell
            cellWord.lblNewsDescription.text = keywordArray[indexPath.row]
            activityIndicator.stopAnimating()
            return cellWord
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            var keyword = ""
            if UserDefaults.standard.value(forKey: "searchTxt") != nil{
                keyword =  UserDefaults.standard.value(forKey: "searchTxt") as! String
            }
            let result =  DBManager().FetchNextURL(category: keyword)
            switch result {
            case .Success(let DBData) :
                let nextURL = DBData
                if nextURL.count > 0{
                    if nextURL[0].category == keyword{
                        let nexturl = nextURL[0].nextURL
                        if isResultLoaded == false{
                            if Reachability.isConnectedToNetwork(){
                                self.saveArticlesInDB(url : nexturl!)
                            }
                        }
                    }
                }
                else{
                    activityIndicator.stopAnimating()
                }
            case .Failure(let errorMsg) :
                print(errorMsg)
            }
        }
    }
    
}

extension SearchVC: UICollectionViewDelegate, UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (Searchresults.count > 0) ? self.Searchresults.count : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newsDetailvc:NewsDetailVC = storyboard.instantiateViewController(withIdentifier: "NewsDetailID") as! NewsDetailVC
        newsDetailvc.newsCurrentIndex = indexPath.row
        newsDetailvc.SearchArticle = Searchresults
        newsDetailvc.articleId = Int(Searchresults[indexPath.row].article_id)
        UserDefaults.standard.set("search", forKey: "isSearch")
        present(newsDetailvc, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchIpadID", for:indexPath) as! searchResultCVCell
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
        let currentArticle = Searchresults[indexPath.row]
        cell.lblTitle.text = currentArticle.title
        cell.layer.cornerRadius = 10.0
        cell.clipsToBounds = true
        cell.viewCellContainer.layer.cornerRadius = 10
        cell.viewCellContainer.layer.shadowColor = UIColor.black.cgColor
        cell.viewCellContainer.layer.shadowOffset = CGSize(width: 3, height: 3)
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
        lblNoNews.isHidden = true
        return cell
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == searchResultTV{
            let height = scrollView.frame.size.height
            let contentYoffset = scrollView.contentOffset.y
            let distanceFromBottom = scrollView.contentSize.height - contentYoffset
            if distanceFromBottom < height {
                //                if recordCount > 0 {
                //                    if isResultLoaded == false{
                //                        activityIndicator.startAnimating()
                //                    }
                //                }
            }
            
        }else{
            if (scrollView.bounds.maxY) == scrollView.contentSize.height{
                let keyword =  UserDefaults.standard.value(forKey: "searchTxt") as! String
                let result =  DBManager().FetchNextURL(category: keyword)
                switch result {
                case .Success(let DBData) :
                    let nextURL = DBData
                    if nextURL.count != 0{
                        if nextURL[0].category == keyword{
                            let nexturl = nextURL[0].nextURL
                            if isResultLoaded == false{
                                if Reachability.isConnectedToNetwork(){
                                    self.saveArticlesInDB(url : nexturl!)
                                }
                            }
                        }
                    }
                    else{
                        activityIndicator.stopAnimating()
                    }
                case .Failure(let errorMsg) :
                    print(errorMsg)
                }
            }
        }
    }
}


extension String {
    func makeHTMLfriendly() -> String {
        var finalString = ""
        for char in self {
            for scalar in String(char).unicodeScalars {
                finalString.append("&#\(scalar.value)")
            }
        }
        return finalString
    }
}

extension SearchVC: UITextFieldDelegate{
    func getSearchEvents(query: String){
        var id = ""
        if UserDefaults.standard.value(forKey: "deviceToken") != nil{
            id = UserDefaults.standard.value(forKey: "deviceToken") as! String
        }
        let param = ["action" : "search",
                     "platform" : Constants.platform,
                     "device_id" : id,
                     "q": query] as! [String : Any]
        APICall().trackingEventsAPI(param : param){response in
            if response == true{
                print("event captured")
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        txtSearch.resignFirstResponder()
        isResultLoaded = false
        if !(txtSearch.text?.isEmpty)!{
            if txtSearch.text != ""{
                var search = txtSearch.text!
                getSearchEvents(query: search)
                activityIndicator.startAnimating()
                search = search.trimmingCharacters(in: .whitespaces)
                
                let allowedCharacterSet = (CharacterSet(charactersIn: "!*();:@&=+$,/?%#[]").inverted)
                
                if let escapedString = search.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) {
                    search = escapedString
                }
                UserDefaults.standard.set(search, forKey: "searchTxt")
                
                if search == ""{
                    self.activityIndicator.stopAnimating()
                    self.searchResultTV.makeToast("Enter keyword to search", duration: 2.0, position: .center)
                }else{
                    Searchresults.removeAll()
                    recordCount = 0
                    DBManager().saveSearchHistory(keyword: txtSearch.text!)
                    searchResultCV.reloadData()
                    if Reachability.isConnectedToNetwork(){
                        DBManager().deleteSearchNextURl()
                        search = search.replacingOccurrences(of: " ", with: "%20")
                        let url = APPURL.SearchURL + search
                        
                        DBManager().deleteAllData(entity: "SearchArticles")
                        if isResultLoaded == false{
                            saveArticlesInDB(url: url)
                        }
                        if UserDefaults.standard.value(forKey: "token") != nil{
                            let BookmarkRecordCount = DBManager().IsCoreDataEmpty(entity: "BookmarkArticles")
                            let LikeRecordCount = DBManager().IsCoreDataEmpty(entity: "LikeDislike")
                            if BookmarkRecordCount != 0 || LikeRecordCount != 0{
                                fetchBookmarkDataFromDB()
                                
                            }
                        }
                    }else{
                        fetchResult()
                    }
                }
            }
            else{
                self.activityIndicator.stopAnimating()
                self.searchResultTV.makeToast("Enter keyword to search", duration: 2.0, position: .center)
            }
        }
            
        else{
            self.activityIndicator.stopAnimating()
            self.searchResultTV.makeToast("Enter keyword to search", duration: 2.0, position: .center)
        }
        
        return true
    }
    
    func fetchArticlesFromDB(){
        let result = DBManager().FetchSearchDataFromDB(entity: "SearchArticles")
        switch result {
        case .Success(let DBData) :
            Searchresults = DBData
            recordCount = Searchresults.count
            activityIndicator.startAnimating()
            if recordCount == 0 {
                activityIndicator.stopAnimating()
                isResultLoaded = false
                lblNoNews.isHidden = false
            }
            else{
                if searchResultTV.isHidden == false{
                    searchResultTV.reloadData()
                }else{
                    searchResultCV.reloadData()
                }
            }
        case .Failure( _) :
            self.searchResultTV.makeToast("Please try again later", duration: 2.0, position: .center)
        }
    }
    
    func fetchResult(){
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "SearchArticles")
        fetchRequest.predicate = NSPredicate(format: "title CONTAINS[c] %@ OR blurb CONTAINS[c] %@",txtSearch.text!, txtSearch.text!)
        let managedContext =
            appDelegate?.persistentContainer.viewContext
        do {
            Searchresults = (try managedContext?.fetch(fetchRequest))
                as! [SearchArticles]
            recordCount = Searchresults.count
            if recordCount == 0 {
                lblNoNews.isHidden = false
                activityIndicator.stopAnimating()
            }else{
                lblNoNews.isHidden = true
            }
            if searchResultTV.isHidden == false{
                searchResultTV.reloadData()
            }else{
                searchResultCV.reloadData()
            }
        }
        catch {
            self.searchResultTV.makeToast("Please try again later", duration: 2.0, position: .center)
        }
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == txtSearch {
            lblNoNews.isHidden = true
            fecthSerchedKeywords()
        }
    }
    
}

extension SearchVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionCellSize = searchResultCV.frame.size.width
        return CGSize(width: collectionCellSize/3.4, height: collectionCellSize/2.4)
    }
}

