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

class HomeVC: UIViewController, UITableViewDelegate, UITableViewDataSource, FloatyDelegate, IndicatorInfoProvider{
    //outlets
    @IBOutlet weak var HomeNewsTV: UITableView!

    //variables
   // var ArticleData = [Article]()
     var tabBarTitle: String = ""
   
    var count = 0
    override func viewDidLoad() {
        super.viewDidLoad()
         loadNewsAPI()
        //ArticleData = loadJson(filename: "news")!
     }
  
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        HomeNewsTV.reloadData() //for tableview
    }
  
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: tabBarTitle)

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
        let url = "https://api.myjson.com/bins/q2kdg"
        
        Alamofire.request(url,method: .get).responseJSON{
            response in
            if(response.result.isSuccess){
                if let data = response.data {
                    let jsonDecoder = JSONDecoder()
                    do {
                         //let jsonData
                        let jsonData = try jsonDecoder.decode(ArticleStatus.self, from: data)
                        ArticleData = [jsonData]
                        self.count = jsonData.totalResults!                        //self.ArticleData = try [jsonDecodeç.decode(ArticleStatus.self, from: data)]
                       // print("self.AData: \(self.ArticleData)")
                       // print("self.AData: \(self.ArticleData.count)")
                        self.HomeNewsTV.reloadData()
                        print("jsonData: \(jsonData)")
                        
                    }
                    catch {
                        print("Error: \(error)")
                    }
                }
            }
        }
       
    }
    //HIde status bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //Tableview methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return count
        
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
        var currentArticle = ArticleData[0].articles[indexPath.row]
        print(currentArticle)
        cell.lblNewsHeading.text = currentArticle.title
        cell.lblSource.text = currentArticle.source
        cell.lblCategory.text = currentArticle.categories?.first
        cell.lblTimesAgo.text = currentArticle.publishedAt
        cell.imgNews.downloadedFrom(link: "\(currentArticle.urlToImage!)")
        
        
        if textSizeSelected == 0{
            cell.lblSource.font = smallFontMedium
             cell.lblNewsHeading.font = smallFont
             cell.lblCategory.font = smallFont
             cell.lblTimesAgo.font = smallFont
            }
        else if textSizeSelected == 2{
            cell.lblSource.font = LargeFontMedium
            cell.lblNewsHeading.font = LargeFont
            cell.lblCategory.font = LargeFont
            cell.lblTimesAgo.font = LargeFont
        }
        else{
            cell.lblSource.font = NormalFontMedium //.systemFont(ofSize: Constants.fontNormalTitle) //
            cell.lblNewsHeading.font = NormalFont
            cell.lblCategory.font = NormalFont
            cell.lblTimesAgo.font = NormalFont
        }
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

