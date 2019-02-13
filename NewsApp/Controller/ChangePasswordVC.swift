//
//  ChangePasswordVC.swift
//  NewsApp
//
//  Created by Jayashri on 12/10/18.
//  Copyright © 2018 Fafadia Tech. All rights reserved.
//

import UIKit
import NightNight
import SkyFloatingLabelTextField

class ChangePasswordVC: UIViewController {
    
    @IBOutlet weak var lblChangePswd: UILabel!
    @IBOutlet weak var viewTitle: UIView!
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var txtOldPswd: SkyFloatingLabelTextField!
    @IBOutlet weak var txtNewPswd: SkyFloatingLabelTextField!
    @IBOutlet weak var txtConfirmPswd: SkyFloatingLabelTextField!
    @IBOutlet weak var btnChangePswd: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if UserDefaults.standard.value(forKey: "first_name") != nil && (UserDefaults.standard.value(forKey: "last_name") != nil){
            lblUsername.text = "\(UserDefaults.standard.value(forKey: "first_name")!)" + "  \(UserDefaults.standard.value(forKey: "last_name")!)"
        }
        let darkModeStatus = UserDefaults.standard.value(forKey: "darkModeEnabled") as! Bool
        if  darkModeStatus == true{
            changeFontColor()
        }
        lblChangePswd.textColor = colorConstants.whiteColor
        viewTitle.backgroundColor = colorConstants.redColor
        lblChangePswd.font = FontConstants.viewTitleFont
        btnChangePswd.backgroundColor = colorConstants.redColor
        btnChangePswd.setTitleColor(colorConstants.whiteColor, for: .normal)
        btnChangePswd.titleLabel?.font = FontConstants.FontBtnTitle
        btnChangePswd.layer.cornerRadius = 15
        btnChangePswd.layer.borderWidth = 0
        hideKeyboardWhenTappedAround()
        NotificationCenter.default.addObserver(self, selector: #selector(darkModeEnabled(_:)), name: .darkModeEnabled, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(darkModeDisabled(_:)), name: .darkModeDisabled, object: nil)
    }
    
    func changeFontColor(){
        txtNewPswd.selectedTitleColor = colorConstants.grayBackground3
        txtOldPswd.selectedTitleColor = colorConstants.grayBackground3
        txtConfirmPswd.selectedTitleColor = colorConstants.grayBackground3
        txtNewPswd.titleColor = colorConstants.grayBackground3
        txtOldPswd.titleColor = colorConstants.grayBackground3
        txtConfirmPswd.titleColor = colorConstants.grayBackground3
        view.backgroundColor = colorConstants.grayBackground3
        lblUsername.textColor = colorConstants.whiteColor
        txtNewPswd.textColor = colorConstants.whiteColor
        txtConfirmPswd.textColor = colorConstants.whiteColor
        txtOldPswd.textColor = colorConstants.whiteColor
    }
    
    @objc private func darkModeEnabled(_ notification: Notification) {
        // Write your dark mode code here
        NightNight.theme = .night
        changeFontColor()
    }
    
    @objc private func darkModeDisabled(_ notification: Notification){
        NightNight.theme = .normal
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .darkModeEnabled, object: nil)
        NotificationCenter.default.removeObserver(self, name: .darkModeDisabled, object: nil)
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ChangePasswordVC.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func btnBackActn(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func btnSubmitActn(_ sender: Any) {
        
        if txtOldPswd.text != "" && txtOldPswd.text != "" && txtNewPswd.text != ""{
            let param = ["old_password" : txtOldPswd.text!,
                         "password" : txtNewPswd.text!,
                         "confirm_password" : txtConfirmPswd.text! ]
            APICall().ChangePasswordAPI(param: param){(status, response) in
                if status == "1"{
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

extension ChangePasswordVC : UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        // Try to find next responder
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        }else {
            // Not found, so remove keyboard.
            textField.resignFirstResponder()
        }
        // Do not add a line break
        return false
    }
}

