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

class NewsDetailVC: UIViewController {
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
    @IBOutlet weak var avPlayerView: AVPlayerView!
    @IBOutlet weak var viewBack: UIView!
    @IBOutlet weak var imgScrollView: UIScrollView!
    
    let imageCache = NSCache<NSString, UIImage>()
    var playbackSlider = UISlider()
    var RecomArticleData = [ArticleStatus]()
    var ArticleData = [ArticleStatus]()
    var bookmarkedArticle = [BookmarkArticles]()
    var ShowArticle = [NewsArticle]()
    var SearchArticle = [SearchArticles]()
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
    var indexCount = 0
    var currentEntity = ""
    var imgArray = [UIImage]()
    var MediaData = [Media]()
   // let imageView = UIImageView()
    override func viewDidLoad() {
        super.viewDidLoad()
         imgNews.isHidden = true
       btnPlayVideo.isHidden = true
       avPlayerView.isHidden = true
        imgScrollView.delegate = self
        btnPlayVideo.isHidden = true
        imgArray = [#imageLiteral(resourceName: "f3"),#imageLiteral(resourceName: "f1") ,#imageLiteral(resourceName: "f2")]
        activityIndicator.cycleColors = [.blue]
        activityIndicator.frame = CGRect(x: view.frame.width/2, y: view.frame.height/2 - 100, width: 40, height: 40)
        activityIndicator.sizeToFit()
        activityIndicator.indicatorMode = .indeterminate
        activityIndicator.progress = 2.0
        imgNews.addSubview(activityIndicator)
        txtViewNewsDesc.textContainer.lineBreakMode = NSLineBreakMode.byTruncatingTail
        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad && statusBarOrientation.isPortrait{
            viewLikeDislike.isHidden = false
            viewBack.isHidden = false
            addsourceConstraint()
        }
        else if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad && statusBarOrientation.isLandscape {
            viewLikeDislike.isHidden = true
            viewBack.isHidden = true
            addLandscapeConstraints()
        }
        else{
            viewLikeDislike.isHidden = true
            viewBack.isHidden = true
            addPotraitConstraint()
        }
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
        self.viewNewsArea.addGestureRecognizer(swipeUp)
        
//        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
//        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
//        self.newsView.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.newsView.addGestureRecognizer(swipeRight)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeDown.direction = UISwipeGestureRecognizerDirection.down
        self.viewNewsArea.addGestureRecognizer(swipeDown)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped(gestureRecognizer:)))
        viewNewsArea.addGestureRecognizer(tapRecognizer)
        tapRecognizer.delegate = self as UIGestureRecognizerDelegate
        
        let PlayerTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(PlayerViewtapped(gestureRecognizer:)))
        avPlayerView.addGestureRecognizer(PlayerTapRecognizer)
        PlayerTapRecognizer.delegate = self as UIGestureRecognizerDelegate
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
        if lblSourceBottomConstraint != nil && lblTimeAgoBottomConstraint != nil {
            NSLayoutConstraint.deactivate([lblSourceBottomConstraint])
            NSLayoutConstraint.deactivate([lblTimeAgoBottomConstraint])
            lblSourceBottomConstraint = NSLayoutConstraint (item: lblSource,
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
            NSLayoutConstraint.activate([lblSourceBottomConstraint])
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
    
    func addLandscapeConstraints(){
        if lblSourceBottomConstraint != nil && lblTimeAgoBottomConstraint != nil {
            NSLayoutConstraint.deactivate([lblSourceBottomConstraint])
            NSLayoutConstraint.deactivate([lblTimeAgoBottomConstraint])
            lblSourceBottomConstraint = NSLayoutConstraint(item:lblSource,
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
            NSLayoutConstraint.activate([lblSourceBottomConstraint])
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
        
        if UIDevice.current.orientation.isLandscape {
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
        }
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
        newsView.backgroundColor = colorConstants.grayBackground1
        viewContainer.backgroundColor = colorConstants.grayBackground1
        viewNewsArea.backgroundColor = colorConstants.grayBackground1
        txtViewNewsDesc.backgroundColor = colorConstants.grayBackground1
        lblNewsHeading.textColor = colorConstants.whiteColor
        lblSource.textColor = colorConstants.whiteColor
        lblTimeAgo.textColor = colorConstants.whiteColor
        txtViewNewsDesc.textColor = colorConstants.whiteColor
        viewWebTitle.backgroundColor = colorConstants.grayBackground3
        lblWebSource.textColor = .white
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
        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone {
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
            lblSource.font = FontConstants.smallFontContentMedium
            lblTimeAgo.font = FontConstants.smallFontContentMedium
            txtViewNewsDesc.font = FontConstants.smallFontTitle
        }
        else if textSizeSelected == 2{
            lblNewsHeading.font = FontConstants.LargeFontHeadingBold
            lblSource.font = FontConstants.LargeFontContentMedium
            lblTimeAgo.font = FontConstants.LargeFontContentMedium
            txtViewNewsDesc.font = FontConstants.LargeFontTitle
        }
        else{
            lblNewsHeading.font = FontConstants.NormalFontHeadingBold
            lblSource.font = FontConstants.NormalFontContentMedium 
            lblTimeAgo.font = FontConstants.NormalFontContentMedium
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
                viewLikeDislike.isHidden = false
                viewBack.isHidden = false
                
            case UISwipeGestureRecognizerDirection.down:
                if newsCurrentIndex > 0
                {
                    newsCurrentIndex = newsCurrentIndex - 1
                    ShowNews(currentIndex : newsCurrentIndex)
                    transition.type = kCATransitionPush
                    transition.subtype = kCATransitionFromBottom
                    view.window!.layer.add(transition, forKey: kCATransition)
                }
                else{
                    self.view.makeToast("No more news to show", duration: 1.0, position: .center)
                }
            case UISwipeGestureRecognizerDirection.left:
                ViewWebContainer.isHidden = false
                viewLikeDislike.isHidden = true
                viewBack.isHidden = true
                let url = URL(string: sourceURL)
                let domain = url?.host
                lblWebSource.text = "\(domain!)"
                transition.type = kCATransitionPush
                transition.subtype = kCATransitionFromRight
                view.window!.layer.add(transition, forKey: kCATransition)
                let myURL = URL(string: sourceURL)!
                let myRequest = URLRequest(url: myURL)
                
                WKWebView.load(myRequest)
                
            case UISwipeGestureRecognizerDirection.up:
                if newsCurrentIndex < indexCount - 1
                {
                    newsCurrentIndex = newsCurrentIndex + 1
                    ShowNews(currentIndex : newsCurrentIndex)
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
    
    @objc func ShowPausebtn() {
        if (btnPlayVideo.currentImage?.isEqual(UIImage(named: AssetConstants.pause)))! {
            btnPlayVideo.isHidden = true
        }
    }
    
    @objc func playbackSliderValueChanged(_ playbackSlider:UISlider){
        let seconds : Int64 = Int64(playbackSlider.value)
        let targetTime:CMTime = CMTimeMake(seconds, 1)
        btnPlayVideo.isHidden = false
        player!.seek(to: targetTime)
        
        if player!.rate == 0{
            player?.pause()
        }
        else{
            player?.play()
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
        avPlayerView.isHidden = true
      
        if ShowArticle.count != 0{
            currentEntity = "ShowArticle"
            let currentArticle = ShowArticle[currentIndex]
            let newDate = dateFormatter.date(from: currentArticle.published_on!)
            let agoDate = Helper().timeAgoSinceDate(newDate!)
            articleId = Int(currentArticle.article_id)
            lblNewsHeading.text = currentArticle.title
            txtViewNewsDesc.text = currentArticle.blurb
            lblSource.text = currentArticle.source
            lblTimeAgo.text = agoDate
            sourceURL = currentArticle.source_url!
            
            let result = DBManager().fetchArticleMedia(articleId: Int(ShowArticle[currentIndex].article_id))
            switch result {
            case .Success(let DBData) :
                MediaData = DBData
            case .Failure(let errorMsg) :
                print(errorMsg)
            }
           
         
            if currentArticle.imageURL != ""{
               
                for img in 0..<MediaData.count + 1 {
                                     //imgArray.count {
               
                    let imageView = UIImageView()
                    imageView.contentMode = .scaleAspectFit
                let xPosition = imgScrollView.frame.width * CGFloat(img)
                    imageView.frame = CGRect(x:xPosition, y: 0, width: avPlayerView.frame.width, height: avPlayerView.frame.height)
                    
                if img == 0 {
                    imageView.sd_setImage(with: URL(string: currentArticle.imageURL!), placeholderImage: nil, options: SDWebImageOptions.refreshCached)
                }
                else if img > 0{
                    if MediaData[img - 1].videoURL == nil{
                       imageView.sd_setImage(with: URL(string: MediaData[img - 1].imageURL!), placeholderImage: nil, options: SDWebImageOptions.refreshCached)
                 }else{
                       imageView.sd_setImage(with: URL(string: MediaData[img - 1].videoURL!), placeholderImage: nil, options: SDWebImageOptions.refreshCached)//imgArray[img]
                }
                }
                   imgScrollView.contentSize.width = imgScrollView.frame.width * CGFloat(img + 2)
                 //  imgScrollView.contentSize.height  = avPlayerView.frame.height
                    imgScrollView.addSubview(imageView)
            }
            }
            else{
                let imageView = UIImageView()
               imageView.frame = CGRect(x:0, y: 0, width: avPlayerView.frame.width, height: avPlayerView.frame.height)
               imageView.contentMode = .scaleAspectFit
               imgScrollView.contentSize.width = avPlayerView.frame.width
                imgScrollView.contentSize.height  = avPlayerView.frame.height
               imageView.image = UIImage(named: AssetConstants.NoImage)
                imgScrollView.addSubview(imageView)
            }
            
          
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
        else if SearchArticle.count != 0 {
            currentEntity = "SearchArticles"
            let currentArticle = SearchArticle[currentIndex]
            let newDate = dateFormatter.date(from: currentArticle.published_on!)
            let agoDate = Helper().timeAgoSinceDate(newDate!)
            articleId = Int(currentArticle.article_id)
            lblNewsHeading.text = currentArticle.title
            txtViewNewsDesc.text = currentArticle.blurb
            lblSource.text = currentArticle.source
            lblTimeAgo.text = agoDate
            sourceURL = currentArticle.source_url!
            
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
        let text = ShowArticle[newsCurrentIndex].title
        let webURL = "Sent via NewsCout : (www.newscout.in)"
        var shareAll : [Any]
        var sourceURL : URL!
        if ShowArticle[newsCurrentIndex].imageURL != nil{
            let url = URL(string:ShowArticle[newsCurrentIndex].imageURL!)
            let image1 = UIImage(named: "\(url)")
            var image = UIImage()
            if let data = try? Data(contentsOf: url!)
            {
                image = UIImage(data: data)!
            }
            if ShowArticle[newsCurrentIndex].source_url != nil{
                sourceURL = URL(string: "\(ShowArticle[newsCurrentIndex].source_url)")
            }
            shareAll = [ text , image1, image,  sourceURL , webURL ] as [Any]
        }
        else{
            if ShowArticle[newsCurrentIndex].source_url != nil{
                sourceURL = URL(string: "\(ShowArticle[newsCurrentIndex].source_url)")
            }
            shareAll = [ text , sourceURL , webURL ] as [Any]
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
        else if isSearch == "recommend" {
            self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
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
        else if isSearch == "home"{
            self.dismiss(animated: false)
            
            
        }
    }
    
    @IBAction func btnWebBackAction(_ sender: Any) {
        ViewWebContainer.isHidden = true
        viewLikeDislike.isHidden = false
        viewBack.isHidden = false
    }
    
    //btn Back Action
    @IBAction func btnBAckAction(_ sender: Any) {
        self.dismiss(animated: false)
    }
    
    @IBAction func PlayButtonTapped() -> Void {
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
        return CGSize(width: width, height: 145.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       // return (self.RecomArticleData.count != 0) ? self.RecomArticleData[0].body!.articles.count + 1 : 0
        return ShowArticle.count != 0 ? ShowArticle.count : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SuggestedNewsID", for: indexPath) as! SuggestedNewsCVCell
        cell.lblTitle.font = FontConstants.NormalFontContent
        cell.lblMoreStories.font = FontConstants.LargeFontContentBold
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
            let currentArticle =  ShowArticle[indexPath.row - 1] //RecomArticleData[0].body!.articles[indexPath.row - 1]
            cell.lblTitle.text = currentArticle.title
            if currentArticle.imageURL != nil{
                
                var checkImg = false
                let imageFormats = ["jpg", "jpeg", "png", "gif"]
                for ext in imageFormats{
                    if currentArticle.imageURL!.contains(ext){
                        checkImg = true
                        break
                    }
                }
                if checkImg == false{
                    cell.btnCellPlayVIdeo.isHidden = false
                    if let thumbnail = createThumbnailOfVideoFromRemoteUrl(url: "https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4"){
                        cell.imgNews.image = thumbnail
                    }
                }
                else{
                    cell.btnCellPlayVIdeo.isHidden = true
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
            else{
                UserDefaults.standard.set("recommend", forKey: "isSearch")
            }
            newsDetailvc.newsCurrentIndex = indexPath.row - 1
            newsDetailvc.ShowArticle =  ShowArticle //RecomArticleData[0].body!.articles
            newsDetailvc.articleId = Int(ShowArticle[indexPath.row].article_id)  //RecomArticleData[0].body!.articles[indexPath.row - 1].article_id!
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
