//
//  CategoryListVC.swift
//  NewsApp
//
//  Created by Jayashree on 05/10/18.
//  Copyright © 2018 Fafadia Tech. All rights reserved.
//

import UIKit

class CategoryListVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    //outlet
    @IBOutlet weak var tableCategoryLIst: UITableView!
    
    var catArr = ["NEWS", "TECHNOLOGY", "SPORTS", "POLITICS", "BUSINESS", "CELEBRITY", "NEWS", "INDIAN PARLIAMENT", "INDIAN RELIGION"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    //HIde status bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
    @IBAction func btnBackAction(_ sender: Any) {
        self.dismiss(animated:false)
    }
    //Tableview methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return catArr.count
    }
 
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = tableCategoryLIst.dequeueReusableCell(withIdentifier: "CategoryListID", for:indexPath) as! CategoryListTVCell
        cell.lblCategoryName.text = catArr[indexPath.row]
        return cell
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
