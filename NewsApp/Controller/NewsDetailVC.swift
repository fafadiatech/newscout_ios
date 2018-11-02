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
    var ArticleData = [ArticleStatus]()
    var ShowArticle = [NewsArticle]()
    var ArticleDetail = ArticleDict.init(article_id: 0, category: "", source: "", title: "", imageURL: "", url: "", published_on: "", blurb: "")
    var suggestedCVCount = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        ViewWebContainer.isHidden = true
        APICall().loadRecommendationNewsAPI{ response in
            switch response {
            case .Success(let data) :
                self.ArticleData = data
                self.suggestedCVCount = self.ArticleData[0].body.articles.count
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
                if newsCurrentIndex < ShowArticle.count
                {
                    newsCurrentIndex = newsCurrentIndex + 1
                    ShowNews(currentIndex : newsCurrentIndex)
                    transition.type = kCATransitionPush
                    transition.subtype = kCATransitionFromTop
                    view.window!.layer.add(transition, forKey: kCATransition)
                    print("Swiped up")
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
        
       // if ShowArticle.count != 0{
            let currentArticle =  ShowArticle[currentIndex]
            let newDate = dateFormatter.date(from: currentArticle.published_on!)
            print("newDAte:\(newDate!)")
            let agoDate = timeAgoSinceDate(newDate!)
            lblNewsHeading.text = currentArticle.title
            txtViewNewsDesc.text = currentArticle.blurb
            lblSource.text = currentArticle.source
            lblTimeAgo.text = agoDate
            imgNews.downloadedFrom(link: "\(currentArticle.imageURL!)")
      //  }
       /* else{
            let currentArticle = ArticleData[0].articles[currentIndex]
            let newDate = dateFormatter.date(from: currentArticle.published_on!)
            print("newDAte:\(newDate!)")
            let agoDate = timeAgoSinceDate(newDate!)
            lblNewsHeading.text = currentArticle.title
            txtViewNewsDesc.text = currentArticle.blurb
            lblSource.text = currentArticle.source
            lblTimeAgo.text = agoDate
            imgNews.downloadedFrom(link: "\(currentArticle.imageURL!)")
        }*/
    }
    @IBAction func btnLikeActn(_ sender: Any) {
    }
    
    @IBAction func btnDislikeActn(_ sender: Any) {
    }
    
    @IBAction func btnShareActn(_ sender: Any) {
        let text = ShowArticle[newsCurrentIndex].title
        let myUrl = NSURL(string:ShowArticle[newsCurrentIndex].imageURL!)
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
        let currentArticle =  ArticleData[0].body.articles[indexPath.row]
        cell.lblTitle.text = currentArticle.title
        cell.imgNews.downloadedFrom(link: "\(currentArticle.imageURL!)")
        return cell
    }
}
