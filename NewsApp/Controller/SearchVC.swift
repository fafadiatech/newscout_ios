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
    let activityIndicator = MDCActivityIndicator()
    //variables
    var Searchresults = [SearchArticles]()
    var nextURL = ""
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    let textSizeSelected = UserDefaults.standard.value(forKey: "textSize") as! Int
    var searchArticlesArr = [Article]()
    var recordCount = 0
    var coredataRecordCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if UserDefaults.standard.value(forKey: "searchTxt") != nil{
            txtSearch.text = (UserDefaults.standard.value(forKey: "searchTxt") as! String)
        }
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
    
    @objc private func darkModeEnabled(_ notification: Notification){
        NightNight.theme = .night
        searchResultTV.backgroundColor = colorConstants.grayBackground3
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
                searchResultTV.reloadData()
            }
        case .Failure( _) : break
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func saveArticlesInDB(url: String){
        DBManager().SaveSearchDataDB(nextUrl: url){response in
            if response == true{
                self.fetchArticlesFromDB()
                if UserDefaults.standard.value(forKey: "token") != nil{
                    
                    let BookmarkRecordCount = DBManager().IsCoreDataEmpty(entity: "BookmarkArticles")
                    let LikeRecordCount = DBManager().IsCoreDataEmpty(entity: "LikeDislike")
                    if BookmarkRecordCount != 0 || LikeRecordCount != 0{
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
}

extension SearchVC: UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recordCount != 0 ? recordCount : 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newsDetailvc:NewsDetailVC = storyboard.instantiateViewController(withIdentifier: "NewsDetailID") as! NewsDetailVC
        newsDetailvc.newsCurrentIndex = indexPath.row
        newsDetailvc.SearchArticle = Searchresults
        newsDetailvc.articleId = Int(Searchresults[indexPath.row].article_id)
        UserDefaults.standard.set("search", forKey: "isSearch")
        present(newsDetailvc, animated: true, completion: nil)
        searchResultTV.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "search", for:indexPath) as! SearchResultTVCell
        let borderColor: UIColor = UIColor.lightGray
        cell.ViewCellBackground.layer.borderColor = borderColor.cgColor
        cell.ViewCellBackground.layer.borderWidth = 1
        cell.ViewCellBackground.layer.cornerRadius = 10.0
        cell.imgNews.layer.cornerRadius = 10.0
        cell.imgNews.clipsToBounds = true
        cell.lblSource.textColor = colorConstants.txtDarkGrayColor
        cell.lbltimeAgo.textColor = colorConstants.txtDarkGrayColor
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.timeZone = NSTimeZone.local
        
        if Searchresults.count > 0{
            let currentArticle = Searchresults[indexPath.row]
            cell.lblSource.text =  currentArticle.source
            if !(currentArticle.published_on?.contains("Z"))!{
                currentArticle.published_on?.append("Z")
            }
            let newDate = dateFormatter.date(from: currentArticle.published_on!)
            if newDate != nil{
                let agoDate = Helper().timeAgoSinceDate(newDate!)
                cell.lbltimeAgo.text = agoDate
            }
            cell.lblNewsDescription.text = currentArticle.title
            cell.imgNews.sd_setImage(with: URL(string: currentArticle.imageURL!), placeholderImage: nil, options: SDWebImageOptions.refreshCached)
        }
        
        if textSizeSelected == 0{
            cell.lblSource.font = FontConstants.smallFontContent
            cell.lbltimeAgo.font = FontConstants.smallFontContent
            cell.lblNewsDescription.font = FontConstants.smallFontHeadingBold
            
        }
        else if textSizeSelected == 2{
            cell.lblSource.font = FontConstants.LargeFontContent
            cell.lbltimeAgo.font = FontConstants.LargeFontContent
            cell.lblNewsDescription.font = FontConstants.LargeFontHeadingBold
        }
        else{
            cell.lblSource.font = FontConstants.NormalFontContent
            cell.lbltimeAgo.font = FontConstants.NormalFontContent
            cell.lblNewsDescription.font = FontConstants.NormalFontHeadingBold
        }
        let darkModeStatus = UserDefaults.standard.value(forKey: "darkModeEnabled") as! Bool
        if  darkModeStatus == true{
            cell.ViewCellBackground.backgroundColor = colorConstants.grayBackground2
            cell.lblSource.textColor = colorConstants.nightModeText
            cell.lbltimeAgo.textColor = colorConstants.nightModeText
            cell.lblNewsDescription.textColor = colorConstants.nightModeText
            NightNight.theme =  .night
        }
        else{
            NightNight.theme =  .normal
        }
        if cell.imgNews.image == nil{
            cell.imgNews.image = UIImage(named: AssetConstants.NoImage)
        }
        activityIndicator.stopAnimating()
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            let keyword =  UserDefaults.standard.value(forKey: "searchTxt") as! String
            let result =  DBManager().FetchNextURL(category: keyword)
            switch result {
            case .Success(let DBData) :
                let nextURL = DBData
                if nextURL.count != 0{
                    if nextURL[0].category == keyword{
                        let nexturl = nextURL[0].nextURL
                        self.saveArticlesInDB(url : nexturl!)
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let height = scrollView.frame.size.height
        let contentYoffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
        if distanceFromBottom < height {
            if recordCount > 0 {
                activityIndicator.startAnimating()
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
extension SearchVC: UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        txtSearch.resignFirstResponder()
        if !(txtSearch.text?.isEmpty)!{
            if txtSearch.text != ""{
                var search = txtSearch.text!
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
                    searchResultTV.reloadData()
                    DBManager().deleteSearchNextURl()
                    search = search.replacingOccurrences(of: " ", with: "%20")
                    let url = APPURL.SearchURL + search
                    
                    DBManager().deleteAllData(entity: "SearchArticles")
                    saveArticlesInDB(url: url)
                    if UserDefaults.standard.value(forKey: "token") != nil{
                        let BookmarkRecordCount = DBManager().IsCoreDataEmpty(entity: "BookmarkArticles")
                        let LikeRecordCount = DBManager().IsCoreDataEmpty(entity: "LikeDislike")
                        if BookmarkRecordCount != 0 || LikeRecordCount != 0{
                            fetchBookmarkDataFromDB()
                            
                        }
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
                lblNoNews.isHidden = false
            }
            else{
                searchResultTV.reloadData()
            }
        case .Failure( _) :
            self.searchResultTV.makeToast("Please try again later", duration: 2.0, position: .center)
        }
    }
    
    func fetchResult(){
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "NewsArticle")
        fetchRequest.predicate = NSPredicate(format: "title CONTAINS[c] %@ OR blurb CONTAINS[c] %@",txtSearch.text!, txtSearch.text!)
        let managedContext =
            appDelegate?.persistentContainer.viewContext
        do {
            Searchresults = (try managedContext?.fetch(fetchRequest))
                as! [SearchArticles]
            recordCount = Searchresults.count
            searchResultTV.reloadData()
            
            if recordCount == 0 {
                lblNoNews.isHidden = false
            }
        }
        catch {
            self.searchResultTV.makeToast("Please try again later", duration: 2.0, position: .center)
        }
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == txtSearch {
            lblNoNews.isHidden = true
        }
    }
    
}
