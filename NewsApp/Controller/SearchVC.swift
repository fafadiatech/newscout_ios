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

class SearchVC: UIViewController {
    @IBOutlet weak var searchResultTV: UITableView!
    @IBOutlet weak var btnSearch: UIButton!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var lblTitle: UILabel!
    let activityIndicator = MDCActivityIndicator()
    //variables
    var ArticleData = [ArticleStatus]()
    var SearchData = [ArticleStatus]()
    var results: [NewsArticle] = []
    var nextURL = ""
    var previousURL = ""
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    var isSearch = false
    let textSizeSelected = UserDefaults.standard.value(forKey: "textSize") as! Int
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(darkModeEnabled(_:)), name: .darkModeEnabled, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(darkModeDisabled(_:)), name: .darkModeDisabled, object: nil)
        activityIndicator.cycleColors = [.blue]
        activityIndicator.frame = CGRect(x: view.frame.width/2, y: view.frame.height/2 - 100, width: 40, height: 40)
        //activityIndicator.frame = CGRect(x: view.frame.width/2, y: view.frame.height/2 - 100, width: 40, height: 40)
        
        activityIndicator.sizeToFit()
        activityIndicator.indicatorMode = .indeterminate
        activityIndicator.progress = 2.0
        view.addSubview(activityIndicator)
        searchView.backgroundColor = colorConstants.redColor
        txtSearch.autocorrectionType = .no
        txtSearch.font = FontConstants.NormalFontContent
        txtSearch.backgroundColor = colorConstants.redColor
        txtSearch.textColor = colorConstants.whiteColor
        lblTitle.textColor = colorConstants.whiteColor
        lblTitle.font = FontConstants.viewTitleFont
        //check whether search or bookmark is selected
        if isSearch == true{
            lblTitle.isHidden = true
            txtSearch.isHidden = false
        }
        else{
            txtSearch.isHidden = true
            lblTitle.isHidden = false
            activityIndicator.startAnimating()
            if UserDefaults.standard.value(forKey: "token") != nil || UserDefaults.standard.value(forKey: "FBToken") != nil || UserDefaults.standard.value(forKey: "googleToken") != nil{
                BookmarkAPICall()
            }
            else{
                activityIndicator.stopAnimating()
                showMsg(title: "Please login to continue..", msg: "")
                self.view.makeToast("You need to login", duration: 1.0, position: .center)
            }
        }
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshBookmarkedNews), for: .valueChanged)
        searchResultTV.refreshControl = refreshControl
        refreshControl.attributedTitle = NSAttributedString(string: "Pull  to Refresh...")
        if (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad){
            searchResultTV.rowHeight = 190;
        }
        else {
            searchResultTV.rowHeight = 129;
        }
    }
    
    @objc private func darkModeEnabled(_ notification: Notification) {
        // Write your dark mode code here
        NightNight.theme = .night
        //HomeNewsTV.mixedBackgroundColor = MixedColor(normal: 0xffffff, night:
        ////  0x000000)
        searchResultTV.backgroundColor = colorConstants.grayBackground3
        
    }
    
    @objc private func darkModeDisabled(_ notification: Notification) {
        // Write your non-dark mode code here
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
    
    func BookmarkAPICall()
    {
        APICall().BookmarkedArticlesAPI(url: APPURL.bookmarkedArticlesURL){ response in
            switch response {
            case .Success(let data) :
                self.ArticleData = data
                print(self.ArticleData[0].body.articles)
                if self.ArticleData[0].body.next != nil{
                    self.nextURL = self.ArticleData[0].body.next!}
                if self.ArticleData[0].body.previous != nil{
                    self.previousURL = self.ArticleData[0].body.previous!}
                if self.ArticleData[0].body.articles.count == 0{
                    self.activityIndicator.stopAnimating()
                    self.searchResultTV.makeToast("There is not any article bookmarked yet...", duration: 1.0, position: .center)
                }else{
                    self.searchResultTV.reloadData()}
            case .Failure(let errormessage) :
                print(errormessage)
                self.activityIndicator.startAnimating()
                self.searchResultTV.makeToast(errormessage, duration: 2.0, position: .center)
            case .Change(let code) :
                print(code)
            }
        }
    }
    
    @objc func refreshBookmarkedNews(refreshControl: UIRefreshControl) {
        BookmarkAPICall()
        refreshControl.endRefreshing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        changeFont()
        searchResultTV.reloadData() //for tableview
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
        self.dismiss(animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension SearchVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (ArticleData.count != 0) ? self.ArticleData[0].body.articles.count : 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("This cell  was selected: \(indexPath.row)")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newsDetailvc:NewsDetailVC = storyboard.instantiateViewController(withIdentifier: "NewsDetailID") as! NewsDetailVC
        newsDetailvc.newsCurrentIndex = indexPath.row
        newsDetailvc.ArticleData = ArticleData
        newsDetailvc.articleId = ArticleData[0].body.articles[indexPath.row].article_id!
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
        if ArticleData.count != 0{
            let currentArticle = ArticleData[0].body.articles[indexPath.row]
            cell.lblSource.text = currentArticle.source
            let newDate = dateFormatter.date(from: currentArticle.published_on!)
            let agoDate = Helper().timeAgoSinceDate(newDate!)
            cell.lbltimeAgo.text = agoDate
            cell.lblNewsDescription.text = currentArticle.title
            cell.imgNews.downloadedFrom(link: "\(currentArticle.imageURL!)")
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
        return cell
    }
    //check whether tableview scrolled up or down
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if targetContentOffset.pointee.y < scrollView.contentOffset.y {
            print("it's going up")
            if nextURL != "" {
                self.activityIndicator.startAnimating()
                APICall().BookmarkedArticlesAPI(url: nextURL){ response in
                    switch response {
                    case .Success(let data) :
                        self.ArticleData = data
                        print(self.ArticleData[0].body.articles.count)
                        print("nexturl data: \(self.ArticleData)")
                        if self.ArticleData[0].body.next != nil{
                            self.nextURL = self.ArticleData[0].body.next!
                        }
                        else{
                            self.nextURL = ""
                            self.searchResultTV.makeToast("No more news to show", duration: 1.0, position: .center)
                        }
                        if self.ArticleData[0].body.previous != nil{
                            self.previousURL = self.ArticleData[0].body.previous!
                        }
                        else{
                            self.previousURL = ""
                        }
                        self.searchResultTV.reloadData()
                    case .Failure(let errormessage) :
                        print(errormessage)
                        self.activityIndicator.startAnimating()
                        self.searchResultTV.makeToast(errormessage, duration: 2.0, position: .center)
                    case .Change(let code):
                        print(code)
                    }
                }
                self.activityIndicator.stopAnimating()
            }
        } else {
            print(" it's going down")
            if previousURL != ""{
                self.activityIndicator.startAnimating()
                APICall().BookmarkedArticlesAPI(url: nextURL){ response in
                    switch response {
                    case .Success(let data) :
                        self.ArticleData = data
                        print(self.ArticleData[0].body.articles.count)
                        print("previous url data: \(self.ArticleData)")
                        if self.ArticleData[0].body.previous != nil{
                            self.previousURL = self.ArticleData[0].body.previous!
                            print(self.previousURL)
                        }
                        else{
                            self.previousURL = ""
                            self.searchResultTV.makeToast("No more news to show", duration: 1.0, position: .center)
                        }
                        if self.ArticleData[0].body.next != nil{
                            self.nextURL = self.ArticleData[0].body.next!
                        }
                        else{
                            self.nextURL = ""
                        }
                        self.searchResultTV.reloadData()
                    case .Failure(let errormessage) :
                        print(errormessage)
                        self.activityIndicator.startAnimating()
                        self.searchResultTV.makeToast(errormessage, duration: 2.0, position: .center)
                    case .Change(let code):
                        print(code)
                    }
                }
                self.activityIndicator.stopAnimating()
            }
        }
    }
}

extension SearchVC: UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        txtSearch.resignFirstResponder()
        if txtSearch.text != ""{
            APICall().loadSearchAPI(searchTxt: txtSearch.text!){ response in
                switch response {
                case .Success(let data) :
                    self.ArticleData = data
                    print(data)
                    if self.ArticleData[0].body.articles.count == 0{
                        self.searchResultTV.makeToast("There is not any news matching with entered keyword", duration: 2.0, position: .center)
                    }
                    self.searchResultTV.reloadData()
                case .Failure(let errormessage) :
                    print(errormessage)
                    self.activityIndicator.startAnimating()
                    self.searchResultTV.makeToast(errormessage, duration: 2.0, position: .center)
                case .Change(let code):
                    print(code)
                }
                self.activityIndicator.stopAnimating()
            }
        }
        else{
            self.searchResultTV.makeToast("Enter keyword to search", duration: 2.0, position: .center)
        }
        // search text in DB
        /*   let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "NewsArticle")
         fetchRequest.predicate = NSPredicate(format: "title CONTAINS[c] %@ OR news_description CONTAINS[c] %@",txtSearch.text!, txtSearch.text!)
         let managedContext =
         appDelegate?.persistentContainer.viewContext
         do {
         results = (try managedContext?.fetch(fetchRequest))! as! [NewsArticle]
         print("result.count: \(results.count)")
         print ("results val: \(results)")
         searchResultTV.reloadData()
         }
         catch {
         print("error executing fetch request: \(error)")
         }
         
         }*/
        
        return true
    }
}
