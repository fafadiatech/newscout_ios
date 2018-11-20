//
//  ProfileVC.swift
//  NewsApp
//
//  Created by Jayashree on 08/10/18.
//  Copyright © 2018 Fafadia Tech. All rights reserved.
//

import UIKit

class ProfileVC: UIViewController {
    
    @IBOutlet weak var viewImage: UIView!
    @IBOutlet weak var btnImgProfile: UIButton!
    @IBOutlet weak var viewProfileDetails: UIView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var lblNameVal: UILabel!
    @IBOutlet weak var lblemailVal: UILabel!
    @IBOutlet weak var btnChangePswd: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //round border corner of forgot pswd and delete acnt btn
        // making profile image button circular
        btnChangePswd.layer.cornerRadius = 15
        btnChangePswd.layer.borderWidth = 0
        btnImgProfile.layer.cornerRadius = 0.5 * btnImgProfile.bounds.size.width
        btnImgProfile.clipsToBounds = true
        btnImgProfile.setImage(UIImage(named:"settings"), for: .normal)
        if UserDefaults.standard.value(forKey: "first_name") != nil{
            lblNameVal.text = UserDefaults.standard.value(forKey: "first_name") as! String
        }
        
        if UserDefaults.standard.value(forKey: "email") != nil{
            lblemailVal.text = UserDefaults.standard.value(forKey: "email") as! String
        }
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnChangePswdActn(_ sender: Any) {
        if UserDefaults.standard.value(forKey: "token") != nil ||  UserDefaults.standard.value(forKey: "googleToken") != nil || UserDefaults.standard.value(forKey: "FBToken") != nil{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc:ChangePasswordVC = storyboard.instantiateViewController(withIdentifier: "ChangePswdID") as! ChangePasswordVC
            present(vc, animated: true, completion: nil)
        }
        else{
            self.view.makeToast("You need to login to continue...", duration: 1.0, position: .center)
        }
    }
    
    @IBAction func btnBackActn(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
