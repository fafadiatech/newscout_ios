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
    var ShowArticle = [NewsArticle]()
    var ArticleDetail = ArticleDict.init(article_id: 0, category_id: 0, source_id: 0, description: "", title: "", imageURL: "", url: "", published_on: "", blurb: "")
    var article_id = Int64()
    var articleCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ViewWebContainer.isHidden = true
        loadArticleDetailsAPI(currentIndex : article_id)
        
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
    
    func loadArticleDetailsAPI(currentIndex : Int64)
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
    }
    
    func changeFont()
    {
        if textSizeSelected == 0{
            lblNewsHeading.font = smallFontMedium
            lblSource.font = smallFont
            lblTimeAgo.font = smallFont
            lblSuggested.font = smallFont
            txtViewNewsDesc.font = smallFont
        }
        else if textSizeSelected == 2{
            lblNewsHeading.font = LargeFontMedium
            lblSource.font = LargeFont
            lblTimeAgo.font = LargeFont
            lblSuggested.font = LargeFont
            txtViewNewsDesc.font = LargeFont
        }
        else{
            lblNewsHeading.font = NormalFontMedium
            lblSource.font = NormalFont
            lblTimeAgo.font = NormalFont
            lblSuggested.font = NormalFont
            txtViewNewsDesc.font = NormalFont
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
                if article_id > 0
                {
                    article_id = article_id - 1
                     loadArticleDetailsAPI(currentIndex : article_id)
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
                if article_id < articleCount
                {
                    article_id = article_id + 1
                     loadArticleDetailsAPI(currentIndex : article_id)
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
    
    func ShowNews(){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.timeZone = NSTimeZone(name: "UTC")! as TimeZone
        
//        if ShowArticle.count != 0{
//            let currentArticle =  ShowArticle[currentIndex]
//            let newDate = dateFormatter.date(from: currentArticle.published_on!)
//            print("newDAte:\(newDate!)")
//            let agoDate = timeAgoSinceDate(newDate!)
//            lblNewsHeading.text = currentArticle.title
//            txtViewNewsDesc.text = currentArticle.news_description
//           // lblSource.text = currentArticle.source_id
//            lblTimeAgo.text = agoDate
//            imgNews.downloadedFrom(link: "\(currentArticle.imageURL!)")
//        }
//        else{
        
        let newDate = dateFormatter.date(from: ArticleDetail.published_on!)
            print("newDAte:\(newDate!)")
            let agoDate = timeAgoSinceDate(newDate!)
            lblNewsHeading.text = ArticleDetail.title
            txtViewNewsDesc.text = ArticleDetail.description
           // lblSource.text = currentArticle.source_id
            lblTimeAgo.text = agoDate
            imgNews.downloadedFrom(link: "\(ArticleDetail.imageURL!)")

    }
    
    @IBAction func btnLikeActn(_ sender: Any) {
    }
    
    @IBAction func btnDislikeActn(_ sender: Any) {
    }
    
    @IBAction func btnShareActn(_ sender: Any) {
//        let text = ArticleData[0].articles[newsCurrentIndex].title
//        let myUrl = NSURL(string:ArticleData[0].articles[newsCurrentIndex].url!)
//        let shareAll = [text ,myUrl] as [Any]
//        let activityViewController = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
//        activityViewController.popoverPresentationController?.sourceView = self.view
//        self.present(activityViewController, animated: true, completion: nil)
        
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
        return ShowArticle.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SuggestedNewsID", for: indexPath) as! SuggestedNewsCVCell
        let currentArticle =  ShowArticle[indexPath.row] //ArticleData[0].articles[indexPath.row]
        cell.lblTitle.text = currentArticle.title
        cell.imgNews.downloadedFrom(link: "\(currentArticle.imageURL!)")
        return cell
    }
}
