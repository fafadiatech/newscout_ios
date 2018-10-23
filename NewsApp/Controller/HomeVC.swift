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

//for conversion of timestamp
func timeAgoSinceDate(_ date:Date, numericDates:Bool = false) -> String {
    let calendar = NSCalendar.current
    let unitFlags: Set<Calendar.Component> = [.minute, .hour, .day, .weekOfYear, .month, .year, .second]
    let now = Date()
    let earliest = now < date ? now : date
    let latest = (earliest == now) ? date : now
    let components = calendar.dateComponents(unitFlags, from: earliest,  to: latest)
    
    if (components.year! >= 2) {
        return "\(components.year!) years ago"
    } else if (components.year! >= 1){
        if (numericDates){
            return "1yr ago"
        } else {
            return "Last year"
        }
    } else if (components.month! >= 2) {
        return "\(components.month!) mo ago"
    } else if (components.month! >= 1){
        if (numericDates){
            return "1mo ago"
        } else {
            return "Last month"
        }
    } else if (components.weekOfYear! >= 2) {
        return "\(components.weekOfYear!) w ago"
    } else if (components.weekOfYear! >= 1){
        if (numericDates){
            return "1w ago"
        } else {
            return "Last week"
        }
    } else if (components.day! >= 2) {
        return "\(components.day!)d ago"
    } else if (components.day! >= 1){
        if (numericDates){
            return "1d ago"
        } else {
            return "Yesterday"
        }
    } else if (components.hour! >= 2) {
        return "\(components.hour!) hours ago"
    } else if (components.hour! >= 1){
        if (numericDates){
            return "1hour ago"
        } else {
            return "An hour ago"
        }
    } else if (components.minute! >= 2) {
        return "\(components.minute!) minutes ago"
    } else if (components.minute! >= 1){
        if (numericDates){
            return "1min ago"
        } else {
            return "A min ago"
        }
    } else if (components.second! >= 3) {
        return "\(components.second!) sec ago"
    } else {
        return "Just now"
    }
}

class HomeVC: UIViewController{
    
    @IBOutlet weak var HomeNewsTV: UITableView!
    var tabBarTitle: String = ""
    var ShowArticle = [NewsArticle]()
    var categoryData = [CategoryList]()
    var sourceData = [SourceList]()
    var categoryResults = [NewsArticle]()
    var isCAt = 0
    var VCIndex = 0
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    var article_id = Int64()
    let activityIndicator = MDCActivityIndicator()
    
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
        // To make the activity indicator disappear:
        // activityIndicator.stopAnimating()
        var paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        print("\(paths[0])")
        let coredataRecordCount = IsCoreDataEmpty()
        if coredataRecordCount != 0{
            FetchDataFromDB()
            HomeNewsTV.reloadData()
        }
        else{
            loadNewsAPI()
            loadSourceAPI()
            loadCategoriesAPI()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        HomeNewsTV.reloadData()
    }
    
    func loadNewsAPI()
    {
        let url = baseURL + "articles/"
        
        Alamofire.request(url,method: .get).responseJSON{
            response in
            if(response.result.isSuccess){
                if let data = response.data {
                    let jsonDecoder = JSONDecoder()
                    do {
                        let jsonData = try jsonDecoder.decode(ArticleStatus.self, from: data)
                        print("jsonData: \(jsonData)")
                        ArticleData = [jsonData]
                        TotalResultcount = ArticleData[0].articles.count
                        self.SaveDataDB()
                        self.FetchDataFromDB()
                        self.HomeNewsTV.reloadData()
                        // self.FetchCategoryArticles()
                    }
                    catch {
                        print("Error: \(error)")
                    }
                }
            }
        }
    }
    
    func loadCategoriesAPI()
    {
        let url = baseURL + "categories"
        
        Alamofire.request(url,method: .get).responseJSON{
            response in
            if(response.result.isSuccess){
                if let data = response.data {
                    let jsonDecoder = JSONDecoder()
                    do {
                        let jsonData = try jsonDecoder.decode(CategoryList.self, from: data)
                        self.categoryData = [jsonData]
                        print(jsonData)
                        self.SaveCatSourceDB()
                    }
                    catch {
                        print("Error: \(error)")
                    }
                }
            }
        }
    }
    
    func loadSourceAPI()
    {
        let url = baseURL + "source"
        
        Alamofire.request(url,method: .get).responseJSON{
            response in
            if(response.result.isSuccess){
                if let data = response.data {
                    let jsonDecoder = JSONDecoder()
                    do {
                        let jsonData = try jsonDecoder.decode(SourceList.self, from: data)
                        self.sourceData = [jsonData]
                    }
                    catch {
                        print("Error: \(error)")
                    }
                }
            }
        }
    }
    
    func IsCoreDataEmpty() -> Int
    {
        let managedContext =
            appDelegate?.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "NewsArticle")
        var records = [NewsArticle]()
        do {
            records = (try managedContext?.fetch(fetchRequest)) as! [NewsArticle]
        }
        catch {
            print("error executing fetch request: \(error)")
        }
        return records.count
    }
    
    //check for existing entry in DB
    func someEntityExists(title: String) -> Bool {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "NewsArticle")
        fetchRequest.predicate = NSPredicate(format: "title = %@",title)
        
        let managedContext =
            appDelegate?.persistentContainer.viewContext
        var results: [NSManagedObject] = []
        
        do {
            results = (try managedContext?.fetch(fetchRequest))!
        }
        catch {
            print("error executing fetch request: \(error)")
        }
        if results.count == 0{
            return false
        }
        else{
            return true
        }
    }
    
    //save articles in DB
    func SaveDataDB()
    {
        let managedContext =
            appDelegate?.persistentContainer.viewContext
        
        if ArticleData.count != 0
        {
            for news in ArticleData[0].articles{
                if  someEntityExists(title: news.title!) == false
                {
                    let newArticle = NewsArticle(context: managedContext!)
                    newArticle.article_id = news.article_id!
                    newArticle.title = news.title
                    newArticle.source_id = news.source_id!
                    newArticle.news_description = news.description
                    newArticle.imageURL = news.imageURL
                    newArticle.source_url = news.url
                    newArticle.published_on = news.published_on
                    newArticle.blurb = news.blurb
                    newArticle.category_id = news.category_id!
                    newArticle.subCategory_id = 0//news.subCategory_id!
                    do {
                        try managedContext?.save()
                        print("successfully saved ..")
                        
                    } catch let error as NSError  {
                        print("Could not save \(error)")
                    }
                }
            }
        }
    }
    
    func SaveCatSourceDB(){
        let managedContext =
            appDelegate?.persistentContainer.viewContext
        
        for cat in categoryData[0].categories{
            print(cat)
            let newCategory = Category(context: managedContext!)
            newCategory.cat_id = cat.cat_id!
            newCategory.name = cat.name
            do {
                try managedContext?.save()
                print("successfully saved ..")
                
            } catch let error as NSError  {
                print("Could not save \(error)")
            }
        }
        
        for source in sourceData[0].source{
            print(source)
            let newSource = Source(context: managedContext!)
            newSource.source_id = source.source_id!
            newSource.source_name = source.source_name
            do {
                try managedContext?.save()
                print("successfully saved ..")
                
            } catch let error as NSError  {
                print("Could not save \(error)")
            }
        }
    }
    
    func FetchDataFromDB()
    {
        let managedContext =
            appDelegate?.persistentContainer.viewContext
        let fetchRequest =
            NSFetchRequest<NewsArticle>(entityName: "NewsArticle")
        // var newArticle = NewsArticle(context: managedContext!)
        do {
            ShowArticle = try (managedContext?.fetch(fetchRequest))!
            TotalResultcount = ShowArticle.count
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func FetchCategoryArticles()
    {
        let managedContext =
            appDelegate?.persistentContainer.viewContext
        let fetchRequest =
            NSFetchRequest<NewsArticle>(entityName: "NewsArticle")
        // let newArticle = NewsArticle(context: managedContext!)
        let name = "Indian Religion"
        fetchRequest.predicate = NSPredicate(format: "categories.title CONTAINS[C] %@", name)
        do {
            categoryResults = try (managedContext?.fetch(fetchRequest))!
            print(categoryResults)
            print(categoryResults.count)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension HomeVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TotalResultcount
        //return categoryResults.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("This cell  was selected: \(indexPath.row)")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newsDetailvc:NewsDetailVC = storyboard.instantiateViewController(withIdentifier: "NewsDetailID") as! NewsDetailVC
        newsDetailvc.articleCount = ArticleData[0].articles.count
        newsDetailvc.article_id = ArticleData[0].articles[indexPath.row].article_id!
        newsDetailvc.ShowArticle = ShowArticle
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
        if ShowArticle.count == 0{
            //display data using API call
            let currentArticle = ArticleData[0].articles[indexPath.row]
            print(currentArticle)
            let newDate = dateFormatter.date(from: currentArticle.published_on!)
            let agoDate = timeAgoSinceDate(newDate!)
            cell.lblNewsHeading.text = currentArticle.title
            //cell.lblSource.text = currentArticle.source_id
            cell.lblTimesAgo.text = agoDate
            cell.imgNews.downloadedFrom(link: "\(currentArticle.imageURL!)")
        }
        else{
            //display data using coredata
            cell.lblNewsHeading.text = ShowArticle[indexPath.row].title
            //cell.lblSource.text = ShowArticle[indexPath.row].source_id
            let newDate = dateFormatter.date(from: ShowArticle[indexPath.row].published_on!)
            let agoDate = timeAgoSinceDate(newDate!)
            cell.lblTimesAgo.text = agoDate
            cell.imgNews.downloadedFrom(link: "\(ShowArticle[indexPath.row].imageURL!)")
        }
        //show data of mentioned category
        /* cell.lblNewsHeading.text = categoryResults[indexPath.row].title
         cell.lblSource.text = categoryResults[indexPath.row].source
         let newDate = dateFormatter.date(from: categoryResults[indexPath.row].publishedAt!)
         let agoDate = timeAgoSinceDate(newDate!)
         cell.lblTimesAgo.text = agoDate
         cell.imgNews.downloadedFrom(link: "\(categoryResults[indexPath.row].imageURL!)")*/
        
        if textSizeSelected == 0{
            cell.lblSource.font = xsmallFont
            cell.lblNewsHeading.font = smallFontMedium
            cell.lblTimesAgo.font = xsmallFont
        }
        else if textSizeSelected == 2{
            cell.lblSource.font = xLargeFont
            cell.lblNewsHeading.font = LargeFontMedium
            cell.lblTimesAgo.font = xLargeFont
        }
        else{
            cell.lblSource.font =  xNormalFont
            cell.lblNewsHeading.font = NormalFontMedium
            cell.lblTimesAgo.font = xNormalFont
        }
        activityIndicator.stopAnimating()
        return cell
    }
}

extension HomeVC: IndicatorInfoProvider{
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: tabBarTitle)
    }
}



