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
    
    @IBOutlet weak var lblSource: UILabel!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var sourceTV: UITableView!
    @IBOutlet weak var btnBack: UIButton!
    
    var url = ""
    var source = ""
    let textSizeSelected = UserDefaults.standard.value(forKey: "textSize") as! Int
    let activityIndicator = MDCActivityIndicator()
    var ShowArticle = [ArticleStatus]()
    var imgWidth = ""
    var imgHeight = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        sourceTV.tableFooterView = UIView(frame: .zero)
        lblSource.text = source
        titleView.backgroundColor = colorConstants.redColor
        NotificationCenter.default.addObserver(self, selector: #selector(darkModeEnabled(_:)), name: .darkModeEnabled, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(darkModeDisabled(_:)), name: .darkModeDisabled, object: nil)
        activityIndicator.cycleColors = [.blue]
        activityIndicator.frame = CGRect(x: view.frame.width/2, y: view.frame.height/2 - 100, width: 40, height: 40)
        activityIndicator.sizeToFit()
        activityIndicator.indicatorMode = .indeterminate
        activityIndicator.progress = 2.0
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        loadSourceArticles()
        // Do any additional setup after loading the view.
    }
    @objc private func darkModeEnabled(_ notification: Notification) {
        NightNight.theme = .night
        sourceTV.backgroundColor = colorConstants.grayBackground3
    }
    
    @objc private func darkModeDisabled(_ notification: Notification){
        NightNight.theme = .normal
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .darkModeEnabled, object: nil)
        NotificationCenter.default.removeObserver(self, name: .darkModeDisabled, object: nil)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func loadSourceArticles(){
        APICall().loadSearchAPI(url : url){
            (status, response)  in
            switch response {
            case .Success(let data) :
                self.ShowArticle = data
                self.sourceTV.reloadData()
                self.activityIndicator.stopAnimating()
            case .Failure(let errormessage) :
                print(errormessage)
            case .Change(let code):
                print(code)
            }
        }
    }
    
    @IBAction func btnBackActn(_ sender: Any) {
        self.dismiss(animated: false)
    }
    
}

extension SourceVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (ShowArticle.count > 0) ? (ShowArticle[0].body?.articles.count)!  : 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let newsDetailvc:NewsDetailVC = storyboard.instantiateViewController(withIdentifier: "NewsDetailID") as! NewsDetailVC
            newsDetailvc.newsCurrentIndex = indexPath.row
            newsDetailvc.sourceArticle = (ShowArticle[0].body?.articles)!
            newsDetailvc.articleId = (ShowArticle[0].body?.articles[indexPath.row].article_id)!
            UserDefaults.standard.set("source", forKey: "isSearch")
            present(newsDetailvc, animated: true, completion: nil)
            sourceTV.deselectRow(at: indexPath, animated: true)
        }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       /* let borderColor: UIColor = UIColor.lightGray
        
        cell.imgNews.layer.cornerRadius = 10.0
        cell.imgNews.clipsToBounds = true
        cell.lblSource.textColor = colorConstants.txtDarkGrayColor
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.timeZone = NSTimeZone.local
        
        var currentArticle = ShowArticle[0].body?.articles[indexPath.row]
        var dateSubString = ""
        if ((currentArticle!.published_on?.count)!) <= 20{
            if !(currentArticle!.published_on?.contains("Z"))!{
                currentArticle!.published_on?.append("Z")
            }
            let newDate = dateFormatter.date(from: currentArticle!.published_on!)
            if newDate != nil{
                let agoDate = try Helper().timeAgoSinceDate(newDate!)
            }
        }
        else{
            dateSubString = String(currentArticle!.published_on!.prefix(19))
            if !(dateSubString.contains("Z")){
                dateSubString.append("Z")
            }
            let newDate = dateFormatter.date(from: dateSubString
            )
            if newDate != nil{
                let agoDate = try Helper().timeAgoSinceDate(newDate!)
            }
        }
        cell.lblSource.text = currentArticle?.source
        cell.lblNewsDescription.text = currentArticle?.title
        cell.imgNews.sd_setImage(with: URL(string: currentArticle!.imageURL!), placeholderImage: nil, options: SDWebImageOptions.refreshCached)
        
        
        if textSizeSelected == 0{
            cell.lblSource.font = FontConstants.smallFontContent
            cell.lblNewsDescription.font = FontConstants.smallFontHeadingBold
            
        }
        else if textSizeSelected == 2{
            cell.lblSource.font = FontConstants.LargeFontContent
            cell.lblNewsDescription.font = FontConstants.LargeFontHeadingBold
        }
        else{
            cell.lblSource.font = FontConstants.NormalFontContent
            cell.lblNewsDescription.font = FontConstants.NormalFontHeadingBold
        }
        let darkModeStatus = UserDefaults.standard.value(forKey: "darkModeEnabled") as! Bool
        if  darkModeStatus == true{
            cell.ViewCellBackground.backgroundColor = colorConstants.grayBackground2
            cell.lblSource.textColor = colorConstants.nightModeText
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
        return cell*/
        let cell = tableView.dequeueReusableCell(withIdentifier: "sourceID", for:indexPath) as! sourceTVCell
        let cellOdd = tableView.dequeueReusableCell(withIdentifier: "sourceZigzagID", for:indexPath) as! sourceZigzagTVCell
        imgWidth = String(describing : Int(cell.imgNews.frame.width))
        imgHeight = String(describing : Int(cell.imgNews.frame.height))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.timeZone = NSTimeZone.local
        let darkModeStatus = UserDefaults.standard.value(forKey: "darkModeEnabled") as! Bool
        let textSizeSelected = UserDefaults.standard.value(forKey: "textSize") as! Int
        var sourceColor = UIColor()
        var fullTxt = ""
        var dateSubString = ""
        var agoDate = ""
        if indexPath.row % 2 != 0{
            
            cell.imgNews.layer.cornerRadius = 10.0
            cell.imgNews.clipsToBounds = true
            
            //display data from DB
           var currentArticle = ShowArticle[0].body?.articles[indexPath.row]
            cell.lblNewsDescription.text = currentArticle!.title
            
            if  darkModeStatus == true{
                cell.ViewCellBackground.backgroundColor = colorConstants.grayBackground2
                cell.lblSource.textColor = colorConstants.nightModeText
                cell.lblNewsDescription.textColor = colorConstants.nightModeText
                NightNight.theme =  .night
            }
            else{
                cell.ViewCellBackground.backgroundColor = .white
                cell.lblSource.textColor = colorConstants.blackColor
                cell.lblNewsDescription.textColor = colorConstants.blackColor
                NightNight.theme =  .normal
            }
            
            if ((currentArticle!.published_on?.count)!) <= 20{
                if !(currentArticle!.published_on?.contains("Z"))!{
                    currentArticle!.published_on?.append("Z")
                }
                let newDate = dateFormatter.date(from: currentArticle!.published_on!)
                if newDate != nil{
                    agoDate = try Helper().timeAgoSinceDate(newDate!)
                    fullTxt = "\(agoDate)" + " via " + currentArticle!.source!
                    let attributedWithTextColor: NSAttributedString = fullTxt.attributedStringWithColor([currentArticle!.source!], color: UIColor.red)
                    cell.lblSource.attributedText = attributedWithTextColor
                }
            }
            else{
                dateSubString = String(currentArticle!.published_on!.prefix(19))
                if !(dateSubString.contains("Z")){
                    dateSubString.append("Z")
                }
                let newDate = dateFormatter.date(from: dateSubString
                )
                if newDate != nil{
                    agoDate = try Helper().timeAgoSinceDate(newDate!)
                    fullTxt = "\(agoDate)" + " via " + currentArticle!.source!
                    let attributedWithTextColor: NSAttributedString = fullTxt.attributedStringWithColor([currentArticle!.source!], color: UIColor.red)
                    cell.lblSource.attributedText = attributedWithTextColor
                }
            }
            let imgURL = APPURL.imageServer + imgWidth + "x" + imgHeight + "/smart/" + currentArticle!.imageURL!
            cell.imgNews.sd_setImage(with: URL(string: imgURL), placeholderImage: nil, options: SDWebImageOptions.refreshCached)
            
            if textSizeSelected == 0{
                cell.lblSource.font = FontConstants.smallFontContent
                cell.lblNewsDescription.font = FontConstants.smallFontHeadingBold
            }
            else if textSizeSelected == 2{
                cell.lblSource.font = FontConstants.LargeFontContent
                cell.lblNewsDescription.font = FontConstants.LargeFontHeadingBold
            }
            else{
                cell.lblSource.font =  FontConstants.NormalFontContent
                cell.lblNewsDescription.font = FontConstants.NormalFontHeadingBold
            }
            
            if cell.imgNews.image == nil{
                cell.imgNews.image = UIImage(named: AssetConstants.NoImage)
            }
            
            activityIndicator.stopAnimating()
            //lblNonews.isHidden = true
            return cell
        }
        else{
            
            cellOdd.imgNews.layer.cornerRadius = 10.0
            cellOdd.imgNews.clipsToBounds = true
            //display data from DB
            var currentArticle = ShowArticle[0].body?.articles[indexPath.row]
            cellOdd.lblNewsDescription.text = currentArticle!.title
    
            if  darkModeStatus == true{
                cellOdd.ViewCellBackground.backgroundColor = colorConstants.grayBackground2
                cellOdd.lblSource.textColor = colorConstants.nightModeText
                cellOdd.lblNewsDescription.textColor = colorConstants.nightModeText
                NightNight.theme =  .night
            }
            else{
                cellOdd.ViewCellBackground.backgroundColor = .white
                cellOdd.lblSource.textColor = colorConstants.blackColor
                cellOdd.lblNewsDescription.textColor = colorConstants.blackColor
                NightNight.theme =  .normal
            }
            
            if ((currentArticle!.published_on?.count)!) <= 20{
                if !(currentArticle!.published_on?.contains("Z"))!{
                    currentArticle!.published_on?.append("Z")
                }
                let newDate = dateFormatter.date(from: currentArticle!.published_on!)
                if newDate != nil{
                    agoDate = try Helper().timeAgoSinceDate(newDate!)
                    fullTxt = "\(agoDate)" + " via " + currentArticle!.source!
                    let attributedWithTextColor: NSAttributedString = fullTxt.attributedStringWithColor([currentArticle!.source!], color: UIColor.red)
                    cellOdd.lblSource.attributedText = attributedWithTextColor
                }
            }
            else{
                dateSubString = String(currentArticle!.published_on!.prefix(19))
                if !(dateSubString.contains("Z")){
                    dateSubString.append("Z")
                }
                let newDate = dateFormatter.date(from: dateSubString
                )
                if newDate != nil{
                    agoDate = try Helper().timeAgoSinceDate(newDate!)
                    fullTxt = "\(agoDate)" + " via " + currentArticle!.source!
                    let attributedWithTextColor: NSAttributedString = fullTxt.attributedStringWithColor([currentArticle!.source!], color: UIColor.red)
                    cellOdd.lblSource.attributedText = attributedWithTextColor
                }
            }
            
            let imgURL = APPURL.imageServer + imgWidth + "x" + imgHeight + "/smart/" + currentArticle!.imageURL!
            cellOdd.imgNews.sd_setImage(with: URL(string: imgURL), placeholderImage: nil, options: SDWebImageOptions.refreshCached)
            if textSizeSelected == 0{
                cellOdd.lblSource.font = FontConstants.smallFontContent
                cellOdd.lblNewsDescription.font = FontConstants.smallFontHeadingBold
            }
            else if textSizeSelected == 2{
                cellOdd.lblSource.font = FontConstants.LargeFontContent
                cellOdd.lblNewsDescription.font = FontConstants.LargeFontHeadingBold
            }
            else{
                cellOdd.lblSource.font =  FontConstants.NormalFontContent
                cellOdd.lblNewsDescription.font = FontConstants.NormalFontHeadingBold
            }
            
            if cellOdd.imgNews.image == nil{
                cellOdd.imgNews.image = UIImage(named: AssetConstants.NoImage)
            }
            
            activityIndicator.stopAnimating()
            //lblNonews.isHidden = true
            return cellOdd
        }
    }
}

