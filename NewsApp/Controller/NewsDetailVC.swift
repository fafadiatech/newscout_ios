//
//  NewsDetailViewController.swift
//  NewsApp
//
//  Created by Jayashri on 22/09/18.
//  Copyright © 2018 Fafadia Tech. All rights reserved.
//

import UIKit
import WebKit
import Alamofire
import SDWebImage
import NightNight
import AVFoundation
import AVKit
import SwiftDevice
import CoreData
import MaterialComponents.MaterialActivityIndicator
import TAPageControl

class NewsDetailVC: UIViewController, UIScrollViewDelegate, TAPageControlDelegate, WKNavigationDelegate {
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var imgNews: UIImageView!
    @IBOutlet var newsView: UIView!
    @IBOutlet weak var lblNewsHeading: UILabel!
    @IBOutlet weak var txtViewNewsDesc: UITextView!
    @IBOutlet weak var lblTimeAgo: UILabel!
    @IBOutlet weak var lblSource: UILabel!
    @IBOutlet weak var btnLike: UIButton!
    @IBOutlet weak var btnDislike: UIButton!
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var suggestedView: UIView!
    @IBOutlet weak var suggestedCV: UICollectionView!
    @IBOutlet weak var WKWebView: WKWebView!
    @IBOutlet weak var viewWebTitle: UIView!
    @IBOutlet weak var ViewWebContainer: UIView!
    @IBOutlet weak var lblWebSource: UILabel!
    @IBOutlet weak var btnBookamark: UIButton!
    @IBOutlet weak var viewLikeDislike: UIView!
    @IBOutlet weak var viewNewsArea: UIView!
    @IBOutlet weak var btnPlayVideo: UIButton!
    @IBOutlet weak var newsAreaHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewLikeDislikeHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var lblSourceBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var lblTimeAgoBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewLikeDislikeBottom: NSLayoutConstraint!
    @IBOutlet weak var viewBack: UIView!
    @IBOutlet weak var imgScrollView: UIScrollView!
    @IBOutlet weak var viewImgContainerTop: NSLayoutConstraint!
    @IBOutlet weak var viewImgContainer: UIView!
    @IBOutlet weak var viewContainerTop: NSLayoutConstraint!
    @IBOutlet weak var btnSource: UIButton!
    @IBOutlet weak var btnSourceBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewReadMore: UIView!
    @IBOutlet weak var btnShuffle: UIButton!
    @IBOutlet weak var btnReadMore: UIButton!
    @IBOutlet weak var btnMoreStories: UIButton!
    
    var btnPlay = UIButton(type: .custom)
    let imageCache = NSCache<NSString, UIImage>()
    var playbackSlider = UISlider()
    var RecomArticleData = [ArticleStatus]()
    var ArticleData = [ArticleStatus]()
    var RecomData = [NewsArticle]()
    var searchRecomData = [SearchArticles]()
    var sourceRecomData = [Article]()
    var bookmarkedArticle = [BookmarkArticles]()
    var ShowArticle = [NewsArticle]()
    var SearchArticle = [SearchArticles]()
    var sourceArticle = [Article]()
    var ArticleDetail : ArticleDetails!
    var newsCurrentIndex = 0
    var articleId = 0
    var sourceURL = ""
    var tapTerm:UITapGestureRecognizer = UITapGestureRecognizer()
    var player:AVPlayer?
    var playerItem:AVPlayerItem?
    var lblSourceTopConstraint : NSLayoutConstraint!
    var lblTimesTopConstraint : NSLayoutConstraint!
    var viewLikeDislikeBottomConstraint : NSLayoutConstraint!
    var deviceOrientation: UIDeviceOrientation = UIDevice.current.orientation
    var statusBarOrientation: UIInterfaceOrientation = UIApplication.shared.statusBarOrientation
    var darkModeStatus = Bool()
    var articleArr = [Article]()
    var playerViewWidth = CGFloat()
    var playerViewHeight = CGFloat()
    let activityIndicator = MDCActivityIndicator()
    let activity = MDCActivityIndicator()
    var indexCount = 0
    var currentEntity = ""
    var imgArray = [UIImage]()
    var MediaData = [Media]()
    var index = 0
    var timer = Timer()
    var customPagecontrol = TAPageControl()
    var imgWidth = ""
    var imgHeight = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imgWidth = String(describing : Int(imgNews.frame.width))
        imgHeight = String(describing : Int(imgNews.frame.height))
        btnReadMore.setTitleColor(.black, for: UIControlState.normal)
        suggestedView.isHidden = true
        WKWebView.navigationDelegate = self
        btnReadMore.backgroundColor = .clear
        btnReadMore.layer.cornerRadius = 5
        btnReadMore.layer.borderWidth = 1
        btnReadMore.layer.borderColor = UIColor.gray.cgColor
        filterRecommendation()
        btnPlayVideo.isHidden = true
        imgScrollView.delegate = self
        imgArray = [#imageLiteral(resourceName: "f3"),#imageLiteral(resourceName: "f1") ,#imageLiteral(resourceName: "f2")]
        activityIndicator.cycleColors = [.blue]
        activityIndicator.frame = CGRect(x: view.frame.width/2, y: view.frame.height/2 - 100, width: 40, height: 40)
        activityIndicator.sizeToFit()
        activityIndicator.indicatorMode = .indeterminate
        activityIndicator.progress = 2.0
        imgNews.addSubview(activityIndicator)
        txtViewNewsDesc.textContainer.lineBreakMode = NSLineBreakMode.byTruncatingTail
        /* if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad && statusBarOrientation.isPortrait{
         viewLikeDislike.isHidden = false
         viewBack.isHidden = false
         //addsourceConstraint()
         }
         else if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad && statusBarOrientation.isLandscape {
         viewLikeDislike.isHidden = true
         viewBack.isHidden = true
         //addImageConstaints()
         //addLandscapeConstraints()
         }
         else{
         viewLikeDislike.isHidden = true
         viewBack.isHidden = true
         //addPotraitConstraint()
         //addImageConstaints()
         }*/
        viewLikeDislike.backgroundColor = colorConstants.redColor
        viewBack.backgroundColor = colorConstants.redColor
        ViewWebContainer.isHidden = true
        if ShowArticle.count != 0 {
            indexCount = ShowArticle.count
        }else{
            indexCount = SearchArticle.count
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(darkModeEnabled(_:)), name: .darkModeEnabled, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(darkModeDisabled(_:)), name: .darkModeDisabled, object: nil)
        darkModeStatus = UserDefaults.standard.value(forKey: "darkModeEnabled") as! Bool
        if  darkModeStatus == true{
            changeTheme()
        }
        //newsDetailAPICall(currentIndex: articleId)
        
        ShowNews(currentIndex: newsCurrentIndex)
        // MediaData = DBManager().fetchArticleMedia(articleId: Int(ShowArticle[newsCurrentIndex].article_id))
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeUp.direction = UISwipeGestureRecognizerDirection.up
        self.newsView.addGestureRecognizer(swipeUp)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.newsView.addGestureRecognizer(swipeRight)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeDown.direction = UISwipeGestureRecognizerDirection.down
        self.newsView.addGestureRecognizer(swipeDown)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped(gestureRecognizer:)))
        viewNewsArea.addGestureRecognizer(tapRecognizer)
        tapRecognizer.delegate = self as UIGestureRecognizerDelegate
    }
    
    override func viewDidAppear(_ animated: Bool) {
        timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(runImages), userInfo: nil, repeats: true)
        // runImages()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        timer.invalidate()
    }
    
    @objc func runImages(){
        customPagecontrol.currentPage = index
        if index == MediaData.count - 1{
            index = 0
        }else{
            index = index + 1
        }
        self.taPageControl(customPagecontrol, didSelectPageAt: index)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageindex = imgScrollView.contentOffset.x / imgScrollView.frame.size.width
        customPagecontrol.currentPage = Int(pageindex)
        index = Int(pageindex)
        // runImages()
    }
    
    func filterRecommendation(){
        RecomData.removeAll()
        searchRecomData.removeAll()
        if ShowArticle.count > 0{
            articleId = Int(ShowArticle[newsCurrentIndex].article_id)
            for news in ShowArticle{
                if news.article_id != articleId{
                    RecomData.append(news)
                }
            }
        }else if sourceArticle.count > 0{
            articleId = (sourceArticle[newsCurrentIndex].article_id)!
            for news in sourceArticle{
                if news.article_id != articleId{
                    sourceRecomData.append(news)
                }
            }
        }
        else{
            for news in SearchArticle{
                articleId  = Int(SearchArticle[newsCurrentIndex].article_id)
                if news.article_id != articleId{
                    searchRecomData.append(news)
                }
            }
        }
        suggestedCV.reloadData()
    }
    
    func taPageControl(_ pageControl: TAPageControl!, didSelectPageAt currentIndex: Int) {
        index =  currentIndex
        imgScrollView.scrollRectToVisible(CGRect(x: view.frame.size.width * CGFloat(currentIndex), y:0, width: view.frame.width, height: imgScrollView.frame.height), animated: true)
    }
    func RecommendationAPICall(){
        APICall().loadRecommendationNewsAPI(articleId: articleId){ (status,response) in
            switch response {
            case .Success(let data) :
                self.RecomArticleData = data
                self.suggestedCV.reloadData()
            case .Failure(let errormessage) :
                if errormessage == "no net"{
                    self.view.makeToast(errormessage, duration: 2.0, position: .center)
                }
            case .Change(let code):
                if code == 404{
                    let defaultList = ["googleToken","FBToken","token", "first_name", "last_name", "user_id", "email"]
                    Helper().clearDefaults(list : defaultList)
                    self.NavigationToLogin()
                }
            }
        }
    }
    
    func addipadPotraitConstraint(){
        if viewLikeDislikeBottom != nil {
            NSLayoutConstraint.deactivate([viewLikeDislikeBottom])
            viewLikeDislikeBottom = NSLayoutConstraint (item: viewLikeDislike,
                                                        attribute: NSLayoutAttribute.bottom,
                                                        relatedBy: NSLayoutRelation.equal,
                                                        toItem: suggestedView,
                                                        attribute: NSLayoutAttribute.top,
                                                        multiplier: 1,
                                                        constant: 0)
            NSLayoutConstraint.activate([viewLikeDislikeBottom])
            addsourceConstraint()
        }
    }
    
    func addsourceConstraint(){
        if btnSourceBottomConstraint != nil && lblTimeAgoBottomConstraint != nil {
            NSLayoutConstraint.deactivate([btnSourceBottomConstraint])
            NSLayoutConstraint.deactivate([lblTimeAgoBottomConstraint])
            btnSourceBottomConstraint = NSLayoutConstraint (item: btnSource,
                                                            attribute: NSLayoutAttribute.bottom,
                                                            relatedBy: NSLayoutRelation.equal,
                                                            toItem: viewLikeDislike,
                                                            attribute: NSLayoutAttribute.top,
                                                            multiplier: 1,
                                                            constant: -10)
            lblTimeAgoBottomConstraint = NSLayoutConstraint (item:lblTimeAgo,
                                                             attribute: NSLayoutAttribute.bottom,
                                                             relatedBy: NSLayoutRelation.equal,
                                                             toItem: viewLikeDislike,
                                                             attribute: NSLayoutAttribute.top,
                                                             multiplier: 1,
                                                             constant: -10)
            NSLayoutConstraint.activate([lblTimeAgoBottomConstraint])
            NSLayoutConstraint.activate([btnSourceBottomConstraint])
        }
    }
    
    func addPotraitConstraint(){
        if viewLikeDislikeBottom != nil{
            NSLayoutConstraint.deactivate([viewLikeDislikeBottom])
            viewLikeDislikeBottom = NSLayoutConstraint (item: viewLikeDislike,
                                                        attribute: NSLayoutAttribute.bottom,
                                                        relatedBy: NSLayoutRelation.equal,
                                                        toItem: suggestedView,
                                                        attribute: NSLayoutAttribute.bottom,
                                                        multiplier: 1,
                                                        constant: 0)
            NSLayoutConstraint.activate([viewLikeDislikeBottom])
        }
        newsAreaHeightConstraint.constant = 100
        viewLikeDislikeHeightConstraint.constant = -26.5
        
    }
    
    func addImageConstaints(){
        if viewImgContainerTop != nil{
            NSLayoutConstraint.deactivate([viewImgContainerTop])
            viewImgContainerTop = NSLayoutConstraint (item:viewImgContainer,
                                                      attribute: NSLayoutAttribute.top,
                                                      relatedBy: NSLayoutRelation.equal,
                                                      toItem: viewContainer,
                                                      attribute: NSLayoutAttribute.top,
                                                      multiplier: 1,
                                                      constant: 0)
            NSLayoutConstraint.activate([viewImgContainerTop])
            
        }
    }
    
    func addLandscapeConstraints(){
        if btnSourceBottomConstraint != nil && lblTimeAgoBottomConstraint != nil {
            NSLayoutConstraint.deactivate([btnSourceBottomConstraint])
            NSLayoutConstraint.deactivate([lblTimeAgoBottomConstraint])
            btnSourceBottomConstraint = NSLayoutConstraint(item:btnSource,
                                                           attribute: NSLayoutAttribute.bottom,
                                                           relatedBy: NSLayoutRelation.equal,
                                                           toItem: suggestedView,
                                                           attribute: NSLayoutAttribute.top,
                                                           multiplier: 1,
                                                           constant: -10)
            lblTimeAgoBottomConstraint = NSLayoutConstraint (item:lblTimeAgo,
                                                             attribute: NSLayoutAttribute.bottom,
                                                             relatedBy: NSLayoutRelation.equal,
                                                             toItem: suggestedView,
                                                             attribute: NSLayoutAttribute.top,
                                                             multiplier: 1,
                                                             constant: -10)
            NSLayoutConstraint.activate([lblTimeAgoBottomConstraint])
            NSLayoutConstraint.activate([btnSourceBottomConstraint])
        }
        if viewLikeDislikeBottom != nil{
            NSLayoutConstraint.deactivate([viewLikeDislikeBottom])
            viewLikeDislikeBottom = NSLayoutConstraint(item:viewLikeDislike,
                                                       attribute: NSLayoutAttribute.bottom,
                                                       relatedBy: NSLayoutRelation.equal,
                                                       toItem: suggestedView,
                                                       attribute: NSLayoutAttribute.bottom,
                                                       multiplier: 1,
                                                       constant: 0)
            
            NSLayoutConstraint.activate([viewLikeDislikeBottom])
        }
        
        if viewLikeDislikeHeightConstraint != nil{
            NSLayoutConstraint.deactivate([viewLikeDislikeHeightConstraint])
            viewLikeDislikeHeightConstraint.constant = -8.5
            NSLayoutConstraint.activate([viewLikeDislikeHeightConstraint])
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        super.viewWillTransition(to: size, with: coordinator)
        
        /* if UIDevice.current.orientation.isLandscape {
         print(UIDevice.current.orientation)
         viewLikeDislike.isHidden = true
         viewBack.isHidden = true
         print("landscape")
         addLandscapeConstraints()
         } else {
         print(UIDevice.current.orientation)
         print("potrait")
         viewLikeDislike.isHidden = false
         viewBack.isHidden = false
         if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad{
         addipadPotraitConstraint()
         }
         else{
         addPotraitConstraint()
         }
         }*/
    }
    
    @objc private func darkModeEnabled(_ notification: Notification){
        NightNight.theme = .night
        changeTheme()
        darkModeStatus = UserDefaults.standard.value(forKey: "darkModeEnabled") as! Bool
    }
    
    @objc private func darkModeDisabled(_ notification: Notification) {
        NightNight.theme = .normal
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .darkModeEnabled, object: nil)
        NotificationCenter.default.removeObserver(self, name: .darkModeDisabled, object: nil)
    }
    
    //create thumbnail of video
    func getThumbnailImage(forUrl url: URL) -> UIImage? {
        let asset: AVAsset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        do {
            let thumbnailImage = try imageGenerator.copyCGImage(at: CMTimeMake(1, 60) , actualTime: nil)
            return UIImage(cgImage: thumbnailImage)
        } catch let error {
            print(error)
        }
        
        return nil
    }
    
    func createThumbnailOfVideoFromRemoteUrl(url: String) -> UIImage? {
        let asset = AVAsset(url: URL(string: url)!)
        let assetImgGenerate = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        let time = CMTimeMakeWithSeconds(1.0, 600)
        do {
            let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
            let thumbnail = UIImage(cgImage: img)
            return thumbnail
        } catch {
            return nil
        }
    }
    
    func changeTheme(){
        suggestedCV.backgroundColor = colorConstants.txtlightGrayColor
        btnSource.setTitleColor(.white, for: UIControlState.normal)
        btnMoreStories.setTitleColor(.white, for: UIControlState.normal)
        viewReadMore.backgroundColor = colorConstants.txtlightGrayColor
        btnReadMore.setTitleColor(.white, for: UIControlState.normal)
        btnReadMore.backgroundColor = colorConstants.txtlightGrayColor
        newsView.backgroundColor = colorConstants.grayBackground1
        viewContainer.backgroundColor = colorConstants.grayBackground1
        viewNewsArea.backgroundColor = colorConstants.grayBackground1
        txtViewNewsDesc.backgroundColor = colorConstants.grayBackground1
        lblNewsHeading.textColor = colorConstants.whiteColor
        txtViewNewsDesc.textColor = colorConstants.whiteColor
        viewWebTitle.backgroundColor = colorConstants.grayBackground3
        lblWebSource.textColor = .white
        imgNews.backgroundColor = colorConstants.txtlightGrayColor
    }
    
    @objc func PlayerViewtapped(gestureRecognizer: UITapGestureRecognizer) {
        if btnPlayVideo.isHidden == true{
            btnPlayVideo.isHidden = false
        }
        else{
            btnPlayVideo.isHidden = true
        }
    }
    
    @objc func tapped(gestureRecognizer: UITapGestureRecognizer) {
        /*if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone {
         if viewLikeDislike.isHidden == true{
         viewLikeDislike.isHidden = false
         viewBack.isHidden = false
         }
         else{
         viewLikeDislike.isHidden = true
         viewBack.isHidden = true
         }
         }
         if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad{
         if statusBarOrientation.isPortrait {
         viewLikeDislike.isHidden = false
         viewBack.isHidden = false
         }
         else{
         if viewLikeDislike.isHidden == true{
         viewLikeDislike.isHidden = false
         viewBack.isHidden = false
         }
         else{
         viewLikeDislike.isHidden = true
         viewBack.isHidden = true
         }
         }
         }*/
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        changeFont()
    }
    
    func changeFont(){
        let textSizeSelected = UserDefaults.standard.value(forKey: "textSize") as! Int
        
        if textSizeSelected == 0{
            lblNewsHeading.font = FontConstants.smallFontHeadingBold
            btnSource.titleLabel?.font =  FontConstants.smallFontContentMedium
            txtViewNewsDesc.font = FontConstants.smallFontTitle
        }
        else if textSizeSelected == 2{
            lblNewsHeading.font = FontConstants.LargeFontHeadingBold
            btnSource.titleLabel?.font =  FontConstants.LargeFontContentMedium
            txtViewNewsDesc.font = FontConstants.LargeFontTitle
        }
        else{
            lblNewsHeading.font = FontConstants.NormalFontHeadingBold
            btnSource.titleLabel?.font =  FontConstants.NormalFontContentMedium
            txtViewNewsDesc.font = FontConstants.NormalFontTitle
        }
    }
    
    //response to swipe gestures
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        
        let transition = CATransition()
        transition.duration = 0.5
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                ViewWebContainer.isHidden = true
                //                viewLikeDislike.isHidden = false
                //                viewBack.isHidden = false
                
            case UISwipeGestureRecognizerDirection.down:
                if newsCurrentIndex > 0
                {
                    suggestedView.isHidden = true
                    newsCurrentIndex = newsCurrentIndex - 1
                    ShowNews(currentIndex : newsCurrentIndex)
                    filterRecommendation()
                    transition.type = kCATransitionPush
                    transition.subtype = kCATransitionFromBottom
                    view.window!.layer.add(transition, forKey: kCATransition)
                }
                else{
                    self.view.makeToast("No more news to show", duration: 1.0, position: .center)
                }
                
            case UISwipeGestureRecognizerDirection.up:
                if newsCurrentIndex < indexCount - 1
                {
                    newsCurrentIndex = newsCurrentIndex + 1
                    suggestedView.isHidden = true
                    ShowNews(currentIndex : newsCurrentIndex)
                    filterRecommendation()
                    transition.type = kCATransitionPush
                    transition.subtype = kCATransitionFromTop
                    view.window!.layer.add(transition, forKey: kCATransition)
                }
                else{
                    self.view.makeToast("No more news to show", duration: 1.0, position: .center)
                }
            default:
                break
            }
        }
    }
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicator.startAnimating()
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicator.stopAnimating()
    }
    func webViewDidFinishLoad(_ : WKWebView) {
        activityIndicator.stopAnimating()
    }
    @IBAction func btnPlayVideo(_ sender: Any) {
        if player?.rate == 0
        {
            player!.play()
            btnPlayVideo.setImage(UIImage(named: AssetConstants.pause), for: .normal)
            btnPlayVideo.isHidden = true
            Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(ShowPausebtn), userInfo: nil, repeats: false)
        } else {
            player!.pause()
            btnPlayVideo.setImage(UIImage(named: AssetConstants.play), for: .normal)
        }
    }
    
    //for play button created programmatically
    @objc func ShowPlayPausebtn() {
        if (btnPlay.currentImage?.isEqual(UIImage(named: AssetConstants.pause)))! {
            btnPlay.isHidden = true
        }
    }
    
    @objc func ShowPausebtn() {
        if (btnPlayVideo.currentImage?.isEqual(UIImage(named: AssetConstants.pause)))! {
            btnPlayVideo.isHidden = true
        }
    }
    
    @objc func playbackSliderValueChanged(_ playbackSlider:UISlider){
        let seconds : Int64 = Int64(playbackSlider.value)
        let targetTime:CMTime = CMTimeMake(seconds, 1)
        player!.seek(to: targetTime)
        
        if player!.rate == 0{
            player?.pause()
        }
        else{
            player?.play()
        }
    }
    
    //for play button created programmatically
    @objc func buttonTapped(sender : UIButton) {
        if player?.rate == 0{
            player!.play()
            btnPlay.setImage(UIImage(named: AssetConstants.pause), for: .normal)
            btnPlay.isHidden = true
            Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(ShowPlayPausebtn), userInfo: nil, repeats: false)
        } else {
            player!.pause()
            btnPlay.setImage(UIImage(named: AssetConstants.play), for: .normal)
        }
    }
    
    func fetchSearchBookmarkDataFromDB(){
        let result = DBManager().FetchSearchLikeBookmarkFromDB()
        switch result {
        case .Success(let DBData) :
            if DBData.count == 0{
                activityIndicator.stopAnimating()
            }
        case .Failure( _) : break
        }
    }
    
    func fetchBookmarkDataFromDB(){
        let result = DBManager().FetchLikeBookmarkFromDB()
        switch result {
        case .Success(let DBData) :
            if DBData.count == 0{
                activityIndicator.stopAnimating()
            }
        case .Failure(let errorMsg) : break
        }
    }
    
    //func ShowNews(currentArticle: ArticleDict){ *for detail API pass articleDict
    func ShowNews(currentIndex: Int){
        MediaData.removeAll()
        activityIndicator.startAnimating()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.timeZone = NSTimeZone.local
        playbackSlider.removeFromSuperview()
        // avPlayerView.isHidden = true
        
        if ShowArticle.count > 0{
            fetchBookmarkDataFromDB()
            currentEntity = "ShowArticle"
            let currentArticle = ShowArticle[currentIndex]
            let newDate = dateFormatter.date(from: currentArticle.published_on!)
            var agoDate = ""
            if newDate != nil{
                agoDate = Helper().timeAgoSinceDate(newDate!)
            }
            articleId = Int(currentArticle.article_id)
            lblNewsHeading.text = currentArticle.title
            txtViewNewsDesc.text = currentArticle.blurb
            var fullTxt = "\(agoDate)" + " via " + currentArticle.source!
            let attributedWithTextColor: NSAttributedString = fullTxt.attributedStringWithColor([currentArticle.source!], color: UIColor.red)
            
            btnSource.setAttributedTitle(attributedWithTextColor, for: .normal)
            sourceURL = currentArticle.source_url!
            if currentArticle.imageURL != ""{
                
                let imgURL = APPURL.imageServer + imgWidth + "x" + imgHeight + "/smart/" + currentArticle.imageURL!
                print("newImage URL : \(imgURL)")
                imgNews.sd_setImage(with: URL(string: imgURL), placeholderImage: nil, options: SDWebImageOptions.refreshCached)
            }
            else{
                imgNews.image = UIImage(named: AssetConstants.NoImage)
            }
            if UserDefaults.standard.value(forKey: "token") != nil{
                if currentArticle.likeDislike?.isLike == 0 {
                    btnLike.setImage(UIImage(named: AssetConstants.thumb_up_filled), for: .normal)
                    btnDislike.setImage(UIImage(named: AssetConstants.thumb_down), for: .normal)
                }
                else if currentArticle.likeDislike?.isLike == 1{
                    btnLike.setImage(UIImage(named: AssetConstants.thumb_up), for: .normal)
                    btnDislike.setImage(UIImage(named: AssetConstants.thumb_down_filled), for: .normal)
                }
                else{
                    btnLike.setImage(UIImage(named: AssetConstants.thumb_up), for: .normal)
                    btnDislike.setImage(UIImage(named: AssetConstants.thumb_down), for: .normal)
                }
                if currentArticle.bookmark?.isBookmark == 1 {
                    setBookmarkImg()
                }else{
                    ResetBookmarkImg()
                }
            }else{
                btnLike.setImage(UIImage(named: AssetConstants.thumb_up), for: .normal)
                btnDislike.setImage(UIImage(named: AssetConstants.thumb_down), for: .normal)
                ResetBookmarkImg()
            }
            /* let result = DBManager().fetchArticleMedia(articleId: Int(ShowArticle[currentIndex].article_id))
             switch result {
             case .Success(let DBData) :
             MediaData = DBData
             case .Failure(let errorMsg) :
             print(errorMsg)
             }
             
             if currentArticle.imageURL != ""{
             
             for img in 0..<MediaData.count + 1 {
             
             let imageView = UIImageView()
             let xPosition = imgScrollView.frame.width *  CGFloat(img)
             imageView.frame = CGRect(x:xPosition, y: 0, width: self.imgScrollView.frame.width, height: hideView.frame.height)
             imageView.contentMode = .scaleAspectFit
             if img == 0 {
             imageView.sd_setImage(with: URL(string: currentArticle.imageURL!), placeholderImage: nil, options: SDWebImageOptions.refreshCached)
             imgScrollView.addSubview(imageView)
             }
             else if img > 0{
             if MediaData[img - 1].videoURL == nil{
             //avPlayerView.isHidden = true
             imageView.sd_setImage(with: URL(string: MediaData[img - 1].imageURL!), placeholderImage: nil, options: SDWebImageOptions.refreshCached)
             
             imgScrollView.addSubview(imageView)
             }else{
             // imageView.sd_setImage(with: URL(string: MediaData[img - 1].videoURL!), placeholderImage: nil, options: SDWebImageOptions.refreshCached)//imgArray[img]
             btnPlayVideo.isHidden = false
             let avPlayerView = AVPlayerView()
             let PlayerTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(PlayerViewtapped(gestureRecognizer:)))
             avPlayerView.addGestureRecognizer(PlayerTapRecognizer)
             PlayerTapRecognizer.delegate = self as UIGestureRecognizerDelegate
             avPlayerView.frame = CGRect(x:xPosition, y: 0, width: self.imgScrollView.frame.width, height: hideView.frame.height)
             imgScrollView.addSubview(avPlayerView)
             
             btnPlay.frame = CGRect(x: 150, y: 120, width: 50, height: 60)
             btnPlay.layer.cornerRadius = 0.5 * btnPlay.bounds.size.width
             btnPlay.clipsToBounds = true
             btnPlay.setImage(UIImage(named: AssetConstants.play), for: .normal)
             
             avPlayerView.addSubview(btnPlay)
             btnPlay.addTarget(self, action: #selector(self.buttonTapped), for: .touchUpInside)
             
             
             //
             
             let url = URL(string: "https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4")
             let playerItem:AVPlayerItem = AVPlayerItem(url: url!)
             self.player = AVPlayer(playerItem: playerItem)
             
             // self.avPlayerView.isHidden = false
             imageView.isHidden = true
             timer.invalidate()
             let avPlayer = AVPlayerLayer(player: self.player!)
             let castedLayer = avPlayerView.layer as! AVPlayerLayer
             castedLayer.player = self.player
             castedLayer.videoGravity = AVLayerVideoGravity.resizeAspect
             avPlayerView.layoutIfNeeded()
             if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad{
             self.playbackSlider = UISlider(frame:CGRect(x:0, y: avPlayerView.bounds.size.height - 40, width:avPlayerView.bounds.size.width, height: 20))
             }
             else{
             self.playbackSlider = UISlider(frame:CGRect(x:0, y: avPlayerView.bounds.size.height - 100, width:avPlayerView.bounds.size.width, height: 20))
             }
             self.playbackSlider.minimumValue = 0
             
             
             let duration : CMTime = playerItem.asset.duration
             let seconds : Float64 = CMTimeGetSeconds(duration)
             
             self.playbackSlider.maximumValue = Float(seconds)
             self.playbackSlider.isContinuous = true
             self.playbackSlider.tintColor = UIColor.green
             
             self.playbackSlider.addTarget(self, action: #selector(NewsDetailVC.playbackSliderValueChanged(_:)), for: .valueChanged)
             avPlayerView.addSubview(self.playbackSlider)
             player!.play()
             
             }
             
             }
             //imgScrollView.contentSize.width = imgScrollView.frame.width * CGFloat(img + 1)
             // imgScrollView.contentSize.height  = avPlayerView.frame.height
             
             
             
             }
             // y: imgScrollView.frame.origin.y + imgScrollView.frame.size.height
             index = 0
             customPagecontrol = TAPageControl(frame: CGRect(x : 0, y: 90, width: imgScrollView.frame.size.width, height : hideView.frame.size.height))
             customPagecontrol.delegate = self
             customPagecontrol.numberOfPages = MediaData.count
             customPagecontrol.dotSize = CGSize(width: 20,height: 20)
             imgScrollView.contentSize = CGSize(width: view.frame.size.width * CGFloat(MediaData.count), height: imgScrollView.frame.size.height)
             self.imgScrollView.addSubview(customPagecontrol)
             
             }
             else{
             let imageView = UIImageView()
             imageView.frame = CGRect(x:0, y: 0, width: hideView.frame.width, height: hideView.frame.height)
             imageView.contentMode = .scaleAspectFit
             imgScrollView.contentSize.width = hideView.frame.width
             imgScrollView.contentSize.height  = hideView.frame.height
             imageView.image = UIImage(named: AssetConstants.NoImage)
             imgScrollView.addSubview(imageView)
             }
             */
            
            /* var checkImg = false
             let imageFormats = ["jpg", "jpeg", "png", "gif"]
             for ext in imageFormats{
             if currentArticle.imageURL!.contains(ext){
             checkImg = true
             break
             }
             }
             
             if checkImg == false{
             DispatchQueue.global(qos: .userInitiated).async {
             self.activityIndicator.startAnimating()
             let newURL = NSURL(string: currentArticle.imageURL!)
             if let thumbnail = self.createThumbnailOfVideoFromRemoteUrl(url: "https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4"){
             self.imgNews.image = thumbnail
             let url = URL(string: "https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4")
             let playerItem:AVPlayerItem = AVPlayerItem(url: url!)
             self.player = AVPlayer(playerItem: playerItem)
             
             self.avPlayerView.isHidden = false
             let avPlayer = AVPlayerLayer(player: self.player!)
             let castedLayer = self.avPlayerView.layer as! AVPlayerLayer
             castedLayer.player = self.player
             castedLayer.videoGravity = AVLayerVideoGravity.resizeAspect
             self.avPlayerView.layoutIfNeeded()
             if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad{
             self.playbackSlider = UISlider(frame:CGRect(x:0, y: self.avPlayerView.bounds.size.height - 40, width:self.avPlayerView.bounds.size.width, height: 20))
             }
             else{
             self.playbackSlider = UISlider(frame:CGRect(x:0, y: self.avPlayerView.bounds.size.height - 100, width:self.avPlayerView.bounds.size.width, height: 20))
             }
             self.playbackSlider.minimumValue = 0
             
             
             let duration : CMTime = playerItem.asset.duration
             let seconds : Float64 = CMTimeGetSeconds(duration)
             
             self.playbackSlider.maximumValue = Float(seconds)
             self.playbackSlider.isContinuous = true
             self.playbackSlider.tintColor = UIColor.green
             
             self.playbackSlider.addTarget(self, action: #selector(NewsDetailVC.playbackSliderValueChanged(_:)), for: .valueChanged)
             self.avPlayerView.addSubview(self.playbackSlider)
             self.btnPlayVideo.isHidden = false
             }
             DispatchQueue.main.async {
             self.activityIndicator.stopAnimating()
             }
             }
             }
             
             else{
             self.btnPlayVideo.isHidden = true
             self.avPlayerView.isHidden = true
             self.imgNews.sd_setImage(with: URL(string: currentArticle.imageURL!), placeholderImage: nil, options: SDWebImageOptions.refreshCached)
             }*/
            
        }
        else if SearchArticle.count > 0 {
            currentEntity = "SearchArticles"
            fetchSearchBookmarkDataFromDB()
            let currentArticle = SearchArticle[currentIndex]
            let newDate = dateFormatter.date(from: currentArticle.published_on!)
            var agoDate = ""
            if newDate != nil{
                agoDate = Helper().timeAgoSinceDate(newDate!)
            }
            articleId = Int(currentArticle.article_id)
            lblNewsHeading.text = currentArticle.title
            txtViewNewsDesc.text = currentArticle.blurb
            var fullTxt = "\(agoDate)" + " via " + currentArticle.source!
            let attributedWithTextColor: NSAttributedString = fullTxt.attributedStringWithColor([currentArticle.source!], color: UIColor.red)
            
            btnSource.setAttributedTitle(attributedWithTextColor, for: .normal)
            sourceURL = currentArticle.source_url!
            if currentArticle.imageURL != ""{
                
                let imgURL = APPURL.imageServer + imgWidth + "x" + imgHeight + "/smart/" + currentArticle.imageURL!
                print("newImage URL : \(imgURL)")
                imgNews.sd_setImage(with: URL(string: imgURL), placeholderImage: nil, options: SDWebImageOptions.refreshCached)
            }
            else{
                imgNews.image = UIImage(named: AssetConstants.NoImage)
            }
            /*
             
             var checkImg = false
             let imageFormats = ["jpg", "jpeg", "png", "gif"]
             for ext in imageFormats{
             if currentArticle.imageURL!.contains(ext){
             checkImg = true
             break
             }
             }
             if checkImg == false{
             DispatchQueue.global(qos: .userInitiated).async {
             self.activityIndicator.startAnimating()
             let newURL = NSURL(string: currentArticle.imageURL!)
             if let thumbnail = self.createThumbnailOfVideoFromRemoteUrl(url: "https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4"){
             self.imgNews.image = thumbnail
             let url = URL(string: "https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4")
             let playerItem:AVPlayerItem = AVPlayerItem(url: url!)
             self.player = AVPlayer(playerItem: playerItem)
             
             // self.avPlayerView.isHidden = false
             let avPlayer = AVPlayerLayer(player: self.player!)
             let castedLayer = self.avPlayerView.layer as! AVPlayerLayer
             castedLayer.player = self.player
             castedLayer.videoGravity = AVLayerVideoGravity.resizeAspect
             self.avPlayerView.layoutIfNeeded()
             if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad{
             self.playbackSlider = UISlider(frame:CGRect(x:0, y: self.avPlayerView.bounds.size.height - 40, width:avPlayerView.bounds.size.width, height: 20))
             }
             else{
             self.playbackSlider = UISlider(frame:CGRect(x:0, y: self.avPlayerView.bounds.size.height - 100, width:avPlayerView.bounds.size.width, height: 20))
             }
             self.playbackSlider.minimumValue = 0
             
             
             let duration : CMTime = playerItem.asset.duration
             let seconds : Float64 = CMTimeGetSeconds(duration)
             
             self.playbackSlider.maximumValue = Float(seconds)
             self.playbackSlider.isContinuous = true
             self.playbackSlider.tintColor = UIColor.green
             
             self.playbackSlider.addTarget(self, action: #selector(NewsDetailVC.playbackSliderValueChanged(_:)), for: .valueChanged)
             self.avPlayerView.addSubview(self.playbackSlider)
             self.btnPlayVideo.isHidden = false
             }
             DispatchQueue.main.async {
             self.activityIndicator.stopAnimating()
             }
             }
             
             }
             else{
             self.btnPlayVideo.isHidden = true
             //  self.avPlayerView.isHidden = true
             self.imgNews.sd_setImage(with: URL(string: currentArticle.imageURL!), placeholderImage: nil, options: SDWebImageOptions.refreshCached)
             }*/
            
            if UserDefaults.standard.value(forKey: "token") != nil{
                if currentArticle.likeDislike?.isLike == 0 {
                    btnLike.setImage(UIImage(named: AssetConstants.thumb_up_filled), for: .normal)
                    btnDislike.setImage(UIImage(named: AssetConstants.thumb_down), for: .normal)
                }
                else if currentArticle.likeDislike?.isLike == 1{
                    btnLike.setImage(UIImage(named: AssetConstants.thumb_up), for: .normal)
                    btnDislike.setImage(UIImage(named: AssetConstants.thumb_down_filled), for: .normal)
                }
                else{
                    btnLike.setImage(UIImage(named: AssetConstants.thumb_up), for: .normal)
                    btnDislike.setImage(UIImage(named: AssetConstants.thumb_down), for: .normal)
                }
                if currentArticle.bookmark?.isBookmark == 1 {
                    setBookmarkImg()
                }else{
                    ResetBookmarkImg()
                }
            }else{
                btnLike.setImage(UIImage(named: AssetConstants.thumb_up), for: .normal)
                btnDislike.setImage(UIImage(named: AssetConstants.thumb_down), for: .normal)
                ResetBookmarkImg()
            }
        }
        else if sourceArticle.count > 0{
            currentEntity = "source"
            let currentArticle = sourceArticle[currentIndex]
            let newDate = dateFormatter.date(from: currentArticle.published_on!)
            var agoDate = ""
            if newDate != nil{
                agoDate = Helper().timeAgoSinceDate(newDate!)
            }
            articleId = Int(currentArticle.article_id)
            lblNewsHeading.text = currentArticle.title
            txtViewNewsDesc.text = currentArticle.blurb
            var fullTxt = "\(agoDate)" + " via " + currentArticle.source!
            let attributedWithTextColor: NSAttributedString = fullTxt.attributedStringWithColor([currentArticle.source!], color: UIColor.red)
            
            btnSource.setAttributedTitle(attributedWithTextColor, for: .normal)
            sourceURL = (currentArticle.source!)
            if currentArticle.imageURL != ""{
                
                let imgURL = APPURL.imageServer + imgWidth + "x" + imgHeight + "/smart/" + currentArticle.imageURL!
                print("newImage URL : \(imgURL)")
                imgNews.sd_setImage(with: URL(string: imgURL), placeholderImage: nil, options: SDWebImageOptions.refreshCached)
            }
            else{
                imgNews.image = UIImage(named: AssetConstants.NoImage)
            }
          
        }
        if imgNews.image == nil{
            imgNews.image = UIImage(named: AssetConstants.NoImage)
        }
        activityIndicator.stopAnimating()
    }
    
    @IBAction func btnLikeActn(_ sender: Any) {
        if UserDefaults.standard.value(forKey: "token") != nil || UserDefaults.standard.value(forKey: "FBToken") != nil || UserDefaults.standard.value(forKey: "googleToken") != nil{
            if (btnLike.currentImage?.isEqual(UIImage(named: AssetConstants.thumb_up)))! {
                let param = ["article_id" : articleId,
                             "isLike" : 0]
                APICall().LikeDislikeAPI(param : param){
                    (status,response) in
                    if status == "0"{
                        self.view.makeToast(response, duration: 1.0, position: .center)
                    }
                    else{
                        self.btnLike.setImage(UIImage(named: AssetConstants.thumb_up_filled), for: .normal)
                        if (self.btnDislike.currentImage?.isEqual(UIImage(named: AssetConstants.thumb_down_filled)))! {
                            self.btnDislike.setImage(UIImage(named: AssetConstants.thumb_down), for: .normal)
                            
                        }
                        self.view.makeToast(response, duration: 1.0, position: .center)
                        DBManager().addLikedArticle(tempentity: self.currentEntity, id: self.articleId, status: 0)
                    }
                }
            }
            else{
                let param = ["article_id" : articleId,
                             "isLike" : 2]
                APICall().LikeDislikeAPI(param: param){
                    (status,response) in
                    if status == "0"{
                        self.view.makeToast(response, duration: 1.0, position: .center)
                    }
                    else{
                        DBManager().deleteLikedDislikedArticle(id: self.articleId){
                            response in
                            if response == true{
                                self.btnLike.setImage(UIImage(named: AssetConstants.thumb_up), for: .normal)
                            }
                        }
                    }
                }
            }
        }
        else{
            NavigationToLogin()
        }
    }
    
    @IBAction func btnDislikeActn(_ sender: Any) {
        if UserDefaults.standard.value(forKey: "token") != nil || UserDefaults.standard.value(forKey: "FBToken") != nil || UserDefaults.standard.value(forKey: "googleToken") != nil{
            if (btnDislike.currentImage?.isEqual(UIImage(named: AssetConstants.thumb_down)))! {
                let param = ["article_id" : articleId,
                             "isLike" : 1]
                APICall().LikeDislikeAPI(param : param ){
                    (status,response) in
                    if status == "0"{
                        self.view.makeToast(response, duration: 1.0, position: .center)
                    }
                    else{
                        self.btnDislike.setImage(UIImage(named: AssetConstants.thumb_down_filled), for: .normal)
                        if (self.btnLike.currentImage?.isEqual(UIImage(named: AssetConstants.thumb_up_filled)))! {
                            self.btnLike.setImage(UIImage(named: AssetConstants.thumb_up), for: .normal)
                        }
                        self.view.makeToast(response, duration: 1.0, position: .center)
                        DBManager().addLikedArticle(tempentity:self.currentEntity, id: self.articleId, status: 1)
                    }
                }
            }
            else{
                let param = ["article_id" : articleId,
                             "isLike" : 2]
                APICall().LikeDislikeAPI(param :param){
                    (status,response) in
                    if status == "0"{
                        self.view.makeToast(response, duration: 1.0, position: .center)
                    }
                    else{
                        DBManager().deleteLikedDislikedArticle(id: self.articleId){ response in
                            if response == true{
                                self.btnDislike.setImage(UIImage(named: AssetConstants.thumb_down), for: .normal)
                            }
                        }
                    }
                }
            }
        }
        else{
            NavigationToLogin()
        }
    }
    
    @IBAction func btnBookmarkActn(_ sender: Any) {
        if UserDefaults.standard.value(forKey: "token") != nil || UserDefaults.standard.value(forKey: "FBToken") != nil || UserDefaults.standard.value(forKey: "googleToken") != nil{
            if (((btnBookamark.currentImage?.isEqual(UIImage(named: AssetConstants.bookmark)))!) || ((btnBookamark.currentImage?.isEqual(UIImage(named: AssetConstants.Bookmark_white)))!)) {
                
                APICall().bookmarkAPI(id: articleId){
                    (status, response) in
                    if status == "0"{
                        self.view.makeToast(response, duration: 1.0, position: .center)
                    }
                    else{
                        self.setBookmarkImg()
                        DBManager().addBookmarkedArticles(currentEntity: self.currentEntity, id: self.articleId)
                        self.view.makeToast(response, duration: 1.0, position: .center)
                    }
                }
            }
            else if (((btnBookamark.currentImage?.isEqual(UIImage(named: AssetConstants.filledBookmark)))!) || ((btnBookamark.currentImage?.isEqual(UIImage(named: AssetConstants.Bookmark_white_fill)))!)){
                APICall().bookmarkAPI(id: articleId){
                    (status, response) in
                    if status == "0"{
                        self.view.makeToast(response, duration: 1.0, position: .center)
                    }
                    else{
                        self.ResetBookmarkImg()
                        DBManager().deleteBookmarkedArticle(id: self.articleId)
                        self.view.makeToast(response, duration: 1.0, position: .center)
                    }
                }
            }
        }
        else{
            NavigationToLogin()
        }
    }
    
    func NavigationToLogin(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc:LoginVC = storyboard.instantiateViewController(withIdentifier: "LoginID") as! LoginVC
        self.present(vc, animated: true, completion: nil)
        UserDefaults.standard.set(false, forKey: "isSettingsLogin")
    }
    
    func setBookmarkImg(){
        if darkModeStatus == true{
            btnBookamark.setImage(UIImage(named: AssetConstants.Bookmark_white_fill), for: .normal)
        }
        else{
            btnBookamark.setImage(UIImage(named: AssetConstants.filledBookmark), for: .normal)
        }
    }
    
    func ResetBookmarkImg(){
        if darkModeStatus == true{
            btnBookamark.setImage(UIImage(named: AssetConstants.Bookmark_white), for: .normal)
        }
        else{
            btnBookamark.setImage(UIImage(named: AssetConstants.bookmark), for: .normal)
        }
    }
    
    @IBAction func btnShareActn(_ sender: Any) {
        var text = ""
        let webURL = "Sent via NewsCout"
        var shareAll : [Any]
        var sourceURL : URL!
        if currentEntity == "ShowArticle"{
            text = ShowArticle[newsCurrentIndex].title!
            if ShowArticle[newsCurrentIndex].imageURL != nil{
                let url = URL(string:ShowArticle[newsCurrentIndex].imageURL!)
                let image1 = UIImage(named: "\(url)")
                var image = UIImage()
                if let data = try? Data(contentsOf: url!)
                {
                    image = UIImage(data: data)!
                }
                if ShowArticle[newsCurrentIndex].source_url != nil{
                    sourceURL = URL(string: ShowArticle[newsCurrentIndex].source_url!)
                }
                shareAll = [ text , image1, image,  sourceURL , webURL ] as [Any]
            }
            else{
                if ShowArticle[newsCurrentIndex].source_url != nil{
                    sourceURL = URL(string: ShowArticle[newsCurrentIndex].source_url!)
                }
                shareAll = [ text , sourceURL , webURL ] as [Any]
            }
        }
        else if currentEntity == "source"{
            text = sourceArticle[newsCurrentIndex].title!
            if sourceArticle[newsCurrentIndex].imageURL != nil{
                let url = URL(string:sourceArticle[newsCurrentIndex].imageURL!)
                let image1 = UIImage(named: "\(url)")
                var image = UIImage()
                if let data = try? Data(contentsOf: url!)
                {
                    image = UIImage(data: data)!
                }
                if sourceArticle[newsCurrentIndex].source != nil{
                    sourceURL = URL(string: sourceArticle[newsCurrentIndex].source!)
                }
                shareAll = [ text , image1, image,  sourceURL , webURL ] as [Any]
            }
            else{
                if sourceArticle[newsCurrentIndex].source! != nil{
                    sourceURL = URL(string: sourceArticle[newsCurrentIndex].source!)
                }
                shareAll = [ text , sourceURL , webURL ] as [Any]
            }
        }
        else{
            if SearchArticle[newsCurrentIndex].imageURL != nil{
                text = SearchArticle[newsCurrentIndex].title!
                let url = URL(string:SearchArticle[newsCurrentIndex].imageURL!)
                let image1 = UIImage(named: "\(url)")
                var image = UIImage()
                if let data = try? Data(contentsOf: url!)
                {
                    image = UIImage(data: data)!
                }
                if SearchArticle[newsCurrentIndex].source_url != nil{
                    sourceURL = URL(string: SearchArticle[newsCurrentIndex].source_url!)
                }
                shareAll = [ text , image1, image,  sourceURL , webURL ] as [Any]
            }
            else{
                if SearchArticle[newsCurrentIndex].source_url != nil{
                    sourceURL = URL(string: SearchArticle[newsCurrentIndex].source_url!)
                }
                shareAll = [ text , sourceURL , webURL ] as [Any]
            }
            
        }
        
        
        let activityViewController = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = sender as! UIView
        self.present(activityViewController, animated: true, completion: nil)
        
    }
    
    @IBAction func btnBackAction(_ sender: Any) {
        let isSearch = UserDefaults.standard.value(forKey: "isSearch") as! String
        if isSearch == "search"{
            self.dismiss(animated: false)
        }
        else if isSearch == "source"{
            self.dismiss(animated: false)
        }
        else if isSearch == "recommend" {
            //self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
            self.dismiss(animated: false)
        }
        else if isSearch == "bookmark"{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc:BookmarkVC = storyboard.instantiateViewController(withIdentifier: "BookmarkID") as! BookmarkVC
            self.present(vc, animated: true, completion: nil)
        }
        else if isSearch == "searchrecommend"{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let searchvc:SearchVC = storyboard.instantiateViewController(withIdentifier: "SearchID") as! SearchVC
            self.present(searchvc, animated: true, completion: nil)
        }
        else if isSearch == "sourcerecommend"{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let sourcevc:SourceVC = storyboard.instantiateViewController(withIdentifier: "SourceID") as! SourceVC
            self.present(sourcevc, animated: true, completion: nil)
        }
        else if isSearch == "home"{
            self.dismiss(animated: false)
        }
    }
    
    @IBAction func btnWebBackAction(_ sender: Any) {
        ViewWebContainer.isHidden = true
        //        viewLikeDislike.isHidden = false
        //        viewBack.isHidden = false
    }
    
    //btn Back Action
    @IBAction func btnBAckAction(_ sender: Any) {
        self.dismiss(animated: false)
    }
    
    @IBAction func PlayButtonTapped() -> Void {
    }
    
    @IBAction func btnSourceActn(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let sourcevc:SourceVC = storyboard.instantiateViewController(withIdentifier: "SourceID") as! SourceVC
        if currentEntity == "SearchArticles"{
             sourcevc.url = APPURL.SourceURL + SearchArticle[newsCurrentIndex].source!
            sourcevc.source = SearchArticle[newsCurrentIndex].source!
        }else if currentEntity == "source"{
            sourcevc.url = APPURL.SourceURL + sourceArticle[newsCurrentIndex].source!
            sourcevc.source = sourceArticle[newsCurrentIndex].source!
        }
        else{
        sourcevc.url = APPURL.SourceURL + ShowArticle[newsCurrentIndex].source!
            sourcevc.source = ShowArticle[newsCurrentIndex].source!
        }
        
        self.present(sourcevc, animated: true, completion: nil)
    }
    
    @IBAction func btnReadMoreActn(_ sender: Any) {
        WKWebView.addSubview(activityIndicator)
        ViewWebContainer.isHidden = false
        let url = URL(string: sourceURL)
        print(sourceURL)
        let domain = url?.host
        lblWebSource.text = "\(domain!)"
        let myURL = URL(string: sourceURL)!
        let myRequest = URLRequest(url: myURL)
        WKWebView.load(myRequest)
    }
    
    @IBAction func btnShuffleActn(_ sender: Any) {
        //            let result = DBManager().FetchDataFromDB(entity: "NewsArticle")
        //            switch result {
        //            case .Success(let DBData) :
        //                if DBData.count == 0{
        //                    let randomInt = Int.random(in: 0..<DBData.count)
        //                    activityIndicator.stopAnimating()
        //                    ShowNews(currentIndex: randomInt)
        //                }
        //            case .Failure(let errorMsg) : break
        //            }
        //
        if newsCurrentIndex < ShowArticle.count - 2{
            newsCurrentIndex = newsCurrentIndex + 2
            ShowNews(currentIndex: newsCurrentIndex)
        }else{
            newsCurrentIndex = newsCurrentIndex - 2
            ShowNews(currentIndex: newsCurrentIndex)
        }
    }
    
    @IBAction func btnMoreStoriesActn(_ sender: Any) {
        if suggestedView.isHidden == true{
            suggestedView.isHidden = false
            btnMoreStories.setTitleColor(.white, for: .normal)
        }else{
            btnMoreStories.setTitleColor(.black, for: .normal)
            suggestedView.isHidden = true
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

extension NewsDetailVC:UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        var width = 1.0
        if indexPath.row == 0{
            if (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad){
                width = 200.0
            }
            else{
                width = 120.0
            }
        }
        else{
            width = 170.0
        }
        return CGSize(width: width, height: Double(suggestedView.frame.size.height))
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // return (self.RecomArticleData.count != 0) ? self.RecomArticleData[0].body!.articles.count + 1 : 0
        if RecomData.count == 0 && searchRecomData.count == 0{
            return 0
        }
        else if RecomData.count >= 5 || searchRecomData.count >= 5{
            return 6
        }else{
            if RecomData.count != 0{
                return RecomData.count + 1
            }else{
                return searchRecomData.count + 1
            }
        }
        // return ShowArticle.count != 0 ? ShowArticle.count : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SuggestedNewsID", for: indexPath) as! SuggestedNewsCVCell
        cell.lblTitle.font = FontConstants.NormalFontContent
        cell.lblMoreStories.font = FontConstants.LargeFontContentBold
        cell.btnCellPlayVIdeo.isHidden = true
        let textSizeSelected = UserDefaults.standard.value(forKey: "textSize") as! Int
        
        if textSizeSelected == 0{
            cell.lblMoreStories.font = FontConstants.smallRecommTitleFont
            cell.lblTitle.font = FontConstants.smallRecommFont
        }
        else if textSizeSelected == 2{
            cell.lblMoreStories.font = FontConstants.largeRecommTitleFont
            cell.lblTitle.font = FontConstants.largeRecommFont
        }
        else{
            cell.lblMoreStories.font = FontConstants.normalRecommTitleFont
            cell.lblTitle.font = FontConstants.normalRecommFont
        }
        if indexPath.row == 0
        {
            cell.lblMoreStories.isHidden = false
            cell.imgNews.isHidden = true
            cell.lblTitle.isHidden = true
            cell.btnCellPlayVIdeo.isHidden = true
        }
        else{
            cell.imgNews.isHidden = false
            cell.lblTitle.isHidden = false
            cell.lblMoreStories.isHidden = true
            if currentEntity == "SearchArticles"{
                let currentArticle =  searchRecomData[indexPath.row - 1] //RecomArticleData[0].body!.articles[indexPath.row - 1]
                cell.lblTitle.text = currentArticle.title
                if currentArticle.imageURL != nil{
                    cell.imgNews.sd_setImage(with: URL(string: currentArticle.imageURL!), placeholderImage: nil, options: SDWebImageOptions.refreshCached)
                }
            }else if currentEntity == "source"{
                let currentArticle =  searchRecomData[indexPath.row - 1] //RecomArticleData[0].body!.articles[indexPath.row - 1]
                cell.lblTitle.text = currentArticle.title
                if currentArticle.imageURL != nil{
                    cell.imgNews.sd_setImage(with: URL(string: currentArticle.imageURL!), placeholderImage: nil, options: SDWebImageOptions.refreshCached)
                }
            }
            else{
                let currentArticle =  RecomData[indexPath.row - 1] //RecomArticleData[0].body!.articles[indexPath.row - 1]
                cell.lblTitle.text = currentArticle.title
                if currentArticle.imageURL != nil{
                    cell.imgNews.sd_setImage(with: URL(string: currentArticle.imageURL!), placeholderImage: nil, options: SDWebImageOptions.refreshCached)
                }
            }
            
            if cell.imgNews.image == nil{
                cell.imgNews.image = UIImage(named: AssetConstants.NoImage)
            }
        }
        
        if  darkModeStatus == true{
            cell.lblMoreStories.textColor = colorConstants.whiteColor
            cell.lblTitle.textColor = colorConstants.whiteColor
            cell.backgroundColor = colorConstants.txtlightGrayColor
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row != 0{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let newsDetailvc:NewsDetailVC = storyboard.instantiateViewController(withIdentifier: "NewsDetailID") as! NewsDetailVC
            let check = UserDefaults.standard.value(forKey: "isSearch") as! String
            if check == "bookmark"{
                UserDefaults.standard.set("bookrecommend", forKey: "isSearch")
            }
            else if check == "search" {
                UserDefaults.standard.set("searchrecommend", forKey: "isSearch")
            }
            else if check == "source"{
                UserDefaults.standard.set("sourcerecommend", forKey: "isSearch")
            }
            else{
                UserDefaults.standard.set("recommend", forKey: "isSearch")
            }
            newsDetailvc.newsCurrentIndex = indexPath.row - 1
            if ShowArticle.count > 0{
                newsDetailvc.ShowArticle =  RecomData //RecomArticleData[0].body!.articles
                newsDetailvc.articleId = Int(RecomData[indexPath.row].article_id)  //RecomArticleData[0].body!.articles[indexPath.row - 1].article_id!
            }else if sourceArticle.count > 0{
                newsDetailvc.sourceArticle = sourceRecomData
                newsDetailvc.articleId = Int(sourceRecomData[indexPath.row].article_id)
            }
            else{
                newsDetailvc.SearchArticle = searchRecomData
                newsDetailvc.articleId = Int(searchRecomData[indexPath.row].article_id)
            }
            present(newsDetailvc, animated: true, completion: nil)
        }
    }
}

extension NewsDetailVC : UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view!.superview!.superclass! .isSubclass(of: UIButton.self) {
            return false
        }
        return true
    }
}
