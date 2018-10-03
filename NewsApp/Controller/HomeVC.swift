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
            isSearch = true
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let searchvc:SearchVC = storyboard.instantiateViewController(withIdentifier: "SearchID") as! SearchVC
            self.present(searchvc, animated: true, completion: nil)
          }
        floaty.addItem("Settings", icon: UIImage(named: "settings")!) { item in
            floaty.autoCloseOnTap = true
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let settingvc:SettingsVC = storyboard.instantiateViewController(withIdentifier: "SettingsID") as! SettingsVC
            self.present(settingvc, animated: true, completion: nil)
            
        }
        floaty.addItem("Bookmark", icon: UIImage(named: "bookmark")!) { item in
            floaty.autoCloseOnTap = true
            isSearch = false
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let settingvc:SearchVC = storyboard.instantiateViewController(withIdentifier: "SearchID") as! SearchVC
            self.present(settingvc, animated: true, completion: nil)
            
        }
        self.view.addSubview(floaty)
        // Do any additional setup after loading the view, typically from a nib.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
            changeFont()
            HomeNewsTV.reloadData() //for tableview
        
    }
    //change font on text size change
    func changeFont()
    {
        print(textSizeSelected)
        
        if textSizeSelected == 0{
        lblHeading.font = .systemFont(ofSize: Constants.fontSmallTitle)
        }
        else if textSizeSelected == 2{
            lblHeading.font = .systemFont(ofSize: Constants.fontLargeTitle)
        }
        else{
            lblHeading.font = .systemFont(ofSize: Constants.fontNormalTitle)
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
        if textSizeSelected == 0{
            cell.lblSource.font = .systemFont(ofSize: Constants.fontSmallTitle)
             cell.lblNewsHeading.font = .systemFont(ofSize: Constants.fontSmallContent)
             cell.lblCategory.font = .systemFont(ofSize: Constants.fontSmallContent)
             cell.lblTimesAgo.font = .systemFont(ofSize: Constants.fontSmallContent)
            }
        else if textSizeSelected == 2{
            cell.lblSource.font = .systemFont(ofSize: Constants.fontLargeTitle)
            cell.lblNewsHeading.font = .systemFont(ofSize: Constants.fontLargeContent)
            cell.lblCategory.font = .systemFont(ofSize: Constants.fontLargeContent)
            cell.lblTimesAgo.font = .systemFont(ofSize: Constants.fontLargeContent)
        }
        else{
            cell.lblSource.font = .systemFont(ofSize: Constants.fontNormalTitle)
            cell.lblNewsHeading.font = .systemFont(ofSize: Constants.fontNormalContent)
            cell.lblCategory.font = .systemFont(ofSize: Constants.fontNormalContent)
            cell.lblTimesAgo.font = .systemFont(ofSize: Constants.fontNormalContent)
        }
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

