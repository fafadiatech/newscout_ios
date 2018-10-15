//
//  SettingsVC.swift
//  NewsApp
//
//  Created by Jayashree on 24/09/18.
//  Copyright © 2018 Fafadia Tech. All rights reserved.
//

import UIKit

class SettingssampleVC: UIViewController {
    @IBOutlet weak var lblTextSize: UILabel!
    @IBOutlet weak var viewTitle: UIView!
    var border = CALayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // lblTextSize.font = lblTextSize.font.withSize(50)
        //bottom border to title view
        border.backgroundColor = UIColor.lightGray.cgColor
        border.frame = CGRect(x: 0, y: view.frame.height - 1, width: view.frame.width, height: 1)
        viewTitle.layer.addSublayer(border)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func btnBackAction(_ sender: Any) {
        self.dismiss(animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
