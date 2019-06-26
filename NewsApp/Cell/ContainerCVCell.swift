//
//  ContainerCVCell.swift
//  NewsApp
//
//  Created by Jayashree on 23/05/19.
//  Copyright © 2019 Fafadia Tech. All rights reserved.
//

import UIKit
import CoreData
import SDWebImage
import NightNight
import MaterialComponents.MaterialActivityIndicator

class ContainerCVCell: UICollectionViewCell,UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    @IBOutlet weak var lblNoNews: UILabel!
    @IBOutlet weak var btnTopNews: UIButton!
    @IBOutlet weak var newsCV: UICollectionView!
    
    @IBOutlet weak var lblSourceTrailing: NSLayoutConstraint!
    
    let activityIndicator = MDCActivityIndicator()
    var sortedData = [NewsArticle]()
    var clusterArticles = [NewsArticle]()
    var prevTrendingData = [NewsArticle]()
    var ShowArticle = [NewsArticle]()
    var newShowArticle = [[NewsArticle]]()
    var rowCount = [0,9,6,5,7,12]
    var imgWidth = ""
    var imgHeight = ""
    var submenuCOunt = 0
    var isTrending = true
    var isTrendingDetail = 0
    var selectedObj : CellDelegate?
    var trendingClickedObj : trendingDetailClicked?
    var trendingTVProtocol : TrendingBack?
    var isAPICalled = false
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        print("init has been called")
    }
    
    func setupViews(){
        newsCV.delegate = self
        newsCV.dataSource = self
        activityIndicator.cycleColors = [.blue]
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshNews), for: .valueChanged)
        newsCV.refreshControl = refreshControl
        refreshControl.attributedTitle = NSAttributedString(string: "Pull  to Refresh...")
        
        let screen = UIScreen.main.bounds
        activityIndicator.frame = CGRect(x: screen.size.width/2, y: screen.size.height/2 - 100, width: 40, height: 40)
        activityIndicator.sizeToFit()
        activityIndicator.indicatorMode = .indeterminate
        activityIndicator.progress = 2.0
        newsCV.addSubview(activityIndicator)
        trendingTVProtocol?.isTrendingTVLoaded(status: false)
        // submenuCOunt = SwipeIndex.shared.currentIndex
        //submenuCOunt = submenuCOunt + 1
        newShowArticle = SwipeIndex.shared.newShowArticle
        btnTopNews.layer.cornerRadius = 0.5 * btnTopNews.bounds.size.width
        newsCV.reloadData()
        activityIndicator.startAnimating()
    }
    func saveTrending(){
        DBManager().saveTrending{response in
            if response == true{
                self.fetchTrending()
            }
        }
    }
    
    func fetchTrending(){
        activityIndicator.startAnimating()
        let result = DBManager().fetchTrendingArticle()
        switch result {
        case .Success(let DBData) :
            if DBData.count > 0{
                self.newShowArticle[0].removeAll()
                newShowArticle[0] = DBData
                newsCV.reloadData()
            }
            else{
                self.activityIndicator.stopAnimating()
            }
        case .Failure(let errorMsg) :
            print(errorMsg)
        }
    }
    
    @objc func refreshNews(refreshControl: UIRefreshControl) {
        DispatchQueue.global(qos: .userInitiated).async {
            if self.isTrending == false && self.isTrendingDetail != 2{
                self.saveArticlesInDB()
            }
            else if self.isTrending == true {
                self.saveTrending()
            }
        }
        DispatchQueue.main.async {
            refreshControl.endRefreshing()
            self.activityIndicator.stopAnimating()
        }
    }
    
    @objc private func darkModeEnabled(_ notification: Notification){
        NightNight.theme = .night
        newsCV.backgroundColor = colorConstants.grayBackground3
        lblNoNews.textColor = .white
    }
    
    @objc private func darkModeDisabled(_ notification: Notification) {
        NightNight.theme = .normal
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .darkModeEnabled, object: nil)
        NotificationCenter.default.removeObserver(self, name: .darkModeDisabled, object: nil)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
    }
    
    func retainTrendingData(){
        if isTrendingDetail ==  2{
            newShowArticle.removeAll()
            newShowArticle.append(clusterArticles)
            newsCV.reloadData()
        }
    }
    
    @IBAction func btnTopNewsActn(_ sender: Any) {
        self.newsCV?.scrollToItem(at: NSIndexPath(item: 0, section: 0) as IndexPath,
                                  at: .top,
                                  animated: true)
    }
    
    func isBackClicked(status: Bool) {
        if status == true{
            retainTrendingData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isTrending == false{
            return (newShowArticle[submenuCOunt].count > 0) ? self.newShowArticle[submenuCOunt].count : 0
        }
        else{
            return (newShowArticle.count > 0) ? self.newShowArticle[0].count : 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func saveArticlesInDB(){
        activityIndicator.startAnimating()
        var subMenuURL = ""
        if UserDefaults.standard.value(forKey: "submenuURL") != nil{
            subMenuURL =  UserDefaults.standard.value(forKey: "submenuURL") as! String
        }
        DBManager().SaveDataDB(nextUrl: subMenuURL ){response in
            if response == true{
                var submenuArr = UserDefaults.standard.value(forKey: "submenuArr") as! [String]
                self.fetchSubmenuId(submenu: submenuArr[self.submenuCOunt])
                self.fetchArticlesFromDB()
            }
        }
    }
    
    func fetchSubmenuId(submenu : String){
        let tagresult = DBManager().fetchsubmenuId(subMenuName: submenu)
        switch tagresult{
        case .Success(let id) :
            let url = APPURL.ArticleByIdURL + "\(id)"
            UserDefaults.standard.setValue(id, forKey: "subMenuId")
            UserDefaults.standard.setValue(url, forKey: "submenuURL")
        case .Failure(let error):
            print(error)
        }
    }
    
    func fetchClusterIdArticles(clusterID: Int){
        let result = DBManager().fetchClusterArticles(trendingId: clusterID)
        switch result {
        case .Success(let DBData) :
            self.clusterArticles = DBData
            if self.clusterArticles.count > 0{
                newShowArticle.removeAll()
                newShowArticle.append(DBData)
                trendingTVProtocol?.isTrendingTVLoaded(status: true)
                newsCV.reloadData()
            }
            else{
                self.lblNoNews.isHidden =  true
                self.activityIndicator.stopAnimating()
            }
        case .Failure(let errorMsg) :
            print(errorMsg)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var currentArticle = NewsArticle()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.timeZone = NSTimeZone.local
        let darkModeStatus = UserDefaults.standard.value(forKey: "darkModeEnabled") as! Bool
        
        let textSizeSelected = UserDefaults.standard.value(forKey: "textSize") as! Int
        var fullTxt = ""
        var dateSubString = ""
        var agoDate = ""
        if (UIDevice.current.userInterfaceIdiom != UIUserInterfaceIdiom.pad){
            if isTrending == false{
                sortedData = newShowArticle[submenuCOunt].sorted{ $0.published_on! > $1.published_on! }
                currentArticle = sortedData[indexPath.row]
                if indexPath.row % 2 == 0{
                    //display data from DB
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeIphoneAlternateID", for:indexPath) as! HomeiPhoneAlternateCVCell
                    cell.imgNews.layer.cornerRadius = 10.0
                    cell.imgNews.clipsToBounds = true
                    
                    cell.outerView.layer.cornerRadius = 10
                    cell.outerView.layer.shadowColor = UIColor.black.cgColor
                    cell.outerView.layer.shadowOffset = CGSize(width: 3, height: 3)
                    cell.outerView.layer.shadowOpacity = 0.7
                    cell.outerView.layer.shadowRadius = 6.0
                    cell.lblTitle.text = currentArticle.title
                    
                    if  darkModeStatus == true{
                        cell.backgroundColor = colorConstants.grayBackground2
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
                            agoDate = try Helper().timeAgoSinceDate(newDate!)
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
                            agoDate = try Helper().timeAgoSinceDate(newDate!)
                            fullTxt = "\(agoDate)" + " via " + currentArticle.source!
                            let attributedWithTextColor: NSAttributedString = fullTxt.attributedStringWithColor([currentArticle.source!], color: UIColor.red)
                            cell.lblSource.attributedText = attributedWithTextColor
                        }
                    }
                    imgWidth = String(describing : Int(cell.imgNews.frame.size.width))
                    imgHeight = String(describing : Int(cell.imgNews.frame.size.height))
            
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
                else{
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeIphoneID", for:indexPath) as! HomeiPhoneCVCell
                    
                    cell.imgNews.layer.cornerRadius = 10.0
                    cell.imgNews.clipsToBounds = true
                    cell.outerView.layer.cornerRadius = 10
                    cell.outerView.layer.shadowColor = UIColor.black.cgColor
                    cell.outerView.layer.shadowOffset = CGSize(width: 3, height: 3)
                    cell.outerView.layer.shadowOpacity = 0.7
                    cell.outerView.layer.shadowRadius = 6.0
                    cell.lblTitle.text = currentArticle.title
                    
                    if  darkModeStatus == true{
                        cell.backgroundColor = colorConstants.grayBackground2
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
                            agoDate = try Helper().timeAgoSinceDate(newDate!)
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
                            agoDate = try Helper().timeAgoSinceDate(newDate!)
                            fullTxt = "\(agoDate)" + " via " + currentArticle.source!
                            let attributedWithTextColor: NSAttributedString = fullTxt.attributedStringWithColor([currentArticle.source!], color: UIColor.red)
                            cell.lblSource.attributedText = attributedWithTextColor
                        }
                    }
                    imgWidth = String(describing : Int(cell.imgNews.frame.size.width))
                    imgHeight = String(describing : Int(cell.imgNews.frame.size.height))
                   
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
            }
        }
        if  isTrending == false{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeIpadID", for:indexPath) as! HomeipadCVCell
            cell.outerView.layer.cornerRadius = 10
            cell.outerView.layer.masksToBounds = false
            cell.outerView.layer.shadowColor = UIColor.black.cgColor
            cell.outerView.layer.shadowOffset = CGSize(width: 0, height: 5)
            let shadowpath = UIBezierPath(roundedRect: bounds, cornerRadius: 2)
            layer.shadowPath = shadowpath.cgPath
            cell.outerView.layer.shadowOpacity = 0.7
            cell.imgNews.layer.cornerRadius = 10.0
            cell.imgNews.clipsToBounds = true
            cell.layer.cornerRadius = 10.0
            cell.clipsToBounds = true
            sortedData = newShowArticle[submenuCOunt].sorted{ $0.published_on! > $1.published_on! }
            currentArticle = sortedData[indexPath.row]
            //display data from DB
            cell.lblTitle.text = currentArticle.title
            
            if  darkModeStatus == true{
                cell.backgroundColor = colorConstants.grayBackground2
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
                    agoDate = try Helper().timeAgoSinceDate(newDate!)
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
                    agoDate = try Helper().timeAgoSinceDate(newDate!)
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
        else{
            let cellCluster = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeIpadClusterID", for:indexPath) as! HomeiPadClusterCVCell
            cellCluster.outerView.layer.cornerRadius = 10
            cellCluster.outerView.layer.masksToBounds = false
            cellCluster.outerView.layer.shadowColor = UIColor.black.cgColor
            cellCluster.outerView.layer.shadowOffset = CGSize(width: 0, height: 5)
            let shadowpath = UIBezierPath(roundedRect: bounds, cornerRadius: 2)
            layer.shadowPath = shadowpath.cgPath
            cellCluster.outerView.layer.shadowOpacity = 0.7
            cellCluster.imgNews.layer.cornerRadius = 10.0
            cellCluster.imgNews.clipsToBounds = true
            cellCluster.layer.cornerRadius = 10.0
            cellCluster.clipsToBounds = true
            
            //display data from DB
            if isTrending == true{
                currentArticle = newShowArticle[0][indexPath.row]
                cellCluster.lblCount.isHidden = false
                cellCluster.imgCount.isHidden = false
                let count = DBManager().showCount(articleId: Int(currentArticle.article_id))
                cellCluster.lblCount.text = String(count)
                if lblSourceTrailing != nil{
                    NSLayoutConstraint.deactivate([lblSourceTrailing])
                    lblSourceTrailing = NSLayoutConstraint (item: cellCluster.lblSource,
                                                            attribute: NSLayoutConstraint.Attribute.trailing,
                                                            relatedBy: NSLayoutConstraint.Relation.equal,
                                                            toItem: cellCluster.imgCount,
                                                            attribute: NSLayoutConstraint.Attribute.leading,
                                                            multiplier: -10,
                                                            constant: 0)
                    NSLayoutConstraint.activate([lblSourceTrailing])
                }
                imgWidth = String(describing : Int(cellCluster.imgNews.frame.size.width))
                imgHeight = String(describing : Int(cellCluster.imgNews.frame.size.height))
            }
            else{
                sortedData = newShowArticle[submenuCOunt].sorted{ $0.published_on! > $1.published_on! }
                currentArticle = sortedData[indexPath.row]
                cellCluster.lblCount.isHidden = true
                cellCluster.imgCount.isHidden = true
                lblSourceTrailing = NSLayoutConstraint (item: cellCluster.lblSource,
                                                        attribute: NSLayoutConstraint.Attribute.trailing,
                                                        relatedBy: NSLayoutConstraint.Relation.equal,
                                                        toItem: cellCluster.lblTitle,
                                                        attribute: NSLayoutConstraint.Attribute.trailing,
                                                        multiplier: 1,
                                                        constant: 0)
                NSLayoutConstraint.activate([lblSourceTrailing])
                imgWidth = String(describing : Int(cellCluster.imgNews.frame.size.width))
                imgHeight = String(describing : Int(cellCluster.imgNews.frame.size.height))
            }
            cellCluster.lblTitle.text = currentArticle.title
            if  darkModeStatus == true{
                cellCluster.backgroundColor = colorConstants.grayBackground2
                cellCluster.containerView.backgroundColor = colorConstants.grayBackground2
                cellCluster.lblSource.textColor = colorConstants.nightModeText
                cellCluster.lblTitle.textColor = colorConstants.nightModeText
                NightNight.theme =  .night
            }
            else{
                cellCluster.backgroundColor = .white
                cellCluster.containerView.backgroundColor = .white
                cellCluster.lblSource.textColor = colorConstants.blackColor
                cellCluster.lblTitle.textColor = colorConstants.blackColor
                NightNight.theme =  .normal
            }
            
            if ((currentArticle.published_on?.count)!) <= 20{
                if !(currentArticle.published_on?.contains("Z"))!{
                    currentArticle.published_on?.append("Z")
                }
                let newDate = dateFormatter.date(from: currentArticle.published_on!)
                if newDate != nil{
                    agoDate = try Helper().timeAgoSinceDate(newDate!)
                    fullTxt = "\(agoDate)" + " via " + currentArticle.source!
                    let attributedWithTextColor: NSAttributedString = fullTxt.attributedStringWithColor([currentArticle.source!], color: UIColor.red)
                    cellCluster.lblSource.attributedText = attributedWithTextColor
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
                    agoDate = try Helper().timeAgoSinceDate(newDate!)
                    fullTxt = "\(agoDate)" + " via " + currentArticle.source!
                    let attributedWithTextColor: NSAttributedString = fullTxt.attributedStringWithColor([currentArticle.source!], color: UIColor.red)
                    cellCluster.lblSource.attributedText = attributedWithTextColor
                }
            }
            let imgURL = APPURL.imageServer + imgWidth + "x" + imgHeight + "/smart/" + currentArticle.imageURL!
            cellCluster.imgNews.sd_setImage(with: URL(string: imgURL), placeholderImage: nil, options: SDWebImageOptions.refreshCached)
            
            if textSizeSelected == 0{
                cellCluster.lblSource.font = FontConstants.smallFontContent
                cellCluster.lblTitle.font = FontConstants.smallFontHeadingBold
            }
            else if textSizeSelected == 2{
                cellCluster.lblSource.font = FontConstants.LargeFontContent
                cellCluster.lblTitle.font = FontConstants.LargeFontHeadingBold
            }
            else{
                cellCluster.lblSource.font =  FontConstants.NormalFontContent
                cellCluster.lblTitle.font = FontConstants.NormalFontHeadingBold
            }
            
            if cellCluster.imgNews.image == nil{
                cellCluster.imgNews.image = UIImage(named: AssetConstants.NoImage)
            }
            activityIndicator.stopAnimating()
            lblNoNews.isHidden = true
            return cellCluster
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isTrending == false{
            selectedObj?.colCategorySelected(indexPath, sortedData)
        }else{
            var id = UserDefaults.standard.array(forKey: "trendingArray") as! [Int]
            trendingClickedObj?.isTrendingDetailedOpened(status: true)
            let selectedCluster = id[indexPath.row]
            fetchClusterIdArticles(clusterID: selectedCluster)
            isTrending = false
            submenuCOunt = 0
            isTrendingDetail = 2
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screen = UIScreen.main.bounds
        if (UIDevice.current.userInterfaceIdiom != UIUserInterfaceIdiom.pad){
            if isTrending == true {
                return CGSize(width: screen.size.width, height: screen.size.height/2 )
            }else{
                return CGSize(width: screen.size.width, height: 140 )
            }
        }
        else{
            let collectionCellSize = newsCV.frame.size.width
            if isTrending == true {
                return CGSize(width: collectionCellSize/2.15, height: collectionCellSize/2)
            }else{
                return CGSize(width: collectionCellSize/3.3, height: collectionCellSize/2.5)
            }
        }
    }
    
    func fetchArticlesFromDB(){
        activityIndicator.startAnimating()
        let result = DBManager().ArticlesfetchByCatId()
        switch result {
        case .Success(let DBData) :
            
            if DBData.count > 0 {
                newShowArticle[submenuCOunt].removeAll()
                newShowArticle[submenuCOunt] = DBData
                activityIndicator.stopAnimating()
                newsCV.reloadData()
            }
        case .Failure(let errorMsg) :
            print(errorMsg)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == newsCV{
            if (scrollView.bounds.maxY) >= scrollView.contentSize.height{
                if isTrending == false {
                    var submenuArr = UserDefaults.standard.value(forKey: "submenuArr") as! [String]
                    
                    let submenu = submenuArr[submenuCOunt]
                    UserDefaults.standard.set(submenu ,forKey: "submenu")
                    if newShowArticle[submenuCOunt].count >= 20{
                        if isAPICalled == false{
                            let result =  DBManager().FetchNextURL(category: submenu)
                            switch result {
                            case .Success(let DBData) :
                                let nextURL = DBData
                                
                                if nextURL.count != 0{
                                    isAPICalled = false
                                    if nextURL[0].category == submenu {
                                        let nexturl = nextURL[0].nextURL
                                        UserDefaults.standard.set(nexturl, forKey: "submenuURL")
                                        self.saveArticlesInDB()
                                    }
                                }
                                else{
                                    isAPICalled = true
                                    activityIndicator.stopAnimating()
                                }
                            case .Failure(let errorMsg) :
                                print(errorMsg)
                            }
                        }
                    }
                }
            }
        }
    }
    
}

