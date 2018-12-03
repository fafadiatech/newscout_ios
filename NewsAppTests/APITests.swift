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
import UIKit
@testable import NewsApp

class APITests: XCTestCase{
    var ArticleData = [ArticleStatus]()
    
    func test_articles_API(){

        APICall().loadNewsbyCategoryAPI(url: "http://192.168.2.204/api/v1/articles/?categories=All News"){response in
            XCTAssertNil(response)
            switch response {
            case .Success(let data) :
                self.ArticleData = data
                print(self.ArticleData[0].body.articles)
              
            case .Failure(let errormessage) :
                print(errormessage)
            }
            do{
                
            }
        }
    }
}
