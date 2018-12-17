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
import NightNight

class SettingsTVC: UITableViewController, GIDSignInUIDelegate {
    @IBOutlet weak var lblDailyEdition: UILabel!
    
    @IBOutlet weak var lblNIghtMode: UILabel!
    @IBOutlet weak var lblProfile: UILabel!
    @IBOutlet weak var lblPersonlized: UILabel!
    @IBOutlet weak var lblBreakingNews: UILabel!
    @IBOutlet var settingsTV: UITableView!
    @IBOutlet weak var segmentTextSize: UISegmentedControl!
    @IBOutlet weak var lblLogin: UILabel!
    @IBOutlet weak var lblLogout: UILabel!
    @IBOutlet weak var btnLogout: UIButton!
    @IBOutlet weak var switchNightMode: UISwitch!
    var textSizeSelected = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let switchStatus = UserDefaults.standard.value(forKey: "darkModeEnabled") as! Bool
        if switchStatus == true{
            switchNightMode.isOn = true
        }
        else{
            switchNightMode.isOn = false
        }
        btnLogout.isHidden = true
        isLoggedIn()
        if UserDefaults.standard.value(forKey: "textSize") != nil{
            textSizeSelected = UserDefaults.standard.value(forKey: "textSize") as! Int
        }
        segmentTextSize.tintColor = colorConstants.redColor
        segmentTextSize.selectedSegmentIndex = textSizeSelected
        let font = FontConstants.NormalFontContentMedium
        segmentTextSize.setTitleTextAttributes([NSAttributedStringKey.font: font],for: .normal)
        if (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad){
            tableView.rowHeight = 70
            segmentTextSize.setWidth(120, forSegmentAt: 0)
            segmentTextSize.setWidth(120, forSegmentAt: 1)
            segmentTextSize.setWidth(120, forSegmentAt: 2)
        }
        else {
            tableView.rowHeight = 44
        }
        NotificationCenter.default.addObserver(self, selector: #selector(darkModeEnabled(_:)), name: .darkModeEnabled, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(darkModeDisabled(_:)), name: .darkModeDisabled, object: nil)
        let darkModeStatus = UserDefaults.standard.value(forKey: "darkModeEnabled") as! Bool
        if  darkModeStatus == true{
            settingsTV.backgroundColor = colorConstants.grayBackground2
            let cell = SettingsTVCell()
            cell.backgroundColor = .black
            changeColor()
            
        }
    }
    
    @objc private func darkModeEnabled(_ notification: Notification) {
        // Write your dark mode code here
        NightNight.theme = .night
        let cell = SettingsTVCell()
        changeColor()
        cell.backgroundColor = .black
        settingsTV.backgroundColor = colorConstants.grayBackground2
        
    }
    
    @objc private func darkModeDisabled(_ notification: Notification) {
        // Write your non-dark mode code here
        NightNight.theme = .normal
        settingsTV.backgroundColor = colorConstants.grayBackground3
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .darkModeEnabled, object: nil)
        NotificationCenter.default.removeObserver(self, name: .darkModeDisabled, object: nil)
    }
    
    func changeColor(){
        
        lblLogin.textColor = .black
        btnLogout.titleLabel?.textColor = .black
        lblProfile.textColor = .black
        lblNIghtMode.textColor = .black
        lblPersonlized.textColor = .black
        lblBreakingNews.textColor = .black
        lblDailyEdition.textColor = .black
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isLoggedIn()
    }
    
    func isLoggedIn()
    {
        if UserDefaults.standard.value(forKey: "token") == nil && UserDefaults.standard.value(forKey: "googleToken") == nil && UserDefaults.standard.value(forKey: "FBToken") == nil  {
            lblLogin.text = "Login"
            btnLogout.isHidden = true
            // userDefault has a value
        }
        else {
            lblLogin.text = "\(UserDefaults.standard.value(forKey: "email")!)"
            btnLogout.isHidden = false
        }
    }
    
    @IBAction func TextSizeAction(_ sender: Any) {
        switch segmentTextSize.selectedSegmentIndex
        {
        case 0:
            print("small Segment Selected")
            textSizeSelected = 0
            UserDefaults.standard.set(0, forKey: "textSize")
            
        case 1:
            print("normal Segment Selected")
            textSizeSelected = 1
            UserDefaults.standard.set(1, forKey: "textSize")
            
        case 2:
            print("large Segment Selected")
            textSizeSelected = 2
            UserDefaults.standard.set(2, forKey: "textSize")
            
        default:
            textSizeSelected = 1
            UserDefaults.standard.set(1, forKey: "textSize")
            break
        }
    }
    
    @IBAction func btnLogoutActn(_ sender: Any) {
        if UserDefaults.standard.value(forKey: "googleToken") != nil{
            GIDSignIn.sharedInstance().signOut()
            let defaults = UserDefaults.standard
            defaults.removeObject(forKey: "googleToken")
            defaults.removeObject(forKey: "email")
            defaults.removeObject(forKey: "first_name")
            defaults.removeObject(forKey: "last_name")
            defaults.synchronize()
            self.btnLogout.isHidden = true
            self.lblLogin.text = "Login"
            print("google sign out successful..")
        }
        else if UserDefaults.standard.value(forKey: "FBToken") != nil{
            let manager = FBSDKLoginManager()
            manager.logOut()
            FBSDKAccessToken.setCurrent(nil)//setCurrentAccessToken(nil)
            FBSDKProfile.setCurrent(nil)
            self.btnLogout.isHidden = true
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
                    
                    self.btnLogout.isHidden = true
                    self.lblLogin.text = "Login"
                    var categories : [String] = []
                    
                    categories = UserDefaults.standard.array(forKey: "categories") as! [String]
                    if categories.contains("For You"){
                        categories.remove(at: 0)
                        UserDefaults.standard.setValue(categories, forKey: "categories")
                    }
                    if categories.contains("Top Stories"){
                        categories = categories.filter{$0 != "Top Stories"}
                        UserDefaults.standard.setValue(categories, forKey: "categories")
                    }
                }
                else{
                    self.view.makeToast(response, duration: 1.0, position: .center)
                }
            }
        }
    }
    
    func tableView(tableView: UITableView,
                   didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let headerView = view as! UITableViewHeaderFooterView
        headerView.textLabel?.textColor = .black
        headerView.textLabel?.font = FontConstants.settingsTVHeader
        let cell = SettingsTVCell()
        let darkModeStatus = UserDefaults.standard.value(forKey: "darkModeEnabled") as! Bool
        if  darkModeStatus == true{
            cell.backgroundColor = .black
        }
        else{
            //cell.backgroundColor = colorConstants.grayBackground3
        }
    }
    
    //    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    //
    //        let cell = UITableViewCell()
    //        let darkModeStatus = UserDefaults.standard.value(forKey: "darkModeEnabled") as! Bool
    //        if  darkModeStatus == true{
    //             cell.backgroundColor = .black
    //            changeColor()
    //        }
    //        else{
    //        cell.backgroundColor = colorConstants.grayBackground3
    //        }
    //        return cell
    //    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 2 && indexPath.row == 0{
            if UserDefaults.standard.value(forKey: "token") == nil && UserDefaults.standard.value(forKey: "googleToken") == nil && UserDefaults.standard.value(forKey: "FBToken") == nil {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc:LoginVC = storyboard.instantiateViewController(withIdentifier: "LoginID") as! LoginVC
                print(indexPath.section)
                present(vc, animated: true, completion: nil)
            }
            
        }
        else if indexPath.section == 2 && indexPath.row == 1{
            if  UserDefaults.standard.value(forKey: "token") != nil{
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let searchvc:ProfileVC
                    = storyboard.instantiateViewController(withIdentifier: "ProfileID") as! ProfileVC
                self.present(searchvc, animated: true, completion: nil)
            }
            else{
                self.view.makeToast("You need to login", duration: 1.0, position: .center)
            }
        }
        
        return indexPath
    }
    
    @IBAction func switchNightModeActn(_ sender: Any) {
        if switchNightMode.isOn == true {
            UserDefaults.standard.setValue(true, forKey: "darkModeEnabled")
            
            // Post the notification to let all current view controllers that the app has changed to dark mode, and they should theme themselves to reflect this change.
            NotificationCenter.default.post(name: .darkModeEnabled, object: nil)
            
        } else {
            
            UserDefaults.standard.setValue(false, forKey: "darkModeEnabled")
            
            // Post the notification to let all current view controllers that the app has changed to non-dark mode, and they should theme themselves to reflect this change.
            NotificationCenter.default.post(name: .darkModeDisabled, object: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

