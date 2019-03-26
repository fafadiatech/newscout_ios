//
//  SourceVC.swift
//  NewsApp
//
//  Created by Jayashree on 26/03/19.
//  Copyright © 2019 Fafadia Tech. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialActivityIndicator
import NightNight
import SDWebImage

class SourceVC: UIViewController {
    @IBOutlet weak var lblBookmark: UILabel!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var bookmarkResultTV: UITableView!
    @IBOutlet weak var btnBack: UIButton!
    var url = ""
    let textSizeSelected = UserDefaults.standard.value(forKey: "textSize") as! Int
     let activityIndicator = MDCActivityIndicator()
     var ShowArticle = [ArticleStatus]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(darkModeEnabled(_:)), name: .darkModeEnabled, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(darkModeDisabled(_:)), name: .darkModeDisabled, object: nil)
        activityIndicator.cycleColors = [.blue]
        activityIndicator.frame = CGRect(x: view.frame.width/2, y: view.frame.height/2 - 100, width: 40, height: 40)
        activityIndicator.sizeToFit()
        activityIndicator.indicatorMode = .indeterminate
        activityIndicator.progress = 2.0
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        // Do any additional setup after loading the view.
    }
    @objc private func darkModeEnabled(_ notification: Notification) {
        NightNight.theme = .night
        bookmarkResultTV.backgroundColor = colorConstants.grayBackground3
    }
    
    @objc private func darkModeDisabled(_ notification: Notification){
        NightNight.theme = .normal
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .darkModeEnabled, object: nil)
        NotificationCenter.default.removeObserver(self, name: .darkModeDisabled, object: nil)
    }
    func loadSourceARticles(){
        APICall().loadSearchAPI(url : url){
            (status, response)  in
            switch response {
            case .Success(let data) :
                self.ShowArticle = data
            case .Failure(let errormessage) :
                print(errormessage)
            case .Change(let code):
                print(code)
            }
    }
}
}

extension SourceVC: UITableViewDelegate, UITableViewDataSource{
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return (ShowArticle.count != 0) ? ShowArticle.count : 0
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let newsDetailvc:NewsDetailVC = storyboard.instantiateViewController(withIdentifier: "NewsDetailID") as! NewsDetailVC
//            newsDetailvc.newsCurrentIndex = indexPath.row
//            newsDetailvc.ShowArticle = ShowArticle
//            UserDefaults.standard.set("bookmark", forKey: "isSearch")
//            newsDetailvc.articleId = Int(ShowArticle[indexPath.row].article_id)
//            present(newsDetailvc, animated: true, completion: nil)
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "bookmarkResultID", for:indexPath) as! BookmarkTVCell
            let borderColor: UIColor = UIColor.lightGray
            cell.ViewCellBackground.layer.borderColor = borderColor.cgColor
            cell.ViewCellBackground.layer.borderWidth = 1
            cell.ViewCellBackground.layer.cornerRadius = 10.0
            cell.imgNews.layer.cornerRadius = 10.0
            cell.imgNews.clipsToBounds = true
            cell.lblSource.textColor = colorConstants.txtDarkGrayColor
            cell.lbltimeAgo.textColor = colorConstants.txtDarkGrayColor
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            dateFormatter.timeZone = NSTimeZone.local
          
            let currentArticle = ArticleStatus.self
                cell.lblSource.text = currentArticle.source
                let newDate = dateFormatter.date(from: currentArticle.published_on!)
                let agoDate = Helper().timeAgoSinceDate(newDate!)
                cell.lbltimeAgo.text = agoDate
                cell.lblNewsDescription.text = currentArticle.title
                cell.imgNews.sd_setImage(with: URL(string: currentArticle.imageURL!), placeholderImage: nil, options: SDWebImageOptions.refreshCached)
         
            
            if textSizeSelected == 0{
                cell.lblSource.font = FontConstants.smallFontContent
                cell.lbltimeAgo.font = FontConstants.smallFontContent
                cell.lblNewsDescription.font = FontConstants.smallFontHeadingBold
                
            }
            else if textSizeSelected == 2{
                cell.lblSource.font = FontConstants.LargeFontContent
                cell.lbltimeAgo.font = FontConstants.LargeFontContent
                cell.lblNewsDescription.font = FontConstants.LargeFontHeadingBold
            }
            else{
                cell.lblSource.font = FontConstants.NormalFontContent
                cell.lbltimeAgo.font = FontConstants.NormalFontContent
                cell.lblNewsDescription.font = FontConstants.NormalFontHeadingBold
            }
            let darkModeStatus = UserDefaults.standard.value(forKey: "darkModeEnabled") as! Bool
            if  darkModeStatus == true{
                cell.ViewCellBackground.backgroundColor = colorConstants.grayBackground2
                cell.lblSource.textColor = colorConstants.nightModeText
                cell.lbltimeAgo.textColor = colorConstants.nightModeText
                cell.lblNewsDescription.textColor = colorConstants.nightModeText
                NightNight.theme =  .night
            }
            else{
                NightNight.theme =  .normal
            }
            if cell.imgNews.image == nil{
                cell.imgNews.image = UIImage(named: AssetConstants.NoImage)
            }
            activityIndicator.stopAnimating()
            return cell
}
}

