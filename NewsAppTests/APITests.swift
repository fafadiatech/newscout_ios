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
        APICall().loadNewsbyCategoryAPI(url: correct_url){response in
            print(response)
            XCTAssertNotNil(response)
            switch response {
            case .Success(let data) :
                self.TestArticleData = data
                if self.TestArticleData[0].header.status == "1"{
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
         waitForExpectations(timeout: 2, handler: nil)
    }
    
    
    func test_CategoriesURL(){
        let promise = expectation(description: "")
        APICall().loadCategoriesAPI(){response in
            print(response)
            XCTAssertNotNil(response)
            switch response {
            case .Success(let data) :
                self.CategoryData = data
                if self.CategoryData[0].categories.count != 0 {
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
    
    override func tearDown() {
        sessionUnderTest = nil
        super.tearDown()
    }
    

}
