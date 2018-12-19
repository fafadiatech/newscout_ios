//
//  APITests.swift
//  NewsAppTests
//
//  Created by Jayashree on 28/11/18.
//  Copyright © 2018 Fafadia Tech. All rights reserved.
//

import Foundation
import XCTest
import Alamofire
import SwiftyJSON
import UIKit
@testable import NewsApp

class APITests: XCTestCase{
    var sessionUnderTest: URLSession!
    var TestArticleData = [ArticleStatus]()
    var CategoryData = [CategoryList]()
    let url = URL(string: "https://itune.apple.com/search?media=music&entity=song&term=abba")
    
    override func setUp() {
        super.setUp()
        sessionUnderTest = URLSession(configuration: URLSessionConfiguration.default)
    }
    
    //articlesSearchByCategory for valid url
    
    func test_articlesSearchByCategory_API(){
        let incorrect_url = "https://api.myjson.com/bins/l23"
        let correct_url = "https://api.myjson.com/bins/16i4x0"
        let promise = expectation(description: "1")
        XCTAssertEqual(self.TestArticleData.count, 0, "article data should be empty before API() runs")
        APICall().loadNewsbyCategoryAPI(url: correct_url){
            (status, response) in
            print(response)
            XCTAssertNotNil(response)
            switch response {
            case .Success(let data) :
                self.TestArticleData = data
                if status == "200"{
                    if self.TestArticleData[0].header.status == "1"{
                        for article in self.TestArticleData[0].body.articles{
                            
                            if article.title != nil && article.source != nil && article.article_id != nil && article.blurb != nil && article.category != nil && article.imageURL != nil && article.published_on != nil{
                                print("all values are present")
                            }
                        }
                        promise.fulfill()
                    }
                }
                
            case .Failure(let errormessage) :
                print(errormessage)
                XCTFail("errormessage code: \(errormessage)")
                
            case .Change(_):
                print("changed")
                XCTFail("status code: 404)")
            }
        }
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertGreaterThan(self.TestArticleData[0].body.articles.count, 0)
    }
    
    func test_CategoriesURL(){
        let promise = expectation(description: "200")
        XCTAssertEqual(self.CategoryData.count, 0, "category data should be empty before API() runs")
        APICall().loadCategoriesAPI{
            (status, response) in
            print(response)
            XCTAssertNotNil(response)
            switch response {
            case .Success(let data) :
                self.CategoryData = data
                if status == 200 {
                    for cat in self.CategoryData[0].categories{
                        if cat.cat_id != nil && cat.title != nil {
                            print("all values are present")
                        }
                    }
                    promise.fulfill()
                }
            case .Failure(let errormessage) :
                print(errormessage)
                XCTFail("errormessage: \(errormessage)")
            }
        }
        waitForExpectations(timeout: 2, handler: nil)
        XCTAssertGreaterThan(self.CategoryData[0].categories.count, 0)
    }
    
    //sample test
    // Asynchronous test: success fast, failure slow
    func testValidCallToiTunesGetsHTTPStatusCode200() {
        // given
        let url = URL(string: "https://itunes.apple.com/search?media=music&entity=song&term=abba")
        // 1
        let promise = expectation(description: "Status code: 200")
        
        // when
        let dataTask = sessionUnderTest.dataTask(with: url!) { data, response, error in
            // then
            if let error = error {
                XCTFail("Error: \(error.localizedDescription)")
                return
            } else if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if statusCode == 200 {
                    // 2
                    promise.fulfill()
                } else {
                    XCTFail("Status code: \(statusCode)")
                }
            }
        }
        dataTask.resume()
        // 3
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    //recommendation API
    func test_Recommendation_API(){
        let promise = expectation(description: "1")
        var recommendationData = [ArticleStatus]()
        XCTAssertEqual(recommendationData.count, 0, "recommendation articles data should be empty before API() runs")
        
        APICall().loadRecommendationNewsAPI(articleId: 43){(status, response) in
            print(response)
            XCTAssertNotNil(response)
            switch response {
            case .Success(let data) :
                recommendationData = data
                if status == "200"{
                    if recommendationData[0].header.status == "1"{
                        for article in recommendationData[0].body.articles{
                            if article.article_id != nil && article.blurb != nil && article.category != nil && article.imageURL != nil && article.published_on != nil && article.source != nil{
                                print("all values are present")
                            }
                        }
                        promise.fulfill()
                    }
                }
                
                
            case .Failure(let errormessage) :
                print(errormessage)
                XCTFail("errormessage code: \(errormessage)")
                
            case .Change(_):
                print("changed")
                XCTFail("status code: 404)")
            }
            
        }
        waitForExpectations(timeout: 9, handler: nil)
        XCTAssertGreaterThan(recommendationData[0].body.articles.count, 0)
    }
    
    //Search API
    func test_Search_API(){
        let promise = expectation(description: "1")
        var searchResultData = [ArticleStatus]()
        var searchKeyword = "oil"
        if searchKeyword != nil{
        APICall().loadSearchAPI(searchTxt: searchKeyword){(status, response) in
            print(response)
            XCTAssertNotNil(response)
            switch response {
            case .Success(let data) :
                searchResultData = data
                if status == "200"{
                    if searchResultData[0].header.status == "1"{
                        for article in searchResultData[0].body.articles{
                            if article.article_id != nil && article.blurb != nil && article.category != nil && article.imageURL != nil && article.published_on != nil && article.source != nil{
                                print("all values are present")
                            }
                        }
                        promise.fulfill()
                    }
                }
            case .Failure(let errormessage) :
                print(errormessage)
                XCTFail("errormessage code: \(errormessage)")
                
            case .Change(_):
                print("changed")
                XCTFail("status code: 404)")
            }
        }
        waitForExpectations(timeout: 9, handler: nil)
        XCTAssertGreaterThan(searchResultData[0].body.articles.count, 0)
        }
        else{
            XCTFail("No search keyword entered")
        }
    }
    
    //Signup API
    func test_SignupAPI(){
        let promise = expectation(description: "sign up successfully")
        let param = ["first_name": "yz",
                     "last_name": "xqww",
                     "email" : "yubsb@gmail.com" ,
                     "password" : "xxxx"]
        if param["first_name"] != nil && param["last_name"] != nil && param["email"] != nil && param["password"] != nil{
        APICall().SignupAPI(param: param ){(status,response) in
            print(response)
            XCTAssertNotNil(response)
            if status == "200"{
                if response == "sign up successfully"{
                    promise.fulfill()
                }
            }
            else{
                XCTFail(response)
            }
        }
        waitForExpectations(timeout: 9, handler: nil)
        }
        else{
            XCTFail("missing mandatory details")
        }
    }
    
    //Login API
    func test_LoginAPI(){
        let promise = expectation(description: "1")
        let param = ["email" : "jayashri@fafadiatech.com",
                     "password" : "jay1234"]
        if param["email"] != nil && param["password"] != nil {
        APICall().LoginAPI(param: param ){(status, response) in
            print(response)
            XCTAssertNotNil(response)
            if status == 200{
                if response  == "1"{
                    promise.fulfill()
                }
            }
            else{
                XCTFail("errormessage code: \(response)")
            }
        }
        waitForExpectations(timeout: 9, handler: nil)
        }
        else{
            XCTFail("missing login details")
        }
    }
    
    //Logout API
    func testLogoutAPI(){
        let promise = expectation(description: "1")
        if UserDefaults.standard.value(forKey: "token") != nil || UserDefaults.standard.value(forKey: "FBToken") != nil || UserDefaults.standard.value(forKey: "googleToken") != nil{
            APICall().LogoutAPI{(status, response) in
                print(status,response)
                XCTAssertNotNil(response)
                if status  == "1"{
                    promise.fulfill()
                }
                else{
                    XCTFail("errormessage code: \(response)")
                }
            }
            waitForExpectations(timeout: 9, handler: nil)
        }
        else{
            XCTFail("Login required")
        }
    }
    
    //Bookmark API
    func test_BookmarkAPI(){
        let promise = expectation(description: "Article bookmarked status has been changed")
        if UserDefaults.standard.value(forKey: "token") != nil || UserDefaults.standard.value(forKey: "FBToken") != nil || UserDefaults.standard.value(forKey: "googleToken") != nil{
            APICall().bookmarkAPI(id: 43){
                (status, response) in
                XCTAssertNotNil(status, response)
                if status == "1"{
                    print(response)
                    promise.fulfill()
                }
                else{
                    print(response)
                    XCTFail("errormessage code: \(response)")
                }
            }
            waitForExpectations(timeout: 9, handler: nil)
        }
        else{
            XCTFail("Login required")
        }
    }
    
    //Like article API
    func test_LikeArticleAPI(){
        let promise = expectation(description: "Article Like status has been changed")
        if UserDefaults.standard.value(forKey: "token") != nil || UserDefaults.standard.value(forKey: "FBToken") != nil || UserDefaults.standard.value(forKey: "googleToken") != nil{
            let param = ["article_id" : 42,
                         "isLike" : 0]
            APICall().LikeDislikeAPI(param: param){
                (status, response) in
                XCTAssertNotNil(status, response)
                if status == "1"{
                    print(response)
                    promise.fulfill()
                }
                else{
                    print(response)
                    XCTFail("errormessage code: \(response)")
                }
            }
            waitForExpectations(timeout: 15, handler: nil)
        }
        else{
            XCTFail("Login required")
        }
    }
    
    //dislike article API
    func test_DisLikeArticleAPI(){
        let promise = expectation(description: "Article DisLike status has been changed")
        
        if UserDefaults.standard.value(forKey: "token") != nil || UserDefaults.standard.value(forKey: "FBToken") != nil || UserDefaults.standard.value(forKey: "googleToken") != nil{
            let param = ["article_id" : 42,
                         "isLike" : 1]
            APICall().LikeDislikeAPI(param: param){
                (status, response) in
                XCTAssertNotNil(status, response)
                if status == "1"{
                    print(response)
                    promise.fulfill()
                }
                else{
                    print(response)
                    XCTFail("errormessage code: \(response)")
                }
            }
            waitForExpectations(timeout: 15, handler: nil)
        }
        else{
            XCTFail("Login required")
        }
    }
    
    //forgot pswd API
    func test_forgotPswdAPI(){
        let promise = expectation(description: "New password sent to your email")
        
        if UserDefaults.standard.value(forKey: "token") != nil || UserDefaults.standard.value(forKey: "FBToken") != nil || UserDefaults.standard.value(forKey: "googleToken") != nil{
            APICall().ForgotPasswordAPI(email: "jayashri@fafadiatech.com"){(status, response) in
                if status == "1"{
                    print(response)
                    promise.fulfill()
                }
                else{
                    XCTFail("errormessage code: \(response)")
                }
            }
            waitForExpectations(timeout: 15, handler: nil)
        }
        else{
            XCTFail("Login required")
        }
    }
    
    //change pswd API
    func test_changePasswordAPI(){
        let promise = expectation(description: "Password chnaged successfully")
        if UserDefaults.standard.value(forKey: "token") != nil || UserDefaults.standard.value(forKey: "FBToken") != nil || UserDefaults.standard.value(forKey: "googleToken") != nil{
            let param = ["old_password" : "EEA2DDE4E8",
                         "password" : "jay1234",
                         "confirm_password" : "jay1234"]
            if param["old_password"] != nil && param["password"] != nil && param["confirm_password"] != nil{
            APICall().ChangePasswordAPI(param: param){(status, response) in
                print("change pswd response:\(response)")
                if response == "Password chnaged successfully"{
                    promise.fulfill()
                }
                else{
                    XCTFail("errormessage code: \(response)")
                }
            }
            waitForExpectations(timeout: 15, handler: nil)
            }
            else{
                XCTFail("Mandatory details are missing")
            }
        }
        else{
            XCTFail("Login required")
        }
    }
    
    override func tearDown() {
        sessionUnderTest = nil
        super.tearDown()
    }
    
    
}
