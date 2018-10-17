//
//  SearchVC.swift
//  NewsApp
//
//  Created by Jayashri on 25/09/18.
//  Copyright © 2018 Fafadia Tech. All rights reserved.
//

import UIKit
import Alamofire
import CoreData

class SearchVC: UIViewController {
    @IBOutlet weak var searchResultTV: UITableView!
    @IBOutlet weak var btnSearch: UIButton!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var lblTitle: UILabel!
    //variables
    var ArticleData = [Article]()
    var count = 0
    var SearchData = [ArticleStatus]()
    var results: [NewsArticle] = []
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadSearchAPI()
        lblTitle.font = LargeFontMedium
        //ArticleData = loadJson(filename: "news")!
        //check whether search or bookmark is selected
        if isSearch == true{
            lblTitle.isHidden = true
            txtSearch.isHidden = false
        }
        else{
            txtSearch.isHidden = true
            lblTitle.isHidden = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        changeFont()
        searchResultTV.reloadData() //for tableview
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func loadSearchAPI()
    {
        let url = "https://api.myjson.com/bins/q2kdg"
        Alamofire.request(url,method: .get).responseJSON{
            response in
            if(response.result.isSuccess){
                if let data = response.data {
                    let jsonDecoder = JSONDecoder()
                    do {
                        let jsonData = try jsonDecoder.decode(ArticleStatus.self, from: data)
                        self.SearchData = [jsonData]
                        self.count = jsonData.totalResults!                        //self.ArticleData = try [jsonDecodeç.decode(ArticleStatus.self, from: data)]
                        // print("self.AData: \(self.ArticleData)")
                        // print("self.AData: \(self.ArticleData.count)")
                        self.searchResultTV.reloadData()
                        print("jsonData: \(jsonData)")
                        
                    }
                    catch {
                        print("Error: \(error)")
                    }
                }
            }
        }
    }
    
    func changeFont()
    {
        print(textSizeSelected)
        
        if textSizeSelected == 0{
            lblTitle.font = NormalFontMedium
            txtSearch.font = NormalFontMedium
        }
        else if textSizeSelected == 2{
            lblTitle.font = LargeFontMedium
            txtSearch.font = LargeFontMedium
        }
        else{
            lblTitle.font = LargeFontMedium
            txtSearch.font = LargeFontMedium
        }
    }
    
    @IBAction func btnSearchAction(_ sender: Any) {
        self.dismiss(animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension SearchVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("This cell  was selected: \(indexPath.row)")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc:NewsDetailVC = storyboard.instantiateViewController(withIdentifier: "NewsDetailID") as! NewsDetailVC
        present(vc, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchResultID", for:indexPath) as! SearchResultTVCell
        let borderColor: UIColor = UIColor.lightGray
        cell.ViewCellBackground.layer.borderColor = borderColor.cgColor
        cell.ViewCellBackground.layer.borderWidth = 1
        cell.ViewCellBackground.layer.cornerRadius = 10.0
        cell.imgNews.layer.cornerRadius = 10.0
        cell.imgNews.clipsToBounds = true
        let currentArticle = results[indexPath.row]
        cell.lblSource.text = currentArticle.source
        cell.lbltimeAgo.text = currentArticle.publishedAt
        cell.lblNewsDescription.text = currentArticle.title
        cell.imgNews.downloadedFrom(link: "\(currentArticle.imageURL!)")
        
        if textSizeSelected == 0{
            cell.lblSource.font = xsmallFont
            cell.lblNewsDescription.font = smallFontMedium
            cell.lbltimeAgo.font = xsmallFont
        }
        else if textSizeSelected == 2{
            cell.lblSource.font = xLargeFont
            cell.lblNewsDescription.font = LargeFontMedium
            cell.lbltimeAgo.font = xLargeFont
        }
        else{
            cell.lblSource.font = xNormalFont
            cell.lblNewsDescription.font = NormalFontMedium
            cell.lbltimeAgo.font = xNormalFont
        }
        return cell
    }
}

extension SearchVC: UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        txtSearch.resignFirstResponder()
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "NewsArticle")
        fetchRequest.predicate = NSPredicate(format: "title CONTAINS[c] %@ OR news_description CONTAINS[c] %@",txtSearch.text!, txtSearch.text!)
        let managedContext =
            appDelegate?.persistentContainer.viewContext
        do {
            results = (try managedContext?.fetch(fetchRequest))! as! [NewsArticle]
            print("result.count: \(results.count)")
            print ("results val: \(results)")
            searchResultTV.reloadData()
        }
        catch {
            print("error executing fetch request: \(error)")
        }
        return true
    }
}
