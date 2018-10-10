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
    @IBOutlet weak var lblHeading: UILabel!
    
    //variables
    var ArticleData = [Article]()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        ArticleData = loadJson(filename: "news")!
        let floaty = Floaty()
        floaty.itemTitleColor = .blue
       
       // floaty.buttonImage = UIImage(named: "floatingMenu")
        floaty.addItem("Search", icon: UIImage(named: "search")!) { item in
            floaty.autoCloseOnTap = true
            isSearch = true
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let searchvc:SearchVC = storyboard.instantiateViewController(withIdentifier: "SearchID") as! SearchVC
            self.present(searchvc, animated: true, completion: nil)
          }
        floaty.addItem("Settings", icon: UIImage(named: "settings")!) { item in
            floaty.autoCloseOnTap = true
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let settingvc:SettingsVC = storyboard.instantiateViewController(withIdentifier: "SettingsID") as! SettingsVC
            self.present(settingvc, animated: true, completion: nil)
            
        }
        floaty.addItem("Bookmark", icon: UIImage(named: "bookmark")!) { item in
            floaty.autoCloseOnTap = true
            isSearch = false
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let settingvc:SearchVC = storyboard.instantiateViewController(withIdentifier: "SearchID") as! SearchVC
            self.present(settingvc, animated: true, completion: nil)
            
        }
        self.view.addSubview(floaty)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
            changeFont()
            HomeNewsTV.reloadData() //for tableview
        
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Child")
    }
    
    //Load data to be displayed from json file
    func loadJson(filename fileName: String) -> [Article]?
    {
        if let url = Bundle.main.url(forResource: fileName, withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let jsonData = try decoder.decode(ArticleStatus.self, from: data)
                
                print("jsondata: \(jsonData)")
                
                return jsonData.articles
            } catch {
                print("error:\(error)")
            }
        }
        return nil
    }
    
    //change font on text size change
    func changeFont()
    {
        print(textSizeSelected)
        
        if textSizeSelected == 0{
        lblHeading.font = smallFontMedium
        }
        else if textSizeSelected == 2{
            lblHeading.font = LargeFontMedium
        }
        else{
           // lblHeading.font = NormalFontMedium
        }

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
            print(cell.lblSource.font.fontName)
            print(cell.lblNewsHeading.font.fontName)
            print(cell.lblCategory.font.fontName)
            print(cell.lblTimesAgo.font.fontName)
        }
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

