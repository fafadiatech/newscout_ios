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
    let imageCache = NSCache<NSString, UIImage>()
    var RecomArticleData = [ArticleStatus]()
    var ArticleData = [ArticleStatus]()
    var ShowArticle = [NewsArticle]()
    var ArticleDetail = ArticleDict.init(article_id: 0, category: "", source: "", title: "", imageURL: "", url: "", published_on: "", blurb: "", isBookmark: false, isLike: 0)
    var newsCurrentIndex = 0
    var articleId = 0
    var sourceURL = ""
    var tapTerm:UITapGestureRecognizer = UITapGestureRecognizer()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        if (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad)
        {
            if UIDeviceOrientationIsLandscape(UIDevice.current.orientation) {
                viewLikeDislike.isHidden = false
                var bottomConstraint = NSLayoutConstraint (item: viewLikeDislike,
                                                           attribute: NSLayoutAttribute.bottom,
                                                           relatedBy: NSLayoutRelation.equal,
                                                           toItem: self.suggestedView,
                                                           attribute: NSLayoutAttribute.top,
                                                           multiplier: 1,
                                                           constant: 0)
                // Add the constraint to the view
                self.view.addConstraint(bottomConstraint)
                suggestedView.frame.origin.y = 720
                // self.viewLikeDislike.frame = CGRect(x: 0, y: 589, width: self.view.frame.width, height: 70)
                
            }
            else{
                viewLikeDislike.isHidden = false
            }
        }
        else
        {
            viewLikeDislike.isHidden = true
        }
        let settingvc = SettingsTVC()
        viewLikeDislike.backgroundColor = colorConstants.redColor
        ViewWebContainer.isHidden = true
        APICall().loadRecommendationNewsAPI(articleId: articleId){ response in
            switch response {
            case .Success(let data) :
                self.RecomArticleData = data
                self.suggestedCV.reloadData()
            case .Failure(let errormessage) :
                print(errormessage)
                self.view.makeToast(errormessage, duration: 2.0, position: .center)
            case .Change(let code):
                print(code)
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
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped(gestureRecognizer:)))
        viewContainer.addGestureRecognizer(tapRecognizer)
        tapRecognizer.delegate = self as! UIGestureRecognizerDelegate
    }
    
    @objc func tapped(gestureRecognizer: UITapGestureRecognizer) {
        if (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone){ //|| UIDeviceOrientationIsLandscape(UIDevice.current.orientation){
            if viewLikeDislike.isHidden == true{
                viewLikeDislike.isHidden = false
            }
            else{
                viewLikeDislike.isHidden = true
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
        let textSizeSelected = UserDefaults.standard.value(forKey: "textSize") as! Int
        txtViewNewsDesc.textColor = colorConstants.txtDarkGrayColor
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
                //self.dismiss(animated: false)
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
                    self.view.makeToast("No more news to show", duration: 1.0, position: .center)
                }
            case UISwipeGestureRecognizerDirection.left:
                ViewWebContainer.isHidden = false
                viewLikeDislike.isHidden = true
                var url = URL(string: sourceURL)
                var domain = url?.host
                lblWebSource.text = "\(domain!)"
                print("Swiped left")
                transition.type = kCATransitionPush
                transition.subtype = kCATransitionFromRight
                view.window!.layer.add(transition, forKey: kCATransition)
                let myURL = URL(string: sourceURL)!
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
                    self.view.makeToast("No more news to show", duration: 1.0, position: .center)
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
        print(currentArticle)
        let newDate = dateFormatter.date(from: currentArticle.published_on!)
        let agoDate = Helper().timeAgoSinceDate(newDate!)
        
        articleId = currentArticle.article_id!
        print(articleId)
        lblNewsHeading.text = currentArticle.title
        txtViewNewsDesc.text = currentArticle.blurb
        lblSource.text = currentArticle.source
        lblTimeAgo.text = agoDate
        sourceURL = currentArticle.url!
        imgNews.downloadedFrom(link: "\(currentArticle.imageURL!)")
        print("currentArticle.isLike: \(currentArticle.isLike)")
        if currentArticle.isLike == 0 {
            btnLike.setImage(UIImage(named: "filledLike.png"), for: .normal)
            btnDislike.setImage(UIImage(named: "dislike.png"), for: .normal)
        }
        else if currentArticle.isLike == 1{
            btnLike.setImage(UIImage(named: "like.png"), for: .normal)
            btnDislike.setImage(UIImage(named: "filledDislike.png"), for: .normal)
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
        if UserDefaults.standard.value(forKey: "token") != nil || UserDefaults.standard.value(forKey: "FBToken") != nil || UserDefaults.standard.value(forKey: "googleToken") != nil{
            if (btnLike.currentImage?.isEqual(UIImage(named: "like.png")))! {
                let param = ["article_id" : articleId,
                             "isLike" : 0]
                APICall().LikeDislikeAPI(param : param){
                    (status,response) in
                    if status == "0"{
                        self.view.makeToast(response, duration: 1.0, position: .center)
                    }
                    else{
                        self.btnLike.setImage(UIImage(named: "filledLike.png"), for: .normal)
                        if (self.btnDislike.currentImage?.isEqual(UIImage(named: "filledDislike.png")))! {
                            self.btnDislike.setImage(UIImage(named: "dislike.png"), for: .normal)
                        }
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
                        self.btnLike.setImage(UIImage(named: "like.png"), for: .normal)
                    }
                }
            }
        }
        else{
            showMsg(title: "Please login to continue..", msg: "")
        }
    }
    
    @IBAction func btnDislikeActn(_ sender: Any) {
        if UserDefaults.standard.value(forKey: "token") != nil || UserDefaults.standard.value(forKey: "FBToken") != nil || UserDefaults.standard.value(forKey: "googleToken") != nil{
            if (btnDislike.currentImage?.isEqual(UIImage(named: "dislike.png")))! {
                let param = ["article_id" : articleId,
                             "isLike" : 1]
                APICall().LikeDislikeAPI(param : param ){
                    (status,response) in
                    if status == "0"{
                        self.view.makeToast(response, duration: 1.0, position: .center)
                    }
                    else{
                        self.btnDislike.setImage(UIImage(named: "filledDislike.png"), for: .normal)
                        if (self.btnLike.currentImage?.isEqual(UIImage(named: "filledLike.png")))! {
                            self.btnLike.setImage(UIImage(named: "like.png"), for: .normal)
                        }
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
                        self.btnDislike.setImage(UIImage(named: "dislike.png"), for: .normal)
                    }
                }
            }
        }
        else{
            showMsg(title: "Please login to continue..", msg: "")
            //self.view.makeToast("Please login to continue..", duration: 1.0, position: .center)
        }
    }
    
    @IBAction func btnBookmarkActn(_ sender: Any) {
        if UserDefaults.standard.value(forKey: "token") != nil || UserDefaults.standard.value(forKey: "FBToken") != nil || UserDefaults.standard.value(forKey: "googleToken") != nil{
            if (btnBookamark.currentImage?.isEqual(UIImage(named: "book.png")))! {
                
                APICall().bookmarkAPI(id: articleId){
                    (status, response) in
                    if status == "0"{
                        self.view.makeToast(response, duration: 1.0, position: .center)
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
                        self.view.makeToast(response, duration: 1.0, position: .center)
                    }
                    else{
                        self.btnBookamark.setImage(UIImage(named: "book.png"), for: .normal)
                        self.view.makeToast(response, duration: 1.0, position: .center)
                    }
                }
            }
        }
        else{
            showMsg(title: "Please login to continue..", msg: "")
        }
    }
    
    @IBAction func btnShareActn(_ sender: Any) {
        let text = ArticleData[0].body.articles[newsCurrentIndex].title
        let webText = "Sent via NewsCout"
        let webURL = "Sent via NewsCout : (www.newscout.in)"
        let imgStr = URL(string: ArticleData[0].body.articles[newsCurrentIndex].imageURL!)
        let url = URL(string:ArticleData[0].body.articles[newsCurrentIndex].imageURL!)
        var image1 = UIImage(named: "\(url)")
        var image = UIImage()
        if let data = try? Data(contentsOf: url!)
        {
             image = UIImage(data: data)!
        }
        let sourceURL = URL(string: "\(ArticleData[0].body.articles[newsCurrentIndex].url!)")
        let shareAll = [ text , image1, image,  sourceURL , webURL ] as [Any]
    
        let activityViewController = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = sender as! UIView
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func btnBackAction(_ sender: Any) {
        //self.dismiss(animated: false)

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc:HomeVC = storyboard.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func btnWebBackAction(_ sender: Any) {
        ViewWebContainer.isHidden = true
        viewLikeDislike.isHidden = false
    }
    
    //btn Back Action
    @IBAction func btnBAckAction(_ sender: Any) {
        self.dismiss(animated: false)
    }
    
    func showMsg(title: String, msg : String)
    {
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        if UI_USER_INTERFACE_IDIOM() == .pad
        {
            alertController.popoverPresentationController?.sourceView = self.view
            alertController.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            
        }
        let action1 = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc:LoginVC = storyboard.instantiateViewController(withIdentifier: "LoginID") as! LoginVC
            self.present(vc, animated: true, completion: nil)
        }
        
        alertController.addAction(action1)
        
        let action2 = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default) { (action:UIAlertAction) in
            print("You've pressed cancel");
        }
        alertController.addAction(action2)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
extension NewsDetailVC:UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {   var width = 1.0
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
        return (self.RecomArticleData.count != 0) ? self.RecomArticleData[0].body.articles.count + 1 : 0
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
        }
        else{
            cell.imgNews.isHidden = false
            cell.lblTitle.isHidden = false
            cell.lblMoreStories.isHidden = true
            let currentArticle =  RecomArticleData[0].body.articles[indexPath.row - 1]
            cell.lblTitle.text = currentArticle.title
            cell.imgNews.sd_setImage(with: URL(string: currentArticle.imageURL!), placeholderImage: nil, options: SDWebImageOptions.refreshCached)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row != 0{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let newsDetailvc:NewsDetailVC = storyboard.instantiateViewController(withIdentifier: "NewsDetailID") as! NewsDetailVC
            newsDetailvc.newsCurrentIndex = indexPath.row - 1
            newsDetailvc.ArticleData = RecomArticleData
            newsDetailvc.articleId = RecomArticleData[0].body.articles[indexPath.row - 1].article_id!
            print("articleId in didselect: \(articleId)")
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

/*class ExampleActivity : UIActivity{
var _activityTitle: String
var _activityImage: UIImage?
var activityItems = [Any]()
var action: ([Any]) -> Void

init(title: String, image: UIImage?, performAction: @escaping ([Any]) -> Void) {
    _activityTitle = title
    _activityImage = image
    action = performAction
    super.init()
}
    override var activityTitle: String? {
        return _activityTitle
    }
    
    override var activityImage: UIImage? {
        return _activityImage
    }
    override var activityType: UIActivityType? {
        return UIActivityType(rawValue: "com.yoursite.yourapp.activity")
    }
    
    override class var activityCategory: UIActivityCategory {
        return .action
    }
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return true
    }
    override func prepare(withActivityItems activityItems: [Any]) {
        self.activityItems = activityItems
    }
    override func perform() {
        action(activityItems)
        activityDidFinish(true)
    }
    let customItem = ExampleActivity(title: "Tap me!", image: UIImage(named: "bookmark")) { sharedItems in
        guard let sharedStrings = sharedItems as? [String] else { return }
        
        for string in sharedStrings {
            print("Here's the string: \(string)")
        }
    }
    
    let items = ["Hello, custom activity!"]
    
    //customItem.popoverPresentationController?.sourceView = sender as! UIView
    //self.present(customItem, animated: true, completion: nil)
}
 */

