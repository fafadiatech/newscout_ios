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

class NewsDetailVC: UIViewController {
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
    @IBOutlet weak var lblSuggested: UILabel!
    @IBOutlet weak var WKWebView: WKWebView!
    @IBOutlet weak var viewWebTitle: UIView!
    @IBOutlet weak var ViewWebContainer: UIView!
    @IBOutlet weak var lblWebSource: UILabel!
    @IBOutlet weak var btnBookamark: UIButton!
    let imageCache = NSCache<NSString, UIImage>()
    var RecomArticleData = [ArticleStatus]()
    var ArticleData = [ArticleStatus]()
    var ShowArticle = [NewsArticle]()
    var ArticleDetail = ArticleDict.init(article_id: 0, category: "", source: "", title: "", imageURL: "", url: "", published_on: "", blurb: "", isBookmark: false, isLike: 0)
    var suggestedCVCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ViewWebContainer.isHidden = true
        APICall().loadRecommendationNewsAPI{ response in
            switch response {
            case .Success(let data) :
                self.RecomArticleData = data
                self.suggestedCVCount = self.RecomArticleData[0].body.articles.count
                self.suggestedCV.reloadData()
            case .Failure(let errormessage) :
                print(errormessage)
            }
        }
        ShowNews(currentIndex: newsCurrentIndex)
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeUp.direction = UISwipeGestureRecognizerDirection.up
        self.newsView.addGestureRecognizer(swipeUp)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.newsView.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.newsView.addGestureRecognizer(swipeRight)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeDown.direction = UISwipeGestureRecognizerDirection.down
        self.newsView.addGestureRecognizer(swipeDown)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        changeFont()
    }
    
    /*func loadArticleDetailsAPI(currentIndex : Int64)
     {
     let url = articleURL + "\(article_id)"
     print(url)
     Alamofire.request(url,method: .get).responseString{
     response in
     if(response.result.isSuccess){
     if let data = response.data {
     let jsonDecoder = JSONDecoder()
     do {
     let jsonData = try jsonDecoder.decode(ArticleDetails.self, from: data)
     self.ArticleDetail = jsonData.article
     self.ShowNews()
     }
     catch {
     print("Error: \(error)")
     }
     }
     }
     }
     }*/
    
    func changeFont()
    {
        if textSizeSelected == 0{
            lblNewsHeading.font = Constants.smallFontMedium
            lblSource.font = Constants.smallFont
            lblTimeAgo.font = Constants.smallFont
            lblSuggested.font = Constants.smallFont
            txtViewNewsDesc.font = Constants.smallFont
        }
        else if textSizeSelected == 2{
            lblNewsHeading.font = Constants.LargeFontMedium
            lblSource.font = Constants.LargeFont
            lblTimeAgo.font = Constants.LargeFont
            lblSuggested.font = Constants.LargeFont
            txtViewNewsDesc.font = Constants.LargeFont
        }
        else{
            lblNewsHeading.font = Constants.NormalFontMedium
            lblSource.font = Constants.NormalFont
            lblTimeAgo.font = Constants.NormalFont
            lblSuggested.font = Constants.NormalFont
            txtViewNewsDesc.font = Constants.NormalFont
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
                print("Swiped right")
                
            case UISwipeGestureRecognizerDirection.down:
                if newsCurrentIndex > 0
                {
                    newsCurrentIndex = newsCurrentIndex - 1
                    ShowNews(currentIndex : newsCurrentIndex)
                    transition.type = kCATransitionPush
                    transition.subtype = kCATransitionFromBottom
                    view.window!.layer.add(transition, forKey: kCATransition)
                    print("swipe down")
                }
                else{
                    self.view.makeToast("No more news to show", duration: 3.0, position: .center)
                }
            case UISwipeGestureRecognizerDirection.left:
                ViewWebContainer.isHidden = false
                print("Swiped left")
                transition.type = kCATransitionPush
                transition.subtype = kCATransitionFromRight
                view.window!.layer.add(transition, forKey: kCATransition)
                let myURL = URL(string: "https://www.google.com/")!
                let myRequest = URLRequest(url: myURL)
                WKWebView.load(myRequest)
                
            case UISwipeGestureRecognizerDirection.up:
                if newsCurrentIndex < ArticleData[0].body.articles.count - 1
                {
                    newsCurrentIndex = newsCurrentIndex + 1
                    ShowNews(currentIndex : newsCurrentIndex)
                    transition.type = kCATransitionPush
                    transition.subtype = kCATransitionFromTop
                    view.window!.layer.add(transition, forKey: kCATransition)
                    print("Swiped up")
                }
                else{
                    self.view.makeToast("No more news to show", duration: 3.0, position: .center)
                }
            default:
                break
            }
        }
    }
    
    func ShowNews(currentIndex: Int){
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.timeZone = NSTimeZone(name: "UTC")! as TimeZone
        
        /*if ShowArticle.count != 0{
         let currentArticle =  ShowArticle[currentIndex]
         let newDate = dateFormatter.date(from: currentArticle.published_on!)
         print("newDAte:\(newDate!)")
         let agoDate = timeAgoSinceDate(newDate!)
         lblNewsHeading.text = currentArticle.title
         txtViewNewsDesc.text = currentArticle.blurb
         lblSource.text = currentArticle.source
         lblTimeAgo.text = agoDate
         imgNews.downloadedFrom(link: "\(currentArticle.imageURL!)")
         }*/
        
        let currentArticle = ArticleData[0].body.articles[currentIndex]
        let newDate = dateFormatter.date(from: currentArticle.published_on!)
        print("newDAte:\(newDate!)")
        let agoDate = timeAgoSinceDate(newDate!)
        lblNewsHeading.text = currentArticle.title
        txtViewNewsDesc.text = currentArticle.blurb
        lblSource.text = currentArticle.source
        lblTimeAgo.text = agoDate
        imgNews.downloadedFrom(link: "\(currentArticle.imageURL!)")
        print("currentArticle.isLike: \(currentArticle.isLike)")
        if currentArticle.isLike == 0 {
            btnLike.setImage(UIImage(named: "filledLike.png"), for: .normal)
            btnDislike.setImage(UIImage(named: "dislike.png"), for: .normal)
            self.btnDislike.isUserInteractionEnabled = false
        }
        else if currentArticle.isLike == 1{
            btnLike.setImage(UIImage(named: "like.png"), for: .normal)
            btnDislike.setImage(UIImage(named: "filledDislike.png"), for: .normal)
            self.btnLike.isUserInteractionEnabled = false
        }
        else if currentArticle.isLike == 2{
            btnLike.setImage(UIImage(named: "like.png"), for: .normal)
            btnDislike.setImage(UIImage(named: "dislike.png"), for: .normal)
        }
        else{
            btnLike.setImage(UIImage(named: "like.png"), for: .normal)
            btnDislike.setImage(UIImage(named: "dislike.png"), for: .normal)
            btnBookamark.setImage(UIImage(named: "book.png"), for: .normal)
        }
        if currentArticle.isBookmark == true{
            btnBookamark.setImage(UIImage(named: "filledBookmrk.png"), for: .normal)
        }else{
            btnBookamark.setImage(UIImage(named: "book.png"), for: .normal)
        }
    }
    
    @IBAction func btnLikeActn(_ sender: Any) {
        if UserDefaults.standard.value(forKey: "token") != nil{
            if (btnLike.currentImage?.isEqual(UIImage(named: "like.png")))! {
                APICall().LikeDislikeAPI(id: articleId, isLike: 0){
                    (status,response) in
                    if status == "0"{
                        self.view.makeToast(response, duration: 3.0, position: .center)
                    }
                    else{
                        self.btnLike.setImage(UIImage(named: "filledLike.png"), for: .normal)
                        self.btnDislike.isUserInteractionEnabled = false
                    }
                }
            }
            else{
                APICall().LikeDislikeAPI(id: articleId, isLike: 2){
                    (status,response) in
                    if status == "0"{
                        self.view.makeToast(response, duration: 3.0, position: .center)
                    }
                    else{
                        self.btnLike.setImage(UIImage(named: "like.png"), for: .normal)
                        self.btnDislike.isUserInteractionEnabled = true
                    }
                }
            }
        }
        else{
            self.view.makeToast("Please login to continue..", duration: 3.0, position: .center)
        }
    }
    
    @IBAction func btnDislikeActn(_ sender: Any) {
        if UserDefaults.standard.value(forKey: "token") != nil{
            if (btnDislike.currentImage?.isEqual(UIImage(named: "dislike.png")))! {
                
                APICall().LikeDislikeAPI(id: articleId, isLike: 1){
                    (status,response) in
                    if status == "0"{
                        self.view.makeToast(response, duration: 3.0, position: .center)
                    }
                    else{
                        self.btnDislike.setImage(UIImage(named: "filledDislike.png"), for: .normal)
                        self.btnLike.isUserInteractionEnabled = false
                    }
                }
            }
            else{
                btnDislike.setImage(UIImage(named: "dislike.png"), for: .normal)
                btnLike.isUserInteractionEnabled = true
                APICall().LikeDislikeAPI(id: articleId, isLike: 2){
                    (status,response) in
                    if status == "0"{
                        self.view.makeToast(response, duration: 3.0, position: .center)
                    }
                    else{
                        self.btnDislike.setImage(UIImage(named: "dislike.png"), for: .normal)
                        self.btnLike.isUserInteractionEnabled = true
                    }
                }
            }
        }
        else{
            self.view.makeToast("Please login to continue..", duration: 3.0, position: .center)
        }
    }
    
    @IBAction func btnBookmarkActn(_ sender: Any) {
        if UserDefaults.standard.value(forKey: "token") != nil{
            if (btnBookamark.currentImage?.isEqual(UIImage(named: "book.png")))! {
                
                APICall().bookmarkAPI(id: articleId){
                    (status, response) in
                    if status == "0"{
                        self.view.makeToast(response, duration: 3.0, position: .center)
                    }
                    else{
                        self.btnBookamark.setImage(UIImage(named: "filledBookmrk.png"), for: .normal)
                        self.view.makeToast(response, duration: 1.0, position: .center)
                    }
                }
            }
            else{
                APICall().bookmarkAPI(id: articleId){
                    (status, response) in
                    if status == "0"{
                        self.view.makeToast(response, duration: 3.0, position: .center)
                    }
                    else{
                        self.btnBookamark.setImage(UIImage(named: "book.png"), for: .normal)
                        self.view.makeToast(response, duration: 1.0, position: .center)
                    }
                }
            }
        }
        else{
            self.view.makeToast("Please login to continue..", duration: 3.0, position: .center)
        }
    }
    
    @IBAction func btnShareActn(_ sender: Any) {
        let text = ArticleData[0].body.articles[newsCurrentIndex].title
        let myUrl = NSURL(string:ArticleData[0].body.articles[newsCurrentIndex].imageURL!)
        let shareAll = [text ,myUrl] as [Any]
        let activityViewController = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func btnBackAction(_ sender: Any) {
        self.dismiss(animated: false)
    }
    
    @IBAction func btnWebBackAction(_ sender: Any) {
        ViewWebContainer.isHidden = true
    }
    
    //btn Back Action
    @IBAction func btnBAckAction(_ sender: Any) {
        self.dismiss(animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
extension NewsDetailVC:UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return suggestedCVCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SuggestedNewsID", for: indexPath) as! SuggestedNewsCVCell
        let currentArticle =  RecomArticleData[0].body.articles[indexPath.row]
        cell.lblTitle.text = currentArticle.title
        cell.imgNews.sd_setImage(with: URL(string: currentArticle.imageURL!), placeholderImage: nil, options: SDWebImageOptions.refreshCached)
        return cell
    }
}
