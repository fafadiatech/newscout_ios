//
//  SignUpVC.swift
//  NewsApp
//
//  Created by Jayashree on 01/10/18.
//  Copyright © 2018 Fafadia Tech. All rights reserved.
//

import UIKit
import NightNight
import SkyFloatingLabelTextField

class SignUpVC: UIViewController {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var viewTitle: UIView!
    @IBOutlet weak var txtFname: SkyFloatingLabelTextField!
    @IBOutlet weak var txtLname: SkyFloatingLabelTextField!
    @IBOutlet weak var txtEmail: SkyFloatingLabelTextField!
    @IBOutlet weak var txtPassword: SkyFloatingLabelTextField!
    @IBOutlet weak var txtConfirmPswd: SkyFloatingLabelTextField!
    @IBOutlet weak var btnSignUp: UIButton!
    @IBOutlet weak var btnAlreadyMember: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
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
        let darkModeStatus = UserDefaults.standard.value(forKey: "darkModeEnabled") as! Bool
        if  darkModeStatus == true{
            changeColor()
        }
    }
    
    func changeColor(){
        txtFname.lineColor = .white
        txtLname.lineColor = .white
        txtPassword.lineColor = .white
        txtConfirmPswd.lineColor = .white
        txtEmail.lineColor = .white
        txtFname.selectedTitleColor = colorConstants.grayBackground3
        txtLname.selectedTitleColor = colorConstants.grayBackground3
        txtEmail.selectedTitleColor = colorConstants.grayBackground3
        txtPassword.selectedTitleColor = colorConstants.grayBackground3
        txtConfirmPswd.selectedTitleColor = colorConstants.grayBackground3
        txtFname.titleColor = colorConstants.grayBackground3
        txtLname.titleColor = colorConstants.grayBackground3
        txtEmail.titleColor = colorConstants.grayBackground3
        txtPassword.titleColor = colorConstants.grayBackground3
        txtConfirmPswd.titleColor = colorConstants.grayBackground3
        view.backgroundColor = colorConstants.grayBackground3
        btnAlreadyMember.backgroundColor = colorConstants.grayBackground3
        btnAlreadyMember.setTitleColor(.white, for: UIControlState.normal)
        containerView.backgroundColor = colorConstants.grayBackground3
    }
    
    @objc private func darkModeEnabled(_ notification: Notification) {
        NightNight.theme = .night
        
    }
    
    @objc private func darkModeDisabled(_ notification: Notification) {
        NightNight.theme = .normal
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .darkModeEnabled, object: nil)
        NotificationCenter.default.removeObserver(self, name: .darkModeDisabled, object: nil)
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
                        if response == "sign up successfully"{
                            self.txtFname.text = ""
                            self.txtLname.text = ""
                            self.txtPassword.text = ""
                            self.txtConfirmPswd.text = ""
                            self.txtEmail.text = ""
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let vc:LoginVC = storyboard.instantiateViewController(withIdentifier: "LoginID") as! LoginVC
                            self.present(vc, animated: true, completion: nil)
                        }
                        else{
                            if response == "User with this email already exist"{
                            self.view.makeToast(response, duration: 1.0, position: .center)
                            }
                        }
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
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension SignUpVC : UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        if textField ==  txtFname || textField == txtLname{
            let allowedCharacters = CharacterSet(charactersIn:"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ ")
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacters.isSuperset(of: characterSet)
        }
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        // Try to find next responder
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        }
        else {
            textField.resignFirstResponder()
        }
        return false
    }
}
