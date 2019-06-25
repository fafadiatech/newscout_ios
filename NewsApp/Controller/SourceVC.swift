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
    
    @IBOutlet weak var lblNoNews: UILabel!
    @IBOutlet weak var sourceCV: UICollectionView!
    @IBOutlet weak var lblSource: UILabel!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var sourceTV: UITableView!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnTopNews: UIButton!
    var nextURL = ""
    var url = ""
    var source = ""
    let textSizeSelected = UserDefaults.standard.value(forKey: "textSize") as! Int
    let activityIndicator = MDCActivityIndicator()
    var ShowArticle = [Article]()
    var imgWidth = ""
    var imgHeight = ""
    var statusBarOrientation: UIInterfaceOrientation = UIApplication.shared.statusBarOrientation
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sourceTV.tableFooterView = UIView(frame: .zero)
        btnTopNews.layer.cornerRadius = 0.5 * btnTopNews.bounds.size.width
        lblSource.text = source
        lblSource.textColor = .white
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
        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad && statusBarOrientation.isPortrait{
            sourceCV.isHidden = false
            sourceTV.isHidden = true
        }
        else {
            sourceCV.isHidden = true
            sourceTV.isHidden = false
        }
        let darkModeStatus = UserDefaults.standard.value(forKey: "darkModeEnabled") as! Bool
        if darkModeStatus == true{
            sourceCV.backgroundColor = colorConstants.grayBackground3
            sourceTV.backgroundColor = colorConstants.grayBackground3
        }else{
            sourceTV.backgroundColor = .white
            sourceCV.backgroundColor = .white
        }
    }
    
    @objc private func darkModeEnabled(_ notification: Notification) {
        NightNight.theme = .night
        sourceTV.backgroundColor = colorConstants.grayBackground3
        sourceCV.backgroundColor = colorConstants.grayBackground3
        lblNoNews.textColor = .white
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
    
    @IBAction func btnTopNewsActn(_ sender: Any) {
        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad{
            self.sourceCV?.scrollToItem(at: NSIndexPath(item: 0, section: 0) as IndexPath,
                                        at: .top,
                                        animated: true)
        }else{
            let indexPath = NSIndexPath(row: 0, section: 0)
            self.sourceTV.scrollToRow(at: indexPath as IndexPath, at: .top, animated: true)
        }
    }
    
    func loadSourceArticles(){
        APICall().loadSearchAPI(url : url){
            (status, response)  in
            switch response {
            case .Success(let data) :
                self.ShowArticle = (data[0].body?.articles)!
                if data[0].body?.next != nil{
                    self.nextURL = (data[0].body?.next)!
                }
                if self.sourceTV.isHidden == false{
                    self.sourceTV.reloadData()
                }else{
                    self.sourceCV.reloadData()
                }
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
        return (ShowArticle.count > 0) ? (ShowArticle.count)  : 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newsDetailvc:NewsDetailVC = storyboard.instantiateViewController(withIdentifier: "NewsDetailID") as! NewsDetailVC
        newsDetailvc.newsCurrentIndex = indexPath.row
        newsDetailvc.sourceArticle = ShowArticle
        newsDetailvc.articleId = (ShowArticle[indexPath.row].article_id)!
        UserDefaults.standard.set("source", forKey: "isSearch")
        present(newsDetailvc, animated: true, completion: nil)
        sourceTV.deselectRow(at: indexPath, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sourceID", for:indexPath) as! sourceTVCell
        let cellOdd = tableView.dequeueReusableCell(withIdentifier: "sourceZigzagID", for:indexPath) as! sourceZigzagTVCell
        imgWidth = String(describing : Int(cell.imgNews.frame.width))
        imgHeight = String(describing : Int(cell.imgNews.frame.height))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.timeZone = NSTimeZone.local
        let darkModeStatus = UserDefaults.standard.value(forKey: "darkModeEnabled") as! Bool
        let textSizeSelected = UserDefaults.standard.value(forKey: "textSize") as! Int
        var fullTxt = ""
        var dateSubString = ""
        var agoDate = ""
        if indexPath.row % 2 != 0{
            cell.viewCellContainer.layer.cornerRadius = 10
            cell.viewCellContainer.layer.shadowColor = UIColor.black.cgColor
            cell.viewCellContainer.layer.shadowOffset = CGSize(width: 3, height: 3)
            cell.viewCellContainer.layer.shadowOpacity = 0.7
            cell.viewCellContainer.layer.shadowRadius = 4.0
            cell.imgNews.layer.cornerRadius = 10.0
            cell.imgNews.clipsToBounds = true
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            //display data from DB
            var currentArticle = ShowArticle[indexPath.row]
            cell.lblNewsDescription.text = currentArticle.title
            
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
            
            if ((currentArticle.published_on?.count)!) <= 20{
                if !(currentArticle.published_on?.contains("Z"))!{
                    currentArticle.published_on?.append("Z")
                }
                let newDate = dateFormatter.date(from: currentArticle.published_on!)
                if newDate != nil{
                    agoDate = Helper().timeAgoSinceDate(newDate!)
                    fullTxt = "\(agoDate)" + " via " + currentArticle.source!
                    let attributedWithTextColor: NSAttributedString = fullTxt.attributedStringWithColor([currentArticle.source!], color: UIColor.red)
                    cell.lblSource.attributedText = attributedWithTextColor
                }
            }
            else{
                dateSubString = String(currentArticle.published_on!.prefix(19))
                if !(dateSubString.contains("Z")){
                    dateSubString.append("Z")
                }
                let newDate = dateFormatter.date(from: dateSubString
                )
                if newDate != nil{
                    agoDate = Helper().timeAgoSinceDate(newDate!)
                    fullTxt = "\(agoDate)" + " via " + currentArticle.source!
                    let attributedWithTextColor: NSAttributedString = fullTxt.attributedStringWithColor([currentArticle.source!], color: UIColor.red)
                    cell.lblSource.attributedText = attributedWithTextColor
                }
            }
            let imgURL = APPURL.imageServer + imgWidth + "x" + imgHeight + "/smart/" + currentArticle.imageURL!
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
            lblNoNews.isHidden = true
            return cell
        }
        else{
            cellOdd.viewCellContainer.layer.cornerRadius = 10
            cellOdd.viewCellContainer.layer.shadowColor = UIColor.black.cgColor
            cellOdd.viewCellContainer.layer.shadowOffset = CGSize(width: 3, height: 3)
            cellOdd.viewCellContainer.layer.shadowOpacity = 0.7
            cellOdd.viewCellContainer.layer.shadowRadius = 4.0
            cellOdd.imgNews.layer.cornerRadius = 10.0
            cellOdd.imgNews.clipsToBounds = true
            cellOdd.selectionStyle = UITableViewCellSelectionStyle.none
            //display data from DB
            var currentArticle = ShowArticle[indexPath.row]
            cellOdd.lblNewsDescription.text = currentArticle.title
            
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
            
            if ((currentArticle.published_on?.count)!) <= 20{
                if !(currentArticle.published_on?.contains("Z"))!{
                    currentArticle.published_on?.append("Z")
                }
                let newDate = dateFormatter.date(from: currentArticle.published_on!)
                if newDate != nil{
                    agoDate = Helper().timeAgoSinceDate(newDate!)
                    fullTxt = "\(agoDate)" + " via " + currentArticle.source!
                    let attributedWithTextColor: NSAttributedString = fullTxt.attributedStringWithColor([currentArticle.source!], color: UIColor.red)
                    cellOdd.lblSource.attributedText = attributedWithTextColor
                }
            }
            else{
                dateSubString = String(currentArticle.published_on!.prefix(19))
                if !(dateSubString.contains("Z")){
                    dateSubString.append("Z")
                }
                let newDate = dateFormatter.date(from: dateSubString
                )
                if newDate != nil{
                    agoDate = Helper().timeAgoSinceDate(newDate!)
                    fullTxt = "\(agoDate)" + " via " + currentArticle.source!
                    let attributedWithTextColor: NSAttributedString = fullTxt.attributedStringWithColor([currentArticle.source!], color: UIColor.red)
                    cellOdd.lblSource.attributedText = attributedWithTextColor
                }
            }
            
            let imgURL = APPURL.imageServer + imgWidth + "x" + imgHeight + "/smart/" + currentArticle.imageURL!
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
            lblNoNews.isHidden = true
            return cellOdd
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            if (ShowArticle.count) >= 20{
                if nextURL != nil{
                    APICall().loadSearchAPI(url : nextURL){
                        (status, response)  in
                        switch response {
                        case .Success(let data) :
                            if (data[0].body?.articles.count)! > 0{
                                for article in (data[0].body?.articles)!{
                                    self.ShowArticle.append(article)
                                }
                            }
                            if data[0].body?.next != ""{
                                self.nextURL = (data[0].body?.next)!
                            }
                            if self.sourceTV.isHidden == false{
                                self.sourceTV.reloadData()
                            }else{
                                self.sourceCV.reloadData()
                            }
                            self.activityIndicator.stopAnimating()
                        case .Failure(let errormessage) :
                            print(errormessage)
                        case .Change(let code):
                            print(code)
                        }
                    }
                }
            }
        }
    }
}

extension SourceVC: UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (ShowArticle.count > 0) ? ShowArticle.count  : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newsDetailvc:NewsDetailVC = storyboard.instantiateViewController(withIdentifier: "NewsDetailID") as! NewsDetailVC
        newsDetailvc.newsCurrentIndex = indexPath.row
        newsDetailvc.sourceArticle = ShowArticle
        newsDetailvc.articleId = (ShowArticle[indexPath.row].article_id)!
        UserDefaults.standard.set("source", forKey: "isSearch")
        present(newsDetailvc, animated: true, completion: nil)
        sourceTV.deselectRow(at: indexPath, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SourceIpadID", for:indexPath) as! SourceCVCell
        imgWidth = String(describing : Int(cell.imgNews.frame.width))
        imgHeight = String(describing : Int(cell.imgNews.frame.height))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.timeZone = NSTimeZone.local
        let darkModeStatus = UserDefaults.standard.value(forKey: "darkModeEnabled") as! Bool
        let textSizeSelected = UserDefaults.standard.value(forKey: "textSize") as! Int
        var fullTxt = ""
        var dateSubString = ""
        var agoDate = ""
        //display data from DB
        var currentArticle = ShowArticle[indexPath.row]
        cell.imgNews.layer.cornerRadius = 10.0
        cell.imgNews.clipsToBounds = true
        cell.layer.cornerRadius = 10.0
        cell.clipsToBounds = true
        cell.lblTitle.text = currentArticle.title
        cell.viewCellContainer.layer.cornerRadius = 10
        cell.viewCellContainer.layer.shadowColor = UIColor.black.cgColor
        cell.viewCellContainer.layer.shadowOffset = CGSize(width: 3, height: 3)
        cell.viewCellContainer.layer.shadowOpacity = 0.7
        cell.viewCellContainer.layer.shadowRadius = 4.0
        if  darkModeStatus == true{
            cell.containerView.backgroundColor = colorConstants.grayBackground2
            cell.lblSource.textColor = colorConstants.nightModeText
            cell.lblTitle.textColor = colorConstants.nightModeText
            NightNight.theme =  .night
        }
        else{
            cell.backgroundColor = .white
            cell.containerView.backgroundColor = .white
            cell.lblSource.textColor = colorConstants.blackColor
            cell.lblTitle.textColor = colorConstants.blackColor
            NightNight.theme =  .normal
        }
        
        if ((currentArticle.published_on?.count)!) <= 20{
            if !(currentArticle.published_on?.contains("Z"))!{
                currentArticle.published_on?.append("Z")
            }
            let newDate = dateFormatter.date(from: currentArticle.published_on!)
            if newDate != nil{
                agoDate = Helper().timeAgoSinceDate(newDate!)
                fullTxt = "\(agoDate)" + " via " + currentArticle.source!
                let attributedWithTextColor: NSAttributedString = fullTxt.attributedStringWithColor([currentArticle.source!], color: UIColor.red)
                cell.lblSource.attributedText = attributedWithTextColor
            }
        }
        else{
            dateSubString = String(currentArticle.published_on!.prefix(19))
            if !(dateSubString.contains("Z")){
                dateSubString.append("Z")
            }
            let newDate = dateFormatter.date(from: dateSubString
            )
            if newDate != nil{
                agoDate = Helper().timeAgoSinceDate(newDate!)
                fullTxt = "\(agoDate)" + " via " + currentArticle.source!
                let attributedWithTextColor: NSAttributedString = fullTxt.attributedStringWithColor([currentArticle.source!], color: UIColor.red)
                cell.lblSource.attributedText = attributedWithTextColor
            }
        }
        let imgURL = APPURL.imageServer + imgWidth + "x" + imgHeight + "/smart/" + currentArticle.imageURL!
        cell.imgNews.sd_setImage(with: URL(string: imgURL), placeholderImage: nil, options: SDWebImageOptions.refreshCached)
        
        if textSizeSelected == 0{
            cell.lblSource.font = FontConstants.smallFontContent
            cell.lblTitle.font = FontConstants.smallFontHeadingBold
        }
        else if textSizeSelected == 2{
            cell.lblSource.font = FontConstants.LargeFontContent
            cell.lblTitle.font = FontConstants.LargeFontHeadingBold
        }
        else{
            cell.lblSource.font =  FontConstants.NormalFontContent
            cell.lblTitle.font = FontConstants.NormalFontHeadingBold
        }
        
        if cell.imgNews.image == nil{
            cell.imgNews.image = UIImage(named: AssetConstants.NoImage)
        }
        
        activityIndicator.stopAnimating()
        lblNoNews.isHidden = true
        return cell
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if (scrollView.bounds.maxY) == scrollView.contentSize.height{
            if (ShowArticle.count) >= 20{
                if nextURL != nil{
                    APICall().loadSearchAPI(url : nextURL){
                        (status, response)  in
                        switch response {
                        case .Success(let data) :
                            if (data[0].body?.articles.count)! > 0{
                                for article in (data[0].body?.articles)!{
                                    self.ShowArticle.append(article)
                                }
                                if data[0].body?.next != ""{
                                    self.nextURL = (data[0].body?.next)!
                                }
                                self.sourceTV.reloadData()
                            }
                            self.activityIndicator.stopAnimating()
                        case .Failure(let errormessage) :
                            print(errormessage)
                        case .Change(let code):
                            print(code)
                            
                        }
                    }
                }
            }
        }
    }
}

extension SourceVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionCellSize = sourceCV.frame.size.width
        return CGSize(width: collectionCellSize/3.4, height: collectionCellSize/2.4)
    }
}
