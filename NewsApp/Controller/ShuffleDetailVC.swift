//
//  ShuffleDetailVC.swift
//  NewsApp
//
//  Created by Jayashree on 27/03/19.
//  Copyright © 2019 Fafadia Tech. All rights reserved.
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

class ShuffleDetailVC: UIViewController , UIScrollViewDelegate, TAPageControlDelegate, WKNavigationDelegate {
    
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var imgNews: UIImageView!
    @IBOutlet var newsView: UIView!
    @IBOutlet weak var lblNewsHeading: UILabel!
    @IBOutlet weak var txtViewNewsDesc: UITextView!
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
    var bookmarkedArticle = [BookmarkArticles]()
    var ShowArticle = [NewsArticle]()
    var shuffleData =  [NewsArticle]()
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
        getShuffleData()
        if shuffleData.count > 0{
            let randomInt = Int.random(in: 0..<shuffleData.count)
            activityIndicator.stopAnimating()
            ShowNews(currentIndex: randomInt)
        }
        viewLikeDislike.backgroundColor = colorConstants.redColor
        viewBack.backgroundColor = colorConstants.redColor
        ViewWebContainer.isHidden = true
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(darkModeEnabled(_:)), name: .darkModeEnabled, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(darkModeDisabled(_:)), name: .darkModeDisabled, object: nil)
        darkModeStatus = UserDefaults.standard.value(forKey: "darkModeEnabled") as! Bool
        if  darkModeStatus == true{
            changeTheme()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(runImages), userInfo: nil, repeats: true)
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
    }
    
    func filterRecommendation(){
        RecomData.removeAll()
        if shuffleData.count > 0{
            articleId = Int(shuffleData[newsCurrentIndex].article_id)
            for news in shuffleData{
                if news.article_id != articleId{
                    RecomData.append(news)
                }
            }
        }
        suggestedCV.reloadData()
    }
    
    func taPageControl(_ pageControl: TAPageControl!, didSelectPageAt currentIndex: Int) {
        index =  currentIndex
        imgScrollView.scrollRectToVisible(CGRect(x: view.frame.size.width * CGFloat(currentIndex), y:0, width: view.frame.width, height: imgScrollView.frame.height), animated: true)
    }
    
 /*   func RecommendationAPICall(){
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
    }*/
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
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
    
    func ShowNews(currentIndex: Int){
        MediaData.removeAll()
        activityIndicator.startAnimating()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.timeZone = NSTimeZone.local
        playbackSlider.removeFromSuperview()
        // avPlayerView.isHidden = true
        
        if shuffleData.count > 0{
            fetchBookmarkDataFromDB()
            if shuffleData[currentIndex].title != nil {
            let currentArticle = shuffleData[currentIndex]
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
        }
        
        if imgNews.image == nil{
            imgNews.image = UIImage(named: AssetConstants.NoImage)
        }
        }
        else{
            getShuffleData()
        }
        activityIndicator.stopAnimating()
    }
    
    @IBAction func btnLikeActn(_ sender: Any) {
        if UserDefaults.standard.value(forKey: "token") != nil{
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
                        DBManager().addLikedArticle(tempentity: "NewsArticle", id: self.articleId, status: 0)
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
        if UserDefaults.standard.value(forKey: "token") != nil{
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
                        DBManager().addLikedArticle(tempentity:"NewsArticle", id: self.articleId, status: 1)
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
        if UserDefaults.standard.value(forKey: "token") != nil {
            if (((btnBookamark.currentImage?.isEqual(UIImage(named: AssetConstants.bookmark)))!) || ((btnBookamark.currentImage?.isEqual(UIImage(named: AssetConstants.Bookmark_white)))!)) {
                
                APICall().bookmarkAPI(id: articleId){
                    (status, response) in
                    if status == "0"{
                        self.view.makeToast(response, duration: 1.0, position: .center)
                    }
                    else{
                        self.setBookmarkImg()
                        DBManager().addBookmarkedArticles(currentEntity: "NewsArticle", id: self.articleId)
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
        text = shuffleData[newsCurrentIndex].title!
        if shuffleData[newsCurrentIndex].imageURL != ""{
            let url = URL(string:shuffleData[newsCurrentIndex].imageURL!)
            let image1 = UIImage(named: "\(url)")
            var image = UIImage()
            if let data = try? Data(contentsOf: url!)
            {
                image = UIImage(data: data)!
            }
            if shuffleData[newsCurrentIndex].source_url != ""{
                sourceURL = URL(string: shuffleData[newsCurrentIndex].source_url!)
            }
            shareAll = [ text , image,  sourceURL , webURL ] as [Any]
        }
        else{
            if shuffleData[newsCurrentIndex].source_url != ""{
                sourceURL = URL(string: shuffleData[newsCurrentIndex].source_url!)
            }
            shareAll = [ text , sourceURL , webURL ] as [Any]
        }
        
        
        let activityViewController = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [UIActivityType.airDrop]
        activityViewController.popoverPresentationController?.sourceView = sender as! UIView
        self.present(activityViewController, animated: true, completion: nil)
        
    }
    
    @IBAction func btnBackAction(_ sender: Any) {
        self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func btnWebBackAction(_ sender: Any) {
        ViewWebContainer.isHidden = true
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
        sourcevc.url = APPURL.SourceURL + shuffleData[newsCurrentIndex].source!
        sourcevc.source = shuffleData[newsCurrentIndex].source!
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
    
    func getShuffleData(){
        let result = DBManager().FetchDataFromDB(entity: "NewsArticle")
        switch result {
        case .Success(let DBData) :
            if DBData.count > 0{
                shuffleData = DBData
                let randomInt = Int.random(in: 0..<DBData.count)
                activityIndicator.stopAnimating()
                ShowNews(currentIndex: randomInt)
                filterRecommendation()
            }
        case .Failure(let errorMsg) : break
        }
    }
    
    @IBAction func btnShuffleActn(_ sender: Any) {
        getShuffleData()
        if shuffleData.count > 0{
            let randomInt = Int.random(in: 0..<shuffleData.count)
            activityIndicator.stopAnimating()
            ShowNews(currentIndex: randomInt)
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

extension ShuffleDetailVC:UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
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
        return RecomData.count != 0 ? RecomData.count + 1 : 0
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
            let currentArticle =  RecomData[indexPath.row - 1] //RecomArticleData[0].body!.articles[indexPath.row - 1]
            cell.lblTitle.text = currentArticle.title
            if currentArticle.imageURL != nil{
                cell.imgNews.sd_setImage(with: URL(string: currentArticle.imageURL!), placeholderImage: nil, options: SDWebImageOptions.refreshCached)
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
            if shuffleData.count > 0{
                newsDetailvc.shuffleData =  RecomData
                newsDetailvc.articleId = Int(RecomData[indexPath.row].article_id)
            }
            present(newsDetailvc, animated: true, completion: nil)
        }
    }
}

extension ShuffleDetailVC : UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view!.superview!.superclass! .isSubclass(of: UIButton.self) {
            return false
        }
        return true
    }
}

