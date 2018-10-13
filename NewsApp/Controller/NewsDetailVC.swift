//
//  NewsDetailViewController.swift
//  NewsApp
//
//  Created by Jayashri on 22/09/18.
//  Copyright © 2018 Fafadia Tech. All rights reserved.
//

import UIKit
import WebKit

class NewsDetailVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
//outlets
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
    //variables
   // var ArticleData = [Article]()
 
    override func viewDidLoad() {
        super.viewDidLoad()
      // ArticleData = loadJson(filename: "news")!
        ShowNews(currentNews: currentIndex)
        //initially hide webview
        ViewWebContainer.isHidden = true
        //swipe gestures
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
    
    //HIde status bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        changeFont()
        }
    
    //Load data to be displayed from json file
    func loadJson(filename fileName: String) -> [Article]?
    {
        if let url = Bundle.main.url(forResource: fileName, withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let jsonData = try decoder.decode(ArticleStatus.self, from: data)
    
                print("jsondata: \(jsonData)")
    
                return jsonData.articles
                } catch {
                        print("error:\(error)")
                    }
                }
        return nil
    }
    func changeFont()
    {
       
        if textSizeSelected == 0{
            lblNewsHeading.font = smallFont
            lblSource.font = smallFont
            lblTimeAgo.font = smallFont
            lblSuggested.font = smallFont
            txtViewNewsDesc.font = smallFont
        }
        else if textSizeSelected == 2{
            lblNewsHeading.font = LargeFont
            lblSource.font = LargeFont
            lblTimeAgo.font = LargeFont
            lblSuggested.font = LargeFont
            txtViewNewsDesc.font = LargeFont

        }
        else{
            lblNewsHeading.font = NormalFont
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
                if currentIndex > 0
                {
                currentIndex = currentIndex - 1
                ShowNews(currentNews : currentIndex)
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
                if currentIndex < ArticleData.count
                {
                currentIndex = currentIndex + 1
                
                ShowNews(currentNews : currentIndex)
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
    func ShowNews(currentNews: Int)
    {
       
        var currentArticle = ArticleData[0].articles[currentNews]
        lblNewsHeading.text = currentArticle.title
        txtViewNewsDesc.text = currentArticle.description
       lblSource.text = currentArticle.source
        lblTimeAgo.text = currentArticle.publishedAt
        imgNews.downloadedFrom(link: "\(currentArticle.urlToImage!)")
        
    }
    @IBAction func btnLikeActn(_ sender: Any) {
    }
    @IBAction func btnDislikeActn(_ sender: Any) {
    }
    @IBAction func btnShareActn(_ sender: Any) {
    }
    
    
    @IBAction func btnBackAction(_ sender: Any) {
    self.dismiss(animated: false)
    }
    @IBAction func btnWebBackAction(_ sender: Any) {
            ViewWebContainer.isHidden = true
        
    }
    //collection view methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       return ArticleData[0].articles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SuggestedNewsID", for: indexPath) as! SuggestedNewsCVCell
        var currentArticle = ArticleData[0].articles[indexPath.row]
        cell.lblTitle.text = currentArticle.title
        cell.imgNews.downloadedFrom(link: "\(currentArticle.urlToImage!)")
//        if textSizeSelected == 0{
//            cell.lblTitle.font = smallFont
//
//        }
//        else if textSizeSelected == 2{
//            cell.lblTitle.font = LargeFont
//        }
//        else{
//            cell.lblTitle.font = NormalFont
//        }
        return cell
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
