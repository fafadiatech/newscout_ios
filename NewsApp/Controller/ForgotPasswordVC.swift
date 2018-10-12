//
//  ForgotPasswordVC.swift
//  NewsApp
//
//  Created by Jayashri on 12/10/18.
//  Copyright © 2018 Fafadia Tech. All rights reserved.
//

import UIKit

class ForgotPasswordVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    //HIde status bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func btnBackActn(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func btnSubmitActn(_ sender: Any) {
    }
   

}
