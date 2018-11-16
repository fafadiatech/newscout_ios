//
//  ViewController.swift
//  NewsApp
//
//  Created by Jayashri on 22/09/18.
//  Copyright © 2018 Fafadia Tech. All rights reserved.
//

import UIKit
import Floaty
import XLPagerTabStrip
import Alamofire
import CoreData
import MaterialComponents.MaterialActivityIndicator

class HomeVC: UIViewController{
    
    @IBOutlet weak var HomeNewsTV: UITableView!
    var tabBarTitle: String = ""
    var ShowArticle = [NewsArticle]()
    var ArticleData = [ArticleStatus]()
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    var article_id = Int64()
    let activityIndicator = MDCActivityIndicator()
    var pageNum = 0
    var coredataRecordCount = 0
    var currentCategory = "All News"
    var selectedCategory = ""
    var nextURL = ""
    var previousURL = ""
    var lastContentOffset: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.cycleColors = [.blue]
        activityIndicator.frame = CGRect(x: 166, y: 150, width: 40, height: 40)
        activityIndicator.sizeToFit()
        activityIndicator.indicatorMode = .indeterminate
        activityIndicator.progress = 2.0
        view.addSubview(activityIndicator)
        
        // To make the activity indicator appear:
        activityIndicator.startAnimating()

        var paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        print("\(paths[0])")
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshNews), for: .valueChanged)
        HomeNewsTV.refreshControl = refreshControl
        refreshControl.attributedTitle = NSAttributedString(string: "Pull  to Refresh...")
        /* coredataRecordCount = DBManager().IsCoreDataEmpty()
         if coredataRecordCount != 0{
         let result = DBManager().FetchDataFromDB()
         switch result {
         case .Success(let DBData) :
         let articles = DBData
         if selectedCat == "" || selectedCat == "FOR YOU" || selectedCat == "All News"
         {
         self.filterNews(selectedCat: "All News" )
         print("cat pressed is: for u")
         }else{
         self.filterNews(selectedCat: selectedCat )
         }
         self.HomeNewsTV.reloadData()
         case .Failure(let errorMsg) :
         print(errorMsg)
         }
         HomeNewsTV.reloadData()
         }
         else{
         DBManager().SaveDataDB(pageNum:pageNum){response in
         if response == true{
         let result = DBManager().FetchDataFromDB()
         switch result {
         case .Success(let DBData) :
         let articles = DBData
         if  selectedCat == "" || selectedCat == "FOR YOU" || selectedCat == "All News"{
         self.filterNews(selectedCat: "All News" )
         }else{
         self.filterNews(selectedCat: selectedCat )
         }
         self.HomeNewsTV.reloadData()
         case .Failure(let errorMsg) :
         print(errorMsg)
         }
         }
         }
         }*/
    }
    
    @objc func refreshNews(refreshControl: UIRefreshControl) {
        ArticlesAPICall()
        refreshControl.endRefreshing()
    }
    
    func filterNews(selectedCat : String)
    {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "NewsArticle")
        fetchRequest.predicate = NSPredicate(format: "category CONTAINS[c] %@", selectedCat)
        let managedContext =
            self.appDelegate?.persistentContainer.viewContext
        do {
            self.ShowArticle = (try managedContext?.fetch(fetchRequest))! as! [NewsArticle]
            print("result.count: \(self.ShowArticle.count)")
        }
        catch {
            print("error executing fetch request: \(error)")
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if tabBarTitle == "FOR YOU"{
            selectedCategory = "All News"
        }
        else{
            selectedCategory = tabBarTitle
        }
        selectedCategory = selectedCategory.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        print("selectedcat: \(tabBarTitle)")
        ArticlesAPICall()
        
    }
    
    func ArticlesAPICall(){
        APICall().loadNewsbyCategoryAPI(category:selectedCategory, url: APPURL.ArticlesByCategoryURL + "\(selectedCategory)" ){ response in
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
                    self.HomeNewsTV.makeToast("No articles found in this category...", duration: 1.0, position: .center)
                }else{
                    self.HomeNewsTV.reloadData()}
            case .Failure(let errormessage) :
                print(errormessage)
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension HomeVC: UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (ArticleData.count != 0) ? self.ArticleData[0].body.articles.count : 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("This cell  was selected: \(indexPath.row)")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newsDetailvc:NewsDetailVC = storyboard.instantiateViewController(withIdentifier: "NewsDetailID") as! NewsDetailVC
        newsCurrentIndex = indexPath.row
        newsDetailvc.ArticleData = ArticleData
        articleId = ArticleData[0].body.articles[indexPath.row].article_id!
        print("articleId in didselect: \(articleId)")
        present(newsDetailvc, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeNewsTVCellID", for:indexPath) as! HomeNewsTVCell
        let borderColor: UIColor = UIColor.lightGray
        cell.ViewCellBackground.layer.borderColor = borderColor.cgColor
        cell.ViewCellBackground.layer.borderWidth = 1
        cell.ViewCellBackground.layer.cornerRadius = 10.0
        cell.imgNews.layer.cornerRadius = 10.0
        cell.imgNews.clipsToBounds = true
        
        //timestamp conversion
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.timeZone = NSTimeZone(name: "UTC")! as TimeZone
        //display data using API
        if ArticleData.count != 0{
            let currentArticle = ArticleData[0].body.articles[indexPath.row]
            cell.lblNewsHeading.text = currentArticle.title
            cell.lblSource.text = currentArticle.source
            let newDate = dateFormatter.date(from: currentArticle.published_on!)
            let agoDate = timeAgoSinceDate(newDate!)
            cell.lblTimesAgo.text = agoDate
            cell.imgNews.downloadedFrom(link: "\(currentArticle.imageURL!)")
        }
        if textSizeSelected == 0{
            cell.lblSource.font = Constants.xsmallFont
            cell.lblNewsHeading.font = Constants.smallFontMedium
            cell.lblTimesAgo.font = Constants.xsmallFont
        }
        else if textSizeSelected == 2{
            cell.lblSource.font = Constants.xLargeFont
            cell.lblNewsHeading.font = Constants.LargeFontMedium
            cell.lblTimesAgo.font = Constants.xLargeFont
        }
        else{
            cell.lblSource.font =  Constants.xNormalFont
            cell.lblNewsHeading.font = Constants.NormalFontMedium
            cell.lblTimesAgo.font = Constants.xNormalFont
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
                APICall().loadNewsbyCategoryAPI(category:selectedCategory, url: nextURL){ response in
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
                            self.HomeNewsTV.makeToast("No more news to show", duration: 1.0, position: .center)
                        }
                        if self.ArticleData[0].body.previous != nil{
                            self.previousURL = self.ArticleData[0].body.previous!
                        }
                        else{
                            self.previousURL = ""
                        }
                        self.HomeNewsTV.reloadData()
                    case .Failure(let errormessage) :
                        print(errormessage)
                    }
                }
                  self.activityIndicator.stopAnimating()
            }
        } else {
            print(" it's going down")
            if previousURL != ""{
                 self.activityIndicator.startAnimating()
                APICall().loadNewsbyCategoryAPI(category:selectedCategory, url: previousURL){ response in
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
                            self.HomeNewsTV.makeToast("No more news to show", duration: 1.0, position: .center)
                        }
                        if self.ArticleData[0].body.next != nil{
                            self.nextURL = self.ArticleData[0].body.next!
                        }
                        else{
                            self.nextURL = ""
                        }
                        self.HomeNewsTV.reloadData()
                    case .Failure(let errormessage) :
                        print(errormessage)
                    }
                }
                self.activityIndicator.stopAnimating()
            }
        }
    }
}

extension HomeVC: IndicatorInfoProvider{
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        print(tabBarTitle)
        return IndicatorInfo(title: tabBarTitle.uppercased())
    }
}



