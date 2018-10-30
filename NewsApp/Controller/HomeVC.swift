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
        let coredataRecordCount = DBManager().IsCoreDataEmpty()
        if coredataRecordCount != 0{
            let result = DBManager().FetchDataFromDB()
            switch result {
            case .Success(let DBData) :
                let articles = DBData
                if selectedCat == "FOR YOU" || selectedCat == "All News"
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
            //HomeNewsTV.reloadData()
        }
        else{
            DBManager().SaveDataDB{response in
                if response == true{
                    let result = DBManager().FetchDataFromDB()
                    switch result {
                    case .Success(let DBData) :
                        let articles = DBData
                        if selectedCat == "FOR YOU" || selectedCat == "All News"
                        {
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
        }
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
            print ("results val: \(self.ShowArticle)")
            TotalResultcount = self.ShowArticle.count
           // self.HomeNewsTV.reloadData()
        }
        catch {
            print("error executing fetch request: \(error)")
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        if selectedCat == "" || selectedCat == "FOR YOU" || selectedCat == "All News"
//        {
//            self.filterNews(selectedCat: "all news" )
//        }else{
//            self.filterNews(selectedCat: selectedCat )
//        }
       // self.HomeNewsTV.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension HomeVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if ShowArticle.count == 0
        {
            let alertController = UIAlertController(title: "There is not any article found in this category...", message: "", preferredStyle: .alert)
            let action1 = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in }
            alertController.addAction(action1)
            self.present(alertController, animated: true, completion: nil)
        }
        activityIndicator.stopAnimating()
        return TotalResultcount
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("This cell  was selected: \(indexPath.row)")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newsDetailvc:NewsDetailVC = storyboard.instantiateViewController(withIdentifier: "NewsDetailID") as! NewsDetailVC
        newsCurrentIndex = indexPath.row
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
        //display data using coredata
        cell.lblNewsHeading.text = ShowArticle[indexPath.row].title
        cell.lblSource.text = ShowArticle[indexPath.row].source
        let newDate = dateFormatter.date(from: ShowArticle[indexPath.row].published_on!)
        let agoDate = timeAgoSinceDate(newDate!)
        cell.lblTimesAgo.text = agoDate
        cell.imgNews.downloadedFrom(link: "\(ShowArticle[indexPath.row].imageURL!)")
        
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



