//
//  NewsDetailViewController.swift
//  NewsApp
//
//  Created by Jayashri on 22/09/18.
//  Copyright © 2018 Fafadia Tech. All rights reserved.
//

import UIKit

class NewsDetailVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
//outlets
    @IBOutlet weak var imgNews: UIImageView!
    @IBOutlet weak var newsDetailView: UIView!
    @IBOutlet weak var lblNewsHeading: UILabel!
    @IBOutlet weak var newsDetailTxtView: UITextView!
    @IBOutlet weak var lblTimeAgo: UILabel!
    @IBOutlet weak var lblSource: UILabel!
    @IBOutlet weak var btnLike: UIButton!
    @IBOutlet weak var btnDislike: UIButton!
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var suggestedView: UIView!
    @IBOutlet weak var suggestedCV: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func btnLikeActn(_ sender: Any) {
    }
    @IBAction func btnDislikeActn(_ sender: Any) {
    }
    @IBAction func btnShareActn(_ sender: Any) {
    }
    
    
    //collection view methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       return 6
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SuggestedNewsID", for: indexPath) as! SuggestedNewsCVCell
        return cell
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
}
