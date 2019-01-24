//
//  SettingsVC.swift
//  NewsApp
//
//  Created by Jayashree on 03/10/18.
//  Copyright © 2018 Fafadia Tech. All rights reserved.
//

import UIKit
import NightNight

class SettingsVC: UIViewController {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var viewTitle: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblTitle.textColor = colorConstants.whiteColor
        viewTitle.backgroundColor = colorConstants.redColor
        lblTitle.font = FontConstants.viewTitleFont
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func btnBackAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc:HomeParentVC = storyboard.instantiateViewController(withIdentifier: "HomeParentID") as! HomeParentVC
        present(vc, animated: true, completion: nil)
      //  self.dismiss(animated: false)
    }
}
