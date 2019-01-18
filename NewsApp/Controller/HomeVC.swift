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
import SDWebImage
import NightNight

class HomeVC: UIViewController{
    
    @IBOutlet weak var HomeNewsTV: UITableView!
    @IBOutlet weak var lblNonews: UILabel!
    var tabBarTitle: String = ""
    var ShowArticle = [NewsArticle]()
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    let activityIndicator = MDCActivityIndicator()
    var pageNum = 0
    var coredataRecordCount = 0
    var currentCategory = "All News"
    var selectedCategory = ""
    var nextURL = ""
    var lastContentOffset: CGFloat = 0
    var articlesArr = [Article]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblNonews.isHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(darkModeEnabled(_:)), name: .darkModeEnabled, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(darkModeDisabled(_:)), name: .darkModeDisabled, object: nil)
        activityIndicator.cycleColors = [.blue]
        activityIndicator.frame = CGRect(x: view.frame.width/2, y: view.frame.height/2 - 100, width: 40, height: 40)
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
    
    @objc private func darkModeEnabled(_ notification: Notification) {
        NightNight.theme = .night
        HomeNewsTV.backgroundColor = colorConstants.grayBackground3
    }
    
    @objc private func darkModeDisabled(_ notification: Notification) {
        NightNight.theme = .normal
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .darkModeEnabled, object: nil)
        NotificationCenter.default.removeObserver(self, name: .darkModeDisabled, object: nil)
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
        ArticlesAPICall()
        
    }
    
    func ArticlesAPICall(){
        APICall().loadNewsbyCategoryAPI(url: APPURL.ArticlesByCategoryURL + "\(selectedCategory)" ){ (status, response) in
            switch response {
            case .Success(let data) :
                if data.count != 0{
                    self.articlesArr = data[0].body.articles
                    if data[0].body.next != nil{
                        self.nextURL = data[0].body.next!
                    }
                    if data[0].body.articles.count == 0{
                        self.activityIndicator.stopAnimating()
                        self.lblNonews.isHidden = false
                    }
                    else{
                        self.HomeNewsTV.reloadData()
                    }
                }
            case .Failure(let errormessage) :
                self.activityIndicator.startAnimating()
                self.HomeNewsTV.makeToast(errormessage, duration: 2.0, position: .center)
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
    }
}

extension HomeVC: UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (articlesArr.count != 0) ? self.articlesArr.count : 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newsDetailvc:NewsDetailVC = storyboard.instantiateViewController(withIdentifier: "NewsDetailID") as! NewsDetailVC
        newsDetailvc.newsCurrentIndex = indexPath.row
        newsDetailvc.articleArr = articlesArr
        newsDetailvc.articleId = articlesArr[indexPath.row].article_id!
        UserDefaults.standard.set("", forKey: "isSearch")
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
        cell.lblSource.textColor = colorConstants.txtDarkGrayColor
        cell.lblTimesAgo.textColor = colorConstants.txtDarkGrayColor
        //display data using API
        if articlesArr.count != 0{
            let currentArticle = articlesArr[indexPath.row]
            cell.lblNewsHeading.text = currentArticle.title
            cell.lblSource.text = currentArticle.source
            let newDate = dateFormatter.date(from: currentArticle.published_on!)
            let agoDate = Helper().timeAgoSinceDate(newDate!)
            cell.lblTimesAgo.text = agoDate
            cell.imgNews.sd_setImage(with: URL(string: currentArticle.imageURL!), placeholderImage: nil, options: SDWebImageOptions.refreshCached)
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
        
        let darkModeStatus = UserDefaults.standard.value(forKey: "darkModeEnabled") as! Bool
        if  darkModeStatus == true{
            cell.ViewCellBackground.backgroundColor = colorConstants.grayBackground2
            cell.lblSource.textColor = colorConstants.nightModeText
            cell.lblTimesAgo.textColor = colorConstants.nightModeText
            cell.lblNewsHeading.textColor = colorConstants.nightModeText
            NightNight.theme =  .night
        }
        else{
            NightNight.theme =  .normal
        }
        if cell.imgNews.image == nil
        {
            cell.imgNews.image = UIImage(named: "NoImage.png")
        }
        
        activityIndicator.stopAnimating()
        return cell
    }
    
    //check whether tableview scrolled up or down
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if targetContentOffset.pointee.y < scrollView.contentOffset.y {
            print("it's going up")
            if nextURL != "" {
                APICall().loadNewsbyCategoryAPI(url: nextURL){
                    (status, response) in
                    switch response {
                    case .Success(let data) :
                        if data.count != 0 {
                            self.articlesArr.append(contentsOf: data[0].body.articles)
                            if data[0].body.next != nil{
                                self.nextURL = data[0].body.next!
                            }
                            else{
                                self.nextURL = ""
                                self.view.makeToast("No more news to show", duration: 1.0, position: .center)
                            }
                            self.HomeNewsTV.reloadData()
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

extension HomeVC: IndicatorInfoProvider{
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: tabBarTitle)
    }
}



