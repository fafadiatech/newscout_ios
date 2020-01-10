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
    @IBOutlet weak var lblProfile: UILabel!
    @IBOutlet weak var lblPersonlized: UILabel!
    @IBOutlet weak var lblBreakingNews: UILabel!
    @IBOutlet var settingsTV: UITableView!
    @IBOutlet weak var segmentTextSize: UISegmentedControl!
    @IBOutlet weak var lblLogin: UILabel!
    @IBOutlet weak var btnLogout: UIButton!
    @IBOutlet weak var switchBreaking: UISwitch!
    @IBOutlet weak var switchDaily: UISwitch!
    @IBOutlet weak var switchPersonalised: UISwitch!
    
    var textSizeSelected = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _ = UserDefaults.standard.value(forKey: "darkModeEnabled") as! Bool
        let dailyStatus = UserDefaults.standard.value(forKey: "daily") as! Bool
        if dailyStatus == true{
            switchDaily.isOn = true
        }
        else{
            switchDaily.isOn = false
        }
        let breakingStatus = UserDefaults.standard.value(forKey: "breaking") as! Bool
        if breakingStatus == true{
            switchBreaking.isOn = true
        }
        else{
            switchBreaking.isOn = false
        }
        let personalisedStatus = UserDefaults.standard.value(forKey: "personalised") as! Bool
        if personalisedStatus == true{
            switchPersonalised.isOn = true
        }
        else{
            switchPersonalised.isOn = false
        }
        btnLogout.isHidden = true
        isLoggedIn()
        if UserDefaults.standard.value(forKey: "textSize") != nil{
            textSizeSelected = UserDefaults.standard.value(forKey: "textSize") as! Int
        }
        segmentTextSize.tintColor = colorConstants.redColor
        segmentTextSize.selectedSegmentIndex = textSizeSelected
        let font = FontConstants.NormalFontContentMedium
        segmentTextSize.setTitleTextAttributes([NSAttributedString.Key.font: font as Any],for: .normal)
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
            settingsTV.backgroundView?.backgroundColor = colorConstants.grayBackground2
            //changefontColor()
        }
        else{
            changeColor()
        }
    }
    
    @objc private func darkModeEnabled(_ notification: Notification) {
        NightNight.theme = .night
        //  changefontColor()
        settingsTV.backgroundColor = colorConstants.grayBackground2
    }
    
    @objc private func darkModeDisabled(_ notification: Notification){
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
        lblPersonlized.textColor = .black
        lblBreakingNews.textColor = .black
        lblDailyEdition.textColor = .black
    }
    func changefontColor(){
        let cell = UITableViewCell()
        cell.backgroundColor = .black
        lblLogin.textColor = .white
        btnLogout.titleLabel?.textColor = .white
        lblProfile.textColor = .white
        lblPersonlized.textColor = .white
        lblBreakingNews.textColor = .white
        lblDailyEdition.textColor = .black
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isLoggedIn()
    }
    
    func isLoggedIn(){
        if UserDefaults.standard.value(forKey: "token") == nil {
            lblLogin.text = "Login"
            btnLogout.isHidden = true
        }
        else {
            if UserDefaults.standard.value(forKey: "email") != nil{
                lblLogin.text = "\(UserDefaults.standard.value(forKey: "email")!)"
                btnLogout.isHidden = false
            }
        }
    }
    
    
    @IBAction func TextSizeAction(_ sender: Any) {
        switch segmentTextSize.selectedSegmentIndex{
        case 0:
            textSizeSelected = 0
            UserDefaults.standard.set(true, forKey: "isTextSizeChanged")
            UserDefaults.standard.set(0, forKey: "textSize")
            
        case 1:
            textSizeSelected = 1
            UserDefaults.standard.set(true, forKey: "isTextSizeChanged")
            UserDefaults.standard.set(1, forKey: "textSize")
            
        case 2:
            textSizeSelected = 2
            UserDefaults.standard.set(true, forKey: "isTextSizeChanged")
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
            let defaultList = ["googleToken", "first_name", "last_name", "email", "token"]
            Helper().clearDefaults(list : defaultList)
            DBManager().deleteAllData(entity: "LikeDislike")
            DBManager().deleteAllData(entity: "BookmarkArticles")
            self.btnLogout.isHidden = true
            self.lblLogin.text = "Login"
        }
        else if UserDefaults.standard.value(forKey: "FBToken") != nil{
            let manager = FBSDKLoginManager()
            manager.logOut()
            FBSDKAccessToken.setCurrent(nil)
            FBSDKProfile.setCurrent(nil)
            self.btnLogout.isHidden = true
            let defaultList = ["FBToken", "first_name", "last_name", "email", "token"]
            DBManager().deleteAllData(entity: "LikeDislike")
            DBManager().deleteAllData(entity: "BookmarkArticles")
            Helper().clearDefaults(list : defaultList)
            self.lblLogin.text = "Login"
        }
        else{
            APICall().LogoutAPI{(status, response) in
                if status == "1"{
                    self.view.makeToast("successfully logged out", duration: 1.0, position: .center)
                    self.btnLogout.isHidden = true
                    self.lblLogin.text = "Login"
                    
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
    
    /*  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let cell = UITableViewCell()
     let darkModeStatus = UserDefaults.standard.value(forKey: "darkModeEnabled") as! Bool
     if  darkModeStatus == true{
     cell.backgroundColor = colorConstants.grayBackground3
     //cell.textLabel?.text = "Jayashri"
     if indexPath.section == 0 && indexPath.row == 0{
     cell.addSubview(segmentTextSize)
     segmentTextSize.contentHorizontalAlignment = .center
     
     }else if indexPath.section == 1 && indexPath.row == 0{
     cell.addSubview(lblBreakingNews)
     
     cell.addSubview(lblPersonlized)
     lblBreakingNews.textColor = .white
     
     }else if indexPath.section == 1 && indexPath.row == 1{
     cell.addSubview(lblDailyEdition)
     lblDailyEdition.textColor = .white
     }
     else if indexPath.section == 2 && indexPath.row == 0{
     cell.addSubview(lblLogin)
     
     }
     
     cell.textLabel?.textColor = .white
     
     }
     else{
     cell.backgroundColor = colorConstants.blackColor
     }
     return cell
     }*/
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let headerView = view as! UITableViewHeaderFooterView
        headerView.textLabel?.font = FontConstants.settingsTVHeader
        let text = headerView.textLabel?.text?.capitalized
        headerView.textLabel?.text = text
        headerView.textLabel?.textColor = colorConstants.redColor
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 2 && indexPath.row == 0{
            if UserDefaults.standard.value(forKey: "token") == nil {
                UserDefaults.standard.set(true, forKey: "isSettingsLogin")
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc:LoginVC = storyboard.instantiateViewController(withIdentifier: "LoginID") as! LoginVC
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
        else if indexPath.section == 2 && indexPath.row == 2{
            let text = "checkout newScout app. I found it best for reading news."
            let url = URL(string: "http://www.fafadiatech.com/")
            let shareAll = [ text, url as Any] as [Any]
            
            let activityViewController = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
            
            activityViewController.popoverPresentationController?.sourceRect = CGRect(x: settingsTV.center.x , y: settingsTV.center.y + 200, width: 0, height: 0)
            activityViewController.popoverPresentationController?.sourceView = settingsTV!
            popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
            self.present(activityViewController, animated: true, completion: nil)
        }
            //Replace url with itunes app url
        else if indexPath.section == 2 && indexPath.row == 3{
            //  UIApplication.sharedApplication().openURL(NSURL(string : "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=\(0)&onlyLatestVersion=true&pageNumber=0&sortOrdering=1)")!);
            let url = URL(string: "https://mail.google.com")!
            UIApplication.shared.open(url)
        }
        else if indexPath.section == 2 && indexPath.row == 4{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let AboutUsvc:AboutUsVC
                = storyboard.instantiateViewController(withIdentifier: "AboutUsID") as! AboutUsVC
            self.present(AboutUsvc, animated: true, completion: nil)
        }
        
        return indexPath
    }
    
    func sendNotificationDetails(){
        let id = UserDefaults.standard.value(forKey: "deviceToken") as! String
        var status = Bool()
        status = UserDefaults.standard.value(forKey: "breaking") as! Bool
        let notifyBreaking =  String(status).capitalized
        status = UserDefaults.standard.value(forKey: "daily") as! Bool
        let notifyDaily = String(status).capitalized
        status = UserDefaults.standard.value(forKey: "personalised") as! Bool
        let notifyPersonalised = String(status).capitalized
        let param = ["device_id" : id,
                     "device_name": "ios",
                     "breaking_news" : notifyBreaking,
                     "daily_edition": notifyDaily,
                     "personalized" : notifyPersonalised]
        APICall().notificationAPI(param : param){(status,response) in
            print(status,response)
        }
        
    }
    
    @IBAction func switchBreakingNewsActn(_ sender: Any) {
        if switchBreaking.isOn == true {
            UserDefaults.standard.set(true, forKey: "breaking")
            sendNotificationDetails()
        }
        else{
            UserDefaults.standard.set(false, forKey: "breaking")
            sendNotificationDetails()
        }
    }
    
    @IBAction func switchDailyNewsActn(_ sender: Any) {
        if switchDaily.isOn == true {
            UserDefaults.standard.set(true, forKey: "daily")
            sendNotificationDetails()
        }
        else{
            UserDefaults.standard.set(false, forKey: "daily")
            sendNotificationDetails()
        }
    }
    
    @IBAction func switchPersonalisedActn(_ sender: Any) {
        if switchPersonalised.isOn == true {
            UserDefaults.standard.set(true, forKey: "personalised")
            sendNotificationDetails()
        }
        else{
            UserDefaults.standard.set(false, forKey: "personalised")
            sendNotificationDetails()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

