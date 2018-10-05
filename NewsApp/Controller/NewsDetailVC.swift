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
    @IBOutlet weak var newsDetailTxtView: UITextView!
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    func changeFont()
    {
        print(textSizeSelected)
        
        if textSizeSelected == 0{
            lblNewsHeading.font = .systemFont(ofSize: Constants.fontSmallTitle)
            lblSource.font = .systemFont(ofSize: Constants.fontSmallTitle)
            lblTimeAgo.font = .systemFont(ofSize: Constants.fontSmallTitle)
            lblSuggested.font = .systemFont(ofSize: Constants.fontSmallTitle)
            newsDetailTxtView.font = .systemFont(ofSize: Constants.fontSmallContent)
        }
        else if textSizeSelected == 2{
            lblNewsHeading.font = .systemFont(ofSize: Constants.fontLargeTitle)
            lblSource.font = .systemFont(ofSize: Constants.fontLargeTitle)
            lblTimeAgo.font = .systemFont(ofSize: Constants.fontLargeTitle)
            lblSuggested.font = .systemFont(ofSize: Constants.fontLargeTitle)
            newsDetailTxtView.font = .systemFont(ofSize: Constants.fontLargeContent)

        }
        else{
            lblNewsHeading.font = .systemFont(ofSize: Constants.fontNormalTitle)
            lblSource.font = .systemFont(ofSize: Constants.fontNormalTitle)
            lblTimeAgo.font = .systemFont(ofSize: Constants.fontNormalTitle)
            lblSuggested.font = .systemFont(ofSize: Constants.fontNormalTitle)
            newsDetailTxtView.font = .systemFont(ofSize: Constants.fontNormalContent)
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
                transition.type = kCATransitionPush
                transition.subtype = kCATransitionFromBottom
                view.window!.layer.add(transition, forKey: kCATransition)
                print("swipe down")
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
                transition.type = kCATransitionPush
                transition.subtype = kCATransitionFromTop
                view.window!.layer.add(transition, forKey: kCATransition)
                 print("Swiped up")
              
            default:
                break
            }
        }
        
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
       return 6
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SuggestedNewsID", for: indexPath) as! SuggestedNewsCVCell
        if textSizeSelected == 0{
            cell.lblSuggestedSource.font = .systemFont(ofSize: Constants.fontSmallTitle)
            cell.lblSuggestedDesc.font = .systemFont(ofSize: Constants.fontSmallContent)
        }
        else if textSizeSelected == 2{
            cell.lblSuggestedSource.font = .systemFont(ofSize: Constants.fontLargeTitle)
            cell.lblSuggestedDesc.font = .systemFont(ofSize: Constants.fontLargeContent)
        }
        else{
            cell.lblSuggestedSource.font = .systemFont(ofSize: Constants.fontNormalTitle)
            cell.lblSuggestedDesc.font = .systemFont(ofSize: Constants.fontNormalContent)
        }
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
