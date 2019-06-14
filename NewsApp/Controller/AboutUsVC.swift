//
//  AboutUsVC.swift
//  NewsApp
//
//  Created by Jayashri on 16/01/19.
//  Copyright © 2019 Fafadia Tech. All rights reserved.
//

import UIKit
import NightNight

extension Data {
    var hexString: String {
        let hexString = map { String(format: "%02.2hhx", $0) }.joined()
        return hexString
    }
}

class AboutUsVC: UIViewController {
    
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var txtViewAboutUs: UITextView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var lblAppVersion: UILabel!
    @IBOutlet weak var lblLastUpdated: UILabel!
    @IBOutlet weak var lblDDby: UILabel!
    @IBOutlet weak var lblAppVersionVal: UILabel!
    @IBOutlet weak var lblLastUpdatedVal: UILabel!
    
    @IBOutlet weak var lblCopyright: UILabel!
    @IBOutlet weak var viewLblContainer: UIView!
    @IBOutlet weak var txtViewLink: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtViewAboutUs.text = "Fafadia Tech is an Information Technology (IT) organization focused on delivering smart, next-generation business solutions that help enterprises across the world overcome their business challenges. These solutions leverage innovations in technology, knowledge of business processes, and domain expertise to provide clients a competitive edge."
        lblLastUpdatedVal.text = " 25/01/2019" 
        let myAttribute = [ NSAttributedString.Key.underlineStyle: NSUnderlineStyle.styleSingle.rawValue ]
        let myAttrString = NSAttributedString(string: "www.fafadiatech.com", attributes: myAttribute)
        txtViewLink.attributedText = myAttrString
        titleView.backgroundColor = colorConstants.redColor
        NotificationCenter.default.addObserver(self, selector: #selector(darkModeEnabled(_:)), name: .darkModeEnabled, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(darkModeDisabled(_:)), name: .darkModeDisabled, object: nil)
        
        lblTitle.textColor = .white
        lblTitle.font = FontConstants.viewTitleFont
        let darkModeStatus = UserDefaults.standard.value(forKey: "darkModeEnabled") as! Bool
        if  darkModeStatus == true{
            changeTheme()
        }
    }
    
    @objc private func darkModeEnabled(_ notification: Notification) {
        NightNight.theme = .night
        changeTheme()
    }
    
    func changeTheme(){
        containerView.backgroundColor = colorConstants.grayBackground3
        txtViewAboutUs.backgroundColor = colorConstants.grayBackground3
        viewLblContainer.backgroundColor = colorConstants.grayBackground3
        txtViewAboutUs.textColor = .white
        lblAppVersion.textColor = .white
        lblLastUpdated.textColor = .white
        lblDDby.textColor = .white
        lblAppVersionVal.textColor = .white
        lblLastUpdatedVal.textColor = .white
        lblCopyright.textColor = .white
    }
    @objc private func darkModeDisabled(_ notification: Notification){
        NightNight.theme = .normal
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .darkModeEnabled, object: nil)
        NotificationCenter.default.removeObserver(self, name: .darkModeDisabled, object: nil)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func btnBackActn(_ sender: Any) {
        self.dismiss(animated: false)
    }
    
}
