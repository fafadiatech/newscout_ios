//
//  SettingsVC.swift
//  NewsApp
//
//  Created by Jayashree on 03/10/18.
//  Copyright © 2018 Fafadia Tech. All rights reserved.
//

import UIKit

class SettingsVC: UIViewController {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var viewTextSize: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        lblTitle.font = LargeFontMedium
        // Do any additional setup after loading the view.
    }
    //HIde status bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func btnBackAction(_ sender: Any) {
        self.dismiss(animated: false)
    }
    
}
