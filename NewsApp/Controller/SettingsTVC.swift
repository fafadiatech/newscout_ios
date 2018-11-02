//
//  SettingsTVCTableViewController.swift
//  NewsApp
//
//  Created by Jayashree on 01/10/18.
//  Copyright © 2018 Fafadia Tech. All rights reserved.
//

import UIKit

class SettingsTVC: UITableViewController {
    
    @IBOutlet weak var segmentTextSize: UISegmentedControl!
    @IBOutlet weak var lblLogin: UILabel!
    @IBOutlet weak var lblLogout: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblLogout.isHidden = true
        isLoggedIn()
        segmentTextSize.selectedSegmentIndex = textSizeSelected
        segmentTextSize.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.black], for: UIControlState.normal)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    //    override func viewDidAppear(_ animated: Bool) {
    //        isLoggedIn()
    //    }
    func isLoggedIn()
    {
        
        if UserDefaults.standard.value(forKey: "token") == nil {
            lblLogin.text = "Login"
            lblLogout.isHidden = true
            // userDefault has a value
        } else {
            print(UserDefaults.standard.value(forKey: "token")!)
            lblLogin.text = "\(UserDefaults.standard.value(forKey: "email")!)"
            lblLogout.isHidden = false
        }
        
    }
    @IBAction func TextSizeAction(_ sender: Any) {
        switch segmentTextSize.selectedSegmentIndex
        {
        case 0:
            print("small Segment Selected")
            textSizeSelected = 0
        case 1:
            print("normal Segment Selected")
            textSizeSelected = 1
        case 2:
            print("large Segment Selected")
            textSizeSelected = 2
        default:
            textSizeSelected = 1
            break
        }
    }
    
    func tableView(tableView: UITableView,
                   didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let headerView = view as! UITableViewHeaderFooterView
        headerView.textLabel?.textColor = .black
        headerView.textLabel?.font = Constants.NormalFontMedium
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 2 && indexPath.row == 0{
            if UserDefaults.standard.value(forKey: "token") == nil {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc:LoginVC = storyboard.instantiateViewController(withIdentifier: "LoginID") as! LoginVC
                print(indexPath.section)
                present(vc, animated: true, completion: nil)
            }
            else{
                APICall().LogoutAPI{(status, response) in
                    print(status,response)
                    if status == "1"{
                        print("Logout response:\(response)")
                        self.showMSg(title: response, msg: "")
                        self.lblLogout.isHidden = true
                        self.lblLogin.text = "Login"
                    }
                    else{
                        self.showMSg(title: response, msg: "")
                    }
                }
                
            }
        }
        return indexPath
    }
    
    func showMSg(title: String, msg: String)
    {
        
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        if UI_USER_INTERFACE_IDIOM() == .pad
        {
            alertController.popoverPresentationController?.sourceView = self.view
            alertController.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            
        }
        let action1 = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in }
        
        alertController.addAction(action1)
        
        self.present(alertController, animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
