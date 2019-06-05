//
//  LoginVC.swift
//  NewsApp
//
//  Created by Jayashree on 01/10/18.
//  Copyright © 2018 Fafadia Tech. All rights reserved.
//

import UIKit
import GoogleSignIn
import FBSDKLoginKit
import FBSDKCoreKit
import NightNight
import SkyFloatingLabelTextField

class LoginVC: UIViewController, GIDSignInUIDelegate, FBSDKLoginButtonDelegate {
    
    @IBOutlet weak var viewTitle: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var txtPassword: SkyFloatingLabelTextField!
    @IBOutlet weak var txtUsername: SkyFloatingLabelTextField!
    @IBOutlet weak var btnForgtPswd: UIButton!
    @IBOutlet weak var btnSignUp: UIButton!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var imgFBlogo: UIImageView!
    //new gmail view outlets
    @IBOutlet weak var viewGmailSignIn: UIView!
    @IBOutlet weak var imgGmailSignIn: UIImageView!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var viewFBLogin: UIView!
    @IBOutlet weak var btnFBLogin: FBSDKLoginButton!
    @IBOutlet weak var tryFBlogin: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tryFBlogin.isHidden = true
        txtUsername.autocorrectionType = .no
        txtPassword.autocorrectionType = .no
        viewGmailSignIn.layer.borderWidth = 1
        viewGmailSignIn.layer.borderColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1).cgColor
        btnLogin.layer.cornerRadius = 15
        btnLogin.layer.borderWidth = 0
        btnSignUp.layer.cornerRadius = 15
        btnSignUp.layer.borderWidth = 0
        btnForgtPswd.layer.cornerRadius = 15
        btnForgtPswd.layer.borderWidth = 0
        btnLogin.backgroundColor = colorConstants.redColor
        btnLogin.setTitleColor(colorConstants.whiteColor, for: .normal)
        btnLogin.titleLabel?.font = FontConstants.FontBtnTitle
        btnForgtPswd.backgroundColor = colorConstants.redColor
        btnForgtPswd.setTitleColor(colorConstants.whiteColor, for: .normal)
        btnForgtPswd.titleLabel?.font = FontConstants.FontBtnTitle
        btnFBLogin.readPermissions = ["public_profile", "email"]
        tryFBlogin.isHidden = true
        if FBSDKAccessToken.current() != nil{
            UserDefaults.standard.set(FBSDKAccessToken.current()?.tokenString, forKey: "FBToken")
            fetchProfile()
        }
        btnFBLogin.titleLabel?.font = FontConstants.FontBtnTitle
        signInButton.titleLabel?.font = FontConstants.FontBtnTitle
        
        GIDSignIn.sharedInstance().uiDelegate = self
        viewTitle.backgroundColor = colorConstants.redColor
        lblTitle.textColor = colorConstants.whiteColor
        lblTitle.font = FontConstants.viewTitleFont
        hideKeyboardWhenTappedAround()
        
        let darkModeStatus = UserDefaults.standard.value(forKey: "darkModeEnabled") as! Bool
        if  darkModeStatus == true{
            changeColor()
        }
        else{
            txtUsername.selectedTitleColor = .white
            txtPassword.selectedTitleColor = .white
        }
    }
    
    func FBLogin(){
        let param = ["provider" : "facebook",
                     "token_id" : UserDefaults.standard.value(forKey: "FBToken") as! String,
                     "device_id" : UserDefaults.standard.value(forKey: "deviceToken") as! String,
                     "device_name": "ios"]
        APICall().SocialLoginAPI(param : param){(status,response) in
            if response == "1"{
                UserDefaults.standard.set(true, forKey: "isWalkthroughShown")
                let check = UserDefaults.standard.value(forKey: "isSettingsLogin") as! Bool
                if check == true{
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let parentVc:ParentViewController = storyboard.instantiateViewController(withIdentifier: "parentID") as! ParentViewController
                    self.present(parentVc, animated: true, completion: nil)
                }
                else{
                    self.dismiss(animated: false)
                }
            }
        }
    }
    
    func changeColor(){
        txtUsername.titleColor = colorConstants.grayBackground3
        txtUsername.selectedTitleColor = colorConstants.grayBackground3
        txtPassword.selectedTitleColor = colorConstants.grayBackground3
        txtPassword.titleColor = colorConstants.grayBackground3
        view.backgroundColor = colorConstants.grayBackground3
        btnSignUp.backgroundColor = colorConstants.grayBackground3
        viewGmailSignIn.backgroundColor =  colorConstants.whiteColor
    }
    
    @objc private func darkModeEnabled(_ notification: Notification) {
        NightNight.theme = .night
        changeColor()
    }
    
    @objc private func darkModeDisabled(_ notification: Notification){
        NightNight.theme = .normal
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .darkModeEnabled, object: nil)
        NotificationCenter.default.removeObserver(self, name: .darkModeDisabled, object: nil)
    }
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginVC.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if FBSDKAccessToken.current() != nil{
            UserDefaults.standard.set(FBSDKAccessToken.current()?.tokenString, forKey: "FBToken")
            fetchProfile()
        }
    }
    
    func fetchProfile(){
        
        if((FBSDKAccessToken.current()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    if let dictionary = result as? [String: AnyObject]{
                        UserDefaults.standard.set(dictionary["email"] as! String?, forKey: "email")
                        UserDefaults.standard.set(dictionary["first_name"] as! String?, forKey: "first_name")
                        UserDefaults.standard.set(dictionary["last_name"] as! String?, forKey: "last_name")
                        self.FBLogin()
                    }
                }
            })
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //default gmail button
    @IBAction func btnGSignInActn(_ sender: Any) {
    }
    
    @IBAction func btnBackActn(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func tryFBLoginActn(_ sender: Any) {
    }
    
    @IBAction func btnNewFBLOgin(_ sender: Any) {
    }
    
    @IBAction func btnSignUpActn(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc:SignUpVC = storyboard.instantiateViewController(withIdentifier: "SignUpID") as! SignUpVC
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func btnLoginActn(_ sender: Any) {
        
        if txtUsername.text == "" || txtPassword.text == ""{
            self.view.makeToast("Please enter valid Email and Password..", duration: 1.0, position: .center)
        }
        else{
            let id = UserDefaults.standard.value(forKey: "deviceToken") as! String
            let param = ["email" : txtUsername.text!,
                         "password" : txtPassword.text!,
                         "device_id" : id,
                         "device_name": "ios"]
            APICall().LoginAPI(param : param){(status,response) in
                if response == "1"{
                    UserDefaults.standard.set(true, forKey: "isWalkthroughShown")
                    let check = UserDefaults.standard.value(forKey: "isSettingsLogin") as! Bool
                    if check == true{
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let parentVc:ParentViewController = storyboard.instantiateViewController(withIdentifier: "parentID") as! ParentViewController
                        self.present(parentVc, animated: true, completion: nil)
                    }
                    else{
                        self.dismiss(animated: false)
                    }
                }
                else{
                    self.view.makeToast(response, duration: 1.0, position: .center)
                }
            }
        }
    }
    
    @IBAction func btnFBLoginActn(_ sender: Any) {
        
    }
    
    @IBAction func googleSignIn(_ sender: Any) {
        GIDSignIn.sharedInstance().uiDelegate=self
        GIDSignIn.sharedInstance().signIn()
        
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil{
            self.view.makeToast("\(error.localizedDescription)", duration: 1.0, position: .center)
        }
        else if result.isCancelled{
            self.view.makeToast("You have cancelled login using Facebook", duration: 1.0, position: .center)
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        let defaultList = ["FBToken", "first_name", "last_name", "email"]
        Helper().clearDefaults(list : defaultList)
        self.view.makeToast("Succesfully Logged out..", duration: 1.0, position: .center)
    }
    
    @IBAction func btnForgotPasswordActn(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let forgotVc:ForgotPasswordVC = storyboard.instantiateViewController(withIdentifier: "ForgotPswdID") as! ForgotPasswordVC
        if txtUsername.text != nil{
            forgotVc.email = txtUsername.text!
        }
        self.present(forgotVc, animated: true, completion: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension LoginVC : UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
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
