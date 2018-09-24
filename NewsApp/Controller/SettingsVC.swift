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
    @IBOutlet weak var searchResultTV: UITableView!
    @IBOutlet weak var btnSearch: UIButton!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var txtSearch: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
