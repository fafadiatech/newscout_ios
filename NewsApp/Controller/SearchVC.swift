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
    @IBOutlet weak var searchAutocompleteTV: UITableView!
    @IBOutlet weak var lblNoNews: UILabel!
    let activityIndicator = MDCActivityIndicator()
    //variables
    var results: [NewsArticle] = []
    var nextURL = ""
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    let textSizeSelected = UserDefaults.standard.value(forKey: "textSize") as! Int
    var searchArticlesArr = [Article]()
    var recordCount = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        if UserDefaults.standard.value(forKey: "searchTxt") != nil{
            txtSearch.text = UserDefaults.standard.value(forKey: "searchTxt") as! String
        }
        lblNoNews.isHidden = true
        searchAutocompleteTV.isHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(darkModeEnabled(_:)), name: .darkModeEnabled, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(darkModeDisabled(_:)), name: .darkModeDisabled, object: nil)
        activityIndicator.cycleColors = [.blue]
        activityIndicator.frame = CGRect(x: view.frame.width/2, y: view.frame.height/2 - 100, width: 40, height: 40)
        activityIndicator.sizeToFit()
        activityIndicator.indicatorMode = .indeterminate
        activityIndicator.progress = 2.0
        view.addSubview(activityIndicator)
        titleView.backgroundColor = colorConstants.redColor
        txtSearch.font = FontConstants.NormalFontContent
        lblTitle.textColor = colorConstants.whiteColor
        lblTitle.font = FontConstants.viewTitleFont
    }
    
    @objc private func darkModeEnabled(_ notification: Notification) {
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
    
    func showMsg(title: String, msg : String)
    {
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
            print("You've pressed cancel");
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
    
    func changeFont()
    {
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension SearchVC: UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recordCount
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("This cell  was selected: \(indexPath.row)")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newsDetailvc:NewsDetailVC = storyboard.instantiateViewController(withIdentifier: "NewsDetailID") as! NewsDetailVC
        newsDetailvc.newsCurrentIndex = indexPath.row
        if searchArticlesArr.count != 0 {
        newsDetailvc.articleArr = searchArticlesArr
        newsDetailvc.articleId = searchArticlesArr[indexPath.row].article_id!
        }
        else{
            newsDetailvc.ShowArticle = results
            newsDetailvc.articleId = Int(results[indexPath.row].article_id)
    
        }
        UserDefaults.standard.set("search", forKey: "isSearch")
        present(newsDetailvc, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchResultID", for:indexPath) as! SearchResultTVCell
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
        dateFormatter.timeZone = NSTimeZone(name: "UTC")! as TimeZone
        
        if searchArticlesArr.count != 0{
            let currentArticle = searchArticlesArr[indexPath.row]
            cell.lblSource.text = currentArticle.source
            let newDate = dateFormatter.date(from: currentArticle.published_on!)
            let agoDate = Helper().timeAgoSinceDate(newDate!)
            cell.lbltimeAgo.text = agoDate
            cell.lblNewsDescription.text = currentArticle.title
            cell.imgNews.sd_setImage(with: URL(string: currentArticle.imageURL!), placeholderImage: nil, options: SDWebImageOptions.refreshCached)
        }
        else if results.count != 0{
            recordCount = results.count
            let currentArticle = results[indexPath.row]
            cell.lblSource.text = currentArticle.source
            let newDate = dateFormatter.date(from: currentArticle.published_on!)
            let agoDate = Helper().timeAgoSinceDate(newDate!)
            cell.lbltimeAgo.text = agoDate
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
        activityIndicator.stopAnimating()
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
            cell.imgNews.image = UIImage(named: "NoImage.png")
        }
        return cell
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if targetContentOffset.pointee.y < scrollView.contentOffset.y {
            print("it's going up")
            if nextURL != "" {
                APICall().loadSearchAPI(url: nextURL){ (Status, response) in
                    switch response {
                    case .Success(let data) :
                        if data.count > 0 {
                            self.searchArticlesArr.append(contentsOf: data[0].body!.articles)
                            if data[0].body!.next != nil{
                                self.nextURL = data[0].body!.next!
                            }
                            else{
                                self.nextURL = ""
                                self.view.makeToast("No more news to show", duration: 1.0, position: .center)
                            }
                            self.searchResultTV.reloadData()
                        }
                    case .Failure(let errormessage) :
                        print(errormessage)
                        self.activityIndicator.startAnimating()
                        self.view.makeToast(errormessage, duration: 2.0, position: .center)
                    case .Change(let code):
                        if code == 404{
                            let defaults = UserDefaults.standard
                            defaults.removeObject(forKey: "googleToken")
                            defaults.removeObject(forKey: "FBToken")
                            defaults.removeObject(forKey: "token")
                            defaults.removeObject(forKey: "email")
                            defaults.removeObject(forKey: "first_name")
                            defaults.removeObject(forKey: "last_name")
                            defaults.synchronize()
                            self.showMsg(title: "Please login to continue..", msg: "")
                        }
                    }
                }
            }
        }
    }
}

extension SearchVC: UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        txtSearch.resignFirstResponder()
        if !(txtSearch.text?.isEmpty)!{
            if txtSearch.text != " "{
                var search = txtSearch.text!
                // search = searchTxt.replacingOccurrences(of: "'", with: "%27")
                let whitespace = NSCharacterSet.whitespaces
                var range = search.rangeOfCharacter(from: whitespace)
                
                if let test = range {
                    print("whitespace found")
                    search = search.trimmingCharacters(in: .whitespacesAndNewlines)
                    search = search.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
                }
                let allowedCharacterSet = (CharacterSet(charactersIn: "!*();:@&=+$,/?%#[]").inverted)
                
                if let escapedString = search.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) {
                    search = escapedString
                }
                UserDefaults.standard.set(search, forKey: "searchTxt")
            
                let url = APPURL.SearchURL + search
                DBManager().SaveSearchDataDB(nextUrl: url){response in
                    if response == true{
                        self.fetchArticlesFromDB()
                    }
                }
               /* APICall().loadSearchAPI(url: url){ (Status, response) in
                    switch response {
                    case .Success(let data) :
                        if data.count > 0{
                            self.searchArticlesArr = data[0].body!.articles
                             self.recordCount = self.searchArticlesArr.count
                            if data[0].body!.next != nil{
                                self.nextURL = data[0].body!.next!
                            }
                            if data[0].body!.articles.count == 0{
                                self.lblNoNews.isHidden = false
                                self.lblNoNews.text = "No news found"
                            }
                            else{
                                self.lblNoNews.isHidden = true
                            }
                            self.searchResultTV.reloadData()
                        }
                    case .Failure(let errormessage) :
                        if Status == "no net"{
                            self.fetchResult()
                        }
                        else{
                        print(errormessage)
                        self.activityIndicator.startAnimating()
                        self.searchResultTV.makeToast(errormessage, duration: 2.0, position: .center)
                        }
                    case .Change(let code):
                        print(code)
                    }
                    self.activityIndicator.stopAnimating()
                }*/
            }
            else{
                self.searchResultTV.makeToast("Enter keyword to search", duration: 2.0, position: .center)
            }
        }
            
        else{
            self.searchResultTV.makeToast("Enter keyword to search", duration: 2.0, position: .center)
        }
        
        return true
    }
    
    func fetchArticlesFromDB(){
        
        let result = DBManager().FetchDataFromDB(entity: "SearchArticles")
        switch result {
        case .Success(let DBData) :
            results = DBData
            recordCount = results.count
            searchResultTV.reloadData()
        
        case .Failure(let errorMsg) :
            print(errorMsg)
        }
    }
    func fetchResult(){
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "NewsArticle")
        fetchRequest.predicate = NSPredicate(format: "title CONTAINS[c] %@ OR blurb CONTAINS[c] %@",txtSearch.text!, txtSearch.text!)
        let managedContext =
            appDelegate?.persistentContainer.viewContext
        do {
            results = (try managedContext?.fetch(fetchRequest))
                as! [NewsArticle]
            recordCount = results.count
            searchResultTV.reloadData()
            
            if recordCount == 0 {
                self.searchResultTV.makeToast("News does not exist", duration: 2.0, position: .center)
            }
        }
        catch {
            print("error executing fetch request: \(error)")
        }
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == txtSearch {
            print("started editing text")
            lblNoNews.isHidden = true
        }
    }
    
}
