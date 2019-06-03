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

class ContainerCVCell: UICollectionViewCell,UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    
    @IBOutlet weak var btnTopNews: UIButton!
    @IBOutlet weak var newsCV: UICollectionView!
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
        trendingTVProtocol?.isTrendingTVLoaded(status: false)
        // submenuCOunt = SwipeIndex.shared.currentIndex
        //submenuCOunt = submenuCOunt + 1
        newShowArticle = SwipeIndex.shared.newShowArticle
        btnTopNews.layer.cornerRadius = 0.5 * btnTopNews.bounds.size.width
        btnTopNews.clipsToBounds = true
        btnTopNews.backgroundColor = colorConstants.redColor
        newsCV.reloadData()
        //fetchArticlesFromDB()
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
            return (newShowArticle.count > 0) ? self.newShowArticle[submenuCOunt].count : 0
        }
        else{
            return (newShowArticle.count > 0) ? self.newShowArticle[0].count : 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func saveArticlesInDB(){
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
                // self.lblNonews.isHidden = true
                //ShowArticle = DBData
                newShowArticle.append(DBData)
                trendingTVProtocol?.isTrendingTVLoaded(status: true)
                newsCV.reloadData()
            }
            else{
                //                self.HomeNewsTV.reloadData()
                //                self.lblNonews.isHidden =  false
                //                self.activityIndicator.stopAnimating()
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
        var sourceColor = UIColor()
        var fullTxt = ""
        var dateSubString = ""
        var agoDate = ""
        // let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeIpadID", for:indexPath) as! HomeipadCVCell
        // HomeIphoneID
        //HomeIphoneAlternateID
        
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
                        cell.containerView.backgroundColor = colorConstants.grayBackground2
                        cell.lblSource.textColor = colorConstants.nightModeText
                        cell.lblTitle.textColor = colorConstants.nightModeText
                        //NightNight.theme =  .night
                    }
                    else{
                        cell.lblSource.textColor = colorConstants.blackColor
                        cell.lblTitle.textColor = colorConstants.blackColor
                        //NightNight.theme =  .normal
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
                    
                    //            activityIndicator.stopAnimating()
                    //            lblNonews.isHidden = true
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
                        cell.containerView.backgroundColor = colorConstants.grayBackground2
                        cell.lblSource.textColor = colorConstants.nightModeText
                        cell.lblTitle.textColor = colorConstants.nightModeText
                        //NightNight.theme =  .night
                    }
                    else{
                        cell.lblSource.textColor = colorConstants.blackColor
                        cell.lblTitle.textColor = colorConstants.blackColor
                        //NightNight.theme =  .normal
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
                    
                    //            activityIndicator.stopAnimating()
                    //            lblNonews.isHidden = true
                    return cell
                }
            }
        }
        let cellCluster = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeIpadClusterID", for:indexPath) as! HomeiPadClusterCVCell
        cellCluster.imgNews.layer.cornerRadius = 10.0
        cellCluster.imgNews.clipsToBounds = true
        
        cellCluster.outerView.layer.cornerRadius = 10
        cellCluster.outerView.layer.shadowColor = UIColor.black.cgColor
        cellCluster.outerView.layer.shadowOffset = CGSize(width: 3, height: 3)
        cellCluster.outerView.layer.shadowOpacity = 0.7
        cellCluster.outerView.layer.shadowRadius = 6.0
        // var currentArticle : Article!
        currentArticle = newShowArticle[0][indexPath.row]
        let count = DBManager().showCount(articleId: Int(currentArticle.article_id))//ShowArticle[indexPath.row]
        // currentArticle = ShowArticle[indexPath.row]
        //display data from DB
        cellCluster.lblTitle.text = currentArticle.title
        cellCluster.lblCount.text = String(count)
        if  darkModeStatus == true{
            cellCluster.containerView.backgroundColor = colorConstants.grayBackground2
            cellCluster.lblSource.textColor = colorConstants.nightModeText
            cellCluster.lblTitle.textColor = colorConstants.nightModeText
            //NightNight.theme =  .night
        }
        else{
            cellCluster.lblSource.textColor = colorConstants.blackColor
            cellCluster.lblTitle.textColor = colorConstants.blackColor
            //NightNight.theme =  .normal
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
            cellCluster.lblCount.font = FontConstants.smallFontHeadingBold
        }
        else if textSizeSelected == 2{
            cellCluster.lblSource.font = FontConstants.LargeFontContent
            cellCluster.lblTitle.font = FontConstants.LargeFontHeadingBold
            cellCluster.lblCount.font = FontConstants.LargeFontHeadingBold
        }
        else{
            cellCluster.lblSource.font =  FontConstants.NormalFontContent
            cellCluster.lblTitle.font = FontConstants.NormalFontHeadingBold
            cellCluster.lblCount.font = FontConstants.NormalFontHeadingBold
        }
        
        if cellCluster.imgNews.image == nil{
            cellCluster.imgNews.image = UIImage(named: AssetConstants.NoImage)
        }
        return cellCluster
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //         let obj = ParentViewController()
        //        if isTrending == false{
        //            obj.sortedData = newShowArticle[submenuCOunt]
        //        }else{
        //            obj.sortedData = newShowArticle[0]
        //        }
        //        var id = UserDefaults.standard.array(forKey: "trendingArray") as! [Int]
        //        let selectedCluster = id[indexPath.row]
        //        fetchClusterIdArticles(clusterID: selectedCluster)
        //        isTrendingDetail = 2
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
        
        //        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        //        let newsDetailvc:NewsDetailVC = storyboard.instantiateViewController(withIdentifier: "NewsDetailID") as! NewsDetailVC
        //
        //        if isTrendingDetail == 0{
        //            UserDefaults.standard.set("home", forKey: "isSearch")
        //        }else{
        //            UserDefaults.standard.set("cluster", forKey: "isSearch")
        //        }
        //        if isTrendingDetail == 0 || isTrendingDetail == 2{
        //            if sortedData.count > 0 {
        //                newsDetailvc.newsCurrentIndex = indexPath.row
        //                newsDetailvc.ShowArticle = sortedData
        //                newsDetailvc.articleId = Int(sortedData[indexPath.row].article_id)
        //                present(newsDetailvc, animated: true, completion: nil)
        //            }
        //        }
        //        else{
        //            var id = UserDefaults.standard.array(forKey: "trendingArray") as! [Int]
        //            let selectedCluster = id[indexPath.row]
        //           //  fetchClusterIdArticles(clusterID: selectedCluster)
        //            isTrendingDetail = 2
        //        }
        //
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
                return CGSize(width: collectionCellSize/3.3, height: collectionCellSize/3)
            }
        }
    }
    
    func fetchArticlesFromDB(){
      
        let result = DBManager().ArticlesfetchByCatId()
        switch result {
        case .Success(let DBData) :
            
            if DBData.count > 0 {
                newShowArticle[submenuCOunt].removeAll()
                newShowArticle[submenuCOunt] = DBData
           // newShowArticle.append(ShowArticle)
                newsCV.reloadData()
            }
        case .Failure(let errorMsg) :
            print(errorMsg)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if (scrollView.bounds.maxY) == scrollView.contentSize.height{
           // activityIndicator.startAnimating()
            if isTrending == false {
                var submenuArr = UserDefaults.standard.value(forKey: "submenuArr") as! [String]
                
                var submenu = submenuArr[submenuCOunt] // UserDefaults.standard.value(forKey: "submenu") as! String
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
                               // activityIndicator.stopAnimating()
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

