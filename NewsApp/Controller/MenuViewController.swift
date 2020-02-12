//
//  MenuViewController.swift
//  NewsApp
//
//  Created by Prasen on 06/02/20.
//  Copyright © 2020 Fafadia Tech. All rights reserved.
//

import Foundation
import UIKit


class MenuViewController: UIViewController{
    @IBOutlet weak var menuTVC: UITableView!
    weak var menuItemSelected : SelectCategory?
    
    var menuItems = ["Trending", "Latest News", "Daily Digest", "Sector Updates", "Regional Updates", "Finance", "Economics", "Misc"]
    var headingImg = [AssetConstants.trending, AssetConstants.latest, AssetConstants.daily, AssetConstants.sector, AssetConstants.regional, AssetConstants.finance, AssetConstants.economy, AssetConstants.misc]
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}


extension MenuViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuItemCell", for: indexPath) as! MenuItemTVCell
        cell.MenuLabel.text = menuItems[indexPath.row]
        cell.MenuImage.image = UIImage(named: headingImg[indexPath.row])
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        sideMenuController?.hideMenu()
        menuItemSelected?.selectMenuCategory(index: indexPath)
    }
}
