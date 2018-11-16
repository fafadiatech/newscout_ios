//
//  SettingsTVCTableViewController.swift
//  NewsApp
//
//  Created by Jayashree on 01/10/18.
//  Copyright © 2018 Fafadia Tech. All rights reserved.
//

import UIKit
import GoogleSignIn
import FBSDKLoginKit
import FBSDKCoreKit

class SettingsTVC: UITableViewController, GIDSignInUIDelegate {
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isLoggedIn()
    }
    
    func isLoggedIn()
    {
        
        if UserDefaults.standard.value(forKey: "token") == nil && UserDefaults.standard.value(forKey: "googleToken") == nil && UserDefaults.standard.value(forKey: "FBToken") == nil  {
            lblLogin.text = "Login"
            lblLogout.isHidden = true
            // userDefault has a value
        }
        else {
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
            if UserDefaults.standard.value(forKey: "token") == nil && UserDefaults.standard.value(forKey: "googleToken") == nil && UserDefaults.standard.value(forKey: "FBToken") == nil {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc:LoginVC = storyboard.instantiateViewController(withIdentifier: "LoginID") as! LoginVC
                print(indexPath.section)
                present(vc, animated: true, completion: nil)
            }
            else{
                if UserDefaults.standard.value(forKey: "googleToken") != nil{
                    GIDSignIn.sharedInstance().signOut()
                    let defaults = UserDefaults.standard
                    defaults.removeObject(forKey: "googleToken")
                    defaults.removeObject(forKey: "email")
                    defaults.removeObject(forKey: "first_name")
                    defaults.removeObject(forKey: "last_name")
                    defaults.synchronize()
                    self.lblLogout.isHidden = true
                    self.lblLogin.text = "Login"
                    print("google sign out successful..")
                }
                else if UserDefaults.standard.value(forKey: "FBToken") != nil{
                    let manager = FBSDKLoginManager()
                    manager.logOut()
                    FBSDKAccessToken.setCurrent(nil)//setCurrentAccessToken(nil)
                    FBSDKProfile.setCurrent(nil)
                    self.lblLogout.isHidden = true
                    let defaults = UserDefaults.standard
                    defaults.removeObject(forKey: "FBToken")
                    defaults.removeObject(forKey: "email")
                    defaults.removeObject(forKey: "first_name")
                    defaults.removeObject(forKey: "last_name")
                    defaults.synchronize()
                    self.lblLogin.text = "Login"
                    print("google sign out successful..")
                }
                else{
                    APICall().LogoutAPI{(status, response) in
                        print(status,response)
                        if status == "1"{
                            print("Logout response:\(response)")
                            self.view.makeToast("successfully logged out", duration: 1.0, position: .center)
                            
                            self.lblLogout.isHidden = true
                            self.lblLogin.text = "Login"
                        }
                        else{
                            self.view.makeToast(response, duration: 1.0, position: .center)
                        }
                    }
                }
            }
        }
        return indexPath
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
