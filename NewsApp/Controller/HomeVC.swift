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
        var settingvc = SettingsTVC()
        // To make the activity indicator appear:
        activityIndicator.startAnimating()
        
        var paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        print("\(paths[0])")
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
        
        if tabBarTitle == "For You"{
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
        APICall().loadNewsbyCategoryAPI(url: APPURL.ArticlesByCategoryURL + "\(selectedCategory)" ){ response in
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
                self.activityIndicator.startAnimating()
                self.HomeNewsTV.makeToast(errormessage, duration: 2.0, position: .center)
            case .Change(let code):
                print(code)
                if code == 0{
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
        newsDetailvc.newsCurrentIndex = indexPath.row
        newsDetailvc.ArticleData = ArticleData
        newsDetailvc.articleId = ArticleData[0].body.articles[indexPath.row].article_id!
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
        //set label colors
        cell.lblSource.textColor = colorConstants.txtDarkGrayColor
        cell.lblTimesAgo.textColor = colorConstants.txtDarkGrayColor
        //display data using API
        if ArticleData.count != 0{
            let currentArticle = ArticleData[0].body.articles[indexPath.row]
            cell.lblNewsHeading.text = currentArticle.title
            cell.lblSource.text = currentArticle.source
            let newDate = dateFormatter.date(from: currentArticle.published_on!)
            let agoDate = Helper().timeAgoSinceDate(newDate!)
            cell.lblTimesAgo.text = agoDate
            cell.imgNews.downloadedFrom(link: "\(currentArticle.imageURL!)")
        }
        let textSizeSelected = UserDefaults.standard.value(forKey: "textSize") as! Int
        if textSizeSelected == 0{
            cell.lblSource.font = FontConstants.smallFontContent
            cell.lblTimesAgo.font = FontConstants.smallFontContent
            cell.lblNewsHeading.font = FontConstants.smallFontHeadingBold
        }
        else if textSizeSelected == 2{
            cell.lblSource.font = FontConstants.LargeFontContent
            cell.lblTimesAgo.font = FontConstants.LargeFontContent
            cell.lblNewsHeading.font = FontConstants.LargeFontHeadingBold
        }
        else{
            cell.lblSource.font =  FontConstants.NormalFontContent
            cell.lblTimesAgo.font = FontConstants.NormalFontContent
            cell.lblNewsHeading.font = FontConstants.NormalFontHeadingBold
            
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
                
                APICall().loadNewsbyCategoryAPI(url: nextURL){ response in
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
                        self.activityIndicator.startAnimating()
                        self.HomeNewsTV.makeToast(errormessage, duration: 2.0, position: .center)
                    case .Change(let code):
                        print(code)
                        if code == 0{
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
                self.activityIndicator.stopAnimating()
            }
        } else {
            print(" it's going down")
            if previousURL != ""{
                self.activityIndicator.startAnimating()
                APICall().loadNewsbyCategoryAPI(url: previousURL){ response in
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
                        self.HomeNewsTV.makeToast(errormessage, duration: 1.0, position: .center)
                        self.activityIndicator.startAnimating()
                        self.HomeNewsTV.makeToast(errormessage, duration: 2.0, position: .center)
                    case .Change(let code):
                        print(code)
                        if code == 0{
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
                self.activityIndicator.stopAnimating()
            }
        }
    }
}

extension HomeVC: IndicatorInfoProvider{
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        print(tabBarTitle)
        return IndicatorInfo(title: tabBarTitle)
    }
}



