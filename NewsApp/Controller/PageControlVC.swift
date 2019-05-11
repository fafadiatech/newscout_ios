//
//  FirstPVC.swift
//  NewsApp
//
//  Created by Jayashri on 29/03/19.
//  Copyright © 2019 Fafadia Tech. All rights reserved.


import UIKit

class PageControlVC: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var pageView: UIView!
    @IBOutlet weak var viewNavigation: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var btnGetStarted: UIButton!
    var arrImages =  [AssetConstants.screen1, AssetConstants.screen2, AssetConstants.screen3, AssetConstants.screen4, AssetConstants.screen5, AssetConstants.screen6]
    var txtArray = ["Top Menu for High level categories...You can swipe left or right", "Bottom menu for sub topic", "Click on any item for detail", "More Stories can be viewed by clicking on More Stories", "Any news article can be shared", "You can search news here"]
    override func viewDidLoad() {
        super.viewDidLoad()
        btnGetStarted.backgroundColor = .clear
        btnGetStarted.layer.cornerRadius = 5
        btnGetStarted.layer.borderWidth = 1
        btnGetStarted.layer.borderColor = UIColor.black.cgColor
    }
    
    override func viewDidLayoutSubviews() {
        self.loadScrollView()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func loadScrollView() {
        let pageCount = arrImages.count
        scrollView.frame = pageView.bounds
        scrollView.delegate = self
        scrollView.backgroundColor = UIColor.clear
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = true
        scrollView.showsVerticalScrollIndicator = false
        
        pageControl.numberOfPages = pageCount
        pageControl.currentPage = 0
        
        for i in (0..<pageCount) {
            
            let imageView = UIImageView()
            let lblTxt = UILabel()
            lblTxt.frame = CGRect(x: i * Int(pageView.frame.width), y: Int(pageView.frame.maxY - 90) , width:
                Int(self.pageView.frame.size.width) , height: 26)
            var heightToMinus = pageControl.frame.height + lblTxt.frame.height + 80
            lblTxt.text = txtArray[i]
            lblTxt.font = UIFont(name: AppFontName.regular, size: 22)
            lblTxt.textAlignment = .center
            imageView.frame = CGRect(x: i * Int(self.pageView.frame.size.width) , y: 20 , width:
                Int(self.pageView.frame.size.width) , height: Int(scrollView.frame.size.height - heightToMinus))
            imageView.contentMode = .scaleAspectFit
            imageView.image = UIImage(named:arrImages[i])
            self.scrollView.addSubview(lblTxt)
            self.scrollView.addSubview(imageView)
        }
        
        let width1 = (Float(arrImages.count) * Float(self.pageView.frame.size.width))
        scrollView.contentSize = CGSize(width: CGFloat(width1), height: self.pageView.frame.size.height - 80)
        
        self.pageView.addSubview(scrollView)
        self.pageControl.addTarget(self, action: #selector(self.pageChanged(sender:)), for: UIControl.Event.valueChanged)
        self.pageView.addSubview(pageControl)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
        print(pageNumber)
    }
    
    @objc func pageChanged(sender:AnyObject){
        let xVal = CGFloat(pageControl.currentPage) * scrollView.frame.size.width
        scrollView.setContentOffset(CGPoint(x: xVal, y: 0), animated: true)
        
    }
    
    @IBAction func btnGetStartedActn(_ sender: Any) {
        UserDefaults.standard.set(true, forKey: "isWalkthroughShown")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
      
        let loginView: HomeParentVC = storyboard.instantiateViewController(withIdentifier: "HomeParentID") as! HomeParentVC
        UIApplication.shared.keyWindow?.rootViewController = loginView
       
        let parentvc:HomeParentVC = storyboard.instantiateViewController(withIdentifier: "HomeParentID") as! HomeParentVC
        
        present(parentvc, animated: true, completion: nil)
    }
    
    @IBAction func btnSignInActn(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc:LoginVC = storyboard.instantiateViewController(withIdentifier: "LoginID") as! LoginVC
        present(vc, animated: true, completion: nil)
    }
    
    func removeSwipeGesture(){
        for view in self.pageControl.subviews {
            if let viewNavigation = view as? UIScrollView {
                viewNavigation.isScrollEnabled = false
            }
        }
    }
}
