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

class HomeVC: UIViewController, UITableViewDelegate, UITableViewDataSource, FloatyDelegate, IndicatorInfoProvider{
    //outlets
    @IBOutlet weak var HomeNewsTV: UITableView!

    //variables
    var ArticleData = [Article]()
     var tabBarTitle: String = ""
  
    override func viewDidLoad() {
        super.viewDidLoad()
        ArticleData = loadJson(filename: "news")!
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
    
    
    //HIde status bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //Tableview methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ArticleData.count
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
        var currentArticle = ArticleData[indexPath.row]
        cell.lblNewsHeading.text = currentArticle.title
        cell.lblSource.text = currentArticle.source
        cell.lblCategory.text = currentArticle.categories.first
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

