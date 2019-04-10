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
            imageView.frame = CGRect(x: i * Int(self.pageView.frame.size.width) , y: 0 , width:
                Int(self.pageView.frame.size.width) , height: Int(scrollView.frame.size.height - pageControl.frame.height))
            imageView.contentMode = .scaleAspectFit
            imageView.image = UIImage(named:arrImages[i])
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
