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
import MaterialComponents.MaterialActivityIndicator

class SearchVC: UIViewController {
    @IBOutlet weak var searchResultTV: UITableView!
    @IBOutlet weak var btnSearch: UIButton!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var lblTitle: UILabel!
    let activityIndicator = MDCActivityIndicator()
    //variables
    var count = 0
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
        activityIndicator.cycleColors = [.blue]
        activityIndicator.frame = CGRect(x: 166, y: 150, width: 40, height: 40)
        activityIndicator.sizeToFit()
        activityIndicator.indicatorMode = .indeterminate
        activityIndicator.progress = 2.0
        view.addSubview(activityIndicator)
        lblTitle.font = Constants.LargeFontMedium
        //check whether search or bookmark is selected
        if isSearch == true{
            lblTitle.isHidden = true
            txtSearch.isHidden = false
        }
        else{
            txtSearch.isHidden = true
            lblTitle.isHidden = false
            activityIndicator.startAnimating()
            BookmarkAPICall()
        }
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshBookmarkedNews), for: .valueChanged)
        searchResultTV.refreshControl = refreshControl
        refreshControl.attributedTitle = NSAttributedString(string: "Pull  to Refresh...")
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
            lblTitle.font = Constants.NormalFontMedium
            txtSearch.font = Constants.NormalFontMedium
        }
        else if textSizeSelected == 2{
            lblTitle.font = Constants.LargeFontMedium
            txtSearch.font = Constants.LargeFontMedium
        }
        else{
            lblTitle.font = Constants.LargeFontMedium
            txtSearch.font = Constants.LargeFontMedium
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
            cell.lblSource.font = Constants.xsmallFont
            cell.lblNewsDescription.font = Constants.smallFontMedium
            cell.lbltimeAgo.font = Constants.xsmallFont
        }
        else if textSizeSelected == 2{
            cell.lblSource.font = Constants.xLargeFont
            cell.lblNewsDescription.font = Constants.LargeFontMedium
            cell.lbltimeAgo.font = Constants.xLargeFont
        }
        else{
            cell.lblSource.font = Constants.xNormalFont
            cell.lblNewsDescription.font = Constants.NormalFontMedium
            cell.lbltimeAgo.font = Constants.xNormalFont
        }
        activityIndicator.stopAnimating()
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

