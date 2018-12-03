//
//  ForgotPasswordVC.swift
//  NewsApp
//
//  Created by Jayashree on 15/11/18.
//  Copyright © 2018 Fafadia Tech. All rights reserved.
//

import UIKit

class ForgotPasswordVC: UIViewController {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var viewTitle: UIView!
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var txtEmail: UITextField!
    
    var email = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtEmail.text = email
        btnSubmit.layer.cornerRadius = 15
        btnSubmit.layer.borderWidth = 0
        btnSubmit.titleLabel?.font = FontConstants.FontBtnTitle
        btnSubmit.backgroundColor = colorConstants.redColor
        btnSubmit.setTitleColor(colorConstants.whiteColor, for: .normal)
        viewTitle.backgroundColor = colorConstants.redColor
        lblTitle.textColor = colorConstants.whiteColor
        lblTitle.font = FontConstants.viewTitleFont
        hideKeyboardWhenTappedAround()
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ForgotPasswordVC.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func btnSubmitEmailActn(_ sender: Any) {
        if txtEmail.text != "" {
            
            APICall().ForgotPasswordAPI(email: txtEmail.text!){response in
                print("ForgotPassword response:\(response)")
                if response == "1"{
                    self.view.makeToast(response, duration: 2.0, position: .center)
                }
                else{
                    self.view.makeToast(response, duration: 1.0, position: .center)
                }
            }
        }
        else{
            self.view.makeToast("Please enter email to continue..", duration: 1.0, position: .center)
        }
    }
    
    @IBAction func btnBackActn(_ sender: Any) {
        self.dismiss(animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
