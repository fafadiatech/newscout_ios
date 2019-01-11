//
//  ProfileVC.swift
//  NewsApp
//
//  Created by Jayashree on 08/10/18.
//  Copyright © 2018 Fafadia Tech. All rights reserved.
//

import UIKit
import NightNight

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
//        btnChangePswd.layer.cornerRadius = 15
//        btnChangePswd.layer.borderWidth = 0
//        btnImgProfile.layer.cornerRadius = 0.5 * btnImgProfile.bounds.size.width
//        btnImgProfile.clipsToBounds = true
       // btnImgProfile.isHidden = true
        btnImgProfile.setImage(UIImage(named:"logo"), for: .normal)
        btnChangePswd.backgroundColor = colorConstants.redColor
        btnChangePswd.setTitleColor(colorConstants.whiteColor, for: .normal)
        btnChangePswd.titleLabel?.font = FontConstants.FontBtnTitle
        if UserDefaults.standard.value(forKey: "first_name") != nil{
            lblNameVal.text = UserDefaults.standard.value(forKey: "first_name") as! String
        }
        
        if UserDefaults.standard.value(forKey: "email") != nil{
            lblemailVal.text = UserDefaults.standard.value(forKey: "email") as! String
        }
        let darkModeStatus = UserDefaults.standard.value(forKey: "darkModeEnabled") as! Bool
        if  darkModeStatus == true{
            viewProfileDetails.backgroundColor = colorConstants.grayBackground3
            lblName.textColor = .white
            lblEmail.textColor = .white
            lblNameVal.textColor = .white
            lblemailVal.textColor = .white
        }
    }
    
    @objc private func darkModeEnabled(_ notification: Notification) {
        // Write your dark mode code here
        NightNight.theme = .night
        viewProfileDetails.backgroundColor = colorConstants.grayBackground3
        lblName.textColor = .white
        lblEmail.textColor = .white
        lblNameVal.textColor = .white
        lblemailVal.textColor = .white
    }
    
    @objc private func darkModeDisabled(_ notification: Notification) {
        // Write your non-dark mode code here
        NightNight.theme = .normal
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .darkModeEnabled, object: nil)
        NotificationCenter.default.removeObserver(self, name: .darkModeDisabled, object: nil)
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
            showMsg(title: "Please login to continue..", msg: "")
        }
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
    
    @IBAction func btnBackActn(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
