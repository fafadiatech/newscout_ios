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
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var btnForgotPswd: UIButton!
    @IBOutlet weak var btnDeleteAcnt: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
       // btnImgProfile.frame = CGRect(x: 160, y: 100, width: 50, height: 50)
        //round border corner of forgot pswd and delete acnt btn
        btnForgotPswd.layer.cornerRadius = 15
        btnForgotPswd.layer.borderWidth = 0
        btnDeleteAcnt.layer.cornerRadius = 15
        btnDeleteAcnt.layer.borderWidth = 0
        // making profile image button circular
        btnImgProfile.layer.cornerRadius = 0.5 * btnImgProfile.bounds.size.width
        btnImgProfile.clipsToBounds = true
        btnImgProfile.setImage(UIImage(named:"settings"), for: .normal)
        // Do any additional setup after loading the view.
    }
    //HIde status bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnForgotPswdActn(_ sender: Any) {
    }

    @IBAction func btnDeleteAcntActn(_ sender: Any) {
    }
    
    @IBAction func btnBackActn(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
