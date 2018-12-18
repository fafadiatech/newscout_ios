//
//  FunctionalityTests.swift
//  NewsAppTests
//
//  Created by Jayashree on 18/12/18.
//  Copyright © 2018 Fafadia Tech. All rights reserved.
//

import Foundation
import XCTest
@testable import NewsApp

class FunctionalityTests: XCTestCase{
    var HomeParentObj : HomeParentVC!
    var LoginObj : LoginVC!
    var categories : [String] = []
    
    override func setUp() {
        super.setUp()
        HomeParentObj = HomeParentVC()
    }
    
    //add category in category tab strip
    func test_addCategory(){
        let addCategory = "Trending"
        let restrictAdd = ["Trending", "For You"]
        if UserDefaults.standard.value(forKey: "categories") == nil{
            
            if UserDefaults.standard.value(forKey: "token") == nil || UserDefaults.standard.value(forKey: "FBToken") == nil || UserDefaults.standard.value(forKey: "googleToken") == nil{
                categories = ["Trending"]
                UserDefaults.standard.setValue(categories, forKey: "categories")
            }
            else{
                categories = ["For You"]
                UserDefaults.standard.setValue(categories, forKey: "categories")
            }
        }
        HomeParentObj.categories = UserDefaults.standard.array(forKey: "categories") as! [String]
        if !restrictAdd.contains(addCategory){
        if !HomeParentObj.categories.contains(addCategory){
            HomeParentObj.updateCategoryList(catName: addCategory)
            if HomeParentObj.categories.contains(addCategory){
                XCTAssert(true, "added new category")
            }
            else{
                XCTAssert(false, "unable to add new category")
            }
        }
        else{
            XCTAssert(false, "already added")
        }
        }
        else{
             XCTAssert(false, "cant add \(addCategory) category")
        }
    }
    
    //delete category from category tab strip
    func test_deleteCategory(){
        HomeParentObj.categories = UserDefaults.standard.array(forKey: "categories") as! [String]
        let restrictDelete = ["Trending", "For You"]
        let deleteCat = "Trending"
        if !restrictDelete.contains(deleteCat){
        if HomeParentObj.categories.contains(deleteCat){
            HomeParentObj.deleteCategory(currentCategory: deleteCat)
            if !HomeParentObj.categories.contains(deleteCat){
                XCTAssert(true, "deleted given category")
            }
            else{
                XCTAssert(false, "unable to delete new category")
            }
        }
        else{
            XCTAssert(false, "category not added")
        }
        }
        else{
             XCTAssert(false, "cant delete \(deleteCat) category")
        }
    }
    
   
    override func tearDown() {
        HomeParentObj = nil
        LoginObj = nil
        super.tearDown()
    }
}
