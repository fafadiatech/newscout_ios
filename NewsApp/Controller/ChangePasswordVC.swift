//
//  ChangePasswordVC.swift
//  NewsApp
//
//  Created by Jayashri on 12/10/18.
//  Copyright © 2018 Fafadia Tech. All rights reserved.
//

import UIKit

class ChangePasswordVC: UIViewController {
    
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var txtOldPswd: UITextField!
    @IBOutlet weak var txtNewPswd: UITextField!
    @IBOutlet weak var txtConfirmPswd: UITextField!
    @IBOutlet weak var btnChangePswd: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if UserDefaults.standard.value(forKey: "first_name") != nil && (UserDefaults.standard.value(forKey: "last_name") != nil){
        lblUsername.text = "\(UserDefaults.standard.value(forKey: "first_name")!)" + "  \(UserDefaults.standard.value(forKey: "last_name")!)"
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func btnBackActn(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func btnSubmitActn(_ sender: Any) {
        if txtOldPswd.text != nil && txtOldPswd.text != nil && txtNewPswd.text != nil{
        APICall().ChangePasswordAPI(old_password: txtOldPswd.text!, password: txtNewPswd.text!, confirm_password: txtConfirmPswd.text!){response in
            print("change pswd response:\(response)")
            if response == "1"{
                self.view.makeToast(response, duration: 1.0, position: .center)
                self.txtOldPswd.text = ""
                self.txtNewPswd.text = ""
                self.txtConfirmPswd.text = ""
            }
            else{
                self.view.makeToast(response, duration: 1.0, position: .center)
            }
        }
    }
        else{
            self.view.makeToast("Please enter all the details", duration: 1.0, position: .center)
        }
    }
}
