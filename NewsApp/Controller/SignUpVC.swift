//
//  SignUpVC.swift
//  NewsApp
//
//  Created by Jayashree on 01/10/18.
//  Copyright © 2018 Fafadia Tech. All rights reserved.
//

import UIKit
import NightNight

class SignUpVC: UIViewController {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var viewTitle: UIView!
    @IBOutlet weak var txtFname: UITextField!
    @IBOutlet weak var txtLname: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtConfirmPswd: UITextField!
    @IBOutlet weak var btnSignUp: UIButton!
    @IBOutlet weak var btnAlreadyMember: UIButton!
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
        btnSignUp.layer.cornerRadius = 15
        btnSignUp.layer.borderWidth = 0
        btnSignUp.backgroundColor = colorConstants.redColor
        btnSignUp.setTitleColor(colorConstants.whiteColor, for: .normal)
        btnSignUp.titleLabel?.font = FontConstants.FontBtnTitle
        hideKeyboardWhenTappedAround()
        NotificationCenter.default.addObserver(self, selector: #selector(SignUpVC.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SignUpVC.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        let darkModeStatus = UserDefaults.standard.value(forKey: "darkModeEnabled") as! Bool
        if  darkModeStatus == true{
            view.backgroundColor = colorConstants.grayBackground3
            btnAlreadyMember.backgroundColor =  colorConstants.grayBackground3
        }
    }
    
    @objc private func darkModeEnabled(_ notification: Notification) {
        // Write your dark mode code here
        NightNight.theme = .night
        view.backgroundColor = colorConstants.grayBackground3
        btnAlreadyMember.backgroundColor = colorConstants.grayBackground3
    }
    
    @objc private func darkModeDisabled(_ notification: Notification) {
        // Write your non-dark mode code here
        NightNight.theme = .normal
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .darkModeEnabled, object: nil)
        NotificationCenter.default.removeObserver(self, name: .darkModeDisabled, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                if UIDevice.current.userInterfaceIdiom == .pad{
                    self.view.frame.origin.y -= keyboardSize.height - 200
                }
                else{
                    // self.view.frame.origin.y -= keyboardSize.height - 100
                }
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                if UIDevice.current.userInterfaceIdiom == .pad{
                    self.view.frame.origin.y += keyboardSize.height - 200
                }
                else{
                    //self.view.frame.origin.y += keyboardSize.height - 100
                }
            }
        }
    }
    @IBAction func btnBackActn(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SignUpVC.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    @IBAction func btnSignUpActn(_ sender: Any) {
        if txtFname.text != "" && txtLname.text != "" && txtEmail.text != "" && txtPassword.text != "" && txtConfirmPswd.text != ""{
            if Helper().validateEmail(enteredEmail: txtEmail.text!) ==  true{
                if txtPassword.text == txtConfirmPswd.text {
                    let param = ["first_name": txtFname.text!,
                                 "last_name": txtLname.text!,
                                 "email" : txtEmail.text!,
                                 "password" : txtPassword.text!]
                    APICall().SignupAPI(param : param){(status,response) in
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
    
    @IBAction func btnLoginActn(_ sender: Any) {
        self.dismiss(animated: true)
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

extension SignUpVC : UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        if textField ==  txtFname || textField == txtLname{
            let allowedCharacters = CharacterSet(charactersIn:"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ ")//Here change this characters based on your requirement
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacters.isSuperset(of: characterSet)
        }
        return true
    }
    
}
