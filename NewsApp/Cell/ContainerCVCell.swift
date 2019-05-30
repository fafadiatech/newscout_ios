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

class ContainerCVCell: UICollectionViewCell,UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, ScrollToTopDelegate  {
    
    @IBOutlet weak var newsCV: UICollectionView!
    var sortedData = [NewsArticle]()
    var ShowArticle = [NewsArticle]()
    var newShowArticle = [[NewsArticle]]()
    var rowCount = [0,9,6,5,7,12]
    var imgWidth = ""
    var imgHeight = ""
    var submenuCOunt = 0
    var isTrending = true
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        
        //setupViews()
        print("init has been called")
        
        
    }
    
    func setupViews(){
        newsCV.delegate = self
        newsCV.dataSource = self
        // newsCV.reloadData()
        //fetchArticlesFromDB()
    }
    //
    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
        //NotificationCenter.default.addObserver(self, selector: "loadList:", name:NSNotification.Name(rawValue: "load"), object: nil)
        
    }
    
    func loadList(notification: NSNotification){
        self.newsCV?.scrollToItem(at: NSIndexPath(item: 0, section: 0) as IndexPath,
                                  at: .top,
                                  animated: true)
    }
    func fetchArticlesFromDB(){
        ShowArticle.removeAll()
        let result = DBManager().ArticlesfetchByCatId()
        switch result {
        case .Success(let DBData) :
            ShowArticle = DBData
            if ShowArticle.count > 0{
                newsCV.reloadData()
            }
            else{
                newsCV.reloadData()
            }
        case .Failure(let errorMsg) :
            print(errorMsg)
        }
    }
    
    
    func topSelected(status: Bool) {
        if status == true{
            self.newsCV?.scrollToItem(at: NSIndexPath(item: 0, section: 0) as IndexPath,
                                      at: .top,
                                      animated: true)
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
        
            // var currentArticle : Article!
            currentArticle = newShowArticle[0][indexPath.row] //ShowArticle[indexPath.row]
            // currentArticle = ShowArticle[indexPath.row]
            //display data from DB
            cellCluster.lblTitle.text = currentArticle.title
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
            return cellCluster
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screen = UIScreen.main.bounds
        if (UIDevice.current.userInterfaceIdiom != UIUserInterfaceIdiom.pad){
            if isTrending == true {
                return CGSize(width: screen.size.width, height: screen.size.height/2 )
            }else{
                return CGSize(width: screen.size.width, height: 120 )
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
    
}

