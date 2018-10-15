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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //HomeNewsTV.contentInset = UIEdgeInsetsMake(10,-10,10,-10)
        loadNewsAPI()
        //ArticleData = loadJson(filename: "news")!
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        HomeNewsTV.reloadData() //for tableview
    }
    
    //Load data to be displayed from json file
    func loadJson(filename fileName: String) -> [Article]?
    {
        if let url = Bundle.main.url(forResource: fileName, withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let jsonData = try decoder.decode(ArticleStatus.self, from: data)
                return jsonData.articles
            } catch {
                print("error:\(error)")
            }
        }
        return nil
    }
    
    func loadNewsAPI()
    {
        let url = "https://api.myjson.com/bins/pmyq0" //"https://api.myjson.com/bins/q2kdg"
        
        Alamofire.request(url,method: .get).responseJSON{
            response in
            if(response.result.isSuccess){
                if let data = response.data {
                    let jsonDecoder = JSONDecoder()
                    do {
                        //let jsonData
                        let jsonData = try jsonDecoder.decode(ArticleStatus.self, from: data)
                        ArticleData = [jsonData]
                        TotalResultcount = jsonData.totalResults!                        //self.ArticleData = try [jsonDecodeç.decode(ArticleStatus.self, from: data)]
                        // print("self.AData: \(self.ArticleData)")
                        // print("self.AData: \(self.ArticleData.count)")
                        self.HomeNewsTV.reloadData()
                    }
                    catch {
                        print("Error: \(error)")
                    }
                }
            }
        }
    }
   
    override var prefersStatusBarHidden: Bool {
        return true
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
        let vc:NewsDetailVC = storyboard.instantiateViewController(withIdentifier: "NewsDetailID") as! NewsDetailVC
        currentIndex = indexPath.row
        print("currentIndex: \(currentIndex)")
        present(vc, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeNewsTVCellID", for:indexPath) as! HomeNewsTVCell
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 10.0
        //cell.layer.masksToBounds = true
         cell.imgNews.layer.cornerRadius = 10.0
        cell.imgNews.clipsToBounds = true
        //cell.imgNews.layer.cornerRadius = 5
        var currentArticle = ArticleData[0].articles[indexPath.row]
        print(currentArticle)
        //timestamp conversion
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.timeZone = NSTimeZone(name: "UTC")! as TimeZone
        let newDate = dateFormatter.date(from: currentArticle.publishedAt!)
        print("newDAte:\(newDate!)")
        let agoDate = timeAgoSinceDate(newDate!)
        //
        cell.lblNewsHeading.text = currentArticle.title
        cell.lblSource.text = currentArticle.source
        cell.lblTimesAgo.text = agoDate
        cell.imgNews.downloadedFrom(link: "\(currentArticle.urlToImage!)")
        
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
