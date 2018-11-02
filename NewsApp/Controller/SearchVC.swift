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
    var count = 0
    var ArticleData = [ArticleStatus]()
    var SearchData = [ArticleStatus]()
    var results: [NewsArticle] = []
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblTitle.font = Constants.LargeFontMedium
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
    
    func changeFont()
    {
        print(textSizeSelected)
        
        if textSizeSelected == 0{
            lblTitle.font = Constants.NormalFontMedium
            txtSearch.font = Constants.NormalFontMedium
        }
        else if textSizeSelected == 2{
            lblTitle.font = Constants.LargeFontMedium
            txtSearch.font = Constants.LargeFontMedium
        }
        else{
            lblTitle.font = Constants.LargeFontMedium
            txtSearch.font = Constants.LargeFontMedium
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
        return count
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
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.timeZone = NSTimeZone(name: "UTC")! as TimeZone
        
        let currentArticle = SearchData[0].body.articles[indexPath.row]
        cell.lblSource.text = currentArticle.source
        let newDate = dateFormatter.date(from: currentArticle.published_on!)
        let agoDate = timeAgoSinceDate(newDate!)
        cell.lbltimeAgo.text = agoDate
        cell.lblNewsDescription.text = currentArticle.title
        cell.imgNews.downloadedFrom(link: "\(currentArticle.imageURL!)")
        //
        if textSizeSelected == 0{
            cell.lblSource.font = Constants.xsmallFont
            cell.lblNewsDescription.font = Constants.smallFontMedium
            cell.lbltimeAgo.font = Constants.xsmallFont
        }
        else if textSizeSelected == 2{
            cell.lblSource.font = Constants.xLargeFont
            cell.lblNewsDescription.font = Constants.LargeFontMedium
            cell.lbltimeAgo.font = Constants.xLargeFont
        }
        else{
            cell.lblSource.font = Constants.xNormalFont
            cell.lblNewsDescription.font = Constants.NormalFontMedium
            cell.lbltimeAgo.font = Constants.xNormalFont
        }
        return cell
    }
}

extension SearchVC: UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        txtSearch.resignFirstResponder()
        APICall().loadSearchAPI(searchTxt: txtSearch.text!){ response in
            switch response {
            case .Success(let data) :
                self.ArticleData = data
                print(data)
                self.count = self.ArticleData[0].body.articles.count
                self.searchResultTV.reloadData()
            case .Failure(let errormessage) :
                print(errormessage)
                // handle the error
            }
        }
        // search text in DB
        /*   let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "NewsArticle")
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
         
         }*/
        return true
    }
}
