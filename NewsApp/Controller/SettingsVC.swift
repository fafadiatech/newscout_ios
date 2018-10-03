//
//  SettingsVC.swift
//  NewsApp
//
//  Created by Jayashree on 24/09/18.
//  Copyright © 2018 Fafadia Tech. All rights reserved.
//

import UIKit

class SettingsVC: UIViewController {
//outlets
    @IBOutlet weak var lblTextSize: UILabel!
    @IBOutlet weak var viewTitle: UIView!
    //variables and constants
     var border = CALayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // lblTextSize.font = lblTextSize.font.withSize(50)
        //bottom border to title view
        border.backgroundColor = UIColor.lightGray.cgColor
        border.frame = CGRect(x: 0, y: view.frame.height - 1, width: view.frame.width, height: 1)
        viewTitle.layer.addSublayer(border)
        }
    
    //HIde status bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
    @IBAction func btnLargeFont(_ sender: Any) {
       textSizeSelected = "large"
    }
    @IBAction func btnMediumFont(_ sender: Any) {
        textSizeSelected = "medium"
    }
    @IBAction func btnSmallFont(_ sender: Any) {
        textSizeSelected = "small"
    }
    //btn Back Action
    @IBAction func btnBackAction(_ sender: Any) {
          self.dismiss(animated: false)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func ChangeSizeActn(_ sender: Any) {
      
       // lblTextSize.//appearance().font = UIFont(name: "System", size: 50)
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
