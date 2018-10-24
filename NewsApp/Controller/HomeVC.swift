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
                self.ShowArticle = DBData
                TotalResultcount = self.ShowArticle.count
                self.HomeNewsTV.reloadData()
            case .Failure(let errorMsg) :
                print(errorMsg)
            }
            HomeNewsTV.reloadData()
        }
        else{
            APICall().loadNewsAPI{ response in
                switch response {
                case .Success(let data) :
                    ArticleData = data
                    print(data)
                    TotalResultcount = ArticleData[0].articles.count
                    DBManager().SaveDataDB()
                    let result = DBManager().FetchDataFromDB()
                    switch result {
                    case .Success(let DBData) :
                        self.ShowArticle = DBData
                        TotalResultcount = self.ShowArticle.count
                        self.HomeNewsTV.reloadData()
                    case .Failure(let errorMsg) :
                        print(errorMsg)
                    }
                case .Failure(let errormessage) :
                    print(errormessage)
                    // handle the error
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        HomeNewsTV.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension HomeVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
        if ShowArticle.count == 0{
            //display data using API call
            let currentArticle = ArticleData[0].articles[indexPath.row]
            print(currentArticle)
            let newDate = dateFormatter.date(from: currentArticle.published_on!)
            let agoDate = timeAgoSinceDate(newDate!)
            cell.lblNewsHeading.text = currentArticle.title
            cell.lblSource.text = currentArticle.source
            cell.lblTimesAgo.text = agoDate
            cell.imgNews.downloadedFrom(link: "\(currentArticle.imageURL!)")
        }
        else{
            //display data using coredata
            cell.lblNewsHeading.text = ShowArticle[indexPath.row].title
            cell.lblSource.text = ShowArticle[indexPath.row].source
            let newDate = dateFormatter.date(from: ShowArticle[indexPath.row].published_on!)
            let agoDate = timeAgoSinceDate(newDate!)
            cell.lblTimesAgo.text = agoDate
            cell.imgNews.downloadedFrom(link: "\(ShowArticle[indexPath.row].imageURL!)")
        }
        
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



