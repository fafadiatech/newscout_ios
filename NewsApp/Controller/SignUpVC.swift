//
//  SignUpVC.swift
//  NewsApp
//
//  Created by Jayashree on 01/10/18.
//  Copyright © 2018 Fafadia Tech. All rights reserved.
//

import UIKit

class SignUpVC: UIViewController {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var viewTitle: UIView!
    @IBOutlet weak var txtFname: UITextField!
    @IBOutlet weak var txtLname: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtConfirmPswd: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        txtFname.autocorrectionType = .no
        txtLname.autocorrectionType = .no
        txtEmail.autocorrectionType = .no
        txtPassword.autocorrectionType = .no
        txtConfirmPswd.autocorrectionType = .no
        viewTitle.backgroundColor = colorConstants.redColor
        lblTitle.textColor = colorConstants.whiteColor
        lblTitle.font = FontConstants.viewTitleFont
    }
    
    @IBAction func btnBackActn(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func btnSignUpActn(_ sender: Any) {
        if txtFname.text != "" && txtLname.text != "" && txtEmail.text != "" && txtPassword.text != "" && txtConfirmPswd.text != ""{
            if Helper().validateEmail(enteredEmail: txtEmail.text!) ==  true{
                if txtPassword.text == txtConfirmPswd.text {
                    let param = ["first_name": txtFname.text!,
                                 "last_name": txtLname.text!,
                                 "email" : txtEmail.text!,
                                 "password" : txtPassword.text!]
                    APICall().SignupAPI(param : param){response in
                        print("signup response:\(response)")
                        if response == "sign up successfully"{
                            self.txtFname.text = ""
                            self.txtLname.text = ""
                            self.txtPassword.text = ""
                            self.txtConfirmPswd.text = ""
                            self.txtEmail.text = ""
                        }
                        self.view.makeToast(response, duration: 1.0, position: .center)
                    }
                }
                else{
                    self.view.makeToast("Password and confirm password are not same", duration: 1.0, position: .center)
                }
            }
            else{
                self.view.makeToast("Please enter valid email address", duration: 1.0, position: .center)
            }
        }
        else{
            self.view.makeToast("Please enter all the details", duration: 1.0, position: .center)
        }
    }
    
    //Hide status bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
