//
//  ForgotPasswordVC.swift
//  NewsApp
//
//  Created by Jayashree on 15/11/18.
//  Copyright © 2018 Fafadia Tech. All rights reserved.
//

import UIKit

class ForgotPasswordVC: UIViewController {

    @IBOutlet weak var txtEmail: UITextField!
    var email = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func btnSubmitEmailActn(_ sender: Any) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
}
