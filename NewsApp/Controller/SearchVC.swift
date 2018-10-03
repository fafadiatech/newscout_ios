//
//  SearchVC.swift
//  NewsApp
//
//  Created by Jayashri on 25/09/18.
//  Copyright © 2018 Fafadia Tech. All rights reserved.
//

import UIKit

class SearchVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var searchResultTV: UITableView!
    @IBOutlet weak var btnSearch: UIButton!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var lblTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //check whether search or bookmark is selected
        if isSearch == true{
           lblTitle.isHidden = true
            txtSearch.isHidden = false
        }
        else{
            txtSearch.isHidden = true
            lblTitle.isHidden = false
        }
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        changeFont()
        searchResultTV.reloadData() //for tableview
        
    }
    //HIde status bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
    func changeFont()
    {
        print(textSizeSelected)
        
        if textSizeSelected == 0{
            lblTitle.font = .systemFont(ofSize: Constants.fontSmallTitle)
            txtSearch.font = .systemFont(ofSize: Constants.fontSmallTitle)
        }
        else if textSizeSelected == 2{
            lblTitle.font = .systemFont(ofSize: Constants.fontLargeTitle)
             txtSearch.font = .systemFont(ofSize: Constants.fontLargeTitle)
        }
        else{
            lblTitle.font = .systemFont(ofSize: Constants.fontNormalTitle)
            txtSearch.font = .systemFont(ofSize: Constants.fontNormalTitle)
        }
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchResultID", for:indexPath) as! SearchResultTVCell
        if textSizeSelected == 0{
            cell.lblSource.font = .systemFont(ofSize: Constants.fontSmallTitle)
            cell.lblNewsDescription.font = .systemFont(ofSize: Constants.fontSmallContent)
            cell.lblCategory.font = .systemFont(ofSize: Constants.fontSmallContent)
            cell.lbltimeAgo.font = .systemFont(ofSize: Constants.fontSmallContent)
        }
        else if textSizeSelected == 2{
            cell.lblSource.font = .systemFont(ofSize: Constants.fontLargeTitle)
            cell.lblNewsDescription.font = .systemFont(ofSize: Constants.fontLargeContent)
            cell.lblCategory.font = .systemFont(ofSize: Constants.fontLargeContent)
            cell.lbltimeAgo.font = .systemFont(ofSize: Constants.fontLargeContent)
        }
        else{
            cell.lblSource.font = .systemFont(ofSize: Constants.fontNormalTitle)
            cell.lblNewsDescription.font = .systemFont(ofSize: Constants.fontNormalContent)
            cell.lblCategory.font = .systemFont(ofSize: Constants.fontNormalContent)
            cell.lbltimeAgo.font = .systemFont(ofSize: Constants.fontNormalContent)
        }
        return cell
    }
    @IBAction func btnSearchAction(_ sender: Any) {
       self.dismiss(animated: false)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
