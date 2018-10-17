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
    // var ArticleData = [Article]()
    var tabBarTitle: String = ""
    var ShowArticle = [NewsArticle]()
    var categoryResults = [NewsArticle]()
    var isCAt = 0
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        print("\(paths[0])")
        let coredataRecordCount = IsCoreDataEmpty()
        if coredataRecordCount != 0{
            FetchDataFromDB()
            HomeNewsTV.reloadData()
        }
        else{
            loadNewsAPI()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func loadNewsAPI()
    {
        let url = "https://api.myjson.com/bins/10kz4w" //"https://api.myjson.com/bins/q2kdg"
        
        Alamofire.request(url,method: .get).responseJSON{
            response in
            if(response.result.isSuccess){
                if let data = response.data {
                    let jsonDecoder = JSONDecoder()
                    do {
                        let jsonData = try jsonDecoder.decode(ArticleStatus.self, from: data)
                        ArticleData = [jsonData]
                        TotalResultcount = jsonData.totalResults!
                        self.SaveDataDB()
                        self.FetchDataFromDB()
                        self.HomeNewsTV.reloadData()
                        self.FetchCategoryArticles()
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
                    newArticle.title = news.title
                    newArticle.source = news.source
                    newArticle.news_description = news.description
                    newArticle.imageURL = news.urlToImage
                    newArticle.url = news.url
                    newArticle.publishedAt = news.publishedAt
                    newArticle.isBookmarked = false
                    newArticle.isLiked = false
                    for category in news.categories!
                    {
                        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Category")
                        fetchRequest.predicate = NSPredicate(format: "title = %@",category)
                        
                        let managedContext =
                            appDelegate?.persistentContainer.viewContext
                        var results: [Category] = []
                        
                        do {
                            results = (try managedContext?.fetch(fetchRequest))! as! [Category]
                            
                        }
                        catch {
                            print("error executing fetch request: \(error)")
                        }
                        if results.count == 0
                        {
                            let newCategory = Category(context: managedContext!)
                            newCategory.title = category
                            newArticle.addToCategories(newCategory)
                        }
                    }
                    print(news.categories)
                    
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
    
    func FetchDataFromDB()
    {
        let managedContext =
            appDelegate?.persistentContainer.viewContext
        let fetchRequest =
            NSFetchRequest<NewsArticle>(entityName: "NewsArticle")
        var newArticle = NewsArticle(context: managedContext!)
        do {
            ShowArticle = try (managedContext?.fetch(fetchRequest))!
            print(ShowArticle.count)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        //categorie as! [Category]
        FetchCategoryArticles()
    }
    func FetchCategoryArticles()
    {
        let managedContext =
            appDelegate?.persistentContainer.viewContext
        let fetchRequest =
            NSFetchRequest<NewsArticle>(entityName: "NewsArticle")
        let newArticle = NewsArticle(context: managedContext!)
        let name = "Indian Religion"
        fetchRequest.predicate = NSPredicate(format: "categories.cat_id CONTAINS[C] %@", name)
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
        // return ShowArticle.count
        return categoryResults.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("This cell  was selected: \(indexPath.row)")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newsDetailvc:NewsDetailVC = storyboard.instantiateViewController(withIdentifier: "NewsDetailID") as! NewsDetailVC
        currentIndex = indexPath.row
        newsDetailvc.ShowArticle = ShowArticle
        print("currentIndex: \(currentIndex)")
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
        /* if ShowArticle.count == 0{
         //display data using API call
         let currentArticle = ArticleData[0].articles[indexPath.row]
         print(currentArticle)
         let newDate = dateFormatter.date(from: currentArticle.publishedAt!)
         print("newDAte:\(newDate!)")
         let agoDate = timeAgoSinceDate(newDate!)
         cell.lblNewsHeading.text = currentArticle.title
         cell.lblSource.text = currentArticle.source
         cell.lblTimesAgo.text = agoDate
         cell.imgNews.downloadedFrom(link: "\(currentArticle.urlToImage!)")
         }
         else{
         //display data using coredata
         cell.lblNewsHeading.text = ShowArticle[indexPath.row].title
         cell.lblSource.text = ShowArticle[indexPath.row].source
         let newDate = dateFormatter.date(from: ShowArticle[indexPath.row].publishedAt!)
         print("newDAte:\(newDate!)")
         let agoDate = timeAgoSinceDate(newDate!)
         cell.lblTimesAgo.text = agoDate
         cell.imgNews.downloadedFrom(link: "\(ShowArticle[indexPath.row].imageURL!)")
         }*/
        //show data of mentioned category
        cell.lblNewsHeading.text = categoryResults[indexPath.row].title
        cell.lblSource.text = categoryResults[indexPath.row].source
        let newDate = dateFormatter.date(from: categoryResults[indexPath.row].publishedAt!)
        print("newDAte:\(newDate!)")
        let agoDate = timeAgoSinceDate(newDate!)
        cell.lblTimesAgo.text = agoDate
        cell.imgNews.downloadedFrom(link: "\(categoryResults[indexPath.row].imageURL!)")
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
            cell.lblSource.font =  xNormalFont//.systemFont(ofSize: Constants.fontNormalTitle) //
            cell.lblNewsHeading.font = NormalFontMedium
            cell.lblTimesAgo.font = xNormalFont
        }
        return cell
    }
}

extension HomeVC: IndicatorInfoProvider{
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: tabBarTitle)
    }
}
