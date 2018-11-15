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

class LoginVC: UIViewController, GIDSignInUIDelegate, FBSDKLoginButtonDelegate{
    
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var btnForgtPswd: UIButton!
    @IBOutlet weak var btnSignUp: UIButton!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var signInButton: GIDSignInButton!
    @IBOutlet weak var btnFbLogin: FBSDKLoginButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtUsername.autocorrectionType = .no
        txtPassword.autocorrectionType = .no
        btnLogin.layer.cornerRadius = 15
        btnLogin.layer.borderWidth = 0
        btnSignUp.layer.cornerRadius = 15
        btnSignUp.layer.borderWidth = 0
        btnForgtPswd.layer.cornerRadius = 15
        btnForgtPswd.layer.borderWidth = 0
        
        btnFbLogin.readPermissions = ["public_profile", "email"]
        if FBSDKAccessToken.current() != nil{
            print(FBSDKAccessToken.current())
            UserDefaults.standard.set(FBSDKAccessToken.current()?.tokenString, forKey: "FBToken")
            fetchProfile()
        }
        btnFbLogin.setTitle("", for: .normal)
        GIDSignIn.sharedInstance().uiDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if FBSDKAccessToken.current() != nil{
            print(FBSDKAccessToken.current())
            UserDefaults.standard.set(FBSDKAccessToken.current()?.tokenString, forKey: "FBToken")
            fetchProfile()
        }
    }
    
    func fetchProfile(){
        
        if((FBSDKAccessToken.current()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    if let dictionary = result as? [String: AnyObject]{
                        print(dictionary)
                        UserDefaults.standard.set(dictionary["email"] as! String?, forKey: "email")
                        UserDefaults.standard.set(dictionary["first_name"] as! String?, forKey: "first_name")
                        UserDefaults.standard.set(dictionary["last_name"] as! String?, forKey: "last_name")
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
        //
    }
    @IBAction func btnBackActn(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func btnSignUpActn(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc:SignUpVC = storyboard.instantiateViewController(withIdentifier: "SignUpID") as! SignUpVC
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func btnLoginActn(_ sender: Any) {
        if txtUsername.text == "" || txtPassword.text == ""{
            self.view.makeToast("Please enter valid username and password..", duration: 3.0, position: .center)
        }
        else{
            APICall().LoginAPI(email: txtUsername.text!, pswd: txtPassword.text!){response in
                print("Login response:\(response)")
                if response == "1"{
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let HomeVc:HomeParentVC = storyboard.instantiateViewController(withIdentifier: "HomeParentID") as! HomeParentVC
                    self.present(HomeVc, animated: true, completion: nil)
                    
                }
                else{
                    self.view.makeToast(response, duration: 3.0, position: .center)
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
        else{
            // UserDefaults.standard.set(email, forKey: "email")
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "FBToken")
        defaults.removeObject(forKey: "email")
        defaults.removeObject(forKey: "first_name")
        defaults.removeObject(forKey: "last_name")
        defaults.synchronize()
        self.view.makeToast("Succesfully Logged out..", duration: 1.0, position: .center)
    }
    
    @IBAction func btnForgotPasswordActn(_ sender: Any) {
        if txtUsername.text != nil{
            
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let forgotVc:ForgotPasswordVC = storyboard.instantiateViewController(withIdentifier: "ForgotPswdID") as! ForgotPasswordVC
        self.present(forgotVc, animated: true, completion: nil)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
