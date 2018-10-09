//
//  SearchVC.swift
//  NewsApp
//
//  Created by Jayashri on 25/09/18.
//  Copyright © 2018 Fafadia Tech. All rights reserved.
//

import UIKit

class SearchVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var searchResultTV: UITableView!
    @IBOutlet weak var btnSearch: UIButton!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var lblTitle: UILabel!
    //variables
     var ArticleData = [Article]()
    override func viewDidLoad() {
        super.viewDidLoad()
         ArticleData = loadJson(filename: "newsDetail")!
        //check whether search or bookmark is selected
        if isSearch == true{
           lblTitle.isHidden = true
            txtSearch.isHidden = false
        }
        else{
            txtSearch.isHidden = true
            lblTitle.isHidden = false
        }
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        changeFont()
        searchResultTV.reloadData() //for tableview
        
    }
    //HIde status bar
    override var prefersStatusBarHidden: Bool {
        return true
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
    func changeFont()
    {
        print(textSizeSelected)
        
        if textSizeSelected == 0{
            lblTitle.font = smallFont
            txtSearch.font = smallFont
        }
        else if textSizeSelected == 2{
            lblTitle.font = LargeFont
             txtSearch.font = LargeFont
        }
        else{
            lblTitle.font = NormalFont
            txtSearch.font = NormalFont
        }
    }
    //Tableview methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return ArticleData.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("This cell  was selected: \(indexPath.row)")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc:NewsDetailVC = storyboard.instantiateViewController(withIdentifier: "NewsDetailID") as! NewsDetailVC
        present(vc, animated: true, completion: nil)
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchResultID", for:indexPath) as! SearchResultTVCell
         var currentArticle = ArticleData[indexPath.row]
        cell.lblSource.text = currentArticle.source
        cell.lbltimeAgo.text = currentArticle.publishedAt
        cell.lblNewsDescription.text = currentArticle.title
        cell.lblCategory.text = currentArticle.categories.first
        cell.imgNews.downloadedFrom(link: "\(currentArticle.urlToImage!)")
        
        if textSizeSelected == 0{
            cell.lblSource.font = smallFont
            cell.lblNewsDescription.font = smallFont
            cell.lblCategory.font = smallFont
            cell.lbltimeAgo.font = smallFont
        }
        else if textSizeSelected == 2{
            cell.lblSource.font = LargeFont
            cell.lblNewsDescription.font = LargeFont
            cell.lblCategory.font = LargeFont
            cell.lbltimeAgo.font = LargeFont
        }
        else{
            cell.lblSource.font = NormalFont
            cell.lblNewsDescription.font = NormalFont
            cell.lblCategory.font = NormalFont
            cell.lbltimeAgo.font = NormalFont
        }
        return cell
    }
    @IBAction func btnSearchAction(_ sender: Any) {
       self.dismiss(animated: false)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
