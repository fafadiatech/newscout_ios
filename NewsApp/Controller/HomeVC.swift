//
//  ViewController.swift
//  NewsApp
//
//  Created by Jayashri on 22/09/18.
//  Copyright © 2018 Fafadia Tech. All rights reserved.
//

import UIKit
import Floaty

class HomeVC: UIViewController, UITableViewDelegate, UITableViewDataSource, FloatyDelegate {

    //outlets
    @IBOutlet weak var HomeNewsTV: UITableView!
    @IBOutlet weak var lblHeading: UILabel!
    
    //variables
   
   
    override func viewDidLoad() {
        super.viewDidLoad()
        let floaty = Floaty()
        floaty.itemTitleColor = UIColor.blue
       // floaty.buttonImage = UIImage(named: "floatingMenu")
        floaty.addItem("Search", icon: UIImage(named: "search")!) { item in
            floaty.autoCloseOnTap = true
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let searchvc:SearchVC = storyboard.instantiateViewController(withIdentifier: "SearchID") as! SearchVC
            self.present(searchvc, animated: true, completion: nil)
          }
        floaty.addItem("Settings", icon: UIImage(named: "settings")!) { item in
            floaty.autoCloseOnTap = true
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let settingvc:SettingsTVC = storyboard.instantiateViewController(withIdentifier: "SettingsTVID") as! SettingsTVC
            self.present(settingvc, animated: true, completion: nil)
            
        }
        floaty.addItem("Bookmark", icon: nil) { item in
            floaty.autoCloseOnTap = true
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let settingvc:SettingsTVC = storyboard.instantiateViewController(withIdentifier: "SettingsTVID") as! SettingsTVC
            self.present(settingvc, animated: true, completion: nil)
            
        }
        self.view.addSubview(floaty)
        // Do any additional setup after loading the view, typically from a nib.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
            changeFont()
        
    }

    func changeFont()
    {
        print(textSizeSelected)
        var currentFont = lblHeading.font.pointSize
        if textSizeSelected == "large"
        {
        if currentFont < 30
        {
                lblHeading.font = UIFont.largeFont(fontSize: Int(currentFont))
        }
        else if textSizeSelected == "small"
        {
            if currentFont > 10
            {
            lblHeading.font = UIFont.smallFont(fontSize: Int(currentFont))
            }
        }
        }
    }
    //HIde status bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
    //Tableview methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("This cell  was selected: \(indexPath.row)")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc:NewsDetailVC = storyboard.instantiateViewController(withIdentifier: "NewsDetailID") as! NewsDetailVC
        present(vc, animated: true, completion: nil)
    }
   
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeNewsTVCellID", for:indexPath) as! HomeNewsTVCell
      
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

