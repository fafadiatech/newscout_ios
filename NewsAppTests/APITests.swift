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
    
    func testValidURL_articlesSearchByCategory_API(){
        let incorrect_url = "https://api.myjson.com/bins/l23"
        let correct_url = "https://api.myjson.com/bins/16i4x0"
        let promise = expectation(description: "1")
        APICall().loadNewsbyCategoryAPI(url: correct_url){
            (status, response) in
            print(response)
            XCTAssertNotNil(response)
            switch response {
            case .Success(let data) :
                self.TestArticleData = data
                if status == "1"{
                    promise.fulfill()
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
    }
    
    func test_CategoriesURL(){
        let promise = expectation(description: "200")
        APICall().loadCategoriesAPI{
            (status, response) in
            print(response)
            XCTAssertNotNil(response)
            switch response {
            case .Success(let data) :
                self.CategoryData = data
                if status == 200 {
                    promise.fulfill()
                }
            case .Failure(let errormessage) :
                print(errormessage)
                XCTFail("errormessage: \(errormessage)")
            }
        }
        waitForExpectations(timeout: 2, handler: nil)
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
        APICall().loadRecommendationNewsAPI(articleId: 43){response in
            print(response)
            XCTAssertNotNil(response)
            switch response {
            case .Success(let data) :
                recommendationData = data
                if recommendationData[0].header.status == "1"{
                    promise.fulfill()
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
    }
    
    //Search API
    func test_Search_API(){
        let promise = expectation(description: "1")
        var searchResultData = [ArticleStatus]()
        APICall().loadSearchAPI(searchTxt: "oil"){response in
            print(response)
            XCTAssertNotNil(response)
            switch response {
            case .Success(let data) :
                searchResultData = data
                if searchResultData[0].header.status == "1"{
                    promise.fulfill()
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
    }
    
    //Signup API
    func test_SignupAPI(){
        let promise = expectation(description: "sign up successfully")
        let param = ["first_name": "",
                     "last_name": "",
                     "email" : "" ,
                     "password" : ""]
        APICall().SignupAPI(param: param ){response in
            print(response)
            XCTAssertNotNil(response)
            if response == "sign up successfully"{
                promise.fulfill()
            }else{
                XCTFail(response)
            }
        }
        waitForExpectations(timeout: 9, handler: nil)
    }
    
    //Login API
    func test_LoginAPI(){
        let promise = expectation(description: "1")
        let param = ["email" : "v@gmail.com",
                     "password" : "v1234"]
        APICall().LoginAPI(param: param ){response in
            print(response)
            XCTAssertNotNil(response)
            if response  == "1"{
                promise.fulfill()
            }
            else{
                XCTFail("errormessage code: \(response)")
            }
        }
        waitForExpectations(timeout: 9, handler: nil)
    }
    
    //Logout API
    func testLogoutAPI(){
        let promise = expectation(description: "1")
        
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
    
    //Bookmark API
    func test_BookmarkAPI(){
        let promise = expectation(description: "no Article")
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
    
    //Like article API
    func test_LikeArticleAPI(){
        let promise = expectation(description: "no Article")
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
    
    //dislike article API
    func test_DisLikeArticleAPI(){
        let promise = expectation(description: "no Article")
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
    
    //forgot pswd API
    func test_forgotPswdAPI(){
        let promise = expectation(description: "New password sent to your email")
        APICall().ForgotPasswordAPI(email: "jayashri@fafadiatech.com"){response in
            if response == "New password sent to your email"{
                print(response)
                promise.fulfill()
            }
            else{
                XCTFail("errormessage code: \(response)")
            }
        }
        waitForExpectations(timeout: 15, handler: nil)
    }
    
    //change pswd API
    func test_changePasswordAPI(){
        let promise = expectation(description: "Password chnaged successfully")
        let param = ["old_password" : "jay123",
                     "password" : "jay1234",
                     "confirm_password" : "jay1234"]
        APICall().ChangePasswordAPI(param: param){response in
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
    
    override func tearDown() {
        sessionUnderTest = nil
        super.tearDown()
    }
    
    
}
