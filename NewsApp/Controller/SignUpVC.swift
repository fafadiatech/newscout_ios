//
//  SignUpVC.swift
//  NewsApp
//
//  Created by Jayashree on 01/10/18.
//  Copyright © 2018 Fafadia Tech. All rights reserved.
//

import UIKit

class SignUpVC: UIViewController {
    
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
    }
    
    @IBAction func btnBackActn(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func btnSignUpActn(_ sender: Any) {
        APICall().SignupAPI(fname: txtFname.text!, lname: txtLname.text!, email: txtEmail.text!, pswd: txtPassword.text!){response in
            print("signup response:\(response)")
            let alertController = UIAlertController(title:response, message: "", preferredStyle: .alert)
            
            let action1 = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in }
            
            alertController.addAction(action1)
            
            self.present(alertController, animated: true, completion: nil)
            
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
